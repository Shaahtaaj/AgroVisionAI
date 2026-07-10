# AgroVision AI Model Specification

## 1. Document Status

| Field | Value |
|---|---|
| Product | AgroVision AI |
| Model purpose | Offline mango leaf disease classification |
| Deployment target | Flutter Android application using TensorFlow Lite |
| Specification status | Current runtime contract with unresolved training metadata |
| Last verified | 2026-07-10 |
| Owner | AgroVision AI project team |

This document describes the model currently bundled with the mobile app. Facts
verified from the repository are stated directly. Training details or evaluation
results that are not available are marked `TBD` and must not be presented as
verified claims.

This specification is the current Flutter runtime contract, not a fully
recovered training-provenance record. Week 1 recovery evidence is maintained in:

- [Recovery evidence](model_recovery/recovery_evidence.csv)
- [TFLite inspection report](model_recovery/tflite_model_report.json), generated
  only when TensorFlow inspection succeeds
- [Recovered training configuration](model_recovery/training_config.json)
- [Dataset manifest](model_recovery/dataset_manifest.json)
- [Python-Flutter parity plan](model_recovery/parity_test_plan.md)
- [Training artifact inventory](model_recovery/training_artifacts_inventory.csv)

Unresolved training, dataset, conversion, and evaluation fields remain `TBD`
until direct evidence is recovered.

## 2. Intended Use

The model classifies a clear photograph of a real mango leaf into one of eight
supported classes. It is intended to support preliminary field screening and to
link a prediction with the offline disease knowledge base.

The model output is advisory. It is not a laboratory diagnosis and must not be
the sole basis for pesticide use, crop destruction, or other high-impact farm
decisions.

### Supported users

- Mango farmers and orchard workers
- Agriculture students and field technicians
- Agricultural extension staff using the app as a screening aid

### Supported input

- One visible mango leaf as the main subject
- A close, sharp, normally exposed RGB photograph
- Camera or gallery images that can be decoded by the Flutter `image` package

### Out of scope

- Non-mango crops
- Fruit, flower, stem, root, soil, or whole-canopy diagnosis
- Disease severity estimation from lesion area
- Multiple simultaneous disease predictions
- Laboratory confirmation or chemical prescription
- Reliable rejection of every non-leaf or non-mango image

## 3. Deployed Artifact

| Property | Current value |
|---|---|
| Model file | `assets/model/mango_model.tflite` |
| Label file | `assets/model/labels.txt` |
| Format | TensorFlow Lite (`.tflite`) |
| Reported model family | Convolutional neural network; exact backbone is `TBD` |
| Model size | 44,684,752 bytes (approximately 42.62 MiB) |
| SHA-256 | `616EA24D8784A6E1E75633B92392DA327E579B52465F9802069D675CF547E1FE` |
| Runtime package | `tflite_flutter` |
| Interpreter threads | 2 |
| Quantization | `TBD`; the current Flutter input path assumes floating-point input |
| Model version | `TBD`; no embedded or external semantic version is currently stored |

Any replacement model must update the hash, version, tensor contract,
evaluation report, and label order in this document.

## 4. Class Taxonomy

The output index must map to labels in this exact order:

| Index | Display label | Stable class id |
|---:|---|---|
| 0 | Anthracnose | `mango_anthracnose` |
| 1 | Bacterial Canker | `mango_bacterial_canker` |
| 2 | Cutting Weevil | `mango_cutting_weevil` |
| 3 | Die Back | `mango_die_back` |
| 4 | Gall Midge | `mango_gall_midge` |
| 5 | Healthy | `mango_healthy` |
| 6 | Powdery Mildew | `mango_powdery_mildew` |
| 7 | Sooty Mould | `mango_sooty_mould` |

`Mango Scab` and `Alternaria Leaf Spot` exist in the knowledge base but are not
outputs of the deployed model. They must be presented as information-only
records unless a future model explicitly adds those classes.

## 5. Tensor Contract

### Verified input tensor

| Property | Contract |
|---|---|
| Batch size | 1 |
| Width | 224 pixels |
| Height | 224 pixels |
| Channels | 3 |
| Tensor name | `serving_default_keras_tensor_10:0` |
| Tensor shape | `[1, 224, 224, 3]` |
| Shape signature | `[-1, 224, 224, 3]` |
| Tensor dtype | `float32` |
| Quantization | None; scale `0.0`, zero point `0`, and no quantization scales or zero points |
| Channel order | RGB, based on the current Flutter contract; training provenance remains `TBD` |
| Runtime values | Floating-point values in `[0.0, 1.0]` |

These tensor facts were verified on 2026-07-10 by the TensorFlow Lite
interpreter. The normalization and resize behavior remain app assumptions until
training evidence or Python-Flutter parity testing proves them.

### Verified output tensor

| Property | Contract |
|---|---|
| Output tensors | One |
| Tensor name | `StatefulPartitionedCall_1:0` |
| Tensor shape | `[1, 8]` |
| Shape signature | `[-1, 8]` |
| Tensor dtype | `float32` |
| Quantization | None; scale `0.0`, zero point `0`, and no quantization scales or zero points |
| Class scores | 8 |
| Label mapping | Output index maps directly to `labels.txt` order |
| Label-count consistency | Verified: 8 labels match 8 output scores |
| Task type | Single-label multiclass classification |

The complete generated evidence is in
[`docs/model_recovery/tflite_model_report.json`](model_recovery/tflite_model_report.json).
The app currently derives output length from the first output tensor shape. A
production build must continue to fail fast if the score count and label count
differ.

## 6. Preprocessing Contract

The deployed Flutter pipeline performs these steps:

```text
read bytes
  -> decode image
  -> resize directly to 224x224 using linear interpolation
  -> read RGB channels
  -> divide each channel by 255.0
  -> create batch [1, 224, 224, 3]
```

Current formula:

```text
normalized_channel = pixel_channel / 255.0
```

Direct resize can distort a non-square leaf image. The training pipeline must
confirm whether direct resize, center crop, letterbox, or another strategy was
used. Mobile preprocessing must exactly match training preprocessing.

## 7. Output Processing

The app processes raw scores as follows:

1. If every score is between `0` and `1` and the total is between `0.95` and
   `1.05`, scores are treated as probabilities.
2. Otherwise, a numerically stable softmax is applied.
3. Predictions are sorted from highest to lowest confidence.
4. Top-1 and top-2 scores are used for rejection.

This behavior assumes mutually exclusive classes. It is not suitable for a
future multi-label or co-infection model without a new output contract.

## 8. Decision and Rejection Rules

| Rule | Current threshold | Result |
|---|---:|---|
| Minimum top-1 confidence | `0.75` | Reject below threshold |
| Minimum top-1 minus top-2 gap | `0.20` | Reject below threshold |
| Reliable result status | `>= 0.80` | Show as reliable |
| Possible result status | `0.60` to `< 0.80` | Show as possible |
| Uncertain result status | `< 0.60` | Do not show treatment |

Because accepted predictions require confidence of at least `0.75`, the
effective accepted `possible` range is `0.75` to `< 0.80`.

These thresholds are temporary engineering values. They must be selected using
validation data, confidence calibration, and out-of-distribution testing rather
than intuition alone.

## 9. Image Quality Gate

Quality inspection downsizes the image to `96x96` and calculates average
luminance and a simple horizontal/vertical edge score.

| Check | Current threshold | Behavior |
|---|---:|---|
| Minimum source dimensions | 300x300 | Warning only |
| Too dark | Brightness `< 55` | Reject |
| Too bright | Brightness `> 215` | Reject |
| Too blurry | Sharpness `< 9` | Reject |

These checks are global image heuristics. They do not prove that a leaf is
present, that the leaf is mango, or that the leaf occupies enough of the frame.
Thresholds must be tested across supported phones and field lighting.

## 10. Runtime Response

For an accepted image, the classifier returns:

```json
{
  "label": "Anthracnose",
  "confidence": 0.87,
  "top_predictions": [
    {"label": "Anthracnose", "confidence": 0.87},
    {"label": "Bacterial Canker", "confidence": 0.08}
  ],
  "image_quality": {
    "width": 1200,
    "height": 1600,
    "brightness": 124.0,
    "sharpness": 18.0,
    "issues": []
  },
  "disease_record": "mango_anthracnose"
}
```

The disease record is resolved locally by matching the model label with
`assets/data/diseases.json`. Treatment text is knowledge-base content and is not
generated by the neural network.

## 11. Current Safety Limitations

The deployed classifier does not currently include:

- A trained unknown or invalid-image class
- A leaf/non-leaf detector
- Mango/non-mango verification
- Leaf segmentation or minimum leaf-area validation
- Out-of-distribution confidence scoring
- Disease severity measurement
- Multi-label co-infection prediction
- Confidence calibration evidence
- Explainability or lesion localization

Confidence and confidence-gap rejection reduce some errors but cannot guarantee
safe rejection of screens, hands, walls, other plants, or unfamiliar diseases.

No chemical treatment should be shown when the prediction is rejected,
uncertain, or unmatched to a verified disease record. Users must be advised to
confirm symptoms and follow locally registered product labels and agricultural
extension guidance.

## 12. Training Provenance Required

The following information is not available in the repository and must be added
for reproducibility:

| Required item | Status |
|---|---|
| Training code and exact commit | `TBD` |
| TensorFlow/Keras versions | `TBD` |
| Backbone and classifier-head architecture | `TBD` |
| Initialization or pretrained weights | `TBD` |
| Dataset names, versions, licenses, and download dates | `TBD` |
| Per-class raw and accepted image counts | `TBD` |
| Orchard/tree-level train-validation-test split | `TBD` |
| Duplicate and leakage audit | `TBD` |
| Augmentation configuration and random seed | `TBD` |
| Optimizer, loss, batch size, epochs, and learning rates | `TBD` |
| Best-checkpoint selection rule | `TBD` |
| TFLite conversion and optimization command | `TBD` |

Training data must include local Sindh field conditions, multiple mango
varieties, phones, backgrounds, lighting, growth stages, disease severities,
healthy leaves, look-alike disorders, and invalid/non-leaf images.

## 13. Evaluation Requirements

Evaluation must report both clean test performance and real-field performance.
At minimum, publish:

- Confusion matrix
- Per-class precision, recall, F1 score, and support
- Macro and weighted F1 score
- Top-1 accuracy
- Calibration curve and expected calibration error
- Rejection coverage versus accepted-set accuracy
- False acceptance rate for non-leaf, non-mango, and unknown-disease images
- Performance by phone, lighting, background, and disease stage
- Model size, load time, median latency, p95 latency, and peak memory

### Proposed release gates

These are targets, not current measured results:

| Metric | Proposed minimum |
|---|---:|
| Clean held-out macro F1 | `>= 0.90` |
| Per-class recall | `>= 0.85` |
| Independent field-set macro F1 | `>= 0.80` |
| Non-leaf/non-mango rejection rate | `>= 0.95` |
| Expected calibration error | `<= 0.05` |
| Accepted-result error rate | `<= 0.10` |
| p95 end-to-end inference on target low-end Android | `< 1.0 second` |

No production-accuracy claim should be made until these metrics are measured on
an independent, leakage-free test set.

## 14. Test Vectors

Each model release must include a versioned test-vector folder containing:

```text
test_vectors/
  valid/
    one_or_more_images_per_class
  boundary/
    low_light_blur_glare_small_leaf_early_stage
  invalid/
    screens_hands_walls_tables_other_crops_non_leaf
  expected_results.json
```

For every vector, store expected preprocessing statistics, top scores, decision
status, and whether the image must be accepted or rejected. Python and Flutter
must produce equivalent results within a documented numeric tolerance.

## 15. Mobile Performance and Optimization

The current 42.62 MiB artifact is heavy for a low-end offline Android target.
The next candidate should evaluate:

- MobileNetV3Small or EfficientNet-Lite0 transfer learning
- Float16 or full-integer INT8 quantization
- Representative-dataset quantization
- Typed input/output buffers
- Background-isolate preprocessing and inference
- Model preload during app startup

A smaller model must not replace the current artifact unless accuracy,
calibration, and rejection behavior pass the same release gates.

## 16. Model Versioning and Release Procedure

Use semantic model versions independent of the app version:

```text
mango-disease-classifier MAJOR.MINOR.PATCH
```

- `MAJOR`: class taxonomy or tensor contract changes
- `MINOR`: retraining, new data, or meaningful metric improvement
- `PATCH`: conversion, metadata, or packaging change with equivalent behavior

Every release must archive:

```text
model.tflite
labels.txt
model_spec.md
dataset_manifest.json
training_config.json
evaluation_report.json
test_vectors/
```

Release checklist:

1. Verify model and label tensor counts match.
2. Verify preprocessing parity between Python and Flutter.
3. Run clean, field, and invalid-image evaluation sets.
4. Record model hash, size, latency, memory, and metrics.
5. Review class labels and disease mappings.
6. Review agricultural safety text independently of model accuracy.
7. Run Flutter unit, integration, and physical-device tests.
8. Update this specification and the app changelog.

## 17. Source-of-Truth Files

| Responsibility | File |
|---|---|
| TFLite artifact | `assets/model/mango_model.tflite` |
| Output label order | `assets/model/labels.txt` |
| Flutter preprocessing and rejection | `lib/services/tflite_disease_classifier.dart` |
| Prediction result contract | `lib/models/prediction_result.dart` |
| Disease and treatment mapping | `assets/data/diseases.json` |
| Dataset and future-model guidance | `docs/AI_DATASET_AND_MODEL_GUIDE.md` |
