import 'package:flutter/material.dart';
import 'favorite_service.dart';
import 'hymn_detail_screen.dart';

class FavoriteHymnsScreen extends StatefulWidget {
  const FavoriteHymnsScreen({super.key});

  @override
  State<FavoriteHymnsScreen> createState() => _FavoriteHymnsScreenState();
}

class _FavoriteHymnsScreenState extends State<FavoriteHymnsScreen> {
  List favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final data = await FavoriteService.getFavorites();
    setState(() {
      favorites = data;
      loading = false;
    });
  }

  Future<void> deleteAll() async {
    for (var hymn in favorites) {
      await FavoriteService.removeFavorite(hymn['number']);
    }
    loadFavorites();
  }

  Future<void> removeOne(int number) async {
    await FavoriteService.removeFavorite(number);
    loadFavorites();
  }

  Future<void> confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete All Favorites"),
          content: const Text("Are you sure you want to delete all favorite hymns?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Favorite Hymns"),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: confirmDeleteAll,
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? Center(
        child: Text(
          "No favorite hymns yet",
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final hymn = favorites[index];
          return Card(
            color: theme.cardColor,
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                "${hymn['number']}. ${hymn['title']}",
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HymnDetailScreen(
                      number: hymn['number'],
                      title: hymn['title'],
                      lyrics: hymn['lyrics'],
                    ),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => removeOne(hymn['number']),
              ),
            ),
          );
        },
      ),
    );
  }
}