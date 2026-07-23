import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SettingsService {
  // =========================
// USER-SPECIFIC KEY
// =========================
  static String _key(String key) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return key;
    }

    return "${uid}_$key";
  }
  // 👤 PROFILE PHOTO
  static const _photoKey = "profile_photo";

  // 📖 BIBLE VERSION
  static const _versionKey = "bible_version";

  // 🔔 NOTIFICATIONS ON/OFF
  static const _notifEnabled = "notif_enabled";
  static const _verseEnabled = "verse_enabled";
  static const _prayerEnabled = "prayer_enabled";

  static const _verseHour = "verse_hour";
  static const _verseMinute = "verse_minute";

  static const _prayerHour = "prayer_hour";
  static const _prayerMinute = "prayer_minute";

  // =========================
  // 👤 PHOTO
  // =========================

  static Future<void> savePhoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoKey, path);
  }

  static Future<String?> getPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoKey);
  }

  // =========================
  // 📖 BIBLE VERSION
  // =========================

  static Future<void> setBibleVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(_versionKey), version);
  }

  static Future<String> getBibleVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(_versionKey)) ?? "KJV";
  }

  // =========================
  // 🔔 NOTIFICATIONS TOGGLE
  // =========================

  static Future<void> setNotifEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(_notifEnabled), value);
  }

  static Future<bool> getNotifEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(_notifEnabled)) ?? true;
  }

  // 🌙 THEME MODE
  static const _themeKey = "dark_mode";

// SAVE THEME
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(_themeKey), value);
  }

// GET THEME
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(_themeKey)) ?? false;
  }
  static Future<void> setVerseEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(_verseEnabled), value);
  }

  static Future<bool> getVerseEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(_verseEnabled)) ?? true;
  }

  static Future<void> setPrayerEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(_prayerEnabled), value);
  }

  static Future<bool> getPrayerEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(_prayerEnabled)) ?? true;
  }
  static Future<void> setVerseTime(
      int hour,
      int minute,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_key(_verseHour), hour);
    await prefs.setInt(_key(_verseMinute), minute);
  }

  static Future<List<int>> getVerseTime() async {
    final prefs = await SharedPreferences.getInstance();

    return [
      prefs.getInt(_key(_verseHour)) ?? 7,
      prefs.getInt(_key(_verseMinute)) ?? 0,
    ];
  }

  static Future<void> setPrayerTime(
      int hour,
      int minute,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_key(_prayerHour), hour);
    await prefs.setInt(_key(_prayerMinute), minute);
  }

  static Future<List<int>> getPrayerTime() async {
    final prefs = await SharedPreferences.getInstance();

    return [
      prefs.getInt(_prayerHour) ?? 6,
      prefs.getInt(_prayerMinute) ?? 0,
    ];
  }
  // Morning Prayer
  static const _morningPrayerHour = "morning_prayer_hour";
  static const _morningPrayerMinute = "morning_prayer_minute";

// Evening Prayer
  static const _eveningPrayerHour = "evening_prayer_hour";
  static const _eveningPrayerMinute = "evening_prayer_minute";

// =========================
// MORNING PRAYER
// =========================
  static Future<void> setMorningPrayerTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(_morningPrayerHour), hour);
    await prefs.setInt(_key(_morningPrayerMinute), minute);
  }

  static Future<List<int>> getMorningPrayerTime() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      prefs.getInt(_key(_morningPrayerHour)) ?? 6,
      prefs.getInt(_key(_morningPrayerMinute)) ?? 0,
    ];
  }

// =========================
// EVENING PRAYER
// =========================
  static Future<void> setEveningPrayerTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key(_eveningPrayerHour), hour);
    await prefs.setInt(_key(_eveningPrayerMinute), minute);
  }

  static Future<List<int>> getEveningPrayerTime() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      prefs.getInt(_key(_eveningPrayerHour)) ?? 18,
      prefs.getInt(_key(_eveningPrayerMinute)) ?? 0,
    ];
  }


  static Future<void> syncFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
        _themeKey,
        data["darkMode"] ?? false);

    await prefs.setString(
        _versionKey,
        data["bibleVersion"] ?? "KJV");

    await prefs.setBool(
        _verseEnabled,
        data["verseEnabled"] ?? true);

    await prefs.setBool(
        _prayerEnabled,
        data["prayerEnabled"] ?? true);
  }


}


