# Python-Flutter Prediction Parity Test Plan

## Purpose

Verify that Python and Flutter produce the same class ranking and nearly the
same scores for the exact same images. This isolates deployment errors caused
by decoding, orientation, cropping, resizing, channel order, normalization,
tensor dtype, quantization, or output processing.

Parity testing validates implementation equivalence. It does not measure
disease accuracy or prove that the training pipeline was correct.

## Prerequisites

- A usable Python environment with TensorFlow Lite support
- The exact deployed `mango_model.tflite` and `labels.txt`
- A Python inference script that exposes preprocessed tensors and raw outputs
- A Flutter integration test or diagnostic runner that exports the same values
- Training preprocessing evidence, when recovered

Supporting Week 2 files:

- Python runner: `tools/run_tflite_inference.py`
- Comparison template: `docs/model_recovery/parity_test_template.csv`
- Flutter capture guidance:
  `docs/model_recovery/flutter_parity_capture_plan.md`

## Test Vector Structure

```text
test_vectors/
  valid/
    anthracnose/
    bacterial_canker/
    cutting_weevil/
    die_back/
    gall_midge/
    healthy/
    powdery_mildew/
    sooty_mould/
  invalid/
    non_leaf/
    non_mango/
    screen_photo/
    hand_wall_table/
  boundary/
    dark/
    bright_glare/
    blurry/
    low_resolution/
    small_leaf_area/
  manifest.csv
```

The first parity set must contain at least two images per supported class plus
invalid images. The final parity and field set should contain at least 30-50
unseen images per class, with several phones, backgrounds, and lighting
conditions.

Images must be byte-identical between Python and Flutter. Do not use messaging
apps or image editors between runs because recompression or orientation changes
can invalidate the comparison.

## Procedure

1. Record each image path, actual class if known, source, and expected decision.
2. Run the original image through Python and export:
   decoded dimensions, orientation, resized tensor statistics, raw output,
   normalized output, top-1 label, and top-1 score.
3. Run the same file through Flutter and export the same fields.
4. Compare the preprocessed tensors before comparing predictions.
5. If tensors differ, inspect orientation, resize/crop behavior, interpolation,
   RGB/BGR order, normalization, dtype, and quantization.
6. Only after tensor parity passes, compare raw and processed output scores.
7. Record every discrepancy and its resolved cause.

## Result CSV

Use this exact minimum format:

```csv
image,actual_class,python_top1,python_score,flutter_top1,flutter_score,absolute_score_difference,status
valid/healthy/h01.jpg,Healthy,Healthy,0.9342,Healthy,0.9341,0.0001,PASS
```

Recommended additional columns are:

```text
python_tensor_min,python_tensor_max,flutter_tensor_min,flutter_tensor_max,
python_raw_scores,flutter_raw_scores,python_decision,flutter_decision,notes
```

## Pass Conditions

- Python and Flutter produce the same top-1 class for the same image and
  preprocessing mode.
- Scores have a small absolute difference when preprocessing and runtime
  precision are identical.
- A numeric score tolerance must be measured and documented. Start with an
  investigation threshold of `0.001`, not as an assumed final guarantee.
- Acceptance/rejection decisions match for every test vector.
- Label indices and label text match exactly.

Quantized models may require a different tolerance, but any tolerance must be
justified with observed results rather than guessed.

## Failure Handling

If Python and Flutter disagree, fix preprocessing or tensor handling before
retraining, quantization, confidence tuning, or UI redesign. Retraining while a
deployment mismatch exists hides the root cause and invalidates comparisons.

Parity success does not prove field accuracy. Disease accuracy, calibration,
and invalid-image rejection require separate independent evaluations.

This is parity testing, not accuracy validation. A matching wrong prediction
passes parity but still fails disease accuracy.
