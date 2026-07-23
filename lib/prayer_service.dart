import 'dart:convert';
import 'package:flutter/services.dart';

class PrayerService {
  static Future<List<dynamic>> loadPrayers() async {
    final String response =
    await rootBundle.loadString('assets/prayers/prayers.json');

    return json.decode(response);
  }

  static Future<Map<String, dynamic>?> getTodayMorningPrayer() async {
    final prayers = await loadPrayers();

    final morningPrayers = prayers
        .where((p) => p['category'] == 'morning')
        .toList();

    if (morningPrayers.isEmpty) return null;

    final dayNumber =
        DateTime.now().difference(DateTime(2025, 1, 1)).inDays;

    return morningPrayers[
    dayNumber % morningPrayers.length];
  }

  static Future<Map<String, dynamic>?> getTodayEveningPrayer() async {
    final prayers = await loadPrayers();

    final eveningPrayers = prayers
        .where((p) => p['category'] == 'evening')
        .toList();

    if (eveningPrayers.isEmpty) return null;

    final dayNumber =
        DateTime.now().difference(DateTime(2025, 1, 1)).inDays;

    return eveningPrayers[
    dayNumber % eveningPrayers.length];
  }
}