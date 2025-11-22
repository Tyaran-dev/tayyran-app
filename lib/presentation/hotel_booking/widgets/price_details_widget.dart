// lib/presentation/hotel_booking/widgets/price_details_widget.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class PriceDetailsWidget extends StatelessWidget {
  final Map<String, double> priceBreakdown;
  final String currency;
  final int nights;
  final int rooms;
  final double percentageCommission;

  const PriceDetailsWidget({
    super.key,
    required this.priceBreakdown,
    required this.currency,
    required this.nights,
    required this.rooms,
    required this.percentageCommission,
  });

  @override
  Widget build(BuildContext context) {
    final basePrice = priceBreakdown['base_price'] ?? 0;
    final tax = priceBreakdown['tax'] ?? 0;
    final adminFee = priceBreakdown['admin_fee'] ?? 0;
    final vat = priceBreakdown['vat'] ?? 0;
    final total = priceBreakdown['total'] ?? 0;

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
                  Icons.receipt_long,
                  color: AppColors.splashBackgroundColorEnd,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'booking.price_breakdown'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Items
            _buildPriceItem(
              '${'booking.room_price'.tr()} ($nights ${nights > 1 ? 'booking.nights'.tr() : 'booking.night'.tr()} × $rooms ${rooms > 1 ? 'booking.rooms'.tr() : 'booking.room'.tr()})',
              basePrice,
              showCurrency: true,
            ),
            _buildPriceItem('booking.tax_fees'.tr(), tax, showCurrency: true),
            _buildPriceItem(
              'booking.admin_fee'.tr(),
              adminFee,
              showCurrency: true,
              isFee: true,
            ),
            _buildPriceItem(
              'booking.vat'.tr(),
              vat,
              showCurrency: true,
              isFee: true,
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'booking.total'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    const SizedBox(width: 8),
                    Image.asset(AppAssets.currencyIcon, width: 20, height: 20),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'booking.includes_taxes_fees'.tr(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(
    String label,
    double amount, {
    bool showCurrency = false,
    bool isFee = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 14,
                    color: isFee ? Colors.orange[700] : Colors.grey[700],
                    fontWeight: isFee ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                if (showCurrency) ...[
                  const SizedBox(width: 4),
                  Image.asset(AppAssets.currencyIcon, width: 16, height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
