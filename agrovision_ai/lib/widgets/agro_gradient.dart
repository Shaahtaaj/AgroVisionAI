import 'package:flutter/material.dart';

class AgroGradient extends StatelessWidget {
  const AgroGradient({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B7A3B), Color(0xFF42C96D)],
        ),
      ),
      child: child,
    );
  }
}
