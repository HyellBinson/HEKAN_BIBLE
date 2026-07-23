import 'package:flutter/material.dart';
import 'bible_service.dart';
import 'notes_screen.dart';
import 'app_state_service.dart';
import 'settings_service.dart';
import 'responsive.dart';

class VerseScreen extends StatefulWidget {
  final String book;
  final int chapter;
  final int? targetVerse;
  final String? initialVersion;


  const VerseScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.targetVerse,
    this.initialVersion,
  });
  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen>
    with AutomaticKeepAliveClientMixin {

  String version = "KJV";

  // 🔥 CHANGED: now dynamic instead of hardcoded
  List<String> versions = [];

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> verses = [];
  Map<int, String> highlights = {};
  bool loading = true;

  double lastOffset = 0;
  bool hasScrolledToTarget = false;

  @override
  bool get wantKeepAlive => true;
  double fontSize = 16;

  @override
  void initState() {
    super.initState();

    debugPrint("Initial version received: ${widget.initialVersion}");

    _scrollController.addListener(() {
      lastOffset = _scrollController.offset;

      print("Saved Offset: ${_scrollController.offset}");

      if (verses.isEmpty) return;

      int currentVerse = 1;

      final index = (_scrollController.offset / 90).floor();

      if (index >= 0 && index < verses.length) {
        currentVerse = verses[index]["verse"];
      }

      AppStateService.saveBible(
        version: version,
        book: widget.book,
        chapter: widget.chapter,
        verse: currentVerse,
        scroll: _scrollController.offset,
      );
      if (mounted) {
        setState(() {});
      }
    });

    if (widget.initialVersion != null) {
      version = widget.initialVersion!;
    }

    loadAvailableVersions(); // 🔥 NEW
    loadVerses();
  }


  Color? _getHighlightColor(int verseNumber) {
    final color = highlights[verseNumber];

    switch (color) {
      case "yellow":
        return Colors.yellow.withOpacity(0.35);

      case "green":
        return Colors.green.withOpacity(0.30);

      case "pink":
        return Colors.pink.withOpacity(0.30);

      case "blue":
        return Colors.blue.withOpacity(0.25);

      case "purple":
        return Colors.purple.withOpacity(0.25);

      default:
        return null;
    }
  }

  // ---------------- LOAD AVAILABLE VERSIONS ----------------
  Future<void> loadAvailableVersions() async {
    final data = await BibleService.getVersions();

    setState(() {
      versions = data;

      // safety fallback
      if (!versions.contains(version) && versions.isNotEmpty) {
        version = versions.first;
      }
    });
  }

  // ---------------- LOAD VERSES ----------------
  Future<void> loadVerses() async {
    setState(() {
      loading = true;
    });
    await AppStateService.saveBible(
      version: version,
      book: widget.book,
      chapter: widget.chapter,
      verse: widget.targetVerse ?? 1,
      scroll: lastOffset,
    );

    final data = await BibleService.getVerses(
      version,
      widget.book,
      widget.chapter,
    );

    final loadedHighlights = await BibleService.getHighlights(
      version: version,
      book: widget.book,
      chapter: widget.chapter,
    );

    setState(() {
      verses = data;
      highlights = loadedHighlights;
      loading = false;
      hasScrolledToTarget = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollAndTarget();
    });
  }

  // ---------------- SAVE SCROLL ----------------
  void _saveScroll() {
    if (_scrollController.hasClients) {
      lastOffset = _scrollController.offset;
    }
  }

  // ---------------- RESTORE SCROLL ----------------
  Future<void> _restoreScrollAndTarget() async {
    if (!_scrollController.hasClients) return;

    final history = await AppStateService.getBible();

    final savedOffset = history["scroll"] as double;

    // Wait until the ListView is fully built
    await Future.delayed(const Duration(milliseconds: 150));

    if (!_scrollController.hasClients) return;

    final max = _scrollController.position.maxScrollExtent;

    final offset = savedOffset.clamp(0.0, max);

    _scrollController.jumpTo(offset);

    if (widget.targetVerse != null && !hasScrolledToTarget) {
      final index = verses.indexWhere(
            (v) => v["verse"] == widget.targetVerse,
      );

      if (index != -1) {
        _scrollController.animateTo(
          index * 90,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        hasScrolledToTarget = true;
      }
    }
  }

  // ---------------- VERSION SWITCH ----------------
// ---------------- VERSION SWITCH ----------------
  Future<void> changeVersion(String newVersion) async {
    setState(() {
      version = newVersion;
    });

    await AppStateService.saveBible(
      version: version,
      book: widget.book,
      chapter: widget.chapter,
      verse: widget.targetVerse ?? 1,
      scroll: _scrollController.hasClients
          ? _scrollController.offset
          : 0,
    );

    await loadVerses();
  }

  // ---------------- BOOKMARK ----------------
  void _showBookmarkDialog(Map<String, dynamic> verse) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Bookmark Verse 🎉"),
          content: Text(
            "Save ${widget.book} ${widget.chapter}:${verse["verse"]}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await BibleService.addBookmark(
                  version: version,
                  book: widget.book,
                  chapter: widget.chapter,
                  verse: verse["verse"],
                  text: verse["text"],
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⭐ Bookmark saved successfully"),
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }



  void _showNoteDialog(Map<String, dynamic> verse) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Note 📝"),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Write your note here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                await BibleService.saveNote(
                  version: version,
                  book: widget.book,
                  chapter: widget.chapter,
                  verse: verse["verse"],
                  note: controller.text.trim(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Note saved successfully 📝"),
                  ),
                );

              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }


  void _showHighlightDialog(Map<String, dynamic> verse) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Highlight Verse"),

          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [

              _colorCircle(Colors.yellow, "yellow", verse),

              _colorCircle(Colors.green, "green", verse),

              _colorCircle(Colors.pink, "pink", verse),

              _colorCircle(Colors.blue, "blue", verse),

              _colorCircle(Colors.purple, "purple", verse),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: const Text(
                  "Remove Highlight",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {

                  await BibleService.removeHighlight(
                    version: version,
                    book: widget.book,
                    chapter: widget.chapter,
                    verse: verse["verse"],
                  );

                  setState(() {
                    highlights.remove(verse["verse"]);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Highlight removed"),
                    ),
                  );
                },
              ),

            ],
          ),
        );
      },
    );


  }

  Widget _colorCircle(
      Color color,
      String colorName,
      Map<String, dynamic> verse,
      ) {

    final selected =
        highlights[verse["verse"]] == colorName;

    return GestureDetector(
      onTap: () async {

        await BibleService.saveHighlight(
          version: version,
          book: widget.book,
          chapter: widget.chapter,
          verse: verse["verse"],
          color: colorName,
        );

        setState(() {
          highlights[verse["verse"]] = colorName;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Highlight saved"),
          ),
        );
      },

      child: Stack(
        alignment: Alignment.center,
        children: [

          CircleAvatar(
            radius: 22,
            backgroundColor: color,
          ),

          if (selected)
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),

        ],
      ),
    );
  }

// ---------------- FONT SIZE ----------------
  void _showFontSizeDialog() {
    final scale = Responsive.scale(context);
    showDialog(
      context: context,
      builder: (context) {
        double tempSize = fontSize;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Font Size"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sample Bible Text",
                    style: TextStyle(
                      fontSize: tempSize * scale,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Slider(
                    min: 12,
                    max: 32,
                    divisions: 20,
                    value: tempSize,
                    label: tempSize.round().toString(),
                    onChanged: (value) {
                      setDialogState(() {
                        tempSize = value;
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      fontSize = tempSize;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scale = Responsive.scale(context);


    final titleSize = 20 * scale;
    final bodySize = fontSize * scale;
    final verseNumberSize = 15 * scale;
    final iconSize = 24 * scale;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1220)
          : const Color(0xFFF5F7FB),

      appBar: AppBar(
        toolbarHeight: 80 * scale,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _showFontSizeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.note_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotesScreen(),
                ),
              );
            },
          ),
        ],

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${widget.book} ${widget.chapter}",
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: DropdownButton<String>(
                value: versions.contains(version) ? version : null,
                underline: const SizedBox(),
                dropdownColor: isDark
                    ? const Color(0xFF111827)
                    : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                items: versions.map((v) {
                  return DropdownMenuItem(
                    value: v,
                    child: Text(v),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  changeVersion(value);
                },
              ),
            ),
          ],
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : verses.isEmpty
          ? const Center(child: Text("No verses found"))
          : ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          16 * scale,
          28 * scale,
          16 * scale,
          16 * scale,
        ),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final verse = verses[index];

          final isTarget =
              widget.targetVerse != null &&
                  verse["verse"] == widget.targetVerse;

          return GestureDetector(
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) {
                  return Wrap(
                    children: [

                      ListTile(
                        leading: const Icon(Icons.highlight),
                        title: const Text("Highlight Verse"),
                        onTap: () {
                          Navigator.pop(context);
                          _showHighlightDialog(verse);
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: const Text("Bookmark Verse"),
                        onTap: () {
                          Navigator.pop(context);
                          _showBookmarkDialog(verse);
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.note_add),
                        title: const Text("Add Note"),
                        onTap: () {
                          Navigator.pop(context);
                          _showNoteDialog(verse);
                        },
                      ),

                    ],
                  );
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12 * scale),
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: isTarget
                    ? Colors.amber.withOpacity(0.25)
                    : (_getHighlightColor(verse["verse"]) ??
                    (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white)),
                borderRadius: BorderRadius.circular(
                  20 * scale,
                ),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(
                        12 * scale,
                      ),
                    ),
                    child: Text(
                      verse["verse"].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: verseNumberSize,
                      ),
                    ),
                  ),

                  SizedBox(width: 14 * scale),
                  Expanded(
                    child: Text(
                      verse["text"],
                      style: TextStyle(
                        fontSize: bodySize,
                        height: 1.7,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}