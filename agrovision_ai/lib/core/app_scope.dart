import 'package:flutter/material.dart';

import 'app_language.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    required this.language,
    required this.onLanguageChanged,
    required super.child,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.language != language;
}
