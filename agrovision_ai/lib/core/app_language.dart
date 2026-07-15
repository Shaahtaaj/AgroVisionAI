enum AppLanguage {
  english('en', 'English'),
  sindhi('sd', 'سنڌي');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  bool get isSindhi => this == AppLanguage.sindhi;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}
