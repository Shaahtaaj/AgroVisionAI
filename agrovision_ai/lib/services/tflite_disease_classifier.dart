import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/disease_repository.dart';
import '../models/prediction_result.dart';

enum ScanRejectionReason {
  unclearObject,
  likelyHand,
  likelyNonLeaf,
  blurry,
  tooDark,
  tooBright,
}

class ScanRejectedException implements Exception {
  const ScanRejectedException(this.reason);

  final ScanRejectionReason reason;
}

class ImageDecodeException implements Exception {
  const ImageDecodeException();
}

class ModelLoadException implements Exception {
  const ModelLoadException();
}

class DiseaseInferenceException implements Exception {
  const DiseaseInferenceException();
}

class TfliteDiseaseClassifier {
  static const int inputSize = 224;
  static const double minConfidence = 0.75;
  static const double minConfidenceGap = 0.20;

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> load() async {
    if (_interpreter != null && _labels != null) return;
    try {
      _interpreter ??= await Interpreter.fromAsset(
        'assets/model/mango_model.tflite',
        options: InterpreterOptions()..threads = 2,
      );
      _labels ??= await _loadLabels();
      if (_labels!.isEmpty) {
        throw StateError('The deployed label file is empty.');
      }
    } catch (error, stackTrace) {
      debugPrint('TFLite model load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      close();
      _labels = null;
      throw const ModelLoadException();
    }
  }

  Future<PredictionResult> predict(File imageFile) async {
    final decoded = await _decode(imageFile);
    final quality = _inspectQuality(decoded);
    _rejectPoorQuality(quality);
    _rejectUnlikelySubject(decoded);
    await load();
    final interpreter = _interpreter!;
    final labels = _labels!;
    final input = _preprocess(decoded);
    late List<PredictionCandidate> candidates;
    try {
      final outputShape = interpreter.getOutputTensor(0).shape;
      final outputLength = outputShape.isEmpty
          ? labels.length
          : outputShape.reduce((a, b) => a * b);
      final output = [List<double>.filled(outputLength, 0)];
      interpreter.run(input, output);
      candidates = _rankPredictions(output.first, labels);
      if (candidates.isEmpty) {
        throw StateError('The model returned no prediction candidates.');
      }
    } catch (error, stackTrace) {
      debugPrint('TFLite inference failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const DiseaseInferenceException();
    }
    final top1 = candidates.first;
    final top2 = candidates.length > 1
        ? candidates[1]
        : const PredictionCandidate(label: 'none', confidence: 0);
    final confidenceGap = top1.confidence - top2.confidence;

    if (top1.confidence < minConfidence || confidenceGap < minConfidenceGap) {
      throw const ScanRejectedException(ScanRejectionReason.unclearObject);
    }

    final label = top1.label;
    final disease = await DiseaseRepository.instance.findByLabel(label);

    return PredictionResult(
      label: label,
      confidence: top1.confidence,
      quality: quality,
      topPredictions: candidates,
      disease: disease,
    );
  }

  Future<img.Image> _decode(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('Unsupported image file.');
      }
      return decoded;
    } catch (error, stackTrace) {
      debugPrint('Image decode failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const ImageDecodeException();
    }
  }

  ImageQualityReport _inspectQuality(img.Image decoded) {
    final small = img.copyResize(decoded, width: 96, height: 96);
    var luminanceTotal = 0.0;
    var edgeTotal = 0.0;

    for (var y = 1; y < small.height - 1; y++) {
      for (var x = 1; x < small.width - 1; x++) {
        final center = _luminance(small.getPixel(x, y));
        luminanceTotal += center;
        final horizontal =
            (_luminance(small.getPixel(x + 1, y)) -
                    _luminance(small.getPixel(x - 1, y)))
                .abs();
        final vertical =
            (_luminance(small.getPixel(x, y + 1)) -
                    _luminance(small.getPixel(x, y - 1)))
                .abs();
        edgeTotal += horizontal + vertical;
      }
    }

    final samples = (small.width - 2) * (small.height - 2);
    final brightness = luminanceTotal / samples;
    final sharpness = edgeTotal / samples;
    final issues = <ImageQualityIssue>[];

    if (decoded.width < 300 || decoded.height < 300) {
      issues.add(ImageQualityIssue.lowResolution);
    }
    if (brightness < 55) {
      issues.add(ImageQualityIssue.tooDark);
    } else if (brightness > 215) {
      issues.add(ImageQualityIssue.tooBright);
    }
    if (sharpness < 9) {
      issues.add(ImageQualityIssue.blurry);
    }

    return ImageQualityReport(
      brightness: brightness,
      sharpness: sharpness,
      width: decoded.width,
      height: decoded.height,
      issues: issues,
    );
  }

  void _rejectPoorQuality(ImageQualityReport quality) {
    if (quality.issues.contains(ImageQualityIssue.blurry)) {
      throw const ScanRejectedException(ScanRejectionReason.blurry);
    }
    if (quality.issues.contains(ImageQualityIssue.tooDark)) {
      throw const ScanRejectedException(ScanRejectionReason.tooDark);
    }
    if (quality.issues.contains(ImageQualityIssue.tooBright)) {
      throw const ScanRejectedException(ScanRejectionReason.tooBright);
    }
  }

  void _rejectUnlikelySubject(img.Image decoded) {
    final small = img.copyResize(decoded, width: 96, height: 96);
    final startX = (small.width * 0.1).round();
    final endX = (small.width * 0.9).round();
    final startY = (small.height * 0.1).round();
    final endY = (small.height * 0.9).round();
    var skinPixels = 0;
    var greenPixels = 0;
    var botanicalPixels = 0;
    var neutralPixels = 0;
    var samples = 0;

    for (var y = startY; y < endY; y++) {
      for (var x = startX; x < endX; x++) {
        final pixel = small.getPixel(x, y);
        final red = pixel.r.toDouble();
        final green = pixel.g.toDouble();
        final blue = pixel.b.toDouble();
        final maximum = max(red, max(green, blue));
        final minimum = min(red, min(green, blue));
        final saturation = maximum == 0 ? 0.0 : (maximum - minimum) / maximum;

        final looksLikeSkin =
            red > 95 &&
            green > 40 &&
            blue > 20 &&
            maximum - minimum > 15 &&
            (red - green).abs() > 15 &&
            red > green &&
            red > blue;
        final looksGreen =
            green > 45 && green > red * 1.04 && green > blue * 1.08;
        final looksLikeLeafColor =
            looksGreen ||
            (green > 35 &&
                green > red * 0.88 &&
                green > blue * 1.05 &&
                saturation > 0.12) ||
            (red > 65 &&
                green > 50 &&
                blue < green * 0.75 &&
                red < green * 1.8 &&
                saturation > 0.20);

        if (looksLikeSkin) skinPixels++;
        if (looksGreen) greenPixels++;
        if (looksLikeLeafColor) botanicalPixels++;
        if (saturation < 0.12) neutralPixels++;
        samples++;
      }
    }

    final skinFraction = skinPixels / samples;
    final greenFraction = greenPixels / samples;
    final botanicalFraction = botanicalPixels / samples;
    final neutralFraction = neutralPixels / samples;
    debugPrint(
      'Subject gate: skin=${skinFraction.toStringAsFixed(3)}, '
      'green=${greenFraction.toStringAsFixed(3)}, '
      'botanical=${botanicalFraction.toStringAsFixed(3)}, '
      'neutral=${neutralFraction.toStringAsFixed(3)}',
    );

    // Keep this conservative: it targets a hand filling the guide area and
    // does not attempt to prove that every accepted subject is a mango leaf.
    if (skinFraction >= 0.32 && greenFraction < 0.18) {
      throw const ScanRejectedException(ScanRejectionReason.likelyHand);
    }

    // Screens, keyboards, walls, and similar neutral objects typically have
    // little botanical color in the guide area. Yellow and brown leaf colors
    // are included above so this does not require a leaf to be purely green.
    if (botanicalFraction < 0.12 && neutralFraction >= 0.35) {
      throw const ScanRejectedException(ScanRejectionReason.likelyNonLeaf);
    }
  }

  double _luminance(img.Pixel pixel) {
    return (0.299 * pixel.r) + (0.587 * pixel.g) + (0.114 * pixel.b);
  }

  List<List<List<List<double>>>> _preprocess(img.Image decoded) {
    final resized = img.copyResize(
      decoded,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    return [
      List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        });
      }),
    ];
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString('assets/model/labels.txt');
    return raw
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<PredictionCandidate> _rankPredictions(
    List<double> scores,
    List<String> labels,
  ) {
    final probabilities = _probabilities(scores);
    final candidates = <PredictionCandidate>[
      for (var i = 0; i < probabilities.length; i++)
        PredictionCandidate(
          label: i < labels.length ? labels[i] : 'class_$i',
          confidence: probabilities[i],
        ),
    ];
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates;
  }

  List<double> _probabilities(List<double> scores) {
    final total = scores.fold<double>(0, (sum, value) => sum + value);
    final looksLikeProbabilities = scores.every(
      (score) => score >= 0 && score <= 1,
    );
    if (looksLikeProbabilities && total > 0.95 && total < 1.05) {
      return scores.map((score) => score.clamp(0, 1).toDouble()).toList();
    }
    final maxScore = scores.reduce(max);
    final expScores = scores.map((score) => exp(score - maxScore)).toList();
    final expTotal = expScores.fold<double>(0, (sum, value) => sum + value);
    return expScores.map((score) => score / expTotal).toList();
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
