import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary & Brand Colors
  static const Color primary = Color(0xFF159957);
  static const Color primaryDark = Color(0xFF0B6A3C);
  static const Color forest = Color(0xFF073022);
  static const Color mint = Color(0xFFEAF8D8);
  static const Color mintLight = Color(0xFFF1FBEA);
  static const Color sage = Color(0xFFF4F8F4);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF132E22);
  static const Color textMedium = Color(0xFF5B7367);
  static const Color textLight = Color(0xFF8BA296);

  // Status & Severity Accents
  static const Color statusReliable = Color(0xFF159957);
  static const Color statusPossible = Color(0xFFE68A00);
  static const Color statusUncertain = Color(0xFFC2410C);
  static const Color statusDanger = Color(0xFFDC2626);

  // Borders & Dividers
  static const Color border = Color(0xFFDDECE0);
  static const Color borderLight = Color(0xFFEEF5EF);

  // Shadows
  static const List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: Color(0x0F073022),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x08073022),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x24159957),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];
}

class AppDecorations {
  const AppDecorations._();

  static BoxDecoration card({
    Color color = AppColors.surface,
    Color borderColor = AppColors.border,
    double borderRadius = 16,
    List<BoxShadow> shadows = AppColors.softCardShadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor),
      boxShadow: shadows,
    );
  }

  static BoxDecoration heroGradient({
    double borderRadius = 20,
    List<Color> colors = const [AppColors.forest, AppColors.primary],
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      boxShadow: AppColors.elevatedShadow,
    );
  }
}

