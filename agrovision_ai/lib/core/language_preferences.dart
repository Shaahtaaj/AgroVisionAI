import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

class LanguagePreferences {
  const LanguagePreferences._();

  static const _languageKey = 'selected_language';

  static Future<AppLanguage> load() async {
    final preferences = await SharedPreferences.getInstance();
    return AppLanguage.fromCode(preferences.getString(_languageKey));
  }

  static Future<void> save(AppLanguage language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language.code);
  }
}
