import 'package:flutter/material.dart';

import 'app/agrovision_app.dart';
import 'core/language_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final language = await LanguagePreferences.load();
  runApp(AgroVisionApp(initialLanguage: language));
}
