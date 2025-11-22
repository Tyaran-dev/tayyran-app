// lib/presentation/hotel_booking/widgets/booking_summary_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';

class BookingSummaryBottomBar extends StatelessWidget {
  final int nights;
  final int numberOfRooms;
  final Map<String, double> priceBreakdown;
  final bool isLoading;
  final bool isFormValid;

  const BookingSummaryBottomBar({
    super.key,
    required this.nights,
    required this.numberOfRooms,
    required this.priceBreakdown,
    required this.isLoading,
    required this.isFormValid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$nights ${nights > 1 ? 'booking.nights'.tr() : 'booking.night'.tr()} • $numberOfRooms ${numberOfRooms > 1 ? 'booking.rooms'.tr() : 'booking.room'.tr()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        priceBreakdown['total']!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        AppAssets.currencyIcon,
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  Text(
                    'booking.includes_taxes_fees'.tr(),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Proceed Button
            SizedBox(
              width: context.widthPct(0.55),
              child: GradientButton(
                onPressed: isFormValid && !isLoading
                    ? () => _proceedToPayment(context)
                    : null,
                text: 'booking.proceed_to_payment'.tr(),
                height: 50,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment(BuildContext context) {
    // Implement payment navigation
    print('Proceeding to payment with valid form');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('booking.proceeding_to_payment'.tr())),
    );
    // You can navigate to your payment screen here
  }
}
