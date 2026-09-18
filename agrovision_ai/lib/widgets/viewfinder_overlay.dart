import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class ViewfinderOverlay extends StatefulWidget {
  const ViewfinderOverlay({
    required this.isScanning,
    this.image,
    this.guideMessage,
    super.key,
  });

  final bool isScanning;
  final File? image;
  final String? guideMessage;

  @override
  State<ViewfinderOverlay> createState() => _ViewfinderOverlayState();
}

class _ViewfinderOverlayState extends State<ViewfinderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scanAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ViewfinderOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.isScanning && _animController.isAnimating) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: AppColors.softCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.image != null)
              Image.file(widget.image!, fit: BoxFit.cover)
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.mintLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 46,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.guideMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          widget.guideMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMedium,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Corner Brackets Reticle
            const CustomPaint(
              painter: _ReticlePainter(color: AppColors.primary),
            ),

            // Animated Scanning Laser
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                    heightFactor: 0.05,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.0),
                            AppColors.primary,
                            AppColors.mint,
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x88159957),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 32.0;
    const padding = 20.0;

    // Top-Left
    final pathTL = Path()
      ..moveTo(padding, padding + cornerLength)
      ..lineTo(padding, padding)
      ..lineTo(padding + cornerLength, padding);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(size.width - padding - cornerLength, padding)
      ..lineTo(size.width - padding, padding)
      ..lineTo(size.width - padding, padding + cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(padding, size.height - padding - cornerLength)
      ..lineTo(padding, size.height - padding)
      ..lineTo(padding + cornerLength, size.height - padding);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(size.width - padding - cornerLength, size.height - padding)
      ..lineTo(size.width - padding, size.height - padding)
      ..lineTo(size.width - padding, size.height - padding - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}

