# Week 2 TFLite Inspection and Parity Summary

## Outcome

Week 2 prepared the TensorFlow Lite inspection and Python-versus-Flutter parity
system without changing the app, UI, model, labels, disease or treatment data,
thresholds, Flutter dependencies, or Android release configuration.

Actual branch:

```text
week-2-tflite-inspection-parity
```

All Week 1 uncommitted recovery work was preserved when the branch was created.

## Python Environment Status

Safe detection was performed for:

```text
python --version
py --version
python3 --version
where python
where py
```

Results:

- `python`, `py`, and `python3` resolve through PowerShell to aliases under
  `C:\Users\TECHNOSELLERS\AppData\Local\Microsoft\WindowsApps\`.
- None of the three commands starts a usable Python interpreter.
- `where python` and `where py` report no executable files.
- No Python 3.11 or 3.12 executable was found in common local installation or
  project virtual-environment paths.

The environment problem is therefore not fixed on this machine. The exact next
step is to install Python 3.11 or 3.12 from python.org or a trusted package
manager, enable PATH integration, and run:

```powershell
.\scripts\setup_model_recovery_env.ps1
```

The setup script does not silently install system Python. It creates the local
`.venv-model-recovery` environment only after a usable interpreter is found.

## TensorFlow and TFLite Inspection

TensorFlow availability could not be checked because Python itself could not
start.

Command attempted:

```text
python tools/inspect_tflite.py
```

The command failed before script execution because the Windows Store
`python.exe` launcher could not start. Consequently:

- `inspect_tflite.py` did not run.
- `docs/model_recovery/tflite_model_report.json` was not generated.
- Input shape and dtype remain App assumption/Unknown as recorded in evidence.
- Output shape, output dtype, and quantization remain Unknown.
- No tensor field was promoted to Verified.

The inspector now reads `labels.txt`, records label order and count, calculates
output score count when possible, and reports whether the primary output count
matches the eight app labels.

## Facts That Remain Verified

- Model path: `assets/model/mango_model.tflite`
- Model size: `44,684,752` bytes
- Model SHA-256:
  `616EA24D8784A6E1E75633B92392DA327E579B52465F9802069D675CF547E1FE`
- Label path: `assets/model/labels.txt`
- Label count: 8
- Label order in the app file remains unchanged
- Hash and label order remain consistent with Week 1 evidence

These facts do not verify the original training `class_indices` or tensor
contract.

## Python Inference and Parity Readiness

Created `tools/run_tflite_inference.py` with:

- Single-image and recursive-folder input
- Pillow RGB decoding
- Top-1 and top-3 output
- Label/output count validation
- Quantized tensor handling when quantization metadata is available
- CSV output at `docs/model_recovery/python_inference_results.csv`
- `flutter_default` preprocessing: direct bilinear resize to `224x224`, RGB,
  `pixel / 255.0`, batch `[1,224,224,3]`
- Investigative modes: `minus_one_to_one`, `raw_0_to_255`, and
  `center_crop_0_to_1`

Only `flutter_default` is the current app assumption. No mode is verified as
the original training preprocessing.

Command attempted:

```text
python tools/run_tflite_inference.py --help
```

It failed before script execution because Python was unavailable. No real test
images exist under `test_vectors/`, inference was not run, and
`python_inference_results.csv` was not generated.

Created parity scaffolding:

- `test_vectors/README.md`
- `docs/model_recovery/parity_test_template.csv`
- `docs/model_recovery/flutter_parity_capture_plan.md`
- Updated `docs/model_recovery/parity_test_plan.md`

## Flutter Tooling

`flutter analyze` and `flutter test` were not retried indefinitely. The same
Flutter/Dart tooling had already timed out and appeared stuck during the current
project audit. Week 2 changes contain no Flutter source or behavior changes.

## What Remains Unknown

- Actual TFLite input shape and dtype
- Actual output shape and dtype
- Quantization type, scale, zero point, and parameters
- Embedded preprocessing or metadata
- Original training preprocessing
- Original model architecture and final activation
- Dataset provenance, counts, split, and leakage status
- Training environment and hyperparameters
- Evaluation, calibration, and field performance
- Python-Flutter score tolerance and parity result
- Invalid-image rejection performance

## Do Not Claim Yet

- Do not claim training preprocessing is recovered.
- Do not claim model accuracy.
- Do not claim confidence calibration.
- Do not claim production readiness.
- Do not claim invalid-image rejection is solved.
- Do not claim chemical recommendations are validated.

## Week 3 Recommended Actions

1. Install Python 3.11 or 3.12 and run the environment setup script.
2. Run `tools/inspect_tflite.py` and preserve the generated JSON report.
3. Promote tensor facts to Verified only after matching the generated report.
4. Add two unseen images per class and 5-10 invalid images to `test_vectors/`
   with provenance notes.
5. Run `tools/run_tflite_inference.py` using `flutter_default` first.
6. Build a test-only Flutter parity harness; do not add production logging.
7. Compare exact image files using `parity_test_template.csv`.
8. Fix any decoding or preprocessing mismatch before retraining, quantization,
   threshold changes, or UI work.
9. Repair the Flutter/Dart toolchain and run analysis and tests once.
10. Search owner-controlled Colab, Kaggle, Drive, email, WhatsApp, and old
    machines for original training evidence without guessing missing facts.
