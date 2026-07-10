# AgroVision AI Parity Test Vectors

This folder is reserved for exact-image Python-versus-Flutter parity testing.
Do not add training images when their origin is known. Do not use this small
parity set to claim model accuracy.

## Folder Structure

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
    hand/
    screen/
    soil/
    other_leaf/
  boundary/
    blur/
    low_light/
    glare/
    small_leaf/
  README.md
```

Create only the folders for which real test images are available. Keep original
files unchanged so Python and Flutter process byte-identical images.

## Minimum Week 2 Target

- Two unseen images per supported class, if available
- Five to ten invalid images, if available
- A few blur, low-light, glare, and small-leaf examples
- Images from more than one phone and background where possible
- No images known to be in the training set

This minimum set checks pipeline parity and obvious rejection behavior. It is
too small to estimate accuracy, calibration, or production reliability.

## Later Validation Target

- At least 30-50 unseen images per class
- Orchard/tree-separated samples where possible
- Multiple mango varieties, phones, backgrounds, and disease stages
- A dedicated non-leaf, non-mango, and unknown-disease set
- Recorded source, consent/license, date, region, device, and actual class

When actual class is uncertain, mark it `unknown` rather than guessing. A plant
pathologist or agricultural expert should verify labels used for accuracy
evaluation.
