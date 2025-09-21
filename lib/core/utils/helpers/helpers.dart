// lib/core/utils/helpers.dart

import 'package:tayyran_app/data/models/flight_search_response.dart';

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
