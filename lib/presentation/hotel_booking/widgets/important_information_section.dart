// lib/presentation/hotel_booking/widgets/important_information_section.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:tayyran_app/core/utils/widgets/rate_conditions_parser.dart';

class ImportantInformationSection extends StatelessWidget {
  final List<dynamic> rateConditions;

  const ImportantInformationSection({super.key, required this.rateConditions});

  @override
  Widget build(BuildContext context) {
    final checkInInstructions = RateConditionsParser.extractCheckInInstructions(
      rateConditions,
    );

    final feesAndExtras = RateConditionsParser.extractFeesAndExtras(
      rateConditions,
    );

    final cardsAccepted = RateConditionsParser.extractCardsAccepted(
      rateConditions,
    );

    final checkTimes = RateConditionsParser.extractCheckTimes(rateConditions);

    final minCheckInAge = RateConditionsParser.extractMinimumCheckInAge(
      rateConditions,
    );

    final generalInfo = RateConditionsParser.extractGeneralInformation(
      rateConditions,
    );

    // Check if we have any information to display
    final hasInformation =
        checkInInstructions != null ||
        feesAndExtras['mandatory'] != null ||
        feesAndExtras['optional'] != null ||
        cardsAccepted != null ||
        minCheckInAge != null ||
        generalInfo.isNotEmpty;

    if (!hasInformation) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'booking.important_information'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Check-in Instructions
            if (checkInInstructions != null)
              _buildStructuredInfoItem(
                Icons.assignment,
                'booking.check_in_instructions'.tr(),
                checkInInstructions,
              ),

            // Check-in/Check-out Times
            _buildStructuredInfoItem(
              Icons.access_time,
              'booking.check_in_out_times'.tr(),
              '${'booking.check_in'.tr()}: ${checkTimes['checkInBegin']} - ${checkTimes['checkInEnd']}\n'
              '${'booking.check_out'.tr()}: ${checkTimes['checkOut']}',
            ),

            // Minimum Check-in Age
            if (minCheckInAge != null)
              _buildStructuredInfoItem(
                Icons.person_outline,
                'booking.minimum_age'.tr(),
                '$minCheckInAge ${'booking.years'.tr()}',
              ),

            // Mandatory Fees
            if (feesAndExtras['mandatory'] != null)
              _buildStructuredInfoItem(
                Icons.attach_money,
                'booking.mandatory_fees'.tr(),
                feesAndExtras['mandatory']!,
              ),

            // Optional Fees
            if (feesAndExtras['optional'] != null)
              _buildStructuredInfoItem(
                Icons.payments,
                'booking.optional_fees'.tr(),
                feesAndExtras['optional']!,
              ),

            // Cards Accepted
            if (cardsAccepted != null)
              _buildStructuredInfoItem(
                Icons.credit_card,
                'booking.cards_accepted'.tr(),
                cardsAccepted,
              ),

            // General Information
            if (generalInfo.isNotEmpty)
              ...generalInfo.take(3).map((info) => _buildGeneralInfoItem(info)),

            // View More Button if there are more general info items
            if (generalInfo.length > 3)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAllImportantInformation(
                    context,
                    checkInInstructions,
                    feesAndExtras,
                    cardsAccepted,
                    checkTimes,
                    minCheckInAge,
                    generalInfo,
                  ),
                  child: Text('booking.view_more_info'.tr()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredInfoItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoItem(String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              info,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllImportantInformation(
    BuildContext context,
    String? checkInInstructions,
    Map<String, String?> feesAndExtras,
    String? cardsAccepted,
    Map<String, String> checkTimes,
    String? minCheckInAge,
    List<String> generalInfo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                    'booking.all_important_info'.tr(),
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Check-in Instructions
                    if (checkInInstructions != null)
                      _buildStructuredInfoItem(
                        Icons.assignment,
                        'booking.check_in_instructions'.tr(),
                        checkInInstructions,
                      ),

                    // Check-in/Check-out Times
                    _buildStructuredInfoItem(
                      Icons.access_time,
                      'booking.check_in_out_times'.tr(),
                      '${'booking.check_in'.tr()}: ${checkTimes['checkInBegin']} - ${checkTimes['checkInEnd']}\n'
                      '${'booking.check_out'.tr()}: ${checkTimes['checkOut']}',
                    ),

                    // Minimum Check-in Age
                    if (minCheckInAge != null)
                      _buildStructuredInfoItem(
                        Icons.person_outline,
                        'booking.minimum_age'.tr(),
                        '$minCheckInAge ${'booking.years'.tr()}',
                      ),

                    // Mandatory Fees
                    if (feesAndExtras['mandatory'] != null)
                      _buildStructuredInfoItem(
                        Icons.attach_money,
                        'booking.mandatory_fees'.tr(),
                        feesAndExtras['mandatory']!,
                      ),

                    // Optional Fees
                    if (feesAndExtras['optional'] != null)
                      _buildStructuredInfoItem(
                        Icons.payments,
                        'booking.optional_fees'.tr(),
                        feesAndExtras['optional']!,
                      ),

                    // Cards Accepted
                    if (cardsAccepted != null)
                      _buildStructuredInfoItem(
                        Icons.credit_card,
                        'booking.cards_accepted'.tr(),
                        cardsAccepted,
                      ),

                    // General Information
                    if (generalInfo.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'booking.general_information'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...generalInfo.map((info) => _buildGeneralInfoItem(info)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
