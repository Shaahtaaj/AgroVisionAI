# Smart Agro Disease Detection App

## Folder Structure

```text
lib/
  app/                  MaterialApp, routes, global classifier lifecycle
  core/                 Language enum, app strings, inherited app scope
  data/                 Local JSON repository
  models/               Disease, medicine, prediction result models
  screens/              Splash, welcome, home, disease info, scan, result
  services/             TensorFlow Lite classifier and image preprocessing
  widgets/              Shared cards, language switcher, info sections
assets/
  data/diseases.json    Offline disease knowledge base
  images/               App logo and future medicine images
  fonts/                Sindhi Lateefi font
  model/                mango_model.tflite and labels.txt
```

## Runtime Flow

```text
SplashScreen
  -> preloads diseases.json
  -> WelcomeScreen
  -> HomeScreen
       -> DiseaseInfoScreen(crop)
       -> ScanScreen
            -> ImagePicker camera/gallery
            -> TfliteDiseaseClassifier
                 -> decode image
                 -> resize 224x224
                 -> normalize RGB 0..1
                 -> run mango_model.tflite
                 -> map output index with labels.txt
                 -> join details from diseases.json
            -> ResultScreen
```

## Local Data Contract

Each disease record contains:

```json
{
  "id": "mango_anthracnose",
  "crop": "Mango",
  "label": "Anthracnose",
  "image": "https://commons.wikimedia.org/wiki/Special:FilePath/Mango_Tree_with_Leaf_Spots.jpg",
  "severity": "High risk",
  "name": "Anthracnose",
  "name_sd": "اينٿراڪنوز",
  "symptoms": [],
  "symptoms_sd": [],
  "causes": [],
  "causes_sd": [],
  "prevention": [],
  "prevention_sd": [],
  "treatment": [],
  "treatment_sd": [],
  "medicines": [
    {
      "name": "Mancozeb 80% WP",
      "name_sd": "مينڪوزيب 80٪ WP",
      "dose": "2-2.5 g per liter water",
      "image": ""
    }
  ]
}
```

## AI Integration

- Model path: `assets/model/mango_model.tflite`
- Label path: `assets/model/labels.txt`
- Input size: `224x224`
- Preprocessing: decode image, resize, RGB normalize to `0..1`
- Output: highest score is converted to confidence and mapped to disease details

Keep `labels.txt` in the exact class order used during training. If the model was trained with a different class order, update only this file and the app will map predictions correctly.

## Language And Media

- English uses the default Roboto-style Material typography.
- Sindhi uses `assets/fonts/mb_lateefi_regular.ttf` through the `Lateefi` font family and switches the app to RTL direction.
- Disease and pesticide images are stored as internet URLs in `diseases.json`. The UI uses a resilient image widget with loading and offline fallback states.
