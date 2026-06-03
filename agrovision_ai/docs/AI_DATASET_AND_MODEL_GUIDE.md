# AgroVision AI Dataset And Model Guide

## Clean Disease Taxonomy

Use this training taxonomy everywhere:

```text
Crop -> Disease Type -> Disease Label -> Severity -> Symptoms -> IPM Treatment
```

Recommended class-id format:

```text
crop_disease_name
mango_anthracnose
mango_powdery_mildew
cotton_leaf_curl
rice_blast
```

Avoid mixing human labels with model labels. Keep:

- `id`: stable app/database id
- `label`: exact model label from `labels.txt`
- `taxonomy.class_label`: normalized training class id
- `name` and `name_sd`: display names only
- `action_urgency`: farmer-facing decision timing
- `favorable_conditions`: weather and disease-pressure context
- `region_prevalence`: Pakistan/Sindh localization support
- `visual_confusion_risks`: when AI diagnosis may be weak
- `economic_threshold_action`: when action is economically justified
- `stage_based_management`: early, moderate, and severe field actions
- `recurrence_risk`: likelihood of returning in future seasons
- `resistance_notes`: fungicide/insecticide resistance guidance
- `ipm_score`: 0-10 intervention urgency under IPM
- `pre_harvest_interval_days`: minimum safety interval after chemical use
- `progression_stages`: visual disease timeline for diagnostics
- `possible_co_infections`: likely mixed-disease or pest+disease combinations
- `false_positive_triggers`: non-disease conditions that can fool image AI
- `ml_focus_regions`: image regions for model attention and annotation
- `treatment_effectiveness`: relative treatment usefulness scores from `0.0` to `1.0`
- `treatment_cost_estimate`: `Low`, `Medium`, or `High`
- `recommendation_summary`: final farmer-facing answer to "what should I do now?"
- `sd`: farmer-friendly Sindhi localization in `simple`, `medium`, and `expert` levels

## Modular Knowledge Base

The production-ready modular dataset lives at:

```text
assets/data/agro_knowledge_base.json
```

It splits repeated data into reusable modules:

```text
core_disease_profiles
  -> identity, taxonomy, severity, urgency, economics, weather, recommendation_summary

symptom_modules
  -> symptoms, causes, ML focus regions, false positives, progression, co-infections

treatment_modules
  -> prevention, treatment, stage-based management, IPM, safety, medicine_ids

medicine_database
  -> shared medicine names, Sindhi names, dose, image, PHI, cost, safety warning
```

This avoids duplication of pesticide images, safety warnings, and repeated medicine metadata. The current `diseases.json` remains as a Flutter-compatible flat file; the modular file is ready for a future backend or app repository refactor.

## API Output Schema

Backend-ready inference output:

```json
{
  "predicted_disease": "Anthracnose",
  "crop": "Mango",
  "confidence": 0.87,
  "severity": "High risk",
  "action_urgency": "Immediate",
  "recommendation_summary": "Remove infected leaves/debris immediately and consider Mancozeb within 48 hours if symptoms are active and spreading.",
  "ipm_score": 8,
  "pre_harvest_interval_days": 14,
  "symptoms_detected": [
    "dark sunken spots",
    "necrotic leaf margins"
  ],
  "recommended_actions": {
    "economic_threshold_action": "Treat if more than 10% leaves show active symptoms",
    "prevention": [
      "Prune trees for air flow",
      "Remove infected leaves and fallen fruits"
    ],
    "treatment": [
      "Use fungicide only after symptom confirmation"
    ],
    "medicine": [
      {
        "name": "Mancozeb 80% WP",
        "dose": "2-2.5 g per liter water",
        "safety": "Follow label, PPE, and pre-harvest interval"
      }
    ]
  },
  "local_language": "Sindhi"
}
```

## Deployment Decision Fields

These fields make the app practical for farmers:

```json
{
  "action_urgency": "Immediate / Within 3 days / Monitor",
  "favorable_conditions": {
    "temperature": "20-30°C",
    "humidity": "High",
    "rainfall": "Frequent rain or leaf wetness"
  },
  "region_prevalence": ["Sindh", "Punjab", "South Asia"],
  "visual_confusion_risks": [
    "Early-stage symptoms may be hard to detect from one image",
    "Can be confused with nutrient deficiency"
  ],
  "economic_threshold_action": "Treat if more than 10% leaves or new flush show active symptoms"
}
```

Use `action_urgency` in the result screen:

- `Immediate`: show urgent warning and recommend field confirmation today
- `Within 3 days`: advise scouting and treatment planning
- `Monitor`: avoid chemical recommendation and advise observation

## Stage-Based Treatment Logic

Each disease should include:

```json
{
  "stage_based_management": {
    "early": [
      "Scout field and confirm symptoms on multiple plants",
      "Remove visibly infected leaves or plant debris where practical"
    ],
    "moderate": [
      "Apply IPM measures and use recommended treatment only if symptoms are spreading"
    ],
    "severe": [
      "Isolate or remove heavily infected plant material",
      "Use recommended chemical control with PPE and local agriculture advice"
    ]
  },
  "recurrence_risk": "High",
  "resistance_notes": "Repeated use of the same fungicide group may select resistant pathogen populations.",
  "ipm_score": 8,
  "pre_harvest_interval_days": 14,
  "progression_stages": [
    "Stage 1: small spots or mild discoloration",
    "Stage 2: lesion expansion and visible tissue damage",
    "Stage 3: tissue necrosis, leaf drop, or fruit/flower damage"
  ],
  "possible_co_infections": [
    "Anthracnose + Powdery mildew"
  ],
  "false_positive_triggers": [
    "dust accumulation on leaves",
    "sun scorch"
  ],
  "ml_focus_regions": [
    "leaf center",
    "leaf margin",
    "lesion border"
  ],
  "treatment_effectiveness": {
    "sanitation_and_pruning": 0.60,
    "copper_fungicide": 0.75,
    "mancozeb": 0.85
  },
  "treatment_cost_estimate": "Medium"
}
```

Use `ipm_score` in UI:

- `0-2`: monitor, no spray recommendation
- `3-5`: cultural/organic actions first
- `6-7`: treatment planning and field confirmation
- `8-10`: urgent IPM control; chemical option only with safety rules

## Advanced AI Fields

Use these fields for stronger future AI workflows:

- `possible_co_infections`: supports multi-label predictions and mixed symptom warnings.
- `false_positive_triggers`: helps explain weak/uncertain predictions to the farmer.
- `ml_focus_regions`: supports dataset annotation, attention maps, and camera guidance.
- `treatment_effectiveness`: lets the recommendation engine rank organic, cultural, and chemical actions.
- `treatment_cost_estimate`: helps farmers choose affordable actions before chemicals.

For future model training, consider multi-label output:

```text
primary_disease_probability + co_infection_probability + image_quality_score
```

## Model Training Improvements

Current JSON contains more mango records than other crops. For production, balance the image dataset per class, not only JSON records.

Target image counts:

- Minimum: 800-1000 usable images per disease class
- Better: 2000+ images per class from local field conditions
- Healthy class: include several varieties, lighting conditions, and growth stages

Underrepresented classes should use augmentation:

- rotation: `-20` to `+20` degrees
- random crop/zoom: `0.8` to `1.15`
- brightness/contrast jitter
- mild blur/noise
- background variation
- horizontal/vertical flip only when disease orientation does not matter

Avoid noisy training labels:

- remove mixed-disease leaves from single-label training
- remove extreme blur, tiny leaf images, and non-leaf photos
- separate pest damage from fungal disease when symptoms overlap
- keep `labels.txt` in the exact same order as training output

Recommended model:

- MobileNetV3Small: best for low-end Android and fast offline inference
- EfficientNet-Lite0: better accuracy with still acceptable mobile speed
- Use transfer learning first, then fine-tune last blocks

Preprocessing:

```text
decode image -> center crop or square crop -> resize 224x224 -> RGB -> normalize exactly like training
```

If training used TensorFlow `Rescaling(1./255)`, Flutter should use `pixel / 255.0`.
If training used `[-1, 1]`, Flutter should use `(pixel / 127.5) - 1.0`.

## Real Field Logic

Use IPM before chemicals:

- confirm symptoms visually
- remove infected plant material
- improve airflow and irrigation practices
- use resistant varieties where possible
- conserve beneficial insects
- use pesticide only when pest/disease pressure justifies it

Medicine advice must remain cautious:

- never recommend fixed chemical use from low-confidence AI output
- always include PPE and label warning
- avoid spraying in wind, heat, or flowering where pollinators may be harmed
- rotate fungicide/insecticide groups to reduce resistance risk
- suggest local agriculture extension confirmation for severe disease

## Sindhi Data Standard

Use consistent Sindhi crop names:

- Mango: `انب`
- Wheat: `ڪڻڪ`
- Cotton: `ڪپھ`
- Rice: `چانور`
- Tomato: `ٽماٽو`

Keep disease names understandable for farmers. Scientific names should stay Latin in `scientific_name`.

## Sindhi Localization Layer

Each disease record now contains a human-written Sindhi advisory layer:

```json
{
  "sd": {
    "simple": {
      "name": "",
      "overview": "",
      "symptoms": [],
      "causes": [],
      "prevention": [],
      "treatment": [],
      "important_note": ""
    },
    "medium": {
      "name": "",
      "overview": "",
      "symptoms": [],
      "causes": [],
      "prevention": [],
      "treatment": [],
      "important_note": ""
    },
    "expert": {
      "name": "",
      "overview": "",
      "symptoms": [],
      "causes": [],
      "prevention": [],
      "treatment": [],
      "important_note": ""
    }
  }
}
```

Use levels like this:

- `simple`: rural farmer-facing guidance, easiest wording
- `medium`: general agriculture user guidance
- `expert`: agriculture officer, student, or field technician wording

The app can start with `simple` for Sindhi users and later expose a setting for difficulty level.
