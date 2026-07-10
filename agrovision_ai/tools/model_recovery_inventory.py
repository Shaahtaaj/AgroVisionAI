#!/usr/bin/env python3
"""Inventory possible AgroVision model-training artifacts safely."""

from __future__ import annotations

import argparse
import csv
import os
from datetime import datetime, timezone
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_PATH = (
    PROJECT_ROOT
    / "docs"
    / "model_recovery"
    / "training_artifacts_inventory.csv"
)

EXTENSIONS = {
    ".ipynb",
    ".py",
    ".h5",
    ".keras",
    ".pb",
    ".tflite",
    ".onnx",
    ".txt",
    ".csv",
    ".json",
    ".yaml",
    ".yml",
    ".md",
}

TRAINING_TERMS = (
    "ImageDataGenerator",
    "image_dataset_from_directory",
    "flow_from_directory",
    "class_indices",
    "class_names",
    "labels.txt",
    "preprocess_input",
    "Rescaling",
    "resize",
    "crop",
    "augmentation",
    "RandomFlip",
    "RandomRotation",
    "RandomZoom",
    "MobileNet",
    "MobileNetV2",
    "MobileNetV3",
    "EfficientNet",
    "EfficientNetLite",
    "TFLiteConverter",
    "representative_dataset",
    "converter.optimizations",
    "categorical_crossentropy",
    "sparse_categorical_crossentropy",
    "Adam",
    "learning_rate",
    "batch_size",
    "epochs",
    "model.fit",
)

SKIP_NAMES = {
    ".git",
    ".gradle",
    "build",
    ".dart_tool",
    "Pods",
    "node_modules",
}
SKIP_PATH_SUFFIXES = {
    Path("android") / ".gradle",
    Path("ios") / "Pods",
}
ALWAYS_RELEVANT = {".ipynb", ".py", ".h5", ".keras", ".pb", ".tflite", ".onnx"}
MAX_TEXT_SCAN_BYTES = 8 * 1024 * 1024


def _git_root(start: Path) -> Path:
    for candidate in (start, *start.parents):
        if (candidate.joinpath(".git").exists()):
            return candidate
    return PROJECT_ROOT


def _is_drive_root(path: Path) -> bool:
    return path.parent == path


def _should_skip(path: Path, scan_root: Path) -> bool:
    try:
        relative = path.relative_to(scan_root)
    except ValueError:
        return True
    if any(part in SKIP_NAMES for part in relative.parts):
        return True
    return any(
        tuple(relative.parts[: len(suffix.parts)]) == suffix.parts
        for suffix in SKIP_PATH_SUFFIXES
    )


def _matched_terms(path: Path, size_bytes: int) -> tuple[list[str], str]:
    filename_matches = [
        term for term in TRAINING_TERMS if term.casefold() in path.name.casefold()
    ]
    if path.suffix.lower() in {".h5", ".keras", ".pb", ".tflite", ".onnx"}:
        return filename_matches, "Binary model artifact; content search skipped"
    if size_bytes > MAX_TEXT_SCAN_BYTES:
        return filename_matches, "Text content search skipped because file exceeds 8 MiB"
    try:
        content = path.read_text(encoding="utf-8", errors="ignore")
    except OSError as error:
        return filename_matches, f"Could not read content: {error}"
    folded = content.casefold()
    matches = list(filename_matches)
    for term in TRAINING_TERMS:
        if term.casefold() in folded and term not in matches:
            matches.append(term)
    return matches, "Text content inspected"


def _scan_root(scan_root: Path, repository_root: Path) -> list[dict[str, str | int]]:
    rows: list[dict[str, str | int]] = []
    recovery_directory = PROJECT_ROOT / "docs" / "model_recovery"
    recovery_tools = {
        Path(__file__).resolve(),
        (PROJECT_ROOT / "tools" / "inspect_tflite.py").resolve(),
    }
    for current_root, directory_names, file_names in os.walk(scan_root):
        current = Path(current_root)
        directory_names[:] = [
            name
            for name in directory_names
            if not _should_skip(current / name, scan_root)
        ]
        for file_name in file_names:
            path = current / file_name
            resolved_path = path.resolve()
            if resolved_path in recovery_tools or recovery_directory in path.parents:
                continue
            if path.suffix.lower() not in EXTENSIONS:
                continue
            try:
                stat = path.stat()
            except OSError:
                continue
            matches, note = _matched_terms(path, stat.st_size)
            if not matches and path.suffix.lower() not in ALWAYS_RELEVANT:
                continue
            try:
                display_path = path.relative_to(repository_root).as_posix()
            except ValueError:
                display_path = str(path.resolve())
            rows.append(
                {
                    "path": display_path,
                    "file_name": path.name,
                    "extension": path.suffix.lower(),
                    "size_bytes": stat.st_size,
                    "last_modified": datetime.fromtimestamp(
                        stat.st_mtime, tz=timezone.utc
                    ).isoformat(),
                    "matched_terms": ";".join(matches),
                    "notes": note,
                }
            )
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scan for possible model-training artifacts."
    )
    parser.add_argument(
        "--no-parent",
        action="store_true",
        help="Do not scan the repository parent even when it is safe.",
    )
    args = parser.parse_args()

    repository_root = _git_root(PROJECT_ROOT)
    roots = [repository_root]
    parent_note = "Parent scan disabled"
    parent = repository_root.parent
    if not args.no_parent:
        if _is_drive_root(parent):
            parent_note = f"Parent scan skipped as unsafe filesystem root: {parent}"
        else:
            roots.append(parent)
            parent_note = f"Included parent scan: {parent}"

    rows: list[dict[str, str | int]] = []
    seen_paths: set[str] = set()
    for root in roots:
        for row in _scan_root(root, repository_root):
            identity = str(row["path"]).casefold()
            if identity in seen_paths:
                continue
            seen_paths.add(identity)
            rows.append(row)

    rows.sort(key=lambda row: str(row["path"]).casefold())
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_PATH.open("w", encoding="utf-8", newline="") as destination:
        writer = csv.DictWriter(
            destination,
            fieldnames=(
                "path",
                "file_name",
                "extension",
                "size_bytes",
                "last_modified",
                "matched_terms",
                "notes",
            ),
        )
        writer.writeheader()
        writer.writerows(rows)

    print("AgroVision AI Training Artifact Inventory")
    print(f"Repository root: {repository_root}")
    print(parent_note)
    print(f"Candidate files recorded: {len(rows)}")
    print(f"Output: {OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
