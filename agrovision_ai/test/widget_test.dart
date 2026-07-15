import 'package:agrovision_ai/app/agrovision_app.dart';
import 'package:agrovision_ai/core/app_language.dart';
import 'package:agrovision_ai/core/language_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AgroVision app starts with splash screen', (tester) async {
    await tester.pumpWidget(const AgroVisionApp());

    expect(find.text('AgroVision AI'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  test('selected language persists across preference loads', () async {
    SharedPreferences.setMockInitialValues({});

    await LanguagePreferences.save(AppLanguage.sindhi);

    expect(await LanguagePreferences.load(), AppLanguage.sindhi);
  });

  test('language defaults to English when no preference exists', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await LanguagePreferences.load(), AppLanguage.english);
  });
}
