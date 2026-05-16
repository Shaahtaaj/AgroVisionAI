import 'disease.dart';

enum PredictionStatus {
  reliable,
  possible,
  uncertain;

  static PredictionStatus fromConfidence(double confidence) {
    if (confidence >= 0.80) return PredictionStatus.reliable;
    if (confidence >= 0.60) return PredictionStatus.possible;
    return PredictionStatus.uncertain;
  }
}

enum ImageQualityIssue { lowResolution, tooDark, tooBright, blurry }

class ImageQualityReport {
  const ImageQualityReport({
    required this.brightness,
    required this.sharpness,
    required this.width,
    required this.height,
    required this.issues,
  });

  final double brightness;
  final double sharpness;
  final int width;
  final int height;
  final List<ImageQualityIssue> issues;

  bool get hasWarnings => issues.isNotEmpty;
}

class PredictionResult {
  const PredictionResult({
    required this.label,
    required this.confidence,
    required this.quality,
    this.disease,
  });

  final String label;
  final double confidence;
  final ImageQualityReport quality;
  final Disease? disease;

  PredictionStatus get status => PredictionStatus.fromConfidence(confidence);

  bool get shouldShowTreatment =>
      status != PredictionStatus.uncertain && disease != null;
}
