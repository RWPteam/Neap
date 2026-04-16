import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:neap/services/time_service.dart';
import 'package:screen_protector/screen_protector.dart';

import 'pages/home.dart';
import 'models/settings_model.dart';
import 'services/setting_service.dart';
import 'l10n/app_localizations.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  // ignore: library_private_types_in_public_api
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SettingsService _settingsService = SettingsService();
  AppSettings _currentSettings = AppSettings.defaults;
  bool _isLoading = true;

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  DateTime? _backgroundTimestamp;
  final Duration _gracePeriod = const Duration(seconds: 5);

  final TimeService _timeService = TimeService();

  static bool shouldSkipAuthentication = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSecuritySettings();
    _initTimeService();
    loadSettings().then(
      (_) => {
        _applyScreenshotProtection(_currentSettings.preventScreenshot),
        _authenticate(),
      },
    );
  }

  Future<void> _initTimeService() async {
    await _timeService.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ScreenProtector.preventScreenshotOff();
    super.dispose();
  }

  Future<void> _initSecuritySettings() async {
    await ScreenProtector.preventScreenshotOn();
    await ScreenProtector.protectDataLeakageWithBlur();
  }

  Future<void> _applyScreenshotProtection(bool enable) async {
    if (enable) {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageWithBlur();
    } else {
      await ScreenProtector.preventScreenshotOff();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool requireAuth = _currentSettings.requireBiometrics;
    if (!requireAuth) return;

    if (state == AppLifecycleState.resumed) {
      if (shouldSkipAuthentication) {
        debugPrint('调用内部模块，跳过验证');
        shouldSkipAuthentication = false;
        setState(() => _isAuthenticated = true);
        _backgroundTimestamp = null;
        return;
      }
      if (_backgroundTimestamp != null) {
        final durationAway = DateTime.now().difference(_backgroundTimestamp!);
        if (durationAway > _gracePeriod) {
          setState(() => _isAuthenticated = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _authenticate();
          });
        } else {
          debugPrint('在宽限期内返回，跳过验证');
        }
      }
      _backgroundTimestamp = null;
    } else if (state == AppLifecycleState.paused) {
      _backgroundTimestamp = DateTime.now();
    }
  }

  Widget _buildLockScreen(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                t.appLocked,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.fingerprint),
                label: Text(t.unlock),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme({required Brightness brightness}) {
    final String pageTheme = _currentSettings.pageTheme;

    final Map<String, Color> themeColors = {
      'default': Colors.blueAccent,
      'orange': Colors.orange,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'red': Colors.red,
      'pink': Colors.pink,
      'purple': Colors.purple,
      'cyan': Colors.cyan,
      'indigo': Colors.indigo,
      'monochrome': brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    };

    ColorScheme colorScheme;

    if (pageTheme == 'monochrome') {
      if (brightness == Brightness.dark) {
        colorScheme = const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.grey,
          surface: Color(0xFF121212),
        );
      } else {
        colorScheme = const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          surface: Color(0xFFF5F5F5),
        );
      }
    } else {
      final seed = themeColors[pageTheme] ?? Colors.blue;
      colorScheme = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      );
    }

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  Future<void> _authenticate() async {
    final bool requireAuth = _currentSettings.requireBiometrics;

    if (!requireAuth) {
      setState(() => _isAuthenticated = true);
      return;
    }

    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    String localizedReason = 'Please authenticate to unlock Neap';
    try {
      Locale currentLocale;
      switch (_currentSettings.language) {
        case 'zh':
          currentLocale = const Locale('zh', 'CN');
          break;
        case 'ja':
          currentLocale = const Locale('ja', 'JP');
          break;
        case 'en':
          currentLocale = const Locale('en', 'US');
          break;
        default:
          currentLocale = const Locale('en', 'US');
      }
      final appLocalizations = await const AppLocalizationsDelegate().load(
        currentLocale,
      );
      localizedReason = appLocalizations.biometricReason;
    } catch (e) {
      debugPrint('加载本地化文本失败: $e');
    }

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() => _isAuthenticated = true);
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate) {
        setState(() => _isAuthenticated = true);
      } else {
        final newSettings = _currentSettings.copyWith(requireBiometrics: false);
        await _settingsService.saveSettings(newSettings);
        setState(() {
          _currentSettings = newSettings;
          _isAuthenticated = true;
        });
      }
    } catch (e) {
      debugPrint('认证错误: $e');
      setState(() => _isAuthenticated = false);
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> loadSettings() async {
    final oldSettings = _currentSettings;
    final settings = await _settingsService.getSettings();
    setState(() {
      _currentSettings = settings;
      _isLoading = false;
    });

    await _timeService.updateSettings(settings);

    if (oldSettings.preventScreenshot != settings.preventScreenshot) {
      await _applyScreenshotProtection(settings.preventScreenshot);
    }
    if (oldSettings.requireBiometrics != settings.requireBiometrics) {
      if (!settings.requireBiometrics) {
        setState(() => _isAuthenticated = true);
      } else {
        setState(() => _isAuthenticated = false);
        _authenticate();
      }
    }
    if (oldSettings.language != settings.language) {
      setState(() {});
    }
  }

  ThemeMode _getThemeMode() {
    switch (_currentSettings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale? _getLocale() {
    switch (_currentSettings.language) {
      case 'zh':
        return const Locale('zh', 'CN');
      case 'en':
        return const Locale('en', 'US');
      case 'ja':
        return const Locale('ja', 'JP');
      case 'system':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<LocalizationsDelegate> localizationsDelegates = [
      const AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    const supportedLocales = [
      Locale('zh', 'CH'),
      Locale('en', 'US'),
      Locale('ja', 'JP'),
    ];

    if (_isLoading) {
      return MaterialApp(
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Neap',
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: _getLocale(),
      navigatorKey: navigatorKey,
      themeMode: _getThemeMode(),
      theme: _buildTheme(brightness: Brightness.light),
      darkTheme: _buildTheme(brightness: Brightness.dark),
      navigatorObservers: [routeObserver],
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (_currentSettings.requireBiometrics && !_isAuthenticated)
              _buildLockScreen(context),
          ],
        );
      },
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
