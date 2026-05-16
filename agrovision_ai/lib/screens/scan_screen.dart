import 'dart:io';

import 'package:flutter/material.dart';
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
        setState(() => _busy = false);
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = error.toString();
      });
    }
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
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
