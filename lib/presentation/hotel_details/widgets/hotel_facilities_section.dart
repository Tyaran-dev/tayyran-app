// lib/presentation/hotel_details/widgets/hotel_facilities_section.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HotelFacilitiesSection extends StatelessWidget {
  final List<String> facilities;
  final VoidCallback? onViewAll;

  const HotelFacilitiesSection({
    super.key,
    required this.facilities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with View All button
          Row(
            children: [
              Text(
                'hotels.facilities'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (facilities.length > 10 && onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'hotels.view_all'.tr(),
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Facilities Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: facilities
                .take(10)
                .map((facility) => _buildFacilityChip(facility))
                .toList(),
          ),

          // Show more indicator
          if (facilities.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'hotels.and_more_facilities'.tr(
                  namedArgs: {'count': (facilities.length - 10).toString()},
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(String facility) {
    final facilityIcons = {
      'wifi': Icons.wifi,
      'pool': Icons.pool,
      'gym': Icons.fitness_center,
      'spa': Icons.spa,
      'parking': Icons.local_parking,
      'restaurant': Icons.restaurant,
      'bar': Icons.local_bar,
      'breakfast': Icons.free_breakfast,
      'air conditioning': Icons.ac_unit,
      'pet': Icons.pets,
      'business': Icons.business_center,
      'security': Icons.security,
      'laundry': Icons.local_laundry_service,
      'concierge': Icons.support_agent,
      'room service': Icons.room_service,
      'massage': Icons.spa,
      'fitness': Icons.fitness_center,
      'swimming': Icons.pool,
      'children': Icons.child_care,
      'airport': Icons.flight,
      'shuttle': Icons.airport_shuttle,
      'disabled': Icons.accessible,
      'elevator': Icons.elevator,
      'smoking': Icons.smoking_rooms,
      'non-smoking': Icons.smoke_free,
    };

    final icon = facilityIcons.entries
        .firstWhere(
          (entry) => facility.toLowerCase().contains(entry.key),
          orElse: () => const MapEntry('', Icons.check_circle),
        )
        .value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Text(
            _truncateFacilityName(facility),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  String _truncateFacilityName(String facility) {
    if (facility.length <= 20) return facility;
    return '${facility.substring(0, 18)}...';
  }
}
