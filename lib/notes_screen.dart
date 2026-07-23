import 'package:flutter/material.dart';
import 'bible_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {

  List<Map<String, dynamic>> notes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await BibleService.getNotes();

    setState(() {
      notes = data;
      loading = false;
    });
  }

  Future<void> deleteNote(String id) async {
    await BibleService.deleteNote(id);
    await loadNotes();
  }

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: _deleteAllNotes,
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
          ? const Center(child: Text("No notes saved yet"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {

          final note = notes[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "${note['book']} ${note['chapter']}:${note['verse']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(note['note'] ?? ""),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteNote(note['id']),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
  Future<void> _deleteAllNotes() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete all notes?"),
          content: const Text("This will remove all saved notes permanently."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  final notes = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('notes')
                      .get();

                  for (final doc in notes.docs) {
                    await doc.reference.delete();
                  }
                }

                await loadNotes();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All notes deleted")),
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}