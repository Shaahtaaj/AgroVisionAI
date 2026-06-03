import 'package:flutter/material.dart';

import '../core/app_language.dart';
import '../core/app_scope.dart';
import '../core/app_strings.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final strings = AppStrings(scope.language);
    return SegmentedButton<AppLanguage>(
      segments: AppLanguage.values
          .map(
            (language) => ButtonSegment<AppLanguage>(
              value: language,
              label: Text(strings.languageName(language)),
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
