import 'package:flutter/material.dart';

import '../core/app_language.dart';
import '../core/app_scope.dart';
import '../screens/about_screen.dart';
import '../screens/disease_info_screen.dart';
import '../screens/home_screen.dart';
import '../screens/result_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/tflite_disease_classifier.dart';

class AgroVisionApp extends StatefulWidget {
  const AgroVisionApp({super.key});

  @override
  State<AgroVisionApp> createState() => _AgroVisionAppState();
}

class _AgroVisionAppState extends State<AgroVisionApp> {
  AppLanguage _language = AppLanguage.english;
  final TfliteDiseaseClassifier _classifier = TfliteDiseaseClassifier();

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      language: _language,
      onLanguageChanged: (language) => setState(() => _language = language),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgroVision AI',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: _language.isSindhi ? 'Lateefi' : 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF159957),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5FAF4),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF153B2D),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          AboutScreen.routeName: (_) => const AboutScreen(),
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
}
