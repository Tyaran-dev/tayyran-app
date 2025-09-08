// lib/utils/language_detector.dart
class LanguageDetector {
  static String detectLanguage(String text) {
    // Check for Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final hasArabic = arabicRegex.hasMatch(text);

    // Check for English (Latin characters)
    final englishRegex = RegExp(r'[a-zA-Z]');
    final hasEnglish = englishRegex.hasMatch(text);

    // Prioritize Arabic if both are present
    if (hasArabic) {
      return 'ar';
    } else if (hasEnglish) {
      return 'en';
    }

    // Default to English
    return 'en';
  }

  static bool isArabic(String text) {
    return detectLanguage(text) == 'ar';
  }

  static bool isEnglish(String text) {
    return detectLanguage(text) == 'en';
  }
}
