import 'package:flutter/material.dart';

import '../core/app_language.dart';
import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../widgets/agro_gradient.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final strings = AppStrings(scope.language);
    return Scaffold(
      body: AgroGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Text(
                        strings.offlineGuide,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Hero(
                  tag: 'app-logo',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 28,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/images/agrovision_logo.png',
                        height: 160,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  strings.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.tagLine,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: _HeroStat(value: '224', label: 'AI input'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _HeroStat(value: '2', label: 'Languages'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _HeroStat(value: 'Offline', label: 'Guide'),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strings.selectLanguage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: AppLanguage.values.map((language) {
                    final selected = scope.language == language;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: selected
                                ? Colors.white
                                : Colors.white24,
                            foregroundColor: selected
                                ? const Color(0xFF0B7A3B)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => scope.onLanguageChanged(language),
                          child: Text(
                            language.label,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B7A3B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      HomeScreen.routeName,
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      strings.continueText,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
