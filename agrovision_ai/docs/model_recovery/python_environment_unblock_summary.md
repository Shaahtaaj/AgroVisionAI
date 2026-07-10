# Python Environment Unblock Summary

Date: 2026-07-10

## Environment Status

The initial command probe did not return a usable Python version:

| Check | Result |
|---|---|
| `python --version` | Windows command resolution failed; no version returned |
| `py --version` | Windows command resolution failed; no version returned |
| `python3 --version` | Windows command resolution failed; no version returned |
| `where python` | No executable found by `where.exe` |
| `where py` | No executable found by `where.exe` |

`Get-Command` found Windows Store aliases and a separate Python 3.14.5 install.
Python 3.14.5 was not used because the recovery setup requires Python 3.11 or
3.12 for the TensorFlow environment.

Python 3.12.10 was installed for the current user. The project setup script was
then run with the Python 3.12 directory prepended to that process's `PATH`, and
it created `.venv-model-recovery`.

## Verified Package Versions

| Component | Verified version |
|---|---|
| Python | 3.12.10 |
| pip | 26.1.2 |
| TensorFlow | 2.21.0 |
| NumPy | 2.5.1 |
| Pillow | 12.3.0 |

The first dependency download attempt was blocked by sandbox networking. The
approved retry exceeded the command timeout, but independent `pip show` checks
confirmed that all required packages had installed successfully.

## TFLite Inspection

`tools/inspect_tflite.py` ran successfully with the project virtual environment
and generated `docs/model_recovery/tflite_model_report.json`. The report was not
created or edited manually.

| Fact | Verified value |
|---|---|
| Input tensor shape | `[1, 224, 224, 3]` |
| Input shape signature | `[-1, 224, 224, 3]` |
| Input dtype | `float32` |
| Output tensor shape | `[1, 8]` |
| Output shape signature | `[-1, 8]` |
| Output dtype | `float32` |
| Quantization | Unquantized float32; tensor scale `0.0`, zero point `0` |
| Labels/output consistency | Match: 8 labels and 8 output scores |
| Model size | 44,684,752 bytes |
| Model SHA-256 | `616EA24D8784A6E1E75633B92392DA327E579B52465F9802069D675CF547E1FE` |

The model hash still matches the existing recovery evidence.

## Inference Runner

`tools/run_tflite_inference.py --help` completed successfully. No real image
files are currently present under `test_vectors/`, so inference was not run and
`docs/model_recovery/python_inference_results.csv` was not fabricated.

## Remaining Unknown/TBD Items

- Original training code, TensorFlow/Keras training versions, and architecture
- Training preprocessing, including exact resize/crop and normalization
- Dataset source, license, class counts, split strategy, and leakage audit
- Training augmentation, optimizer, loss, batch size, and epoch history
- TFLite conversion command and source checkpoint
- Accuracy, calibration, confusion matrix, and external field validation
- Python-Flutter prediction parity on shared real images

## Next Recommended Step

Add a small, consented set of real mango-leaf test images to `test_vectors/`,
run the Python inference runner with `--preprocessing flutter_default`, capture
the same image predictions in Flutter, and complete the parity comparison.
