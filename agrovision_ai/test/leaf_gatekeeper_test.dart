import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:agrovision_ai/services/tflite_disease_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TfliteDiseaseClassifier Gatekeeper', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('gatekeeper_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('rejects textured neutral surfaces (walls, paper, screens)', () async {
      final classifier = TfliteDiseaseClassifier();
      final neutralImage = img.Image(width: 320, height: 320);
      // Create textured noise so it has sharpness > 10, but zero green/botanical
      for (var y = 0; y < 320; y++) {
        for (var x = 0; x < 320; x++) {
          final v = (180 + ((x * y) % 50)).clamp(0, 255);
          neutralImage.setPixelRgb(x, y, v, v, v);
        }
      }
      final file = File('${tempDir.path}/neutral.jpg');
      await file.writeAsBytes(img.encodeJpg(neutralImage));

      expect(
        () => classifier.predict(file),
        throwsA(isA<ScanRejectedException>().having(
          (e) => e.reason,
          'reason',
          ScanRejectionReason.likelyNonLeaf,
        )),
      );
    });

    test('rejects textured skin/hand tone surfaces', () async {
      final classifier = TfliteDiseaseClassifier();
      final skinImage = img.Image(width: 320, height: 320);
      for (var y = 0; y < 320; y++) {
        for (var x = 0; x < 320; x++) {
          final noise = (x + y) % 30;
          skinImage.setPixelRgb(x, y, 210 + noise, 130 + noise, 90 + noise);
        }
      }
      final file = File('${tempDir.path}/skin.jpg');
      await file.writeAsBytes(img.encodeJpg(skinImage));

      expect(
        () => classifier.predict(file),
        throwsA(isA<ScanRejectedException>().having(
          (e) => e.reason,
          'reason',
          ScanRejectionReason.likelyHand,
        )),
      );
    });

    test('rejects wooden desk texture without vegetation', () async {
      final classifier = TfliteDiseaseClassifier();
      final woodImage = img.Image(width: 320, height: 320);
      for (var y = 0; y < 320; y++) {
        for (var x = 0; x < 320; x++) {
          final grain = (x * 3 + y) % 35;
          woodImage.setPixelRgb(x, y, 150 + grain, 95 + grain, 55 + grain);
        }
      }
      final file = File('${tempDir.path}/wood.jpg');
      await file.writeAsBytes(img.encodeJpg(woodImage));

      expect(
        () => classifier.predict(file),
        throwsA(isA<ScanRejectedException>()),
      );
    });
  });
}

