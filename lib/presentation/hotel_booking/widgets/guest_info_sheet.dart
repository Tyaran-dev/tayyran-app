// lib/presentation/hotel_booking/widgets/guest_info_sheet.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/guest_info.dart';

class GuestInfoSheet extends StatefulWidget {
  final GuestInfo guest;
  final int roomIndex;
  final int guestIndex;
  final Function(GuestInfo) onSave;

  const GuestInfoSheet({
    super.key,
    required this.guest,
    required this.roomIndex,
    required this.guestIndex,
    required this.onSave,
  });

  @override
  State<GuestInfoSheet> createState() => _GuestInfoSheetState();
}

class _GuestInfoSheetState extends State<GuestInfoSheet> {
  late GuestInfo _currentGuest;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentGuest = widget.guest;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'booking.guest_information'.tr(),
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
            const SizedBox(height: 16),

            // Room and Guest Info
            if (widget.roomIndex != -1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(Icons.hotel, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${'booking.room'.tr()} ${widget.roomIndex + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      widget.guestIndex == 0
                          ? 'booking.primary_guest'.tr()
                          : '${'booking.guest'.tr()} ${widget.guestIndex + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _currentGuest.title.isNotEmpty
                        ? _currentGuest.title
                        : null,
                    decoration: InputDecoration(
                      labelText: 'booking.title'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ['mr', 'mrs', 'ms', 'miss', 'dr']
                        .map(
                          (titleKey) => DropdownMenuItem(
                            value: titleKey,
                            child: Text('booking.$titleKey'.tr()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _currentGuest = _currentGuest.copyWith(
                          title: value ?? '',
                        );
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'booking.please_select_title'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    initialValue: _currentGuest.firstName,
                    decoration: InputDecoration(
                      labelText: 'booking.first_name'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentGuest = _currentGuest.copyWith(
                          firstName: value,
                        );
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'booking.please_enter_first_name'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    initialValue: _currentGuest.lastName,
                    decoration: InputDecoration(
                      labelText: 'booking.last_name'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentGuest = _currentGuest.copyWith(lastName: value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'booking.please_enter_last_name'.tr();
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            GradientButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onSave(_currentGuest);
                  Navigator.pop(context);
                }
              },
              text: 'booking.save_guest_info'.tr(),
              height: 50,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
