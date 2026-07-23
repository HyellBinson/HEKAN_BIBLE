import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BibleService {

  static Database? _database;

  static Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bible.db');

    final exists = await databaseExists(path);

    if (!exists) {
      ByteData data =
      await rootBundle.load('assets/bible.db');

      List<int> bytes = data.buffer.asUint8List();

      await File(path).writeAsBytes(bytes);
    }

    final db = await openDatabase(path);

    // 🔥 SAFETY: ensure bookmarks table exists even if DB is old
    await db.execute('''
    CREATE TABLE IF NOT EXISTS bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book TEXT,
      chapter INTEGER,
      verse INTEGER,
      text TEXT
    )
  ''');

    return db;
  }

  // =========================
  // VERSES (FIXED VERSION)
  // =========================

  static Future<List<Map<String, dynamic>>> getVerses(
      String version,
      String book,
      int chapter,
      ) async {

    final db = await database;

    final result = await db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [version, book, chapter],
      orderBy: 'verse ASC',
    );

    return result;
  }

  // =========================
  // BOOKMARKS
  // =========================

  static Future<void> addBookmark({
    required String version,
    required String book,
    required int chapter,
    required int verse,
    required String text,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final bookmarks = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks');

    final existing = await bookmarks
        .where('version', isEqualTo: version)
        .where('book', isEqualTo: book)
        .where('chapter', isEqualTo: chapter)
        .where('verse', isEqualTo: verse)
        .get();

    if (existing.docs.isNotEmpty) return;

    await bookmarks.add({
      'version': version,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  static Future<List<Map<String, dynamic>>> getBookmarks() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<void> deleteBookmark(String id) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(id)
        .delete();
  }
  static Future<void> deleteAllBookmarks() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final bookmarks = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in bookmarks.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }


  static Future<void> saveHighlight({
    required String version,
    required String book,
    required int chapter,
    required int verse,
    required String color,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final highlights = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('highlights');

    final existing = await highlights
        .where('version', isEqualTo: version)
        .where('book', isEqualTo: book)
        .where('chapter', isEqualTo: chapter)
        .where('verse', isEqualTo: verse)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'color': color,
      });
    } else {
      await highlights.add({
        'version': version,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'color': color,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
  static Future<void> removeHighlight({
    required String version,
    required String book,
    required int chapter,
    required int verse,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final highlights = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('highlights')
        .where('version', isEqualTo: version)
        .where('book', isEqualTo: book)
        .where('chapter', isEqualTo: chapter)
        .where('verse', isEqualTo: verse)
        .get();

    for (final doc in highlights.docs) {
      await doc.reference.delete();
    }
  }

  static Future<Map<int, String>> getHighlights({
    required String version,
    required String book,
    required int chapter,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('highlights')
        .where('version', isEqualTo: version)
        .where('book', isEqualTo: book)
        .where('chapter', isEqualTo: chapter)
        .get();

    Map<int, String> data = {};

    for (final doc in snapshot.docs) {
      data[doc["verse"]] = doc["color"];
    }

    return data;
  }

  // =========================
  // SEARCH ENGINE (SAFE + SMART)
  // =========================

  static Future<List<Map<String, dynamic>>> searchVerses(
      String query,
      ) async {

    final db = await database;

    final q = query.trim().toLowerCase();

    // =========================
    // 🔥 GENESIS 1:12 / GENESIS 1 12
    // =========================

    final referenceRegex =
    RegExp(r"^(.+?)\s+(\d+)(?::|\s)?(\d+)?$");

    final match = referenceRegex.firstMatch(q);

    if (match != null) {

      final book = match.group(1)?.trim();
      final chapter = int.tryParse(match.group(2)!);
      final verse = int.tryParse(match.group(3) ?? "");

      if (book != null && chapter != null) {

        if (verse != null) {

          return await db.query(
            'verses',
            where:
            'LOWER(book) = ? AND chapter = ? AND verse = ?',
            whereArgs: [
              book.toLowerCase(),
              chapter,
              verse,
            ],
          );
        }

        return await db.query(
          'verses',
          where:
          'LOWER(book) = ? AND chapter = ?',
          whereArgs: [
            book.toLowerCase(),
            chapter,
          ],
          orderBy: 'verse ASC',
        );
      }
    }

    // =========================
    // 🔥 BOOK ONLY SEARCH
    // =========================

    final bookCheck = await db.query(
      'verses',
      where: 'LOWER(book) = ?',
      whereArgs: [q],
      limit: 1,
    );

    if (bookCheck.isNotEmpty) {

      return await db.query(
        'verses',
        where: 'LOWER(book) = ?',
        whereArgs: [q],
        orderBy: 'chapter ASC, verse ASC',
      );
    }

    // =========================
    // 🔥 WORD / PHRASE SEARCH
    // =========================

    return await db.query(
      'verses',
      where: 'LOWER(text) LIKE ?',
      whereArgs: ['%$q%'],
      limit: 200,
    );
  }

  static Future<List<String>> getVersions() async {
    final db = await database;

    final result = await db.rawQuery(
        "SELECT DISTINCT version FROM verses"
    );

    return result.map((e) => e["version"] as String).toList();
  }

  static Future<void> saveNote({
    required String version,
    required String book,
    required int chapter,
    required int verse,
    required String note,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final notes = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes');

    final existing = await notes
        .where('version', isEqualTo: version)
        .where('book', isEqualTo: book)
        .where('chapter', isEqualTo: chapter)
        .where('verse', isEqualTo: verse)
        .get();


    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } else {
      await notes.add({
        'version': version,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<void> deleteNote(String id) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(id)
        .delete();
  }

  static Future<Map<String, dynamic>> getRandomVerse() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT *
    FROM verses
    ORDER BY RANDOM()
    LIMIT 1
  ''');

    return result.first;
  }
  static Future<Map<String, dynamic>> getVerseOfTheDay(String version) async {
    final db = await database;

    final verses = [
      ["Jeremiah", 29, 11],
      ["Isaiah", 41, 10],
      ["Philippians", 4, 13],
      ["Romans", 8, 28],
      ["Joshua", 1, 9],
      ["Psalm", 46, 1],
      ["Psalm", 23, 1],
      ["Matthew", 11, 28],
      ["Proverbs", 3, 5],
      ["John", 3, 16],
      ["Psalm", 121, 1],
      ["Lamentations", 3, 22],
      ["Hebrews", 13, 5],
      ["2 Timothy", 1, 7],
      ["Isaiah", 40, 31],
    ];

    final dayNumber =
        DateTime.now().difference(DateTime(2025, 1, 1)).inDays;

    final selected = verses[dayNumber % verses.length];

    final result = await db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
      whereArgs: [
        version,
        selected[0],
        selected[1],
        selected[2],
      ],
      limit: 1,
    );

    return result.first;
  }

  static Future<Map<String, dynamic>> getTodaysVerses(
      String version,
      ) async {

    final db = await database;

    // Load JSON
    final jsonString =
    await rootBundle.loadString('assets/daily/daily_verses.json');

    final List<dynamic> dailyList = json.decode(jsonString);

    // Pick today's collection
    final dayNumber =
        DateTime.now().difference(DateTime(2025, 1, 1)).inDays;

    final today =
    dailyList[dayNumber % dailyList.length];

    List<Map<String, dynamic>> loadedVerses = [];

    for (final ref in today["verses"]) {

      final result = await db.query(
        'verses',
        where:
        'version = ? AND book = ? AND chapter = ? AND verse = ?',
        whereArgs: [
          version,
          ref[0],
          ref[1],
          ref[2],
        ],
        limit: 1,
      );

      if (result.isNotEmpty) {
        loadedVerses.add(result.first);
      }
    }

    return {
      "theme": today["theme"],
      "gradient": today["gradient"],
      "verses": loadedVerses,
    };
  }
}