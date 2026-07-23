import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {

  static CollectionReference<Map<String, dynamic>>? _favoritesRef() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorite_hymns');
  }

  // Get all favorites
  static Future<List<Map<String, dynamic>>> getFavorites() async {

    final ref = _favoritesRef();

    if (ref == null) return [];

    final snapshot = await ref
        .orderBy('number')
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  // Add favorite
  static Future<void> addFavorite(
      Map<String, dynamic> hymn,
      ) async {

    final ref = _favoritesRef();

    if (ref == null) return;

    await ref.doc(hymn['number'].toString()).set({
      ...hymn,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove favorite
  static Future<void> removeFavorite(int number) async {

    final ref = _favoritesRef();

    if (ref == null) return;

    await ref.doc(number.toString()).delete();
  }

  // Check favorite
  static Future<bool> isFavorite(int number) async {

    final ref = _favoritesRef();

    if (ref == null) return false;

    final doc = await ref.doc(number.toString()).get();

    return doc.exists;
  }
}