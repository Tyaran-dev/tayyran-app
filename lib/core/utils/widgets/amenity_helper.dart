// lib/presentation/hotel_booking/utils/amenity_helper.dart
import 'package:flutter/material.dart';

class AmenityHelper {
  static IconData getIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();

    final iconMap = {
      'wifi': Icons.wifi,
      'internet': Icons.wifi,
      'tv': Icons.tv,
      'television': Icons.tv,
      'air conditioning': Icons.ac_unit,
      'balcony': Icons.landscape,
      'patio': Icons.landscape,
      'safe': Icons.security,
      'minibar': Icons.kitchen,
      'housekeeping': Icons.cleaning_services,
      'phone': Icons.phone,
      'bath': Icons.shower,
      'shower': Icons.shower,
      'smoking': Icons.smoke_free,
      'non-smoking': Icons.smoke_free,
    };

    for (final entry in iconMap.entries) {
      if (amenityLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return Icons.check_circle;
  }

  static String formatName(String amenity) {
    return amenity
        .replaceAll('Free ', '')
        .replaceAll('In-room ', '')
        .replaceAll('_', ' ')
        .trim();
  }
}
