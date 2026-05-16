enum AppLanguage {
  english('en', 'English'),
  sindhi('sd', 'سنڌي');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  bool get isSindhi => this == AppLanguage.sindhi;
}
