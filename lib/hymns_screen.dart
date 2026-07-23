import 'dart:ui';
import 'package:flutter/material.dart';
import 'english_hymns_screen.dart';
import 'hausa_hymns_screen.dart';
import 'favorite_hymns_screen.dart';
import 'responsive.dart';

class HymnsScreen extends StatelessWidget {
  const HymnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scale = Responsive.scale(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/hymns_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.55),
          ),

          SafeArea(
            child: SingleChildScrollView(  // ← Helps with split-screen
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                10 * scale,
                20 * scale,
                20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10 * scale),

                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "HYMNS",
                        style: TextStyle(
                          fontSize: 32 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon:Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 26 * scale,
                        ),
                        tooltip: "Favorite Hymns",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoriteHymnsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),
                  Text(
                    "Choose a language",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14 * scale,
                    ),
                  ),

                  SizedBox(height: 25 * scale),
                  SizedBox(height: 20 * scale),

                  // ENGLISH HYMNS
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EnglishHymnScreen()),
                      );
                    },
                    child: Container(
                      height: 185 * scale,                   // ← Increased slightly
                      width: double.infinity,
                      padding: EdgeInsets.all(20 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25 * scale),
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            top: 10,
                            left: 10,
                            child: Icon(Icons.music_note, color: Colors.white, size: 30),
                          ),
                         Positioned(
                            bottom: 65,
                            left: 10,
                            child: Text(
                              "English Hymns",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                         Positioned(
                            bottom: 38,
                            left: 10,
                            child: Text(
                              "View all English hymns",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                               Positioned(
                            bottom: 10,
                            left: 10,
                            child: Text(
                              "1200 Hymns",
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // HAUSA HYMNS
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HausaHymnsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 185 * scale,                      // ← Increased slightly
                      width: double.infinity,
                      padding: EdgeInsets.all(20 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25 * scale),
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Icon(
                              Icons.library_music,
                              color: Colors.white,
                              size: 30 * scale,
                            ),
                          ),
                           Positioned(
                            bottom: 65,
                            left: 10,
                            child: Text(
                              "Hausa Hymns",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Positioned(
                            bottom: 38,
                            left: 10,
                            child: Text(
                              "Duba dukkan wakokin Hausa",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14 * scale,
                              ),
                            ),
                          ),
                           Positioned(
                            bottom: 10,
                            left: 10,
                            child: Text(
                              "350 Hymns",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13 * scale,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}