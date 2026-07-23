import 'package:flutter/material.dart';
import 'hymn_service.dart';
import 'hymn_detail_screen.dart';

class HausaHymnsScreen extends StatefulWidget {
  const HausaHymnsScreen({super.key});

  @override
  State<HausaHymnsScreen> createState() => _HausaHymnsScreenState();
}

class _HausaHymnsScreenState extends State<HausaHymnsScreen> {
  List hymns = [];
  bool loading = true;
  TextEditingController searchController = TextEditingController();
  String query = "";

  @override
  void initState() {
    super.initState();
    loadHymns();
  }

  Future<void> loadHymns() async {
    final data = await HymnService.loadHausaHymns();
    setState(() {
      hymns = data;
      loading = false;
    });
  }

  List get filteredHymns {
    if (query.isEmpty) return hymns;
    return hymns.where((hymn) {
      final title = hymn['title'].toString().toLowerCase();
      final number = hymn['number'].toString();
      final input = query.toLowerCase();
      return title.contains(input) || number.contains(input);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Hausa Hymns",
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => query = value),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Search hymn number or title...",
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHymns.length,
              itemBuilder: (context, index) {
                final hymn = filteredHymns[index];
                return Card(
                  color: theme.cardColor,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(
                      "${hymn['number']}. ${hymn['title']}",
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.hintColor,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}