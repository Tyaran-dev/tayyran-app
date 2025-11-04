// lib/core/services/app_locale.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale {
  static final AppLocale _instance = AppLocale._internal();
  factory AppLocale() => _instance;
  AppLocale._internal();

  static const String _languageKey = 'app_language';
  Locale _locale = const Locale('ar'); // Default to Arabic
  bool _isInitialized = false;

  Locale get locale => _locale;

  // Initialize from SharedPreferences - call this in main()
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? 'ar';
      _locale = Locale(savedLanguage);
      _isInitialized = true;
      print('✅ AppLocale initialized with: $savedLanguage');
    } catch (e) {
      print('❌ Error initializing AppLocale: $e');
      _locale = const Locale('ar');
      _isInitialized = true;
    }
  }

  // Sync with EasyLocalization context - call this when you have context
  void syncWithEasyLocalization(BuildContext context) {
    final easyLocale = context.locale;
    if (_locale.languageCode != easyLocale.languageCode) {
      _locale = easyLocale;
      _saveToPrefs(easyLocale.languageCode);
    }
  }

  // Update locale (use this when changing language)
  Future<void> setLocale(Locale locale, {BuildContext? context}) async {
    _locale = locale;
    await _saveToPrefs(locale.languageCode);

    // If context is provided, also update EasyLocalization
    if (context != null) {
      await context.setLocale(locale);
    }
  }

  Future<void> _saveToPrefs(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      print('💾 AppLocale saved: $languageCode');
    } catch (e) {
      print('❌ Error saving locale to prefs: $e');
    }
  }

  // Helper methods
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  String get languageCode => _locale.languageCode;

  // Static convenience methods
  static Future<String> get currentLanguageCode async {
    return _instance.languageCode;
  }

  static Future<bool> get isCurrentArabic async {
    return _instance.isArabic;
  }

  static Future<bool> get isCurrentEnglish async {
    return _instance.isEnglish;
  }
}
