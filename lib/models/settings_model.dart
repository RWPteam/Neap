class AppSettings {
  final String themeMode;
  final String pageTheme;
  final bool useMaterialYou;
  final bool requireBiometrics;

  const AppSettings({
    required this.themeMode,
    required this.pageTheme,
    required this.useMaterialYou,
    required this.requireBiometrics,
  });

  static const defaults = AppSettings(
    themeMode: 'system',
    pageTheme: 'default',
    useMaterialYou: false,
    requireBiometrics: true,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] ?? 'system',
      pageTheme: json['pageTheme'] ?? 'default',
      useMaterialYou: json['useMaterialYou'] ?? false,
      requireBiometrics: json['requireBiometrics'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'pageTheme': pageTheme,
      'useMaterialYou': useMaterialYou,
      'requireBiometrics': requireBiometrics,
    };
  }

  AppSettings copyWith({
    String? themeMode,
    String? pageTheme,
    bool? useMaterialYou,
    bool? requireBiometrics,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      pageTheme: pageTheme ?? this.pageTheme,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      requireBiometrics: requireBiometrics ?? this.requireBiometrics,
    );
  }
}
