import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../core/app_theme.dart';
import '../services/tflite_disease_classifier.dart';
import '../widgets/viewfinder_overlay.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Tips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TipChip(icon: Icons.filter_center_focus, label: strings.tipCenterLeaf),
                const SizedBox(width: 8),
                _TipChip(icon: Icons.wb_sunny_outlined, label: strings.tipGoodLight),
                const SizedBox(width: 8),
                _TipChip(icon: Icons.smartphone, label: strings.tipAvoidScreens),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Smart Reticle Viewfinder
          ViewfinderOverlay(
            isScanning: _busy,
            image: _image,
            guideMessage: _cameraGuideMessage(context),
          ),
          const SizedBox(height: 14),

          // Subtitle / Scope note
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 6),
                  Text(
                    strings.mangoOnly,
                    style: const TextStyle(
                      color: AppColors.forest,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Controls & Shutter Bar
          if (_busy) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppDecorations.card(
                color: Colors.white,
                borderColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Column(
                children: [
                  const LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.mintLight,
                    minHeight: 6,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        strings.processing,
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery button
                InkWell(
                  onTap: () => _pick(ImageSource.gallery),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: AppColors.softCardShadow,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.forest,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Main Circular Camera Shutter
                GestureDetector(
                  onTap: () => _pick(ImageSource.camera),
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40159957),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Info / Tips hint button
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppColors.primaryDark,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                strings.chooseImage,
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],

          if (_error != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD2C2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10C2410C),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE3D6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFC2410C),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFF7C2D12),
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
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
      ScanRejectionReason.likelyHand =>
        isSindhi
            ? 'تصوير ۾ هٿ يا چمڙي جهڙي شيءِ نظر اچي ٿي. مھرباني ڪري رڳو انب جو صاف ۽ حقيقي پن جانچيو.'
            : 'A hand or skin-like object was detected. Please scan only a clear real mango leaf.',
      ScanRejectionReason.likelyNonLeaf =>
        isSindhi
            ? 'تصوير ۾ انب جو پن صاف نظر نٿو اچي. ڪمپيوٽر جي پردي، ڪي بورڊ يا ٻي شيءِ بدران رڳو حقيقي پن جانچيو.'
            : 'A clear mango leaf was not found. Avoid screens, keyboards, and other objects.',
    };
    return '$title\n$message';
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
