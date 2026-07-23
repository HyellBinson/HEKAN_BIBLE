import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_state_service.dart';
import 'prayer_detail_screen.dart';
import 'notification_service.dart';

class SplashScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SplashScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool isDark = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final savedTheme = await SettingsService.getDarkMode();

    widget.onThemeChanged(savedTheme);

    if (mounted) {
      setState(() {
        isDark = savedTheme;
      });
    }

    // Get current user
    // Get cached Firebase user (works offline)
    final User? user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // ==============================
    // Not logged in
    // ==============================
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
      return;
    }

    // ==============================
    // Email not verified
    // ==============================
    if (!user.emailVerified) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
      return;
    }

    // User is guaranteed to be non-null below
    final currentUser = user!;

    // ==============================
    // Open from Notification
    // ==============================
    if (NotificationService.pendingPayload != null) {
      final payload = NotificationService.pendingPayload!;
      NotificationService.pendingPayload = null;

      final parts = payload.split("|");

      // Bible notification
      if (parts[0] == "verse") {
        final bible = await AppStateService.getBible();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              name: currentUser.displayName ?? "User",
              onThemeChanged: widget.onThemeChanged,
              resumeBible: true,
              resumeBook: parts[1],
              resumeChapter: int.parse(parts[2]),
              resumeVerse: int.parse(parts[3]),
              resumeVersion: bible["version"],
            ),
          ),
        );
        return;
      }

      // Prayer notification
      if (parts[0] == "prayer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PrayerDetailScreen(
              title: parts[1],
              content: parts.sublist(2).join("|"),
            ),
          ),
        );
        return;
      }
    }

    // ==============================
    // Resume Last Screen
    // ==============================
    final lastScreen = await AppStateService.getLastScreen();

    if (lastScreen == "bible") {
      final bible = await AppStateService.getBible();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: currentUser.displayName ?? "User",
            onThemeChanged: widget.onThemeChanged,
            resumeBible: true,
            resumeBook: bible["book"],
            resumeChapter: bible["chapter"],
            resumeVerse: bible["verse"],
            resumeVersion: bible["version"],
          ),
        ),
      );
    } else if (lastScreen == "hymn") {
      final hymn = await AppStateService.getHymn();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: currentUser.displayName ?? "User",
            onThemeChanged: widget.onThemeChanged,
            resumeHymn: true,
            resumeHymnNumber: hymn["number"],
            resumeHymnTitle: hymn["title"],
            resumeHymnLyrics: hymn["lyrics"],
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: currentUser.displayName ?? "User",
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            /// CENTER
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Image.asset(
                        "assets/icon/app_icon.png",
                        width: 140,
                        height: 140,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "HEKAN BIBLE",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// BOTTOM TEXT
            Positioned(
              bottom: 35,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Hyell Platform",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white70
                        : Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}