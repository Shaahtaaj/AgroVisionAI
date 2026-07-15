# AgroVision AI Model Recovery

This slim folder preserves the final verified runtime contract and accepted
Python-Android parity result for the deployed mango model.

## Final Status

- Top-1 Python-Android parity: Verified on 12 smoke images.
- Aligned runtime score parity: Verified at tolerance 0.03.
- Exact tensor parity: Not verified.
- Training preprocessing: Not recovered.
- Model accuracy: Not validated.
- Production readiness: Not claimed.

## Essential Evidence

- MODEL_SPEC: ../MODEL_SPEC.md
- Recovery evidence: recovery_evidence.csv
- TFLite inspection: tflite_model_report.json
- Python environment record: python_environment_unblock_summary.md
- Final alignment summary: week_3e_preprocessing_alignment_summary.md
- Final aligned comparison: parity_comparison_report_aligned_candidate.csv
- Cleanup record: cleanup_summary.md

Raw tensor dumps, local smoke images, intermediate inference CSVs, and weekly
debug logs were removed after their accepted conclusions were summarized.

## Verification Tools

The retained reusable tools are:

- tools/inspect_tflite.py
- tools/run_tflite_inference.py
- tools/preprocessing_modes.py

Recreate the isolated Python environment when verification is needed:

    .\scripts\setup_model_recovery_env.ps1

Then inspect the model:

    .\.venv-model-recovery\Scripts\python.exe tools\inspect_tflite.py

For Python runtime evaluation aligned toward the deployed package:image resize
path, use:

    .\.venv-model-recovery\Scripts\python.exe tools\run_tflite_inference.py --input <images> --preprocessing flutter_image_linear_candidate

The aligned candidate supports runtime comparison only. It does not prove the
original training preprocessing or model accuracy.
