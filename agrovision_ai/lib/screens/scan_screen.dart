import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../services/tflite_disease_classifier.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({required this.classifier, super.key});

  static const routeName = '/scan';

  final TfliteDiseaseClassifier classifier;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final strings = AppStrings(AppScope.of(context).language);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
      );
      if (picked == null) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = strings.noImageSelected;
        });
        return;
      }
      final image = File(picked.path);
      setState(() => _image = image);
      final result = await widget.classifier.predict(image);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        ResultScreen.routeName,
        arguments: ResultScreenArgs(image: image, prediction: result),
      );
    } on ScanRejectedException catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _localizedRejectionMessage(context, error.reason);
      });
    } on PlatformException catch (error, stackTrace) {
      debugPrint('Image picker failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _permissionMessage(strings, error);
      });
    } on ImageDecodeException catch (error, stackTrace) {
      debugPrint('Image decode failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = strings.imageReadFailed;
      });
    } on ModelLoadException catch (error, stackTrace) {
      debugPrint('Disease model load failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = strings.modelLoadFailed;
      });
    } on DiseaseInferenceException catch (error, stackTrace) {
      debugPrint('Disease inference failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = strings.unexpectedScanError;
      });
    } catch (error, stackTrace) {
      debugPrint('Unexpected scan failure: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = strings.unexpectedScanError;
      });
    }
  }

  String _permissionMessage(AppStrings strings, PlatformException error) {
    return switch (error.code) {
      'camera_access_denied' => strings.cameraPermissionRequired,
      'camera_access_denied_without_prompt' ||
      'camera_access_restricted' => strings.cameraPermissionSettings,
      'photo_access_denied' ||
      'photo_access_restricted' => strings.galleryPermissionRequired,
      _ => strings.unexpectedScanError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.scanLeaf,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDCEADE)),
              ),
              child: _image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo,
                          color: Color(0xFF159957),
                          size: 58,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings.chooseImage,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.mangoOnly,
                          style: const TextStyle(color: Color(0xFF60756B)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _cameraGuideMessage(context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF60756B),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          if (_busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              strings.processing,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera),
              label: Text(strings.camera),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: Text(strings.gallery),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Card(
              color: const Color(0xFFFFF1EB),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber, color: Color(0xFFC2410C)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFF7C2D12),
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _cameraGuideMessage(BuildContext context) {
    final isSindhi = AppScope.of(context).language.isSindhi;
    if (isSindhi) {
      return 'رڳو انب جو صاف ۽ حقيقي پن جانچيو. فون يا ڪمپيوٽر جي پردي واري تصوير نه ڏيو.';
    }
    return 'Please scan only a clear real mango leaf. Avoid laptop/mobile screen photos.';
  }

  String _localizedRejectionMessage(
    BuildContext context,
    ScanRejectionReason reason,
  ) {
    final isSindhi = AppScope.of(context).language.isSindhi;
    final title = isSindhi
        ? 'اڻڄاتل يا غير واضح شيءِ'
        : 'Unknown or unclear object';
    final message = switch (reason) {
      ScanRejectionReason.blurry =>
        isSindhi
            ? 'تصوير ڌنڌلي آهي. مھرباني ڪري انب جو صاف ۽ ويجهو پن جانچيو.'
            : 'The image is blurry. Please scan a clear real mango leaf only.',
      ScanRejectionReason.tooDark =>
        isSindhi
            ? 'تصوير اونداھي آهي. مھرباني ڪري بهتر روشني ۾ انب جو پن جانچيو.'
            : 'The image is too dark. Please scan a clear real mango leaf in better light.',
      ScanRejectionReason.tooBright =>
        isSindhi
            ? 'تصوير تمام روشن يا چمڪ واري آهي. مھرباني ڪري سڌي چمڪ کان بچي انب جو پن جانچيو.'
            : 'The image is too bright or has glare. Please avoid direct glare and scan a real mango leaf.',
      ScanRejectionReason.unclearObject =>
        isSindhi
            ? 'مھرباني ڪري رڳو انب جو صاف پن جانچيو. فون يا ڪمپيوٽر جي پردي واري تصوير نه ڏيو.'
            : 'Please scan a clear real mango leaf only. Avoid mobile or laptop screen images.',
    };
    return '$title\n$message';
  }
}
