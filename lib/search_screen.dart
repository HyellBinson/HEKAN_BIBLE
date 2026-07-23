import 'dart:ui';
import 'package:flutter/material.dart';
import 'bible_service.dart';
import 'verse_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  final TextEditingController controller = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> searchBible(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await BibleService.searchVerses(q);
      setState(() {
        results = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Search Bible"),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: Stack(
        children: [
          // Background gradient (adapted for dark mode)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.grey[900]!, Colors.grey[850]!]
                    : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
              ),
            ),
          ),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(isDark ? 0.9 : 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: _searchFocusNode,
                    onChanged: searchBible,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      hintText: "Search verses or books...",
                      hintStyle: TextStyle(color: theme.hintColor),
                      prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),

              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.95),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: results.isEmpty && !isLoading
                          ? Center(
                        child: Text(
                          "No book or chapter found",
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                          ),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final verse = results[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VerseScreen(
                                    book: verse["book"],
                                    chapter: verse["chapter"],
                                    targetVerse: verse["verse"],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${verse["book"]} ${verse["chapter"]}:${verse["verse"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    verse["text"],
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}