# Project Cleanup Summary

Date: 2026-07-12

Branch: project-cleanup-slim

## Why Cleanup Was Done

Model-recovery and parity debugging were complete. The project was slimmed to
retain final evidence and reusable verification tools without carrying local
environments, build products, raw tensors, test photographs, temporary Flutter
harnesses, or repeated weekly logs.

## Files Kept

Essential documentation:

- docs/MODEL_SPEC.md
- docs/model_recovery/README.md
- docs/model_recovery/recovery_evidence.csv
- docs/model_recovery/tflite_model_report.json
- docs/model_recovery/python_environment_unblock_summary.md
- docs/model_recovery/week_3e_preprocessing_alignment_summary.md
- docs/model_recovery/parity_comparison_report_aligned_candidate.csv

Reusable tools:

- tools/inspect_tflite.py
- tools/run_tflite_inference.py
- tools/preprocessing_modes.py

Test placeholders:

- test_vectors/README.md
- test_vectors/parity_smoke/README.md

## Files Removed

- Local .venv-model-recovery environment
- Flutter build and .dart_tool output
- docs/model_recovery/tensor_debug raw tensors and summaries
- Original and aligned intermediate Python inference CSVs
- Intermediate Flutter inference and parity CSVs
- Test-vector manifests, counts, and REVIEW debug lists
- Dataset/training inventory drafts superseded by final evidence
- Week 1, Week 2, Week 3, Week 3B, Week 3C, and Week 3D logs
- Local parity smoke JPG images and empty category placeholder trees
- One-time Python tensor/candidate/comparison tools
- Test-only Android/Flutter parity and tensor-dump entrypoints
- Flutter parity test wrapper

Approximately 3.55 GB of generated environment, cache, and build content was
removed, in addition to raw tensors and local test photographs.

## Files Archived

None. Temporary materials were deleted because their accepted conclusions are
preserved in the final summary, aligned comparison, MODEL_SPEC, and recovery
evidence.

## Protected Files

The cleanup did not change:

- assets/model/mango_model.tflite
- assets/model/labels.txt
- assets/data/diseases.json
- lib/
- android/
- pubspec.yaml
- pubspec.lock

Production behavior, UI, confidence thresholds, treatment guidance, and Android
release configuration remain unchanged.

## Final Model-Recovery Status

- Top-1 Python-Android parity: Verified on 12 smoke images.
- Aligned runtime score parity: Verified at tolerance 0.03.
- Exact tensor parity: Not verified.
- Training preprocessing: Not recovered.
- Model accuracy: Not validated.
- Production readiness: Not claimed.

## Next Recommended Development Focus

Return to product work: farmer-facing usability, robust Sindhi localization,
field-data collection with consent and provenance, and independent agronomic
review. Do not expand model-recovery testing unless a concrete release or
evaluation need requires it.
