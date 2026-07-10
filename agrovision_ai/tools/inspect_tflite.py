#!/usr/bin/env python3
"""Inspect the deployed AgroVision TensorFlow Lite model without Flutter."""

from __future__ import annotations

import hashlib
import json
import math
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


PROJECT_ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = PROJECT_ROOT / "assets" / "model" / "mango_model.tflite"
LABEL_PATH = PROJECT_ROOT / "assets" / "model" / "labels.txt"
REPORT_PATH = (
    PROJECT_ROOT
    / "docs"
    / "model_recovery"
    / "tflite_model_report.json"
)


def _json_value(value: Any) -> Any:
    """Convert NumPy-backed TensorFlow values into JSON-safe values."""
    if hasattr(value, "tolist"):
        return value.tolist()
    if hasattr(value, "item"):
        return value.item()
    if isinstance(value, tuple):
        return [_json_value(item) for item in value]
    if isinstance(value, dict):
        return {key: _json_value(item) for key, item in value.items()}
    return value


def _tensor_report(details: dict[str, Any]) -> dict[str, Any]:
    dtype = details.get("dtype")
    return {
        "name": details.get("name"),
        "index": details.get("index"),
        "shape": _json_value(details.get("shape")),
        "shape_signature": _json_value(details.get("shape_signature")),
        "dtype": getattr(
            dtype, "name", getattr(dtype, "__name__", str(dtype))
        ),
        "quantization": _json_value(details.get("quantization")),
        "quantization_parameters": _json_value(
            details.get("quantization_parameters", {})
        ),
        "sparsity_parameters": _json_value(
            details.get("sparsity_parameters", {})
        ),
    }


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def _score_count(shape: Any) -> int | None:
    values = _json_value(shape)
    if not isinstance(values, list) or not values:
        return None
    if any(not isinstance(value, int) or value <= 0 for value in values):
        return None
    return math.prod(values)


def main() -> int:
    if not MODEL_PATH.is_file():
        print(f"ERROR: Model file not found: {MODEL_PATH}", file=sys.stderr)
        return 1
    if not LABEL_PATH.is_file():
        print(f"ERROR: Label file not found: {LABEL_PATH}", file=sys.stderr)
        return 1

    try:
        import tensorflow as tf
    except (ImportError, ModuleNotFoundError) as error:
        print(
            "ERROR: TensorFlow is not installed. Install a compatible "
            "TensorFlow package in a Python environment, then run "
            "`python tools/inspect_tflite.py` again. No model file was changed.",
            file=sys.stderr,
        )
        print(f"Import detail: {error}", file=sys.stderr)
        return 2

    try:
        interpreter = tf.lite.Interpreter(model_path=str(MODEL_PATH))
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
    except Exception as error:  # TensorFlow raises several backend exceptions.
        print(f"ERROR: TensorFlow Lite inspection failed: {error}", file=sys.stderr)
        return 3

    size_bytes = MODEL_PATH.stat().st_size
    labels = [
        line.strip()
        for line in LABEL_PATH.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    inputs = [_tensor_report(details) for details in input_details]
    outputs = [_tensor_report(details) for details in output_details]
    primary_score_count = (
        _score_count(output_details[0].get("shape")) if output_details else None
    )
    label_count_matches_output = (
        primary_score_count == len(labels)
        if primary_score_count is not None and len(output_details) == 1
        else None
    )
    report = {
        "report_status": "Verified by TensorFlow Lite interpreter inspection",
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "tensorflow_version": tf.__version__,
        "model": {
            "path": MODEL_PATH.relative_to(PROJECT_ROOT).as_posix(),
            "size_bytes": size_bytes,
            "size_mib": round(size_bytes / (1024 * 1024), 6),
            "sha256": _sha256(MODEL_PATH),
        },
        "labels": {
            "path": LABEL_PATH.relative_to(PROJECT_ROOT).as_posix(),
            "count": len(labels),
            "order": labels,
        },
        "inputs": inputs,
        "outputs": outputs,
        "consistency": {
            "output_tensor_count": len(outputs),
            "primary_output_score_count": primary_score_count,
            "label_count": len(labels),
            "label_count_matches_primary_output": label_count_matches_output,
        },
    }

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print("AgroVision AI TensorFlow Lite Model Inspection")
    print(f"Model: {report['model']['path']}")
    print(
        f"Size: {report['model']['size_bytes']} bytes "
        f"({report['model']['size_mib']:.3f} MiB)"
    )
    print(f"SHA-256: {report['model']['sha256']}")
    print(f"TensorFlow: {report['tensorflow_version']}")
    print(f"Labels: {len(labels)}")
    for position, details in enumerate(report["inputs"]):
        print(
            f"Input {position}: name={details['name']} shape={details['shape']} "
            f"signature={details['shape_signature']} dtype={details['dtype']} "
            f"quantization={details['quantization']}"
        )
    for position, details in enumerate(report["outputs"]):
        print(
            f"Output {position}: name={details['name']} shape={details['shape']} "
            f"signature={details['shape_signature']} dtype={details['dtype']} "
            f"quantization={details['quantization']}"
        )
    print(
        "Label/output consistency: "
        f"scores={primary_score_count} labels={len(labels)} "
        f"match={label_count_matches_output}"
    )
    print(f"Report written to: {REPORT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
