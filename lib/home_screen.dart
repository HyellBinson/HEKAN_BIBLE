import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hekan_bible/settings_screen.dart';
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
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'bookmark_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

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
  String imageBase64 = "";
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

  Future<void> loadProfilePhoto() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists) return;

    if (!mounted) return;

    setState(() {
      imageBase64 = doc.data()?["profileImage"] ?? "";
    });
  }

  Future<void> _shareVerse() async {
    if (todayVerse.isEmpty) return;

    final text =
        "${todayVerse["text"]}\n\n${todayVerse["book"]} ${todayVerse["chapter"]}:${todayVerse["verse"]} ($version)\n\nShared from HEKAN Bible";

    await Share.share(text);
  }

  Future<void> _copyVerse() async {
    if (todayVerse.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(
        text:
        "${todayVerse["text"]}\n\n${todayVerse["book"]} ${todayVerse["chapter"]}:${todayVerse["verse"]}",
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Verse copied to clipboard"),
      ),
    );
  }

  void _bookmarkVerse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bookmark feature coming soon"),
      ),
    );
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
    loadProfilePhoto();

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

    final scale = (screenWidth / 375).clamp(0.78, 1.1);
    final isSmall = screenWidth < 360;
    final isTiny = screenWidth < 340;

    final cardRadius = 32.0 * scale;
    final cardPadding = 24.0 * scale;
    final titleSize = 13.5 * scale;
    final verseSize = screenWidth < 360
        ? 16.0
        : screenWidth < 390
        ? 18.0
        : 20.0;
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
              padding: EdgeInsets.only(
                left: 0,
                right: 0,
                top: 0,
                bottom: 14 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header


                  // TODAY'S VERSE - Bigger Modern Card
                  SizedBox(
                    height: isTiny
                        ? 250 * scale
                        : isSmall
                        ? 280 * scale
                        : 310 * scale,
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
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32 * scale),
                            bottomRight: Radius.circular(32 * scale),
                          ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            "Welcome Back 👋",
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14 * scale,
                                            ),
                                          ),
                                          Text(
                                            widget.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth < 360 ? 24 : 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "TODAY'S VERSE",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth < 360 ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [

                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ProfileScreen(
                                                      name: widget.name,
                                                      onThemeChanged: widget.onThemeChanged,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(2.5),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.amber,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: screenWidth < 360
                                                      ? 18
                                                      : screenWidth < 400
                                                      ? 20
                                                      : 24,
                                                  backgroundImage: imageBase64.isNotEmpty
                                                      ? MemoryImage(base64Decode(imageBase64))
                                                      : null,
                                                  child: imageBase64.isEmpty
                                                      ? Icon(
                                                    Icons.person,
                                                    size: screenWidth < 360 ? 18 : 22,
                                                  )
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,

                                              ),

                                            ),

                                            SizedBox(width: 12 * scale),


                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => const SearchScreen(),
                                                  ),
                                                );
                                              },
                                              child: Icon(
                                                Icons.search_rounded,
                                                color: Colors.amber,
                                                size: 28 * scale,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10 * scale),


                                      ],
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 16),

// Scrollable verse text
                                Expanded(
                                  child: ClipRect(
                                    child: Scrollbar(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Text(
                                          todayVerse["text"],
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth < 360 ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    // Reference
                                    const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 19),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${todayVerse["book"]} ${todayVerse["chapter"]}:${todayVerse["verse"]}",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: referenceSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                   Spacer(),

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
                                            horizontal: screenWidth < 360 ? 7 * scale : 9 * scale,
                                            vertical: screenWidth < 360 ? 3 * scale : 4 * scale,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E293B),
                                            borderRadius: BorderRadius.circular(screenWidth < 360 ? 14 : 18),
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: screenWidth < 360 ? 1.2 : 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "LAST READ",
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: screenWidth < 360 ? 8 * scale : 9 * scale,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              SizedBox(height: screenWidth < 360 ? 2 * scale : 4 * scale),
                                              Text(
                                                "${continueReading["book"]} ${continueReading["chapter"]}:${continueReading["verse"]}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: screenWidth < 360 ? 10 : 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                    const Spacer(),

                                    // Share & Copy icons
                                    IconButton(
                                      icon: Icon(
                                        Icons.share,
                                        color: Colors.amber,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      onPressed: _shareVerse,          // ← connected
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    SizedBox(width: isSmall ? 3 : 9),
                                    IconButton(
                                      icon: Icon(
                                        Icons.copy,
                                        color: Colors.amber,
                                        size: isSmall ? 18 : 20,
                                      ),
                                      onPressed: _copyVerse,           // ← connected
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  ),


                  SizedBox(height: 25 * scale),



                  // Quick Access
                  Text(
                    "Quick Access",
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),


                  Flexible(
                    flex: screenWidth < 360 ? 1 : 1,
                    child: GridView.count(
                      crossAxisCount: 3,
                      physics: const BouncingScrollPhysics(),
                      crossAxisSpacing: 12 * scale,
                      mainAxisSpacing: isSmall ? 14 * scale : 18 * scale,
                      childAspectRatio: isTiny ? 1.05 : isSmall ? 1.1 : 1.0,
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

                        _tile(
                          Icons.bookmark_rounded,
                          "Bookmarks",
                          Colors.orange,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BookmarkScreen()),
                          ),
                          scale,
                        ),

                        _tile(
                          Icons.settings_rounded,
                          "Settings",
                          Colors.blueGrey,
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
    final isSmall = MediaQuery
        .of(context)
        .size
        .width < 360;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20 * scale),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20 * scale),
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
                size: isSmall ? 28 * scale : 34 * scale,
              ),
              SizedBox(height: 8 * scale),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmall ? 13 * scale : 14.5 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}