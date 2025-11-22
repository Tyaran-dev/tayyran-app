// // lib/presentation/hotel_booking/widgets/hotel_info_card.dart
// import 'package:flutter/material.dart';
// import 'package:tayyran_app/data/models/hotel_search_model.dart';

// class HotelInfoCard extends StatelessWidget {
//   final HotelData hotel;
//   final HotelRoom selectedRoom;

//   const HotelInfoCard({
//     super.key,
//     required this.hotel,
//     required this.selectedRoom,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               hotel.hotelName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               selectedRoom.displayName,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _formatMealType(selectedRoom.mealType),
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatMealType(String mealType) {
//     final mealTypes = {
//       'BreakFast': 'Breakfast Included',
//       'Half_Board': 'Half Board',
//       'Full_Board': 'Full Board',
//       'All_Inclusive': 'All Inclusive',
//       'Room_Only': 'Room Only',
//       'None': 'No Meals',
//     };
//     return mealTypes[mealType] ?? mealType;
//   }
// }
// lib/presentation/hotel_booking/widgets/hotel_info_card.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class HotelInfoCard extends StatelessWidget {
  final HotelData hotel;
  final HotelRoom selectedRoom;

  const HotelInfoCard({
    super.key,
    required this.hotel,
    required this.selectedRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Name with Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.hotelName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Hotel Image/Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.splashBackgroundColorEnd.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.hotel,
                    size: 30,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Room Type
            _buildInfoRow(Icons.king_bed, selectedRoom.displayName),
            const SizedBox(height: 8),

            // Meal Type
            _buildInfoRow(
              Icons.restaurant,
              _formatMealType(selectedRoom.mealType),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  String _formatMealType(String mealType) {
    final mealTypes = {
      'BreakFast': 'Breakfast Included',
      'Half_Board': 'Half Board',
      'Full_Board': 'Full Board',
      'All_Inclusive': 'All Inclusive',
      'Room_Only': 'Room Only',
      'None': 'No Meals',
    };
    return mealTypes[mealType] ?? mealType;
  }
}
