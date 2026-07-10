# Flutter Parity Capture Plan

## Purpose

Capture Flutter-side preprocessing, predictions, scores, quality metrics, and
decision status for the exact same image files used by the Python inference
runner. This is diagnostic work and must not alter production behavior.

## Required Inputs

- Byte-identical files under `test_vectors/`
- Deployed `assets/model/mango_model.tflite`
- Deployed `assets/model/labels.txt`
- Python results from `tools/run_tflite_inference.py`
- `docs/model_recovery/parity_test_template.csv`

Flutter and Python must process the exact same image files. Do not recapture,
crop, screenshot, send through WhatsApp, or otherwise recompress one side's
copy.

## Option A: Temporary Debug-Only Logging

1. Work on a temporary diagnostic branch.
2. Add logging guarded by `kDebugMode` or assertions only.
3. Log a structured record containing:
   image filename, decoded dimensions, preprocessing mode, tensor shape,
   tensor min/max/mean, top predictions and scores, brightness, sharpness,
   quality issues, confidence gap, and final decision status.
4. Run the app against files selected from `test_vectors/`.
5. Copy structured results into the parity template.
6. Remove the logging before merging. Debug logs must not enter production and
   must not include unrelated user image paths or personal information.

This option is fast but easier to execute inconsistently and should be treated
as temporary instrumentation.

## Option B: Test-Only Harness

1. Create a Flutter test/helper outside production screens.
2. Make test-vector images available as test assets without changing release
   assets.
3. Load each image through the same decoder, quality checks, preprocessing,
   interpreter, score processing, and label order as the app classifier.
4. Print or export one JSON/CSV-compatible record per image.
5. Compare those records with Python results automatically.

The test-only harness is preferred because it is repeatable, reviewable, and
can become a regression test. It must not add a user-facing screen or change
production thresholds.

## Required Flutter Record

```text
image_path
decoded_width
decoded_height
input_shape
input_dtype
tensor_min
tensor_max
tensor_mean
top1_label
top1_score
top2_label
top2_score
top3_label
top3_score
brightness
sharpness
quality_issues
decision_status
```

## Comparison Rule

For the same preprocessing mode and exact image:

- Top-1 labels must match.
- Scores should differ only by a small measured tolerance.
- Acceptance/rejection decisions must match.
- Label indices must match the app label file.

If Python and Flutter disagree, investigate decoding, EXIF orientation,
crop/resize behavior, interpolation, channel order, normalization, dtype,
quantization, and output processing before retraining, quantization, confidence
tuning, or UI changes.

Parity testing proves implementation agreement only. It does not validate
disease accuracy, confidence calibration, field performance, or chemical
recommendations.
