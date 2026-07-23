import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_screen.dart';

import 'settings_service.dart';
import 'login_screen.dart';
import 'notification_service.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  runApp(const HekanApp());
}

class HekanApp extends StatefulWidget {
  const HekanApp({super.key});

  @override
  State<HekanApp> createState() => _HekanAppState();
}

class _HekanAppState extends State<HekanApp> {
  bool isDark = false;

  bool loading = true;

  Future<void> _loadApp() async {
    final savedTheme =
    await SettingsService.getDarkMode();



    if (mounted) {
      setState(() {
        isDark = savedTheme;

        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadApp();
    _requestPermissions();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await SettingsService.getDarkMode();

    if (mounted) {
      setState(() {
        isDark = savedTheme;
      });
    }
  }

  void updateTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  Future<void> _requestPermissions() async {
    // Notification Permission
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'HEKAN Bible',

      theme: ThemeData.light(),

      darkTheme: ThemeData.dark(),

      themeMode: isDark
          ? ThemeMode.dark
          : ThemeMode.light,

      home: SplashScreen(
        onThemeChanged: updateTheme,
      ),
    );
  }
}