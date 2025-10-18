// lib/core/utils/helpers.dart

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/data/country_data.dart';
import 'package:tayyran_app/data/models/flight_pricing_response.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';

/// Helper method to print nested map structure
void printNestedMap(Map<String, dynamic> map, {String indent = ''}) {
  for (var entry in map.entries) {
    if (entry.value is Map<String, dynamic>) {
      print('$indent${entry.key}: {');
      printNestedMap(entry.value as Map<String, dynamic>, indent: '$indent  ');
      print('$indent}');
    } else if (entry.value is List) {
      print('$indent${entry.key}: [');
      final list = entry.value as List;
      if (list.isNotEmpty && list.first is Map<String, dynamic>) {
        printNestedMap(list.first as Map<String, dynamic>, indent: '$indent  ');
      } else if (list.isNotEmpty) {
        print('$indent  ${list.first}');
      }
      print('$indent]');
    } else {
      print('$indent${entry.key}: ${entry.value}');
    }
  }
}

/// Helper method to safely parse double values
double? safeParseDouble(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

/// Helper method to safely parse int values
int? safeParseInt(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

/// Helper method to safely parse bool values
bool? safeParseBool(dynamic value) {
  if (value == null) return null;

  if (value is bool) return value;

  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }

  if (value is num) {
    return value != 0;
  }

  return null;
}

bool isValidDate(String date) {
  try {
    final parts = date.split('-');
    if (parts.length != 3) return false;
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return year > 1900 && month >= 1 && month <= 12 && day >= 1 && day <= 31;
  } catch (e) {
    return false;
  }
}

bool isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

int getTotalPassengers(FlightOffer flightOffer) {
  return flightOffer.adults + flightOffer.children + flightOffer.infants;
}

bool validateAllPassengers(List<Passenger> passengers) {
  for (final passenger in passengers) {
    if (passenger.firstName.isEmpty ||
        passenger.lastName.isEmpty ||
        passenger.dateOfBirth.isEmpty ||
        passenger.passportNumber.isEmpty ||
        passenger.nationality.isEmpty) {
      return false;
    }
  }
  return true;
}

String genderFromTitle(String title) {
  switch (title) {
    case 'Mr':
      return 'Male';
    case 'Mrs':
    case 'Ms':
    case 'Miss':
      return 'Female';
    default:
      return 'Male';
  }
}

double calculateTotalTax(List<Tax> taxes) {
  double total = 0.0;
  for (final tax in taxes) {
    total += double.tryParse(tax.amount) ?? 0.0;
  }
  return total;
}

String getCountryNameFromCode(String countryCode) {
  final country = CountryData.countries.firstWhere(
    (c) => c['code'] == countryCode,
    orElse: () => {'name_en': countryCode, 'name_ar': countryCode},
  );
  return country['name_en']!;
}

String formatTime(String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString);
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

String formatDateString(String dateString) {
  final date = DateTime.parse(dateString);
  return '${date.day}/${date.month}/${date.year}';
}

// Helper methods
String formatTimeAmPm(DateTime dateTime) =>
    DateFormat('h:mm a').format(dateTime);
String formatDateFull(DateTime dateTime) =>
    DateFormat('MMM dd, yyyy').format(dateTime);

IconData getFareRuleIcon(String category) {
  switch (category) {
    case 'EXCHANGE':
      return Icons.swap_horiz;
    case 'REFUND':
      return Icons.currency_exchange;
    case 'REVALIDATION':
      return Icons.autorenew;
    default:
      return Icons.info_outline;
  }
}

String getFareRuleTitle(String category) {
  switch (category) {
    case 'EXCHANGE':
      return 'flight_change'.tr();
    case 'REFUND':
      return 'refund_policy'.tr();
    case 'REVALIDATION':
      return 'revalidation'.tr();
    default:
      return category;
  }
}

String formatTravelerTypeWithNumber(String type, int number) {
  final baseType = formatTravelerType(type);
  return '$baseType $number';
}

String formatTravelerType(String type) {
  switch (type.toUpperCase()) {
    case 'ADULT':
      return 'adult'.tr();
    case 'CHILD':
      return 'child'.tr();
    case 'INFANT':
      return 'infant'.tr();
    case 'HELD_INFANT':
      return 'infant'.tr();
    default:
      return type;
  }
}

void prettyPrintJson(Map<String, dynamic> json) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final String prettyJson = encoder.convert(json);
  final lines = prettyJson.split('\n');
  for (final line in lines) {
    print('      $line');
  }
}

// Helper method to check if current language is RTL
bool isRTL(BuildContext context) {
  return context.locale.languageCode == 'ar';
}

String getCurrentLang(BuildContext context) {
  return context.locale.languageCode;
}

DateTime parseDate(String dateString) {
  try {
    final parts = dateString.split('-');
    if (parts.length == 3) {
      // Check if the middle part is a month name (non-numeric)
      final isNamedMonth = int.tryParse(parts[1]) == null;

      if (isNamedMonth) {
        // Handle both Arabic and English month names
        final month = getMonthNumberFromLocalizedName(parts[1]);
        final day = int.parse(parts[0]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } else {
        // Handle numeric format (DD-MM-YYYY or YYYY-MM-DD)
        // Check if first part is year (4 digits)
        if (parts[0].length == 4) {
          // YYYY-MM-DD format
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        } else {
          // DD-MM-YYYY format
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
    }
  } catch (e) {
    print('❌ Error parsing date "$dateString": $e');
  }
  return DateTime.now();
}

// Format date for display (localized) - uses Easy Localization context
String formatDateForDisplay(DateTime date, BuildContext context) {
  final locale = EasyLocalization.of(context)?.locale.languageCode ?? 'en';

  print('🔧 formatDateForDisplay: $date, locale: $locale');

  if (locale == 'ar') {
    // Arabic format: day-month-year with Arabic month names
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final result = "${date.day}-${arabicMonths[date.month - 1]}-${date.year}";
    print('✅ Arabic format: $result');
    return result;
  } else {
    // English format: day-month-year with English month names
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
    final result = "${date.day}-${monthNames[date.month - 1]}-${date.year}";
    print('✅ English format: $result');
    return result;
  }
}

// Format date for backend (always English) - no context needed
String formatDateForBackend(DateTime date) {
  final result =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  print('🔧 formatDateForBackend: $date -> $result');
  return result;
}

// Helper method to get month number from localized month name
int getMonthNumberFromLocalizedName(String monthName) {
  final monthMap = {
    // Arabic months
    'يناير': 1, 'فبراير': 2, 'مارس': 3, 'أبريل': 4,
    'مايو': 5, 'يونيو': 6, 'يوليو': 7, 'أغسطس': 8,
    'سبتمبر': 9, 'أكتوبر': 10, 'نوفمبر': 11, 'ديسمبر': 12,
    // English months
    // 'January': 1, 'February': 2, 'March': 3, 'April': 4,
    // 'May': 5, 'June': 6, 'July': 7, 'August': 8,
    // 'September': 9, 'October': 10, 'November': 11, 'December': 12,
    // Abbreviated English months
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };

  final monthNumber = monthMap[monthName];
  if (monthNumber == null) {
    print('❌ Unknown month name: "$monthName"');
    return DateTime.now().month;
  }
  return monthNumber;
}

// Check if a date string is in the past
bool isDateInPast(String dateString) {
  try {
    final date = parseDate(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  } catch (e) {
    if (kDebugMode) {
      print('Error checking if date is in past: $e');
    }
    return false;
  }
}

Future<String> getAirlineName(Carrier carrier) async {
  final savedLanguage = await SharedPreferencesService.getLanguage();
  final isArabic = savedLanguage == 'ar';
  return isArabic ? carrier.airlineNameAr : carrier.airLineName;
}
