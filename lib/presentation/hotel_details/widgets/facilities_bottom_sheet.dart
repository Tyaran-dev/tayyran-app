// lib/presentation/hotel_details/widgets/facilities_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FacilitiesBottomSheet extends StatefulWidget {
  final List<String> facilities;

  const FacilitiesBottomSheet({super.key, required this.facilities});

  @override
  State<FacilitiesBottomSheet> createState() => _FacilitiesBottomSheetState();
}

class _FacilitiesBottomSheetState extends State<FacilitiesBottomSheet> {
  late List<String> _filteredFacilities;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFacilities = widget.facilities;
    _searchController.addListener(_filterFacilities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFacilities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFacilities = widget.facilities;
      } else {
        _filteredFacilities = widget.facilities
            .where((facility) => facility.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Text(
                'All Facilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_filteredFacilities.length} ${'hotels.facilities'.tr()}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search_facilities'.tr(),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 16),

          // Facilities List
          Expanded(
            child: _filteredFacilities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredFacilities.length,
                    itemBuilder: (context, index) {
                      return _buildFacilityItem(_filteredFacilities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'hotels.no_facilities_found'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String facility) {
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
      'tv': Icons.tv,
      'minibar': Icons.kitchen,
      'safe': Icons.lock,
      'balcony': Icons.landscape,
      'view': Icons.visibility,
      'beach': Icons.beach_access,
      'garden': Icons.nature,
      'terrace': Icons.terrain,
    };

    final icon = facilityIcons.entries
        .firstWhere(
          (entry) => facility.toLowerCase().contains(entry.key),
          orElse: () => const MapEntry('', Icons.check_circle),
        )
        .value;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue[700], size: 20),
      ),
      title: Text(
        _capitalizeFirst(facility),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
