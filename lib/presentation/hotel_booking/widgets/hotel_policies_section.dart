// lib/presentation/hotel_booking/widgets/hotel_policies_section.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_price_details.dart';

class HotelPoliciesSection extends StatelessWidget {
  final HotelPriceDetails priceDetails;

  const HotelPoliciesSection({super.key, required this.priceDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'booking.hotel_policies'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Check-in/Check-out times
            _buildPolicyItem(
              Icons.login,
              'booking.check_in_time'.tr(),
              priceDetails.checkInTime,
            ),
            _buildPolicyItem(
              Icons.logout,
              'booking.check_out_time'.tr(),
              priceDetails.checkOutTime,
            ),

            // Cancellation Policy
            if (priceDetails.cancelPolicies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'booking.cancellation_policy'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...priceDetails.cancelPolicies.take(3).map((policy) {
                return _buildCancellationPolicyItem(policy);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicyItem(dynamic policy) {
    final fromDate = policy['FromDate'] ?? '';
    final chargeType = policy['ChargeType'] ?? '';
    final charge = policy['CancellationCharge'] ?? 0;

    final chargeValue = (charge is num)
        ? charge.toStringAsFixed(2)
        : charge.toString();

    String chargeText = '';
    if (chargeType == 'Fixed') {
      chargeText = chargeValue;
    } else if (chargeType == 'Percentage') {
      chargeText = '$chargeValue%';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: Text(
              fromDate.isNotEmpty ? _formatPolicyDate(fromDate) : '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(
            chargeText,
            style: TextStyle(
              fontSize: 12,
              color: charge == 0 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          charge == 0
              ? Image.asset(AppAssets.currencyIcon, width: 20, height: 20)
              : const SizedBox(),
        ],
      ),
    );
  }

  String _formatPolicyDate(String dateString) {
    try {
      final parts = dateString
          .split(' ')[0]
          .split('-'); // "17-11-2025 00:00:00"
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; // Convert to "2025-11-17"
      }
    } catch (e) {
      print('Error formatting policy date: $e');
    }
    return dateString;
  }
}
