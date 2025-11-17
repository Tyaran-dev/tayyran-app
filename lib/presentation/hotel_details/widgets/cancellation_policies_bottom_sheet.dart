// lib/presentation/hotel_details/widgets/cancellation_policies_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';

class CancellationPoliciesBottomSheet extends StatelessWidget {
  final HotelRoom room;

  const CancellationPoliciesBottomSheet({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
              const Icon(Icons.cancel, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${room.displayName} - ${'hotels.cancellation_policy'.tr()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Refundable Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: room.isRefundable ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: room.isRefundable
                    ? AppColors.splashBackgroundColorEnd
                    : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  room.isRefundable ? Icons.verified : Icons.warning,
                  color: room.isRefundable
                      ? AppColors.splashBackgroundColorEnd
                      : Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    room.isRefundable
                        ? 'hotels.refundable_yes'.tr()
                        : 'hotels.refundable_no'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: room.isRefundable
                          ? AppColors.splashBackgroundColorEnd
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cancellation Policies
          Expanded(
            child: room.cancelPolicies.isEmpty
                ? _buildNoCancellationPolicy()
                : _buildCancellationPoliciesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCancellationPolicy() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'hotels.no_cancellation_policy'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPoliciesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'hotels.cancellation_terms'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: room.cancelPolicies.length,
            itemBuilder: (context, index) {
              final policy = room.cancelPolicies[index];
              return _buildPolicyItem(policy, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyItem(CancelPolicy policy, int index) {
    final isFreeCancellation = policy.cancellationCharge == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFreeCancellation ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFreeCancellation
              ? AppColors.splashBackgroundColorEnd
              : Colors.orange,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Policy Number
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isFreeCancellation
                  ? AppColors.splashBackgroundColorEnd
                  : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Policy Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(policy.fromDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                if (policy.chargeType == 'Percentage')
                  Text(
                    '${policy.cancellationCharge}${"hotels.percentage_charge".tr()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )
                else if (policy.chargeType == 'Fixed')
                  Row(
                    children: [
                      Image.asset(
                        AppAssets.currencyIcon,
                        height: 25,
                        width: 25,
                      ),
                      SizedBox(width: 4),
                      Text(
                        policy.cancellationCharge.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Free Cancellation Badge
          if (isFreeCancellation)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.splashBackgroundColorEnd,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'FREE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split(' ');
      final datePart = parts[0]; // "14-11-2025"
      final dateParts = datePart.split('-');
      if (dateParts.length == 3) {
        final day = dateParts[0];
        final month = dateParts[1];
        final year = dateParts[2];
        return 'Until $day/$month/$year';
      }
      return 'Until $dateString';
    } catch (e) {
      return 'Until $dateString';
    }
  }
}
