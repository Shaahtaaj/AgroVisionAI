import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../core/app_strings.dart';
import '../widgets/language_switcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.about,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: const [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF113B2E), Color(0xFF159957)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26159957),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 154,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/developer_shah_taj.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.developerName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.developerRole,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      strings.finalYearProject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco, color: Color(0xFF159957)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.vision,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.aboutBody,
                    textAlign: language.isSindhi
                        ? TextAlign.right
                        : TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: language.isSindhi ? 1.75 : 1.45,
                      fontSize: language.isSindhi ? 22 : 16,
                      color: const Color(0xFF263D33),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
