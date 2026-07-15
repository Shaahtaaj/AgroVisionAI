# Week 3E Preprocessing Alignment Summary

Date: 2026-07-12

## Outcome

| Item | Result |
|---|---|
| REVIEW images tested | 5 |
| Candidate modes tested | 6 |
| Best candidate | flutter_image_linear_candidate |
| Original average tensor difference | 0.017033204 |
| Improved average tensor difference | 0.002185994 |
| Original worst maximum difference | 0.811764710 |
| Improved worst maximum difference | 0.058823556 |
| Exact tensor parity | Not achieved |
| Aligned score result | 12 PASS / 0 REVIEW / 0 FAIL / 0 SKIPPED |
| Runtime score parity | Verified at provisional tolerance 0.03 |
| Training preprocessing | Unknown |

The original flutter_default mode is preserved and now explicitly remains the
Pillow bilinear implementation. It should not be described as numerically
identical to Android Flutter preprocessing.

The best candidate implements package:image 4.9.1 linear resize sampling and
uint8 truncation in Python. It substantially improves tensor similarity and
reduces the maximum aligned score difference to 0.018201113.

No exact tensor match was achieved, so MODEL_SPEC.md was not updated with an
exact preprocessing-parity claim. Chrome was not used as an Android emulator:
it is a web target and cannot provide native tflite_flutter FFI parity. Existing
captured Android tensors provided the required real comparison evidence.

## Recommended Next Step

Use flutter_image_linear_candidate for Python runtime-parity evaluation while
keeping its candidate status explicit. If exact tensor parity becomes necessary,
compare Pillow and package:image decoded RGB bytes before resizing to isolate
the remaining JPEG-decoder difference.

## Do Not Claim Yet

- Do not claim model accuracy.
- Do not claim field accuracy.
- Do not claim training preprocessing is recovered.
- Do not claim confidence calibration.
- Do not claim invalid-image rejection is solved.
- Do not claim production readiness.
- Do not claim chemical recommendations are validated.
