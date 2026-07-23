import 'package:flutter/material.dart';
import 'bible_service.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {

  late Future<List<Map<String, dynamic>>> bookmarks;

  @override
  void initState() {
    super.initState();
    bookmarks = BibleService.getBookmarks();
  }

  void refreshBookmarks() {
    setState(() {
      bookmarks = BibleService.getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      backgroundColor:
      isDark
          ? const Color(0xFF0B1220)
          : const Color(0xFFF5F7FB),

      appBar: AppBar(

        title: const Text("Bookmarks"),

        centerTitle: true,

        backgroundColor: Colors.transparent,

        elevation: 0,

        actions: [

          IconButton(

            icon: const Icon(Icons.delete_sweep_rounded),

            onPressed: () async {

              final result = await showDialog(

                context: context,

                builder: (context) {

                  return AlertDialog(

                    backgroundColor:
                    const Color(0xFF111827),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    title: const Text(
                      "Delete All",
                      style: TextStyle(color: Colors.white),
                    ),

                    content: const Text(
                      "Delete all bookmarks?",
                      style: TextStyle(color: Colors.white70),
                    ),

                    actions: [

                      TextButton(

                        onPressed: () {
                          Navigator.pop(context, false);
                        },

                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(

                        onPressed: () {
                          Navigator.pop(context, true);
                        },

                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );

              if (result == true) {

                await BibleService.deleteAllBookmarks();

                refreshBookmarks();

                ScaffoldMessenger.of(context)
                    .showSnackBar(

                  const SnackBar(
                    content: Text(
                      "All bookmarks deleted 🗑️",
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(

        future: bookmarks,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {

            return const Center(
              child: Text(
                "No bookmarks yet ⭐",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(

            padding: const EdgeInsets.all(16),

            itemCount: data.length,

            itemBuilder: (context, index) {

              final verse = data[index];

              return GestureDetector(

                onLongPress: () async {

                  final result = await showDialog(

                    context: context,

                    builder: (context) {

                      return AlertDialog(

                        backgroundColor:
                        const Color(0xFF111827),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        title: const Text(
                          "Remove Bookmark",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),

                        content: const Text(
                          "Remove this bookmark?",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        actions: [

                          TextButton(

                            onPressed: () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },

                            child: const Text("Cancel"),
                          ),

                          ElevatedButton(

                            onPressed: () {
                              Navigator.pop(
                                context,
                                true,
                              );
                            },

                            child: const Text("Remove"),
                          ),
                        ],
                      );
                    },
                  );

                  if (result == true) {

                    await BibleService.deleteBookmark(
                      verse["id"] as String,
                    );

                    refreshBookmarks();

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content: Text(
                          "Bookmark removed 🗑️",
                        ),
                      ),
                    );
                  }
                },

                child: Container(

                  margin:
                  const EdgeInsets.only(bottom: 14),

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color:
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,

                    borderRadius:
                    BorderRadius.circular(20),

                    boxShadow: [

                      BoxShadow(

                        color:
                        Colors.black.withOpacity(0.03),

                        blurRadius: 8,
                      ),
                    ],
                  ),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(

                        "${verse["book"]} ${verse["chapter"]}:${verse["verse"]}",

                        style: const TextStyle(

                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(

                        verse["text"],

                        style: TextStyle(

                          fontSize: 15,

                          height: 1.6,

                          color:
                          isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}