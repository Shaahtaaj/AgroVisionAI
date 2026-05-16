import 'package:flutter/material.dart';

import '../core/app_language.dart';
import '../core/app_scope.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return SegmentedButton<AppLanguage>(
      segments: AppLanguage.values
          .map(
            (language) => ButtonSegment<AppLanguage>(
              value: language,
              label: Text(language.label),
            ),
          )
          .toList(),
      selected: {scope.language},
      onSelectionChanged: (selection) =>
          scope.onLanguageChanged(selection.first),
      showSelectedIcon: false,
    );
  }
}
