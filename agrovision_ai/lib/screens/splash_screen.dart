import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../data/disease_repository.dart';
import '../widgets/agro_gradient.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.wait([
      DiseaseRepository.instance.getDiseases(),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (!mounted) return;
    unawaited(Navigator.pushReplacementNamed(context, WelcomeScreen.routeName));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(AppScope.of(context).language);
    return Scaffold(
      body: AgroGradient(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    'assets/images/agrovision_logo.png',
                    width: 180,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  strings.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.tagLine,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
