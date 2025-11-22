// lib/presentation/hotel_booking/widgets/guests_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/booking_summary_helper.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/guest_info.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/guest_info_sheet.dart';
import 'package:tayyran_app/presentation/hotel_booking/cubit/hotel_booking_cubit.dart';

class GuestsSection extends StatelessWidget {
  final int numberOfRooms;
  final int totalAdults;
  final List<List<GuestInfo>> guests;

  const GuestsSection({
    super.key,
    required this.numberOfRooms,
    required this.totalAdults,
    required this.guests,
  });

  @override
  Widget build(BuildContext context) {
    final guestsPerRoom = BookingSummaryHelper.calculateGuestsPerRoom(
      totalAdults,
      numberOfRooms,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'booking.guest_information'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${guests.fold<int>(0, (sum, room) => sum + room.length)}/$totalAdults',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(numberOfRooms, (roomIndex) {
              final roomGuests = guests.length > roomIndex
                  ? guests[roomIndex]
                  : [];
              final guestsInThisRoom = guestsPerRoom[roomIndex];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (numberOfRooms > 1) ...[
                    Text(
                      '${'booking.room'.tr()} ${roomIndex + 1} ($guestsInThisRoom ${'booking.guests'.tr()})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...List.generate(guestsInThisRoom, (guestIndex) {
                    final guest = roomGuests.length > guestIndex
                        ? roomGuests[guestIndex]
                        : const GuestInfo();

                    return _buildGuestItem(
                      context,
                      roomIndex,
                      guestIndex,
                      guest,
                      guestIndex == 0
                          ? 'booking.primary_guest'.tr()
                          : '${'booking.guest'.tr()} ${guestIndex + 1}',
                    );
                  }),
                  if (roomIndex < numberOfRooms - 1) const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestItem(
    BuildContext context,
    int roomIndex,
    int guestIndex,
    GuestInfo guest,
    String label,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.splashBackgroundColorEnd.withOpacity(0.1),
        child: Icon(Icons.person, color: AppColors.splashBackgroundColorEnd),
      ),
      title: Text(
        guest.isValid
            ? '${guest.title} ${guest.firstName} ${guest.lastName}'
            : label,
        style: TextStyle(
          fontWeight: guest.isValid ? FontWeight.normal : FontWeight.w500,
          color: guest.isValid ? Colors.black : Colors.grey[600],
        ),
      ),
      subtitle: guest.isValid ? null : Text('booking.tap_to_fill_info'.tr()),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: () => _showGuestInfoSheet(context, roomIndex, guestIndex, guest),
    );
  }

  void _showGuestInfoSheet(
    BuildContext context,
    int roomIndex,
    int guestIndex,
    GuestInfo guest,
  ) {
    final cubit = context.read<HotelBookingCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return GuestInfoSheet(
          guest: guest,
          roomIndex: roomIndex,
          guestIndex: guestIndex,
          onSave: (updatedGuest) {
            cubit.updateGuestInfoFromSheet(roomIndex, guestIndex, updatedGuest);
          },
        );
      },
    );
  }
}
