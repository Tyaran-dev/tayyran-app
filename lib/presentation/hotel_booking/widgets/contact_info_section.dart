// lib/presentation/hotel_booking/widgets/contact_info_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:tayyran_app/presentation/hotel_booking/cubit/hotel_booking_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/country_code_selection_bottom_sheet.dart';

class ContactInfoSection extends StatelessWidget {
  final String contactEmail;
  final String contactPhone;
  final String countryCode;

  const ContactInfoSection({
    super.key,
    required this.contactEmail,
    required this.contactPhone,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HotelBookingCubit>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'booking.contact_information'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              initialValue: contactEmail,
              decoration: InputDecoration(
                labelText: 'booking.email'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                cubit.updateContactInfo(value, contactPhone);
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Country Code
                SizedBox(
                  width: 140,
                  child: InkWell(
                    onTap: () => _showCountryCodeSelection(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Country Code',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            countryCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Phone Number
                Expanded(
                  child: TextFormField(
                    initialValue: contactPhone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixText: ' ',
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => cubit.updateContactPhone(value),
                  ),
                ),
              ],
            ),
            if (contactPhone.isNotEmpty && !cubit.isValidPhone(contactPhone))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'validation.invalid_phone'.tr(),
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCountryCodeSelection(BuildContext context) async {
    final cubit = context.read<HotelBookingCubit>();

    final selectedCountry = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => const CountryCodeSelectionBottomSheet(),
    );

    if (selectedCountry != null && selectedCountry['dial_code'] != null) {
      cubit.updateCountryCode(selectedCountry['dial_code']!);
    }
  }
}
