import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesService {
  static const String _recentSearchesKey = 'recent_searches';
  static const String _isFirstTimeKey = 'is_first_time';

  // Recent Searches Methods
  static Future<void> saveRecentSearches(
    List<Map<String, dynamic>> searches,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentSearchesKey, json.encode(searches));
  }

  static Future<List<Map<String, dynamic>>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searchesJson = prefs.getString(_recentSearchesKey);

    if (searchesJson == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(searchesJson);
      return jsonList.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error loading recent searches: $e');
      return [];
    }
  }

  static Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  // First Time User Methods
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  static Future<void> setFirstTimeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  static Future<void> resetFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, true);
  }
}
