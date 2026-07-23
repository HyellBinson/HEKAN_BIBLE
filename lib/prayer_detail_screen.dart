import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'app_state_service.dart';

class PrayerDetailScreen extends StatefulWidget {
  final String title;
  final String content;

  const PrayerDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen>
    with SingleTickerProviderStateMixin {
  double fontSize = 18;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    AppStateService.savePrayer(
      title: widget.title,
      content: widget.content,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void increaseFont() {
    setState(() {
      if (fontSize < 30) fontSize++;
    });
  }

  void decreaseFont() {
    setState(() {
      if (fontSize > 12) fontSize--;
    });
  }

  void resetFont() {
    setState(() {
      fontSize = 18;
    });
  }

  void sharePrayer() {
    Share.share("${widget.title}\n\n${widget.content}");
  }

  @override
  Widget build(BuildContext context) {
    final isMorning =
    widget.title.toLowerCase().contains("morning");

    final backgroundImage = isMorning
        ? "assets/images/morning_prayer.jpg"
        : "assets/images/evening_prayer.jpg";

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // Animated Light Effect
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: 80 + (_controller.value * 30),
                right: 40,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    isMorning
                        ? Icons.wb_sunny
                        : Icons.nightlight_round,
                    size: 140,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.white,
                  title: Text(widget.title),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: decreaseFont,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: increaseFont,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: resetFont,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: sharePrayer,
                    ),
                  ],
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isMorning
                                  ? Icons.wb_sunny
                                  : Icons.nightlight_round,
                              color: Colors.white,
                              size: 60,
                            ),

                            const SizedBox(height: 20),

                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 25),

                            AnimatedDefaultTextStyle(
                              duration:
                              const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: fontSize,
                                height: 1.9,
                                color: Colors.white,
                              ),
                              child: Text(
                                widget.content,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}