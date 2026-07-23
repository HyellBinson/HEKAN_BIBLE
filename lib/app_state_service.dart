import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppStateService {
  static String _uid() =>
      FirebaseAuth.instance.currentUser?.uid ?? "guest";

  static String _key(String key) => "${_uid()}_$key";

  static const _screen = "screen";

  // Bible
  static const _book = "book";
  static const _chapter = "chapter";
  static const _verse = "verse";
  static const _version = "version";
  static const _scroll = "scroll";

  // Hymn
  static const _hymnNumber = "hymn_number";

  // Prayer
  static const _prayerTitle = "prayer_title";
  static const _prayerContent = "prayer_content";

  // ===========================
  // BIBLE
  // ===========================

  static Future<void> saveBible({
    required String version,
    required String book,
    required int chapter,
    required int verse,
    required double scroll,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key(_screen), "bible");
    await prefs.setString(_key(_book), book);
    await prefs.setInt(_key(_chapter), chapter);
    await prefs.setInt(_key(_verse), verse);
    await prefs.setString(_key(_version), version);
    await prefs.setDouble(_key(_scroll), scroll);
  }

  // ===========================
  // HYMN
  // ===========================

  // LAST HYMN
  static Future<void> saveHymn({
    required int number,
    required String title,
    required String lyrics,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key(_screen), "hymn");

    await prefs.setInt(_key(_hymnNumber), number);
    await prefs.setString(_key("hymn_title"), title);
    await prefs.setString(_key("hymn_lyrics"), lyrics);
  }



  // ===========================
  // PRAYER
  // ===========================

  static Future<void> savePrayer({
    required String title,
    required String content,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key(_screen), "prayer");
    await prefs.setString(_key(_prayerTitle), title);
    await prefs.setString(_key(_prayerContent), content);
  }

  // ===========================
  // GETTERS
  // ===========================

  static Future<void> saveLastScreen(String screen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(_screen), screen);
  }

  static Future<String> getLastScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(_screen)) ?? "home";
  }
  static Future<Map<String, dynamic>> getBible() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "book": prefs.getString(_key(_book)) ?? "Genesis",
      "chapter": prefs.getInt(_key(_chapter)) ?? 1,
      "verse": prefs.getInt(_key(_verse)) ?? 1,
      "version": prefs.getString(_key(_version)) ?? "KJV",
      "scroll": prefs.getDouble(_key(_scroll)) ?? 0,
    };
  }

  static Future<int> getHymnNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(_hymnNumber)) ?? 1;
  }

  static Future<Map<String, String>> getPrayer() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "title": prefs.getString(_key(_prayerTitle)) ?? "",
      "content": prefs.getString(_key(_prayerContent)) ?? "",
    };
  }
  static Future<Map<String, dynamic>> getHymn() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "number": prefs.getInt(_key(_hymnNumber)) ?? 1,
      "title": prefs.getString(_key("hymn_title")) ?? "",
      "lyrics": prefs.getString(_key("hymn_lyrics")) ?? "",
    };
  }

}