import 'package:flutter/material.dart';
import 'chapter_screen.dart';
import 'search_screen.dart';
import 'responsive.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  /// 📖 OLD TESTAMENT
  final List<String> oldTestament = [
    "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua",
    "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings",
    "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job",
    "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah",
    "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel",
    "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah",
    "Haggai", "Zechariah", "Malachi",
  ];

  /// ✨ NEW TESTAMENT
  final List<String> newTestament = [
    "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians",
    "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians",
    "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus",
    "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John",
    "2 John", "3 John", "Jude", "Revelation",
  ];

  /// 📚 CHAPTER COUNTS
  final Map<String, int> chapterCounts = {
    // ... (your chapter counts remain unchanged)
    "Genesis": 50, "Exodus": 40, "Leviticus": 27, "Numbers": 36,
    "Deuteronomy": 34, "Joshua": 24, "Judges": 21, "Ruth": 4,
    "1 Samuel": 31, "2 Samuel": 24, "1 Kings": 22, "2 Kings": 25,
    "1 Chronicles": 29, "2 Chronicles": 36, "Ezra": 10, "Nehemiah": 13,
    "Esther": 10, "Job": 42, "Psalms": 150, "Proverbs": 31,
    "Ecclesiastes": 12, "Song of Solomon": 8, "Isaiah": 66,
    "Jeremiah": 52, "Lamentations": 5, "Ezekiel": 48, "Daniel": 12,
    "Hosea": 14, "Joel": 3, "Amos": 9, "Obadiah": 1, "Jonah": 4,
    "Micah": 7, "Nahum": 3, "Habakkuk": 3, "Zephaniah": 3, "Haggai": 2,
    "Zechariah": 14, "Malachi": 4,

    "Matthew": 28, "Mark": 16, "Luke": 24, "John": 21, "Acts": 28,
    "Romans": 16, "1 Corinthians": 16, "2 Corinthians": 13, "Galatians": 6,
    "Ephesians": 6, "Philippians": 4, "Colossians": 4, "1 Thessalonians": 5,
    "2 Thessalonians": 3, "1 Timothy": 6, "2 Timothy": 4, "Titus": 3,
    "Philemon": 1, "Hebrews": 13, "James": 5, "1 Peter": 5, "2 Peter": 3,
    "1 John": 5, "2 John": 1, "3 John": 1, "Jude": 1, "Revelation": 22,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scale = Responsive.scale(context);

    final titleSize = 32 * scale;
    final subtitleSize = 15 * scale;
    final padding = 20 * scale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/testament_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          SafeArea(
            child: SingleChildScrollView(   // ← Added this
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Holy Bible",
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Choose a testament",
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 25 * scale),


                  _testamentCard(
                    context: context,
                    title: "Old Testament",
                    subtitle: "39 Books",
                    icon: Icons.auto_stories_rounded,
                    books: oldTestament,
                  ),
                  const SizedBox(height: 18),

                  _testamentCard(
                    context: context,
                    title: "New Testament",
                    subtitle: "27 Books",
                    icon: Icons.menu_book_rounded,
                    books: newTestament,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Updated Testament Card - Even more flexible
  Widget _testamentCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> books,
  }) {

    final scale = Responsive.scale(context);

    final iconSize = 28 * scale;
    final titleSize = 24 * scale;
    final subtitleSize = 15 * scale;


    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BooksScreen(
                    title: title,
                    books: books,
                    chapterCounts: chapterCounts,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(22 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30 * scale),
                color: Colors.white.withOpacity(0.15),
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(top: -30, right: -20, child: Container(height: 110, width: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
                  Positioned(bottom: -35, left: -15, child: Container(height: 110, width: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(14 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(18 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Icon(icon, color: Colors.white, size: iconSize,),
                      ),
                      SizedBox(height: 20 * scale),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: subtitleSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// BooksScreen remains the same
class BooksScreen extends StatelessWidget {
  final String title;
  final List<String> books;
  final Map<String, int> chapterCounts;

  const BooksScreen({
    super.key,
    required this.title,
    required this.books,
    required this.chapterCounts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scale = Responsive.scale(context);

    final titleSize = 16 * scale;
    final subtitleSize = 12 * scale;
    final iconSize = 22 * scale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16 * scale),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12 * scale),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20 * scale),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: ListTile(
              minVerticalPadding: 10,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child:  Icon(Icons.menu_book_rounded, color: Colors.green,size: iconSize,),
              ),
              title: Text(book, style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),),
              subtitle:  Text("Tap to open chapters", style: TextStyle(fontSize:  subtitleSize),),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                final chapterCount = chapterCounts[book] ?? 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChapterScreen(book: book, chapterCount: chapterCount)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}