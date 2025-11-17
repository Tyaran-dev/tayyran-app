// lib/presentation/hotel_details/widgets/price_details_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';

class PriceDetailsBottomSheet extends StatelessWidget {
  final HotelRoom room;
  final double percentageCommission;

  const PriceDetailsBottomSheet({
    super.key,
    required this.room,
    required this.percentageCommission,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = room.getPriceBreakdown(percentageCommission);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Center(
            child: Text(
              'hotels.price_breakdown'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          _buildBreakdownItem('hotels.room_price'.tr(), breakdown.subtotal),
          _buildBreakdownItem(
            'hotels.administration_fee'.tr(),
            breakdown.administrationFee,
          ),

          _buildBreakdownItem('hotels.vat'.tr(), breakdown.vat),

          const Divider(height: 30, thickness: 1),

          // Total
          _buildTotalItem(breakdown.total),

          const SizedBox(height: 24),

          // Close Button
          SizedBox(width: double.infinity),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String title, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Text(
                amount.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Image.asset(AppAssets.currencyIcon, width: 30, height: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'hotels.total'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(
              total.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
            Image.asset(AppAssets.currencyIcon, width: 30, height: 30),
          ],
        ),
      ],
    );
  }
}
