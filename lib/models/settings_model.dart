class AppSettings {
  final String themeMode;
  final String pageTheme;
  final bool useMaterialYou;
  final bool requireBiometrics;
  final String language;
  final bool preventScreenshot;
  final bool useNetworkTime;
  final String ntpServer;
  final bool showOnHome;

  const AppSettings({
    required this.themeMode,
    required this.pageTheme,
    required this.useMaterialYou,
    required this.requireBiometrics,
    required this.language,
    required this.preventScreenshot,
    required this.useNetworkTime,
    required this.ntpServer,
    required this.showOnHome,
  });

  static const defaults = AppSettings(
    themeMode: 'system',
    pageTheme: 'default',
    useMaterialYou: false,
    requireBiometrics: false,
    language: 'system',
    preventScreenshot: true,
    useNetworkTime: false,
    ntpServer: 'pool.ntp.org',
    showOnHome: false,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] ?? 'system',
      pageTheme: json['pageTheme'] ?? 'default',
      useMaterialYou: json['useMaterialYou'] ?? false,
      requireBiometrics: json['requireBiometrics'] ?? false,
      language: json['language'] ?? 'system',
      preventScreenshot: json['preventScreenshot'] ?? true,
      useNetworkTime: json['useNetworkTime'] ?? false,
      ntpServer: json['ntpServer'] ?? 'pool.ntp.org',
      showOnHome: json['showOnHome'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'pageTheme': pageTheme,
      'useMaterialYou': useMaterialYou,
      'requireBiometrics': requireBiometrics,
      'language': language,
      'preventScreenshot': preventScreenshot,
      'useNetworkTime': useNetworkTime,
      'ntpServer': ntpServer,
      'showOnHome': showOnHome,
    };
  }

  AppSettings copyWith({
    String? themeMode,
    String? pageTheme,
    bool? useMaterialYou,
    bool? requireBiometrics,
    String? language,
    bool? preventScreenshot,
    bool? useNetworkTime,
    String? ntpServer,
    bool? showOnHome,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      pageTheme: pageTheme ?? this.pageTheme,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      requireBiometrics: requireBiometrics ?? this.requireBiometrics,
      language: language ?? this.language,
      preventScreenshot: preventScreenshot ?? this.preventScreenshot,
      useNetworkTime: useNetworkTime ?? this.useNetworkTime,
      ntpServer: ntpServer ?? this.ntpServer,
      showOnHome: showOnHome ?? this.showOnHome,
    );
  }
}
