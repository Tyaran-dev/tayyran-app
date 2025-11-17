// lib/presentation/hotel_details/widgets/hotel_location_section.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HotelLocationSection extends StatelessWidget {
  final String address;
  final String cityName;
  final String countryName;
  final Map<String, String> attractions;

  const HotelLocationSection({
    super.key,
    required this.address,
    required this.cityName,
    required this.countryName,
    required this.attractions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'hotels.location'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Address Information
          _buildAddressInfo(),

          const SizedBox(height: 16),

          // Map Preview (optional - you can integrate with maps later)
          _buildMapPreview(context),

          const SizedBox(height: 16),

          // Nearby Attractions
          if (attractions.isNotEmpty) _buildAttractionsSection(),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City and Country
        Text(
          '$cityName, $countryName',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        // Full Address
        Text(
          address,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),

        const SizedBox(height: 12),

        // Additional Location Info
        _buildLocationFeatures(),
      ],
    );
  }

  Widget _buildLocationFeatures() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildLocationFeature(
          Icons.directions_car,
          'hotels.parking_available'.tr(),
        ),
        _buildLocationFeature(Icons.train, 'hotels.near_transport'.tr()),
        _buildLocationFeature(Icons.shopping_cart, 'hotels.near_shopping'.tr()),
      ],
    );
  }

  Widget _buildLocationFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // You can integrate with maps here
        _openMaps(context);
      },
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Stack(
          children: [
            // Placeholder for map - you can replace with actual map widget
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 32, color: Colors.grey[500]),
                  const SizedBox(height: 8),
                  Text(
                    'hotels.view_on_map'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Open in maps button
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'hotels.open_map'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(Icons.attractions, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'hotels.nearby_attractions'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Attractions List
        Column(
          children: attractions.entries
              .take(5)
              .map((entry) => _buildAttractionItem(entry.key, entry.value))
              .toList(),
        ),

        // Show more indicator if there are more attractions
        if (attractions.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'hotels.and_more_attractions'.tr(
                namedArgs: {'count': (attractions.length - 5).toString()},
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttractionItem(String name, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Attraction icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.place, size: 18, color: Colors.orange[600]),
          ),

          const SizedBox(width: 12),

          // Attraction info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  distance,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Distance indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Text(
              _parseDistance(distance),
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _parseDistance(String distance) {
    // Simple distance parser - you can customize based on your API response format
    if (distance.toLowerCase().contains('km')) {
      return distance;
    } else if (distance.toLowerCase().contains('m')) {
      return distance;
    } else {
      return 'Nearby';
    }
  }

  void _openMaps(BuildContext context) {
    // Implement map opening functionality
    // You can use packages like: url_launcher, google_maps_flutter, etc.

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('hotels.open_maps'.tr()),
        content: Text('hotels.maps_feature_coming_soon'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }
}

// Shimmer version for loading state
class HotelLocationSectionShimmer extends StatelessWidget {
  const HotelLocationSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Header shimmer
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Address info shimmer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Map preview shimmer
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
