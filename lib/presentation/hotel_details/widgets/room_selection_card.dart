import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';

class RoomSelectionCard extends StatelessWidget {
  final HotelRoom room;
  final String currency;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onViewCancellationPolicy;
  final double percentageCommission;
  const RoomSelectionCard({
    super.key,
    required this.room,
    required this.currency,
    required this.isSelected,
    required this.onSelect,
    this.onViewCancellationPolicy,
    required this.percentageCommission,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? AppColors.splashBackgroundColorEnd
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Room Type and Meal Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      room.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildMealTypeBadge(room.mealType),
                ],
              ),

              const SizedBox(height: 12),

              // Price Section
              _buildPriceSection(),

              const SizedBox(height: 12),

              // Meal Type Info
              if (room.mealType.isNotEmpty && room.mealType != 'None')
                _buildInfoRow(
                  Icons.restaurant,
                  'hotels.meal_type'.tr(),
                  _formatMealType(room.mealType),
                ),

              // Inclusion Info
              if (room.inclusion.isNotEmpty)
                _buildInfoRow(
                  Icons.card_giftcard,
                  'hotels.inclusions'.tr(),
                  room.inclusion,
                ),

              // Refundable Section
              _buildRefundableSection(),

              const SizedBox(height: 16),

              // Select Button
              Align(
                alignment: Alignment.centerRight,
                child: GradientButton(
                  onPressed: onSelect,
                  text: isSelected
                      ? 'hotels.selected'.tr()
                      : 'hotels.select'.tr(),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeBadge(String mealType) {
    final mealTypeConfig = {
      'Room_Only': {'color': Colors.grey, 'label': 'room_only'},
      'BreakFast': {'color': Colors.orange, 'label': 'breakfast'},
      'Half_Board': {'color': Colors.blue, 'label': 'half_board'},
      'Full_Board': {
        'color': AppColors.splashBackgroundColorEnd,
        'label': 'full_board',
      },
      'All_Inclusive': {'color': Colors.purple, 'label': 'all_inclusive'},
    };

    final config =
        mealTypeConfig[mealType] ??
        {'color': Colors.grey, 'label': mealType.tr()};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config['color'] as Color),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          fontSize: 10,
          color: config['color'] as Color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget _buildPriceWithIcon() {
  //   return Row(
  //     children: [
  //       Image.asset(AppAssets.currencyIcon, width: 24, height: 24),
  //       const SizedBox(width: 8),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             room.totalPrice.toStringAsFixed(2),
  //             style: const TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: AppColors.splashBackgroundColorEnd,
  //             ),
  //           ),
  //           const SizedBox(height: 2),
  //           Text(
  //             'hotels.includes_taxes'.tr(),
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.black,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPriceSection() {
    final breakdown = room.getPriceBreakdown(percentageCommission);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(AppAssets.currencyIcon, width: 24, height: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breakdown.total.toStringAsFixed(
                    2,
                  ), // Show final total with your fees
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'hotels.includes_taxes'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundableSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            room.isRefundable ? Icons.verified : Icons.warning,
            size: 16,
            color: room.isRefundable
                ? AppColors.splashBackgroundColorEnd
                : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hotels.refundable'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.isRefundable
                      ? 'hotels.refundable_yes'.tr()
                      : 'hotels.refundable_no'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: room.isRefundable
                        ? AppColors.splashBackgroundColorEnd
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          if (onViewCancellationPolicy != null &&
              room.cancelPolicies.isNotEmpty)
            TextButton(
              onPressed: onViewCancellationPolicy,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'hotels.view_policy'.tr(),
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  String _formatMealType(String mealType) {
    final mealTypes = {
      'BreakFast': 'Breakfast Included',
      'Half_Board': 'Half Board (Breakfast + Lunch/Dinner)',
      'Full_Board': 'Full Board (All Meals)',
      'All_Inclusive': 'All Inclusive (Meals + Drinks)',
      'Room_Only': 'Room Only (No Meals)',
      'None': 'No Meals',
    };
    return mealTypes[mealType] ?? mealType;
  }
}
