import 'package:flutter/material.dart';
import 'prayer_service.dart';
import 'prayer_detail_screen.dart';
import 'app_state_service.dart';
import 'responsive.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with SingleTickerProviderStateMixin {
  List prayers = [];
  bool loading = true;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    loadPrayers();
  }

  Future<void> loadPrayers() async {
    final data = await PrayerService.loadPrayers();

    setState(() {
      prayers = data;
      loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scale = Responsive.scale(context);

    final dayNumber =
        DateTime.now().difference(DateTime(2025, 1, 1)).inDays;

    final morningPrayers = prayers
        .where((p) => p['category'] == 'morning')
        .toList();

    final eveningPrayers = prayers
        .where((p) => p['category'] == 'evening')
        .toList();

    final todayMorningPrayer = morningPrayers.isNotEmpty
        ? morningPrayers[dayNumber % morningPrayers.length]
        : null;

    final todayEveningPrayer = eveningPrayers.isNotEmpty
        ? eveningPrayers[dayNumber % eveningPrayers.length]
        : null;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/prayer_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),


          SafeArea(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15 * scale),

                  Text(
                    "Prayer Room",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // MORNING PRAYER
                  if (todayMorningPrayer != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 8 * scale,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrayerDetailScreen(
                                title: todayMorningPrayer['title'],
                                content: todayMorningPrayer['content'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 185 * scale,
                          width: double.infinity,
                          padding: EdgeInsets.all(18 * scale),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20 * scale),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFB74D),
                                Color(0xFFFF9800),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             Row(
                                children: [
                                  Icon(
                                    Icons.wb_sunny,
                                    color: Colors.white,
                                    size: 24 * scale,
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Text(
                                    "Today's Morning Prayer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12 * scale),

                              Expanded(
                                child: Text(
                                  todayMorningPrayer['content'],
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15 * scale,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10 * scale),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Read Prayer →",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14 * scale,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

            // EVENING PRAYER
                  if (todayEveningPrayer != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PrayerDetailScreen(
                                title: todayEveningPrayer['title'],
                                content: todayEveningPrayer['content'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 185 * scale,
                          width: double.infinity,
                          padding: EdgeInsets.all(18 * scale),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF3949AB),
                                Color(0xFF1A237E),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.nightlight_round,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Today's Evening Prayer",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Expanded(
                                child: Text(
                                  todayEveningPrayer['content'],
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15 * scale,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Read Prayer →",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 10 * scale),



                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}