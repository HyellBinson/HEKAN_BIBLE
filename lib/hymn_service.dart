import 'dart:convert';
import 'package:flutter/services.dart';

class HymnService {
  static Future<List<dynamic>> loadEnglishHymns() async {
    final String response =
    await rootBundle.loadString('assets/hymns/english_hymns.json');

    return json.decode(response);
  }

  static Future<List<dynamic>> loadHausaHymns() async {
    final String response =
    await rootBundle.loadString('assets/hymns/hausa_hymns.json');

    return json.decode(response);
  }
}