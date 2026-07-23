import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static String get uid =>
      FirebaseAuth.instance.currentUser!.uid;

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser() {
    return _db
        .collection("users")
        .doc(uid)
        .get();
  }

  static Future<void> updateUser(
      Map<String, dynamic> data,
      ) async {
    await _db
        .collection("users")
        .doc(uid)
        .update(data);
  }

  static Future<dynamic> getField(
      String field,
      ) async {
    final doc = await getUser();

    if (!doc.exists) return null;

    return doc.data()?[field];
  }
}