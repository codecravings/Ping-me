import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pingme/l10n/app_localizations.dart';
import 'package:pingme/providers/reminder_provider.dart';
import 'package:pingme/providers/settings_provider.dart';
import 'package:pingme/screens/home_screen.dart';
import 'package:pingme/screens/permission_screen.dart';
import 'package:pingme/services/permission_service.dart';
import 'package:pingme/services/background_service.dart';
import 'package:pingme/theme/app_theme.dart';
import 'package:pingme/widgets/overlay_reminder.dart';

// Entry point for main app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize background services
  await BackgroundServiceHelper.initialize();

  runApp(const PingMeApp());
}

// Entry point for overlay window (called when overlay is displayed)
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayReminderWidget(),
    ),
  );
}

class PingMeApp extends StatelessWidget {
  const PingMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider()..init(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'PingMe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('mr'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppStartupScreen(),
          );
        },
      ),
    );
  }
}

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  final PermissionService _permissionService = PermissionService();
  bool _isLoading = true;
  bool _hasOverlayPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await _permissionService.isOverlayPermissionGranted();

    if (mounted) {
      setState(() {
        _hasOverlayPermission = hasPermission;
        _isLoading = false;
      });
    }
  }

  void _onPermissionGranted() {
    setState(() {
      _hasOverlayPermission = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasOverlayPermission) {
      return PermissionScreen(
        onPermissionGranted: _onPermissionGranted,
      );
    }

    return const HomeScreen();
  }
}
