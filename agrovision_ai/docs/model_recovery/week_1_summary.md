# Week 1 Model Recovery Summary

## Outcome

Week 1 established a traceable runtime contract and an evidence-controlled
workspace without changing Flutter behavior, UI, the deployed model, labels,
disease data, dependencies, or release configuration.

Work was performed on branch:

```text
week-1-model-recovery
```

## What Was Inspected

- Deployed model path, file size, timestamp, and SHA-256
- App label file and label order
- Flutter model loading, image decoding, quality checks, preprocessing,
  inference, output processing, and rejection thresholds
- Prediction result model and disease-record mapping
- Existing model specification and dataset/model guide
- Repository and safe parent-scan boundary for possible training artifacts
- Availability of Python, TensorFlow inspection, Flutter analysis, and tests

The repository inventory skipped `.git`, `build`, `.dart_tool`,
`android/.gradle`, `ios/Pods`, and `node_modules`. The Git repository parent is
the `D:\` filesystem root, so recursive parent scanning was skipped as unsafe.

## What Was Verified

- Model: `assets/model/mango_model.tflite`
- Model size: `44,684,752` bytes
- Model SHA-256:
  `616EA24D8784A6E1E75633B92392DA327E579B52465F9802069D675CF547E1FE`
- Label file: `assets/model/labels.txt`
- App label count: 8
- App label order:
  Anthracnose, Bacterial Canker, Cutting Weevil, Die Back, Gall Midge,
  Healthy, Powdery Mildew, Sooty Mould
- Flutter currently constructs a `224x224` RGB batch and applies
  `pixel / 255.0`
- Flutter directly resizes with linear interpolation
- Flutter applies softmax only when outputs do not already look like
  probabilities
- Current top-1 acceptance threshold: `0.75`
- Current top-1/top-2 gap threshold: `0.20`

The preprocessing facts above are verified as current app implementation, but
their compatibility with the original training pipeline remains an **App
assumption**.

## Inventory Result

The generated inventory recorded 9 candidate files. No original training
notebook, training script, `.h5`/`.keras` source model, conversion script,
dataset split manifest, training log, or evaluation report was found.

Documentation containing words such as MobileNet, EfficientNet, augmentation,
and Rescaling was found, but those files contain recommendations rather than
proof of the original training configuration.

## What Remains Unknown

- Actual TFLite input/output tensor shape, dtype, and quantization parameters
- Exact model backbone, classification head, and final activation
- TensorFlow and Keras versions
- Whether pretrained weights were used
- Original dataset name, source, version, license, region, and dates
- Total and per-class image counts
- Train/validation/test proportions and split unit
- Duplicate or tree/orchard leakage audit
- Exact augmentation, optimizer, loss, batch size, epochs, and random seed
- Source model and TFLite conversion command
- Confusion matrix and per-class metrics
- Confidence calibration
- Independent Sindh field validation
- Python-Flutter preprocessing and prediction parity

Original files stored in Colab, Kaggle, Drive, email, WhatsApp, or another
computer were not accessible and therefore were not guessed.

## Command Results

### Training inventory

```text
python tools/model_recovery_inventory.py
```

Could not run because `python.exe` resolves to an unavailable Windows Store
launcher and no usable Python installation was found. To keep Week 1 moving,
the CSV was generated with a read-only PowerShell fallback using the same
extensions, terms, and excluded directories. The reusable Python tool remains
the source implementation for future runs.

### TensorFlow Lite inspection

```text
python tools/inspect_tflite.py
```

Could not run for the same unavailable Python reason. TensorFlow availability
could not be tested, and `tflite_model_report.json` was not generated. Tensor
shape, dtype, and quantization remain Unknown.

### Flutter checks

`flutter analyze` and `flutter test` were not rerun during recovery because the
Flutter/Dart tooling had already timed out and appeared stuck during the same
project audit. Week 1 contains no app behavior changes, but these checks must be
restored and run in Week 2.

## Current Risks

1. Flutter preprocessing may not match training preprocessing.
2. Label order is verified only from the app file, not original
   `class_indices`.
3. Unknown tensor dtype or embedded preprocessing may make the runtime
   assumption incorrect.
4. No reproducible training pipeline or dataset provenance is available.
5. No leakage-free evaluation or field-accuracy evidence is available.
6. No Python-Flutter parity test vectors exist.
7. Confidence thresholds are engineering constants, not calibrated results.

## Do Not Claim Yet

- Do not claim production readiness.
- Do not claim calibrated confidence.
- Do not claim field accuracy.
- Do not claim valid chemical recommendation from AI output.
- Do not claim broad crop detection.
- Do not claim preprocessing is correct until training evidence or parity
  testing confirms it.

## Exact Next Actions for Week 2

1. Install or activate a working Python environment without changing Flutter
   dependencies.
2. Install a TensorFlow version compatible with the environment and run
   `python tools/inspect_tflite.py`.
3. Copy verified tensor details into `recovery_evidence.csv`,
   `training_config.json`, and `MODEL_SPEC.md`.
4. Search external owner-controlled locations for the original notebook,
   dataset link, `class_indices`, saved Keras model, conversion command, and
   evaluation outputs.
5. Create `test_vectors/` with at least two images per class plus invalid and
   boundary images.
6. Implement a non-production Python inference runner using the inspected
   tensor contract.
7. Add a Flutter diagnostic/integration runner that exports preprocessing and
   raw prediction values without changing user-facing behavior.
8. Execute the parity plan and resolve preprocessing differences before any
   retraining, quantization, threshold tuning, or UI redesign.
9. Repair the Flutter/Dart toolchain and run `flutter analyze` and
   `flutter test`.
10. Begin a dataset manifest only from recovered source evidence; leave all
    unsupported fields `TBD`.
