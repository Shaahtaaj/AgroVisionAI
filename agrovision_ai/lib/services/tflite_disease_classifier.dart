import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/disease_repository.dart';
import '../models/prediction_result.dart';

class TfliteDiseaseClassifier {
  static const int inputSize = 224;

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> load() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/model/mango_model.tflite',
      options: InterpreterOptions()..threads = 2,
    );
    _labels ??= await _loadLabels();
  }

  Future<PredictionResult> predict(File imageFile) async {
    await load();
    final interpreter = _interpreter!;
    final labels = _labels!;
    final decoded = await _decode(imageFile);
    final quality = _inspectQuality(decoded);
    final input = _preprocess(decoded);
    final outputShape = interpreter.getOutputTensor(0).shape;
    final outputLength = outputShape.isEmpty
        ? labels.length
        : outputShape.reduce((a, b) => a * b);
    final output = [List<double>.filled(outputLength, 0)];

    interpreter.run(input, output);

    final scores = output.first;
    final bestIndex = _argMax(scores);
    final confidence = _confidence(scores[bestIndex], scores);
    final label = bestIndex < labels.length
        ? labels[bestIndex]
        : 'class_$bestIndex';
    final disease = await DiseaseRepository.instance.findByLabel(label);

    return PredictionResult(
      label: label,
      confidence: confidence,
      quality: quality,
      disease: disease,
    );
  }

  Future<img.Image> _decode(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unsupported image file.');
    }
    return decoded;
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

  int _argMax(List<double> values) {
    var bestIndex = 0;
    var bestValue = values.first;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > bestValue) {
        bestIndex = i;
        bestValue = values[i];
      }
    }
    return bestIndex;
  }

  double _confidence(double rawScore, List<double> scores) {
    final total = scores.fold<double>(0, (sum, value) => sum + value);
    if (rawScore >= 0 && rawScore <= 1 && total > 0.95 && total < 1.05) {
      return rawScore.clamp(0, 1);
    }
    final maxScore = scores.reduce(max);
    final expScores = scores.map((score) => exp(score - maxScore)).toList();
    final expTotal = expScores.fold<double>(0, (sum, value) => sum + value);
    return (exp(rawScore - maxScore) / expTotal).clamp(0, 1);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
