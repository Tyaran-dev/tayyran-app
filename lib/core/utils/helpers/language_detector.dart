// lib/core/utils/language_detector.dart
import 'dart:ui';

class LanguageDetector {
  static String detectLanguage(String text) {
    if (text.isEmpty) return 'en'; // Default to English

    // Remove numbers and special characters for better detection
    final cleanText = text.replaceAll(RegExp(r'[0-9\W_]'), '');
    if (cleanText.isEmpty) return 'en';

    // Arabic character range
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );

    // Count Arabic vs English characters
    int arabicCount = 0;
    int englishCount = 0;

    for (var i = 0; i < cleanText.length; i++) {
      final char = cleanText[i];
      if (arabicRegex.hasMatch(char)) {
        arabicCount++;
      } else if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
        englishCount++;
      }
    }

    // Decide based on character count
    if (arabicCount > englishCount) {
      return 'ar';
    } else if (englishCount > arabicCount) {
      return 'en';
    }

    // If equal or undetermined, use system locale
    final systemLocale = PlatformDispatcher.instance.locale;
    return systemLocale.languageCode == 'ar' ? 'ar' : 'en';
  }

  static bool isArabic(String text) {
    return detectLanguage(text) == 'ar';
  }

  static bool isEnglish(String text) {
    return detectLanguage(text) == 'en';
  }
}
