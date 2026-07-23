import 'package:flutter/material.dart';
import 'verse_screen.dart';
import 'bookmark_screen.dart';
import 'app_state_service.dart';
import 'responsive.dart';

class ChapterScreen extends StatefulWidget {
  final String book;
  final int chapterCount;
  const ChapterScreen({
    super.key,
    required this.book,
    required this.chapterCount,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen>
    with TickerProviderStateMixin {

  late AnimationController _colorController;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final scale = Responsive.scale(context);


    return Scaffold(

      backgroundColor:
      isDark
          ? const Color(0xFF0B1220)
          : const Color(0xFFF5F7FB),

      appBar: AppBar(

        title: Text(
          widget.book,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22 * scale,
          ),
        ),

        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
        isDark ? Colors.white : Colors.black87,

        actions: [

          IconButton(

            icon: const Icon(Icons.bookmark_rounded),

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookmarkScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),

        child: GridView.builder(

          physics: const BouncingScrollPhysics(),

          padding: EdgeInsets.only(
            top: 24 * scale,
            bottom: 40 * scale,
          ),

          itemCount: widget.chapterCount,

          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isTablet(context) ? 6 : 4,
            crossAxisSpacing: 16 * scale,
            mainAxisSpacing: 16 * scale,
            childAspectRatio: 1.0,
          ),

          itemBuilder: (context, index) {

            final chapter = index + 1;

            return TweenAnimationBuilder<double>(

              tween: Tween(begin: 0.0, end: 1.0),

              duration: Duration(
                milliseconds: 400 + (index % 20) * 25,
              ),

              curve: Curves.easeOutCubic,

              builder: (context, value, child) {

                return Transform.scale(

                  scale: 0.85 + (0.15 * value),

                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },

              child: _AnimatedColorChapterCard(
                scale: scale,
                chapter: chapter,
                colorAnimation: _colorController,
                onTap: () async {

                  await AppStateService.saveBible(
                    version: "KJV",
                    book: widget.book,
                    chapter: chapter,
                    verse: 1,
                    scroll: 0,
                  );

                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration:
                      const Duration(milliseconds: 450),

                      pageBuilder: (_, __, ___) => VerseScreen(
                        book: widget.book,
                        chapter: chapter,
                      ),

                      transitionsBuilder:
                          (_, animation, __, child) {

                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedColorChapterCard extends StatefulWidget {
  final int chapter;
  final Animation<double> colorAnimation;
  final VoidCallback onTap;
  final double scale;

  const _AnimatedColorChapterCard({
    super.key,
    required this.chapter,
    required this.colorAnimation,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_AnimatedColorChapterCard> createState() =>
      _AnimatedColorChapterCardState();
}

class _AnimatedColorChapterCardState
    extends State<_AnimatedColorChapterCard> {

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(

      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),

      onTap: widget.onTap,

      child: AnimatedScale(

        scale: _isPressed ? 0.92 : 1.0,

        duration: const Duration(milliseconds: 150),

        child: AnimatedBuilder(

          animation: widget.colorAnimation,

          builder: (context, child) {

            final colors = _getAnimatedGradientColors(
              widget.colorAnimation.value,
              isDark,
            );

            return Container(

              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(24 * widget.scale),

                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),

                border: Border.all(
                  color: Colors.white.withOpacity(
                    isDark ? 0.1 : 0.15,
                  ),
                  width: 1.1,
                ),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),

                  BoxShadow(
                    color: colors[1].withOpacity(0.25),
                    blurRadius: 30,
                    spreadRadius: -10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: ClipRRect(

                borderRadius: BorderRadius.circular(24 * widget.scale),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: widget.colorAnimation,
                        builder: (context, _) {

                          return FractionallySizedBox(
                            alignment: Alignment(
                              -1 + (2 * widget.colorAnimation.value),
                              -1,
                            ),
                            widthFactor: 0.4,

                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Center(
                      child: Text(
                        "${widget.chapter}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26 * widget.scale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Color> _getAnimatedGradientColors(double t, bool isDark) {
    return [
      Color.lerp(
        const Color(0xFF0F172A),
        const Color(0xFF111827),
        t,
      )!,
      Color.lerp(
        const Color(0xFF1F2937),
        const Color(0xFF0B1220),
        (t + 0.3) % 1.0,
      )!,
      Color.lerp(
        const Color(0xFF0B1220),
        const Color(0xFF1E293B),
        t,
      )!,
    ];
  }
}