import 'app_language.dart';

class AppFonts {
  const AppFonts._();

  static const String sarangSattar = 'MBSarangSattar';
  static const String lateefiBold = 'MBLateefiBold';

  /// Default/body font family (MB Sarang Sattar for Sindhi, Roboto for English).
  static String body(AppLanguage language) =>
      language.isSindhi ? sarangSattar : 'Roboto';

  /// Heading and highlighted text font family (MB Lateefi Bold for Sindhi, Roboto for English).
  static String heading(AppLanguage language) =>
      language.isSindhi ? lateefiBold : 'Roboto';
}

