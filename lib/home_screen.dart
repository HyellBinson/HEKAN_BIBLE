import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'bible_screen.dart';
import 'search_screen.dart';
import 'prayer_screen.dart';
import 'profile_screen.dart';
import 'hymns_screen.dart';
import 'verse_screen.dart';
import 'app_state_service.dart';
import 'hymn_detail_screen.dart';
import 'bible_service.dart';
import 'settings_service.dart';
import 'notes_screen.dart';
import 'dart:math';
import 'responsive.dart';
import 'update_service.dart';

class HomeScreen extends StatefulWidget {

  final String name;
  final Function(bool)? onThemeChanged;

  // Resume Bible
  final bool resumeBible;
  final String? resumeBook;
  final int? resumeChapter;
  final int? resumeVerse;
  final String? resumeVersion;

  //resume hymn
  final bool resumeHymn;
  final int? resumeHymnNumber;
  final String? resumeHymnTitle;
  final String? resumeHymnLyrics;

  const HomeScreen({
    super.key,
    required this.name,
    this.onThemeChanged,

    this.resumeBible = false,
    this.resumeBook,
    this.resumeChapter,
    this.resumeVerse,
    this.resumeVersion,

    //resume hymn
    this.resumeHymn = false,
    this.resumeHymnNumber,
    this.resumeHymnTitle,
    this.resumeHymnLyrics,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _colorTimer;

  // Today's verse
  Map<String, dynamic> todayVerse = {};
  Map<String, dynamic> continueReading = {};

// Current Bible version
  String version = "KJV";

// Beautiful gradients
  final List<List<Color>> verseGradients = [
    [const Color(0xFF2563EB), const Color(0xFF1E3A8A)],
    [const Color(0xFF7C3AED), const Color(0xFF4C1D95)],
    [const Color(0xFF059669), const Color(0xFF065F46)],
    [const Color(0xFFEA580C), const Color(0xFF9A3412)],
    [const Color(0xFFDB2777), const Color(0xFF831843)],
    [const Color(0xFF0891B2), const Color(0xFF164E63)],
  ];

  late List<Color> todayGradient;
  int currentIndex = 0;
  final Random _random = Random();

  Future<void> loadLastScreen() async {

    final screen =
    await AppStateService.getLastScreen();

    if (!mounted) return;

    setState(() {

      switch (screen) {

        case "home":
          currentIndex = 0;
          break;

        case "bible":
          currentIndex = 1;
          break;

        case "hymns":
          currentIndex = 2;
          break;

        case "prayer":
          currentIndex = 3;
          break;

        case "profile":
          currentIndex = 4;
          break;
      }

    });

  }
  final List<List<Color>> gradients = [
    [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)], // Blue
    [const Color(0xFF166534), const Color(0xFF22C55E)], // Green
    [const Color(0xFF6B21A8), const Color(0xFFA855F7)], // Purple
    [const Color(0xFF9A3412), const Color(0xFFFB923C)], // Orange
    [const Color(0xFF991B1B), const Color(0xFFEF4444)], // Red
    [const Color(0xFF155E75), const Color(0xFF06B6D4)], // Cyan
    [const Color(0xFF365314), const Color(0xFF84CC16)], // Lime
  ];


  Future<void> loadTodaysVerse() async {
    try {
      version = await SettingsService.getBibleVersion();

      final daily = await BibleService.getTodaysVerses(version);

      final verses = daily["verses"] as List<Map<String, dynamic>>;

      if (verses.isEmpty) return;

      setState(() {
        todayVerse = verses.first;

        // Use the gradient defined in daily_verses.json
        todayGradient = verseGradients[
        _random.nextInt(verseGradients.length)
        ];
      });
    } catch (e) {
      debugPrint("Failed to load today's verse: $e");
    }
  }

  Future<void> loadContinueReading() async {
    final bible = await AppStateService.getBible();

    if (!mounted) return;

    setState(() {
      continueReading = bible;
    });
  }


  Future<void> checkForUpdates() async {
    final info = await UpdateService.checkForUpdate();

    if (info == null) return;

    final current = info["currentVersion"];
    final latest = info["latestVersion"];

    if (current != latest) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: !info["forceUpdate"],
        builder: (_) {
          return AlertDialog(
            title: const Text("Update Available"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "A new version ($latest) of HEKAN Bible is available.\n"),
                Text(info["whatsNew"]),
              ],
            ),

            actions: [
              if (!info["forceUpdate"])
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Later"),
                ),

              ElevatedButton(
                onPressed: () async {
                  await UpdateService.openDownload(
                    info["downloadUrl"],
                  );
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      );
    }
  }


  Future<void> refreshHome() async {
    await loadContinueReading();
    await loadTodaysVerse();

    if (mounted) {
      setState(() {});
    }
  }



  late Timer timer;

  @override
  void initState() {
    super.initState();
    loadLastScreen();

    loadTodaysVerse();
    loadContinueReading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdates();

      if (widget.resumeBible) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerseScreen(
              book: widget.resumeBook!,
              chapter: widget.resumeChapter!,
              targetVerse: widget.resumeVerse,
              initialVersion: widget.resumeVersion,
            ),
          ),
        );

      }




      VerseScreen(
        book: widget.resumeBook!,
        chapter: widget.resumeChapter!,
        targetVerse: widget.resumeVerse,
        initialVersion: widget.resumeVersion,
      );

      //remember hymn
      if (widget.resumeHymn) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HymnDetailScreen(
              number: widget.resumeHymnNumber!,
              title: widget.resumeHymnTitle!,
              lyrics: widget.resumeHymnLyrics!,
            ),
          ),
        );

      }

    });


  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _dashboard(),
      BibleScreen(),
      const HymnsScreen(),
      const PrayerScreen(),
      ProfileScreen(
        name: widget.name,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
    final scale = Responsive.scale(context);

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) async {

          if (index == 0) {
            await loadContinueReading();
            await loadTodaysVerse();
          }

          setState(() {
            currentIndex = index;
          });

          switch (index) {
            case 0:
              await AppStateService.saveLastScreen("home");
              break;

            case 1:
              await AppStateService.saveLastScreen("bible");
              break;

            case 2:
              await AppStateService.saveLastScreen("hymns");
              break;

            case 3:
              await AppStateService.saveLastScreen("prayer");
              break;

            case 4:
              await AppStateService.saveLastScreen("profile");
              break;
          }
        },
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: "Bible",
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: "Hymns",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: "Prayer",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  /// 🔥 MODERN DASHBOARD
  Widget _dashboard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final screenWidth = MediaQuery.of(context).size.width;

    final scale = screenWidth < 360
        ? 0.85
        : screenWidth < 390
        ? 0.92
        : 1.0;

    final cardRadius = 32.0 * scale;
    final cardPadding = 24.0 * scale;
    final titleSize = 13.5 * scale;
    final verseSize = 20.5 * scale;
    final referenceSize = 15.5 * scale;
    final iconSize = 19.0 * scale;
    final badgePaddingH = 14.0 * scale;
    final badgePaddingV = 7.0 * scale;

    final bgColor = isDark ? const Color(0xFF0A0F1C) : const Color(0xFFF8FAFC);

    if (todayVerse.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                14 * scale,
                16 * scale,
                14 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back, ${widget.name} 👋",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "HEKAN",
                              style: TextStyle(
                                fontSize: 32 * scale,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                          ),
                          child: const Icon(Icons.search_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20 * scale),

                  // TODAY'S VERSE - Bigger Modern Card
                  Expanded(
                    flex: screenWidth < 360 ? 4 : 3,// Bigger card
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerseScreen(
                              book: todayVerse["book"],
                              chapter: todayVerse["chapter"],
                              targetVerse: todayVerse["verse"],
                              initialVersion: version,
                            ),
                          ),
                        );

                        await refreshHome();
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32 * scale),
                          gradient: LinearGradient(
                            colors: todayGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: todayGradient.first.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(cardRadius),
                          child: Container(
                            padding: EdgeInsets.all(cardPadding),
                            color: Colors.white.withOpacity(0.09),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [

                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: badgePaddingH,
                                        vertical: badgePaddingV,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.20),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: Text(
                                        "TODAY'S VERSE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: titleSize,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),


                                    const Spacer(),

                                    if (continueReading.isNotEmpty)
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VerseScreen(
                                                book: continueReading["book"],
                                                chapter: continueReading["chapter"],
                                                targetVerse: continueReading["verse"],
                                                initialVersion: continueReading["version"],
                                              ),
                                            ),
                                          );

                                          await refreshHome();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10 * scale,
                                            vertical: 6 * scale,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E293B),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                               Text(
                                                "LAST READ",
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 8 * scale,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "📖 ${continueReading["book"]} ${continueReading["chapter"]}:${continueReading["verse"]}",
                                                style:  TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10 * scale,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),


                                    const Spacer(),

                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white70,
                                      size: iconSize,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

// Scrollable verse text
                                Flexible(
                                  child: ClipRect(
                                    child: Scrollbar(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Text(
                                          todayVerse["text"],
                                          textAlign: TextAlign.justify,
                                          style:  TextStyle(
                                            color: Colors.white,
                                            fontSize: verseSize,
                                            fontWeight: FontWeight.w600,
                                            height: 1.55,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 19),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${todayVerse["book"]} ${todayVerse["chapter"]}:${todayVerse["verse"]}",
                                      style:  TextStyle(
                                        color: Colors.white70,
                                        fontSize: referenceSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    const SizedBox(width: 8),



                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16 * scale),

                  // Quick Access
                  const Text(
                    "Quick Access",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Flexible(
                    flex: screenWidth < 360 ? 3 : 4,
                    child: GridView.count(
                      crossAxisCount: isLandscape ? 4 : 2,
                      physics: const BouncingScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: screenWidth < 360 ? 1.35 : 1.15,
                      children: [
                        _tile(
                          Icons.menu_book_rounded,
                          "Bible",
                          Colors.green,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BibleScreen()),
                          ),
                          scale,
                        ),
                        _tile(
                          Icons.music_note_rounded,
                          "Hymns",
                          Colors.deepOrange,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HymnsScreen()),
                          ),
                          scale,
                        ),

                        _tile(
                          Icons.favorite_rounded,
                          "Prayer",
                          Colors.redAccent,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PrayerScreen()),
                          ),
                          scale,
                        ),

                        _tile(
                          Icons.edit_note_rounded,
                          "Notes",
                          Colors.blueAccent,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotesScreen()),
                          ),
                          scale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }





  Widget _tile(
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap,
      double scale,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28 * scale),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28 * scale),
            border: Border.all(
              color: color.withOpacity(0.25),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 36 * scale,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}