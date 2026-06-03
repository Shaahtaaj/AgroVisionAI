import 'package:flutter/material.dart';

import '../core/agri_terms.dart';
import '../core/app_scope.dart';
import '../core/app_strings.dart';

class AgriTermsScreen extends StatelessWidget {
  const AgriTermsScreen({super.key});

  static const routeName = '/agri-terms';

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    final strings = AppStrings(language);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.agriWords,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            strings.agriWordsSubtitle,
            style: const TextStyle(color: Color(0xFF60756B), height: 1.4),
          ),
          const SizedBox(height: 14),
          ...AgriTerms.all.map((term) => _TermCard(term: term)),
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term});

  final AgriTerm term;

  @override
  Widget build(BuildContext context) {
    final language = AppScope.of(context).language;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFF159957)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    term.title(language),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(term.subtitle(language), style: const TextStyle(height: 1.4)),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8D8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Text(
                  term.categorySd,
                  style: const TextStyle(
                    color: Color(0xFF0B7A3B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
