import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:local_auth/local_auth.dart';
import 'package:screen_protector/screen_protector.dart';

import 'pages/home.dart';
import 'models/settings_model.dart';
import 'services/setting_service.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SettingsService _settingsService = SettingsService();
  AppSettings _currentSettings = AppSettings.defaults;
  bool _isLoading = true;

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  DateTime? _backgroundTimestamp;
  final Duration _gracePeriod = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSecuritySettings();
    loadSettings().then((_) => _authenticate());
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool requireAuth = _currentSettings.requireBiometrics;
    if (!requireAuth) return;

    if (state == AppLifecycleState.resumed) {
      if (_backgroundTimestamp != null) {
        final durationAway = DateTime.now().difference(_backgroundTimestamp!);
        if (durationAway > _gracePeriod) {
          setState(() {
            _isAuthenticated = false;
          });
          _authenticate();
        } else {
          debugPrint('在宽限期内返回，跳过验证');
        }
      }
      _backgroundTimestamp = null;
    } else if (state == AppLifecycleState.paused) {
      _backgroundTimestamp = DateTime.now();
    }
  }

  Future<void> _authenticate() async {
    final bool requireAuth = _currentSettings.requireBiometrics;

    if (!requireAuth) {
      setState(() => _isAuthenticated = true);
      return;
    }

    if (_isAuthenticated || _isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() => _isAuthenticated = true);
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: '请验证指纹以解锁 Neap',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      setState(() {
        _isAuthenticated = didAuthenticate;
      });
    } catch (e) {
      debugPrint('认证错误: $e');
      setState(() => _isAuthenticated = false);
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> loadSettings() async {
    final settings = await _settingsService.getSettings();
    setState(() {
      _currentSettings = settings;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    const localizationsDelegates = [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    const supportedLocales = [Locale('zh', 'CH'), Locale('en', 'US')];

    if (_isLoading) {
      return const MaterialApp(
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Neap',
          localizationsDelegates: localizationsDelegates,
          supportedLocales: supportedLocales,
          themeMode: _getThemeMode(),
          theme: _buildTheme(
            brightness: Brightness.light,
            dynamicScheme: lightDynamic,
          ),
          darkTheme: _buildTheme(
            brightness: Brightness.dark,
            dynamicScheme: darkDynamic,
          ),
          navigatorObservers: [routeObserver],
          home: _isAuthenticated ? const HomePage() : _buildLockScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildLockScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 72, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              '应用已锁定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text('点击解锁'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    ColorScheme? dynamicScheme,
  }) {
    final bool useMaterialYou = _currentSettings.useMaterialYou;
    final String pageTheme = _currentSettings.pageTheme;

    final Map<String, Color> themeColors = {
      'default': Colors.blue,
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

    if (useMaterialYou && dynamicScheme != null) {
      colorScheme = dynamicScheme;
    } else if (pageTheme == 'monochrome') {
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
      fontFamily: 'hmossans',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}
