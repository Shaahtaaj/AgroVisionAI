# App Quality Sprint 1 Summary

## Branch

`app-quality-sprint-1`

## Changes

- Language selection is stored locally with the existing `shared_preferences` dependency.
- The saved language is loaded before the Flutter app starts; English is used only when no saved language exists.
- Camera cancellation, permission failures, unreadable images, model-load failures, and inference failures now show short English or Sindhi guidance.
- Technical failure details are written to debug logs and are not displayed to farmers.
- Disease knowledge cards show either **AI Detectable** or **Information Only**.
- Detectability is derived from `assets/model/labels.txt`; it is not maintained as a second hard-coded class list.
- Scan-result lookup accepts only labels present in the deployed model label file.
- Mango Scab and Alternaria Leaf Spot remain available as knowledge content and are marked Information Only.

## Files Changed

- `lib/main.dart`
- `lib/app/agrovision_app.dart`
- `lib/core/app_language.dart`
- `lib/core/app_strings.dart`
- `lib/core/language_preferences.dart`
- `lib/data/disease_repository.dart`
- `lib/screens/disease_info_screen.dart`
- `lib/screens/scan_screen.dart`
- `lib/services/tflite_disease_classifier.dart`
- `test/widget_test.dart`
- `test/disease_detectability_test.dart`
- `docs/app_quality_sprint_1_summary.md`

## Manual Testing

1. Select Sindhi, close the app completely, reopen it, and confirm the app remains in Sindhi.
2. Deny camera permission and confirm a friendly localized message appears without technical exception text.
3. Permanently deny camera permission and confirm the message directs the user to app settings.
4. Cancel camera and gallery selection and confirm the app reports that no image was selected.
5. Open Mango disease information and confirm Anthracnose is AI Detectable.
6. Confirm Mango Scab and Alternaria Leaf Spot are Information Only.
7. Scan a supported image and confirm the existing result flow still works.

## Verification

- `flutter analyze`: passed with no issues.
- `flutter test`: passed, 4 tests.
- `git diff --check`: passed.
- The initial combined Flutter command timed out in the Windows wrapper without diagnostics; independent analyzer and test runs then completed successfully.

## Intentionally Unchanged

- TFLite model and label order
- Confidence and confidence-gap thresholds
- Disease and treatment content
- Android package ID, signing, and release configuration
- Frozen model-recovery conclusions and artifacts
- Model training, quantization, replacement, or additional AI models

## Frozen Model Status

- Top-1 Python-Android parity: Verified on 12 smoke images.
- Aligned runtime score parity: Verified at tolerance 0.03.
- Exact tensor parity: Not verified.
- Training preprocessing: Not recovered.
- Model accuracy: Not validated.
- Production readiness: Not claimed.
