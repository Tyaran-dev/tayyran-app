// lib/presentation/hotel_booking/widgets/stay_details_card.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class StayDetailsCard extends StatelessWidget {
  final String checkIn;
  final String checkOut;
  final String checkInTime;
  final String checkOutTime;
  final int nights;
  final int totalAdults;
  final int totalChildren;
  final int numberOfRooms;

  const StayDetailsCard({
    super.key,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.nights,
    required this.totalAdults,
    required this.totalChildren,
    required this.numberOfRooms,
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
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: AppColors.splashBackgroundColorEnd,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'booking.stay_details'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline
            _buildTimelineSection(),
            const SizedBox(height: 16),

            // Summary
            _buildSummarySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Check-in
          Expanded(
            child: _buildTimelineItem(
              'booking.check_in'.tr(),
              _formatDate(checkIn),
              _formatTimeWithAmPm(checkInTime),
              Icons.login,
              Colors.green,
            ),
          ),

          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
          ),

          // Check-out
          Expanded(
            child: _buildTimelineItem(
              'booking.check_out'.tr(),
              _formatDate(checkOut),
              _formatTimeWithAmPm(checkOutTime),
              Icons.logout,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String date,
    String time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(Icons.hotel, '$numberOfRooms', 'booking.rooms'.tr()),
        _buildSummaryItem(
          Icons.nightlight_round,
          '$nights',
          nights > 1 ? 'booking.nights'.tr() : 'booking.night'.tr(),
        ),
        _buildSummaryItem(
          Icons.people,
          '${totalAdults + totalChildren}',
          'booking.guests'.tr(),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.splashBackgroundColorEnd.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppColors.splashBackgroundColorEnd,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeWithAmPm(String timeString) {
    try {
      // Handle different time formats
      String cleanTime = timeString.trim();

      // If it's already in 12-hour format with AM/PM, return as is
      if (cleanTime.toLowerCase().contains('am') ||
          cleanTime.toLowerCase().contains('pm')) {
        return cleanTime;
      }

      // Handle 24-hour format
      if (cleanTime.contains(':')) {
        List<String> parts = cleanTime.split(':');
        if (parts.length >= 2) {
          int hour = int.tryParse(parts[0]) ?? 0;
          int minute = int.tryParse(parts[1]) ?? 0;

          String period = hour >= 12 ? 'PM' : 'AM';
          int displayHour = hour % 12;
          if (displayHour == 0) displayHour = 12;

          return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
        }
      }

      // If parsing fails, return original time
      return cleanTime;
    } catch (e) {
      return timeString;
    }
  }
}
