// lib/presentation/hotel_booking/widgets/amenities_section.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/utils/widgets/amenity_helper.dart';

class AmenitiesSection extends StatelessWidget {
  final List<dynamic> amenities;

  const AmenitiesSection({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox();

    // Get unique amenities (remove duplicates)
    final uniqueAmenities = amenities.toSet().toList();
    final displayedAmenities = uniqueAmenities.take(10).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'booking.room_amenities'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (uniqueAmenities.length > 10)
                  Text(
                    '${displayedAmenities.length}/${uniqueAmenities.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Amenities Grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: displayedAmenities.map((amenity) {
                final amenityString = amenity.toString();
                final formattedName = AmenityHelper.formatName(amenityString);

                return Container(
                  constraints: const BoxConstraints(
                    maxWidth: 200, // Prevent excessive width
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AmenityHelper.getIcon(amenityString),
                        size: 14,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _truncateText(formattedName, maxLength: 20),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // View All Button if there are more amenities
            if (uniqueAmenities.length > 10)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAllAmenities(context, uniqueAmenities),
                  child: Text('booking.view_all_amenities'.tr()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  void _showAllAmenities(BuildContext context, List<dynamic> amenities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'booking.all_amenities'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Amenities List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: amenities.length,
                itemBuilder: (context, index) {
                  final amenity = amenities[index].toString();
                  return ListTile(
                    leading: Icon(
                      AmenityHelper.getIcon(amenity),
                      color: Colors.blue[700],
                    ),
                    title: Text(
                      AmenityHelper.formatName(amenity),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                    minLeadingWidth: 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
