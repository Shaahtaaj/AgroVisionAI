import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_fonts.dart';
import '../core/app_scope.dart';
import '../core/app_theme.dart';
import '../models/prediction_result.dart';

class ConfidenceGauge extends StatefulWidget {
  const ConfidenceGauge({
    required this.confidence,
    required this.status,
    this.size = 110,
    super.key,
  });

  final double confidence;
  final PredictionStatus status;
  final double size;

  @override
  State<ConfidenceGauge> createState() => _ConfidenceGaugeState();
}

class _ConfidenceGaugeState extends State<ConfidenceGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = Tween<double>(begin: 0.0, end: widget.confidence).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ConfidenceGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidence != widget.confidence) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.confidence,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor() {
    return switch (widget.status) {
      PredictionStatus.reliable => AppColors.statusReliable,
      PredictionStatus.possible => AppColors.statusPossible,
      PredictionStatus.uncertain => AppColors.statusUncertain,
    };
  }

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final color = _statusColor();

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final displayValue = (_animation.value * 100).toStringAsFixed(1);
          return CustomPaint(
            painter: _GaugePainter(
              progress: _animation.value,
              color: color,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$displayValue%',
                    style: TextStyle(
                      fontFamily: AppFonts.heading(language),
                      fontSize: widget.size * 0.18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.forest,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    switch (widget.status) {
                      PredictionStatus.reliable => Icons.verified_rounded,
                      PredictionStatus.possible => Icons.help_outline_rounded,
                      PredictionStatus.uncertain => Icons.report_problem_rounded,
                    },
                    size: widget.size * 0.16,
                    color: color,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.09;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
