// lib/core/utils/helpers/localization_helper.dart
import 'package:flutter/material.dart';

class LocalizationHelper {
  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  // ========== TIME FORMATTING METHODS ==========

  /// Format time from DateTime with localization
  static String formatTimeLocalized(DateTime? dateTime, BuildContext context) {
    if (dateTime == null) return "";

    final isArabicLocale = isArabic(context);
    return isArabicLocale
        ? _formatTimeArabic(dateTime)
        : _formatTimeEnglish(dateTime);
  }

  /// Format time from String with localization
  static String formatTimeStringLocalized(
    String timeString,
    BuildContext context,
  ) {
    if (timeString.isEmpty) return "";

    try {
      // Try to parse the time string to DateTime
      final dateTime = _parseTimeString(timeString);
      if (dateTime != null) {
        return formatTimeLocalized(dateTime, context);
      }

      // If parsing fails, try to handle common time formats directly
      return _formatTimeStringDirectly(timeString, context);
    } catch (e) {
      print('Error formatting time string: $e');
      return timeString; // Return original string as fallback
    }
  }

  // ========== DATE FORMATTING METHODS ==========

  /// Format date from DateTime with localization
  static String formatDateLocalized(DateTime? dateTime, BuildContext context) {
    if (dateTime == null) return "";

    final isArabicLocale = isArabic(context);
    return isArabicLocale
        ? _formatDateArabic(dateTime)
        : _formatDateEnglish(dateTime);
  }

  /// Format date from String with localization
  static String formatDateStringLocalized(
    String dateString,
    BuildContext context,
  ) {
    if (dateString.isEmpty) return "";

    try {
      // Try to parse the date string to DateTime
      final dateTime = _parseDateString(dateString);
      if (dateTime != null) {
        return formatDateLocalized(dateTime, context);
      }

      // If parsing fails, try to handle common date formats directly
      return _formatDateStringDirectly(dateString, context);
    } catch (e) {
      print('Error formatting date string: $e');
      return dateString; // Return original string as fallback
    }
  }

  // ========== PRIVATE PARSING METHODS ==========

  /// Parse time string to DateTime
  static DateTime? _parseTimeString(String timeString) {
    try {
      // Handle common time formats:
      // "2:30 PM", "14:30", "2:30:45", etc.
      final now = DateTime.now();
      final timeParts = timeString.split(' ');

      String timePart = timeParts[0];
      String? period = timeParts.length > 1 ? timeParts[1] : null;

      final timeComponents = timePart.split(':');
      if (timeComponents.length >= 2) {
        int hour = int.parse(timeComponents[0]);
        int minute = int.parse(timeComponents[1]);

        // Handle 12-hour format with AM/PM
        if (period != null) {
          if (period.toLowerCase() == 'pm' && hour < 12) {
            hour += 12;
          } else if (period.toLowerCase() == 'am' && hour == 12) {
            hour = 0;
          }
        }

        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      print('Error parsing time string: $e');
    }
    return null;
  }

  /// Parse date string to DateTime
  static DateTime? _parseDateString(String dateString) {
    try {
      // Handle common date formats:
      // "25 Dec 2024", "2024-12-25", "25/12/2024", etc.

      // Try parsing "25 Dec 2024" format
      final parts = dateString.split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = _getMonthNumber(parts[1]);
        final year = int.parse(parts[2]);

        if (month != null) {
          return DateTime(year, month, day);
        }
      }

      // Try parsing "2024-12-25" format
      if (dateString.contains('-')) {
        final isoParts = dateString.split('-');
        if (isoParts.length == 3) {
          final year = int.parse(isoParts[0]);
          final month = int.parse(isoParts[1]);
          final day = int.parse(isoParts[2]);
          return DateTime(year, month, day);
        }
      }

      // Try parsing "25/12/2024" format
      if (dateString.contains('/')) {
        final slashParts = dateString.split('/');
        if (slashParts.length == 3) {
          final day = int.parse(slashParts[0]);
          final month = int.parse(slashParts[1]);
          final year = int.parse(slashParts[2]);
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      print('Error parsing date string: $e');
    }
    return null;
  }

  // ========== DIRECT STRING FORMATTING (Fallback) ==========

  /// Format time string directly without parsing (fallback)
  static String _formatTimeStringDirectly(
    String timeString,
    BuildContext context,
  ) {
    final isArabicLocale = isArabic(context);

    if (isArabicLocale) {
      return _convertTimeToArabicNumerals(timeString);
    }
    return timeString;
  }

  /// Format date string directly without parsing (fallback)
  static String _formatDateStringDirectly(
    String dateString,
    BuildContext context,
  ) {
    final isArabicLocale = isArabic(context);

    if (isArabicLocale) {
      return _convertDateToArabicNumerals(dateString);
    }
    return dateString;
  }

  // ========== ORIGINAL FORMATTING METHODS ==========

  static String _formatTimeArabic(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'م' : 'ص';
    final hour12 = hour % 12;
    final hourDisplay = hour12 == 0 ? 12 : hour12;
    return '$hourDisplay:${minute.toString().padLeft(2, '0')} $period';
  }

  static String _formatTimeEnglish(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12;
    final hourDisplay = hour12 == 0 ? 12 : hour12;
    return '$hourDisplay:${minute.toString().padLeft(2, '0')} $period';
  }

  static String _formatDateArabic(DateTime dateTime) {
    final day = dateTime.day;
    final month = _getArabicMonth(dateTime.month);
    final year = dateTime.year;
    return '$day $month $year';
  }

  static String _formatDateEnglish(DateTime dateTime) {
    final monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year}";
  }

  // ========== HELPER METHODS ==========

  static String _getArabicMonth(int month) {
    final months = {
      1: 'يناير',
      2: 'فبراير',
      3: 'مارس',
      4: 'أبريل',
      5: 'مايو',
      6: 'يونيو',
      7: 'يوليو',
      8: 'أغسطس',
      9: 'سبتمبر',
      10: 'أكتوبر',
      11: 'نوفمبر',
      12: 'ديسمبر',
    };
    return months[month] ?? '';
  }

  static int? _getMonthNumber(String monthName) {
    final months = {
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return months[monthName.toLowerCase()];
  }

  static String convertToArabicNumerals(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  static String _convertTimeToArabicNumerals(String time) {
    String result = convertToArabicNumerals(time);
    result = result.replaceAll('AM', 'ص');
    result = result.replaceAll('PM', 'م');
    result = result.replaceAll('am', 'ص');
    result = result.replaceAll('pm', 'م');
    return result;
  }

  static String _convertDateToArabicNumerals(String date) {
    String result = convertToArabicNumerals(date);
    result = result.replaceAll('Jan', 'يناير');
    result = result.replaceAll('Feb', 'فبراير');
    result = result.replaceAll('Mar', 'مارس');
    result = result.replaceAll('Apr', 'أبريل');
    result = result.replaceAll('May', 'مايو');
    result = result.replaceAll('Jun', 'يونيو');
    result = result.replaceAll('Jul', 'يوليو');
    result = result.replaceAll('Aug', 'أغسطس');
    result = result.replaceAll('Sep', 'سبتمبر');
    result = result.replaceAll('Oct', 'أكتوبر');
    result = result.replaceAll('Nov', 'نوفمبر');
    result = result.replaceAll('Dec', 'ديسمبر');

    result = result.replaceAll('January', 'يناير');
    result = result.replaceAll('February', 'فبراير');
    result = result.replaceAll('March', 'مارس');
    result = result.replaceAll('April', 'أبريل');
    result = result.replaceAll('May', 'مايو');
    result = result.replaceAll('June', 'يونيو');
    result = result.replaceAll('July', 'يوليو');
    result = result.replaceAll('August', 'أغسطس');
    result = result.replaceAll('September', 'سبتمبر');
    result = result.replaceAll('October', 'أكتوبر');
    result = result.replaceAll('November', 'نوفمبر');
    result = result.replaceAll('December', 'ديسمبر');
    return result;
  }
}
