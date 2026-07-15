#!/usr/bin/env python3
"""Run the deployed AgroVision TFLite model for parity investigation."""

from __future__ import annotations

import argparse
import csv
import math
import sys
from pathlib import Path
from typing import Any, cast

from preprocessing_modes import PREPROCESSING_MODES, preprocess_image

PROJECT_ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = PROJECT_ROOT / "assets" / "model" / "mango_model.tflite"
LABEL_PATH = PROJECT_ROOT / "assets" / "model" / "labels.txt"
DEFAULT_OUTPUT = (
    PROJECT_ROOT
    / "docs"
    / "model_recovery"
    / "python_inference_results.csv"
)
IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}
CSV_COLUMNS = (
    "image_path",
    "preprocessing_mode",
    "top1_label",
    "top1_score",
    "top2_label",
    "top2_score",
    "top3_label",
    "top3_score",
    "score_sum",
    "status",
    "error",
)


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Run one image or a recursive image folder through the deployed "
            "AgroVision TensorFlow Lite model."
        )
    )
    parser.add_argument(
        "--input",
        required=True,
        type=Path,
        help="Image file or folder to scan recursively.",
    )
    parser.add_argument(
        "--preprocessing",
        choices=PREPROCESSING_MODES,
        default="flutter_default",
        help=(
            "Preprocessing candidate. Only flutter_default represents the "
            "current app assumption; other modes are investigative."
        ),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"CSV output path (default: {DEFAULT_OUTPUT}).",
    )
    return parser.parse_args()


def _load_dependencies() -> tuple[Any, Any, Any]:
    try:
        import numpy as np
        import tensorflow as tf
        from PIL import Image
    except (ImportError, ModuleNotFoundError) as error:
        print(
            "ERROR: Python recovery dependencies are unavailable. Run "
            "`scripts/setup_model_recovery_env.ps1`, activate the resulting "
            "environment, and retry.",
            file=sys.stderr,
        )
        print(f"Import detail: {error}", file=sys.stderr)
        raise SystemExit(2) from error
    return np, tf, Image


def _images(input_path: Path) -> list[Path]:
    if input_path.is_file():
        return [input_path] if input_path.suffix.lower() in IMAGE_EXTENSIONS else []
    if input_path.is_dir():
        return sorted(
            path
            for path in input_path.rglob("*")
            if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
        )
    return []


def _preprocess(
    image_path: Path,
    mode: str,
    np: Any,
    Image: Any,
    tf: Any,
) -> Any:
    tensor, _ = preprocess_image(
        image_path,
        mode,
        np=np,
        Image=Image,
        tf=tf,
    )
    return tensor


def _coerce_input(values: Any, tensor_details: dict[str, Any], np: Any) -> Any:
    dtype = tensor_details["dtype"]
    if np.issubdtype(dtype, np.floating):
        return values.astype(dtype)

    quantization = tensor_details.get("quantization", (0.0, 0))
    scale, zero_point = quantization
    if not scale:
        raise ValueError(
            "Integer input tensor has no usable quantization scale; cannot "
            "convert candidate preprocessing values safely."
        )
    quantized = np.rint(values / scale + zero_point)
    limits = np.iinfo(dtype)
    return np.clip(quantized, limits.min, limits.max).astype(dtype)


def _dequantize_output(values: Any, tensor_details: dict[str, Any], np: Any) -> Any:
    flattened = np.asarray(values).reshape(-1)
    if np.issubdtype(flattened.dtype, np.integer):
        scale, zero_point = tensor_details.get("quantization", (0.0, 0))
        if scale:
            flattened = (flattened.astype(np.float64) - zero_point) * scale
    return flattened.astype(np.float64)


def _probabilities(scores: Any, np: Any) -> Any:
    total = float(np.sum(scores))
    if bool(np.all(scores >= 0.0)) and bool(np.all(scores <= 1.0)) and 0.95 < total < 1.05:
        return np.clip(scores, 0.0, 1.0)
    maximum = float(np.max(scores))
    exponentials = np.exp(scores - maximum)
    return exponentials / float(np.sum(exponentials))


def _error_row(image_path: Path, mode: str, error: Exception) -> dict[str, Any]:
    row = {column: "" for column in CSV_COLUMNS}
    row.update(
        {
            "image_path": str(image_path),
            "preprocessing_mode": mode,
            "status": "ERROR",
            "error": str(error),
        }
    )
    return row


def main() -> int:
    args = _parse_args()
    np, tf, Image = _load_dependencies()

    if not MODEL_PATH.is_file() or not LABEL_PATH.is_file():
        print("ERROR: Deployed model or label file is missing.", file=sys.stderr)
        return 1

    image_paths = _images(args.input.resolve())
    if not image_paths:
        print(f"ERROR: No supported images found at: {args.input}", file=sys.stderr)
        return 1

    labels = [
        line.strip()
        for line in LABEL_PATH.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    if len(input_details) != 1 or len(output_details) != 1:
        print(
            "ERROR: This parity runner requires exactly one input and one output tensor.",
            file=sys.stderr,
        )
        return 3

    input_tensor = input_details[0]
    output_tensor = output_details[0]
    rows: list[dict[str, Any]] = []

    for image_path in image_paths:
        try:
            values = _preprocess(
                image_path,
                args.preprocessing,
                np=np,
                Image=Image,
                tf=tf,
            )
            expected_shape = tuple(int(value) for value in input_tensor["shape"])
            if tuple(values.shape) != expected_shape:
                raise ValueError(
                    f"Preprocessed shape {tuple(values.shape)} does not match "
                    f"model input shape {expected_shape}."
                )
            interpreter.set_tensor(
                input_tensor["index"], _coerce_input(values, input_tensor, np)
            )
            interpreter.invoke()
            raw_output = interpreter.get_tensor(output_tensor["index"])
            scores = _dequantize_output(raw_output, output_tensor, np)
            probabilities = _probabilities(scores, np)
            if len(probabilities) != len(labels):
                raise ValueError(
                    f"Output score count {len(probabilities)} does not match "
                    f"label count {len(labels)}."
                )
            ranked = sorted(
                range(len(probabilities)),
                key=lambda index: float(probabilities[index]),
                reverse=True,
            )[: min(3, len(labels))]
            padded = ranked + [ranked[-1]] * (3 - len(ranked))
            rows.append(
                {
                    "image_path": str(image_path),
                    "preprocessing_mode": args.preprocessing,
                    "top1_label": labels[padded[0]],
                    "top1_score": f"{float(probabilities[padded[0]]):.9f}",
                    "top2_label": labels[padded[1]],
                    "top2_score": f"{float(probabilities[padded[1]]):.9f}",
                    "top3_label": labels[padded[2]],
                    "top3_score": f"{float(probabilities[padded[2]]):.9f}",
                    "score_sum": f"{math.fsum(float(v) for v in probabilities):.9f}",
                    "status": "OK",
                    "error": "",
                }
            )
        except Exception as error:
            rows.append(_error_row(image_path, args.preprocessing, error))

    output_path = args.output.resolve()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8", newline="") as destination:
        writer = csv.DictWriter(destination, fieldnames=CSV_COLUMNS)
        writer.writeheader()
        # rows is a list[dict[str, Any]] which mypy may not consider a
        # valid Iterable[Mapping[Literal[...], Any]]. Cast to Any to
        # satisfy the type checker while preserving runtime behavior.
        writer.writerows(cast(Any, rows))

    successful = sum(row["status"] == "OK" for row in rows)
    print(f"Images found: {len(image_paths)}")
    print(f"Successful: {successful}")
    print(f"Failed: {len(rows) - successful}")
    print(f"Preprocessing mode: {args.preprocessing}")
    print(f"Output: {output_path}")
    return 0 if successful == len(rows) else 4


if __name__ == "__main__":
    raise SystemExit(main())
