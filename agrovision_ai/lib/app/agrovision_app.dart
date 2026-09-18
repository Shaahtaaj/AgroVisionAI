import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_fonts.dart';
import '../core/app_language.dart';
import '../core/app_scope.dart';
import '../core/app_theme.dart';
import '../core/language_preferences.dart';
import '../screens/about_screen.dart';
import '../screens/agri_terms_screen.dart';
import '../screens/disease_info_screen.dart';
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/tflite_disease_classifier.dart';

class AgroVisionApp extends StatefulWidget {
  const AgroVisionApp({this.initialLanguage = AppLanguage.english, super.key});

  final AppLanguage initialLanguage;

  @override
  State<AgroVisionApp> createState() => _AgroVisionAppState();
}

class _AgroVisionAppState extends State<AgroVisionApp> {
  late AppLanguage _language;
  final TfliteDiseaseClassifier _classifier = TfliteDiseaseClassifier();

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _changeLanguage(AppLanguage language) {
    if (_language == language) return;
    setState(() => _language = language);
    unawaited(_persistLanguage(language));
  }

  Future<void> _persistLanguage(AppLanguage language) async {
    try {
      await LanguagePreferences.save(language);
    } catch (error, stackTrace) {
      debugPrint('Could not persist app language: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      language: _language,
      onLanguageChanged: _changeLanguage,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgroVision AI',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: AppFonts.body(_language),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.sage,
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.forest,
            titleTextStyle: TextStyle(
              fontFamily: AppFonts.heading(_language),
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.forest,
            ),
          ),
          textTheme: _buildTextTheme(_language),
          cardTheme: CardThemeData(
            elevation: 0,
            color: AppColors.surface,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.forest,
              side: const BorderSide(color: AppColors.border, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          AboutScreen.routeName: (_) => const AboutScreen(),
          AgriTermsScreen.routeName: (_) => const AgriTermsScreen(),
          ScanScreen.routeName: (_) => ScanScreen(classifier: _classifier),
        },
        builder: (context, child) => Directionality(
          textDirection: _language.isSindhi
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == DiseaseInfoScreen.routeName) {
            final crop = settings.arguments! as String;
            return MaterialPageRoute(
              builder: (_) => DiseaseInfoScreen(crop: crop),
              settings: settings,
            );
          }
          if (settings.name == ResultScreen.routeName) {
            final args = settings.arguments! as ResultScreenArgs;
            return MaterialPageRoute(
              builder: (_) => ResultScreen(args: args),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }

  TextTheme _buildTextTheme(AppLanguage language) {
    final bodyFont = AppFonts.body(language);
    final headingFont = AppFonts.heading(language);

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      displayMedium: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      displaySmall: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      headlineLarge: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w800,
      ),
      titleSmall: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(fontFamily: bodyFont),
      bodyMedium: TextStyle(fontFamily: bodyFont),
      bodySmall: TextStyle(fontFamily: bodyFont),
      labelLarge: TextStyle(
        fontFamily: headingFont,
        fontWeight: FontWeight.w800,
      ),
      labelMedium: TextStyle(fontFamily: bodyFont),
      labelSmall: TextStyle(fontFamily: bodyFont),
    );
  }
}
