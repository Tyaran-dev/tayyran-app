// lib/presentation/hotels/widgets/hotel_card.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';

class HotelCard extends StatelessWidget {
  final HotelData hotel;
  final VoidCallback onTap;

  const HotelCard({super.key, required this.hotel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Image
            Stack(
              children: [
                _buildHotelImage(),
                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hotel.hotelRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Hotel Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel Name
                  Text(
                    hotel.hotelName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Location and Star Rating
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hotel.cityName}, ${hotel.countryName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStarRating(hotel.hotelRating),
                      const SizedBox(width: 4),
                      Text(
                        'hotels.star_hotel'.tr(
                          namedArgs: {
                            'number': hotel.hotelRating.toInt().toString(),
                          },
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Facilities
                  _buildEnhancedFacilities(),

                  const SizedBox(height: 12),

                  // Price
                  _buildPriceSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Image.network(
        hotel.image,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Icon(Icons.hotel, size: 64, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    final int starCount = rating.floor();
    final bool hasHalfStar = rating - starCount >= 0.5;

    return Row(
      children: [
        for (int i = 0; i < starCount; i++)
          Icon(Icons.star, color: Colors.amber, size: 16),
        if (hasHalfStar) Icon(Icons.star_half, color: Colors.amber, size: 16),
        for (int i = 0; i < 5 - starCount - (hasHalfStar ? 1 : 0); i++)
          Icon(Icons.star_border, color: Colors.grey[400], size: 16),
      ],
    );
  }

  Widget _buildEnhancedFacilities() {
    if (hotel.hotelFacilities.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'hotels.no_facilities'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final limitedFacilities = hotel.hotelFacilities.take(3).toList();
    final hasMoreFacilities = hotel.hotelFacilities.length > 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hotels.facilities'.tr(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...limitedFacilities.map(
              (facility) => _buildFacilityChip(facility),
            ),
            if (hasMoreFacilities)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+${hotel.hotelFacilities.length - 4}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.more_horiz, size: 16, color: Colors.grey[600]),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilityChip(String facility) {
    // Map common facilities to icons
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
    };

    final icon = facilityIcons.entries
        .firstWhere(
          (entry) => facility.toLowerCase().contains(entry.key),
          orElse: () => MapEntry('', Icons.check_circle),
        )
        .value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green[700]),
          const SizedBox(width: 6),
          Text(
            _truncateFacilityName(facility),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.splashBackgroundColorEnd,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateFacilityName(String facility) {
    if (facility.length <= 15) return facility;
    return '${facility.substring(0, 13)}...';
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.splashBackgroundColorEnd.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hotels.starting_from'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hotel.minHotelPrice.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.splashBackgroundColorEnd,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(
                      AppAssets.currencyIcon,
                      width: 18,
                      height: 18,
                      color: AppColors.splashBackgroundColorEnd,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'hotels.per_night'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
