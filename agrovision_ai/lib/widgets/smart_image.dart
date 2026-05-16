import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  const SmartImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage(context);
    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  Widget _buildImage(BuildContext context) {
    if (source.isEmpty) {
      return _Fallback(width: width, height: height);
    }
    if (source.startsWith('http')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _Fallback(width: width, height: height, loading: true);
        },
        errorBuilder: (_, _, _) => _Fallback(width: width, height: height),
      );
    }
    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _Fallback(width: width, height: height),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height, this.loading = false});

  final double? width;
  final double? height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE7F7EA), Color(0xFFCFEFDB)],
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.eco, color: Color(0xFF159957), size: 34),
      ),
    );
  }
}
