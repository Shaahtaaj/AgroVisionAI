# Model Recovery Workspace

This folder contains Week 1 evidence for recovering the provenance and runtime
contract of the deployed AgroVision AI mango model. Recovery files document
what is verified, what the Flutter app assumes, what is inferred, and what
remains unknown.

## Run the inventory

From the Flutter project directory:

```powershell
python tools/model_recovery_inventory.py
```

The tool automatically scans the repository parent when it is safe. Disable
that optional parent scan with:

```powershell
python tools/model_recovery_inventory.py --no-parent
```

The inventory skips `.git`, `build`, `.dart_tool`, `android/.gradle`,
`ios/Pods`, and `node_modules`. It writes:

```text
docs/model_recovery/training_artifacts_inventory.csv
```

## Inspect the TFLite model

TensorFlow must be installed in the active Python environment:

```powershell
python tools/inspect_tflite.py
```

On success, the script writes:

```text
docs/model_recovery/tflite_model_report.json
```

If TensorFlow is missing, the script exits with a clear error and does not
modify the model. Do not manually invent tensor details in the report.

## Evidence statuses

- `Verified`: directly proven by repository content, file metadata, hash, or an
  generated inspection report.
- `App assumption`: behavior implemented by Flutter but not confirmed against
  the original training pipeline.
- `Inferred`: supported by indirect evidence but not directly proven.
- `Unknown`: evidence is unavailable.

The deployed model, labels, Flutter behavior, disease data, and release
configuration are outside the scope of Week 1 changes.

## Prepare the Week 2 Python environment

The recovery dependencies are isolated from Flutter in:

```text
requirements-model-recovery.txt
```

After installing Python 3.11 or 3.12, run:

```powershell
.\scripts\setup_model_recovery_env.ps1
```

The script creates `.venv-model-recovery`, upgrades pip, installs TensorFlow,
NumPy, and Pillow, and prints the inspection and inference commands. It does
not install system Python.

Python inference usage:

```powershell
.\.venv-model-recovery\Scripts\python.exe tools\run_tflite_inference.py `
  --input test_vectors `
  --preprocessing flutter_default
```

Only `flutter_default` represents the current app preprocessing assumption.
Other modes are diagnostic candidates and are not recovered training facts.
