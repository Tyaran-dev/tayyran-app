// // lib/presentation/passenger_info/widgets/passenger_form_bottom_sheet.dart
// import 'package:flutter/material.dart';
// import 'package:tayyran_app/core/constants/color_constants.dart';
// import 'package:tayyran_app/core/utils/helpers/helpers.dart';
// import 'package:tayyran_app/core/utils/widgets/index.dart';
// import 'package:tayyran_app/data/models/passenger_model.dart';
// import 'package:tayyran_app/presentation/passenger_info/cubit/passenger_info_cubit.dart';
// import 'package:tayyran_app/presentation/passenger_info/widgets/country_selection_bottom_sheet.dart';

// class PassengerFormBottomSheet extends StatefulWidget {
//   final int passengerIndex;
//   final PassengerInfoCubit cubit;

//   const PassengerFormBottomSheet({
//     super.key,
//     required this.passengerIndex,
//     required this.cubit,
//   });

//   @override
//   State<PassengerFormBottomSheet> createState() =>
//       _PassengerFormBottomSheetState();
// }

// class _PassengerFormBottomSheetState extends State<PassengerFormBottomSheet> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _dateOfBirthController;
//   late TextEditingController _passportNumberController;
//   late TextEditingController _issuingCountryController;
//   late TextEditingController _passportExpiryController;
//   late TextEditingController _nationalityController;
//   late String _selectedTitle;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.passengerIndex < widget.cubit.state.passengers.length) {
//       final passenger = widget.cubit.state.passengers[widget.passengerIndex];

//       _selectedTitle = passenger.title.isNotEmpty ? passenger.title : 'Mr';
//       _firstNameController = TextEditingController(text: passenger.firstName);
//       _lastNameController = TextEditingController(text: passenger.lastName);
//       _dateOfBirthController = TextEditingController(
//         text: passenger.dateOfBirth,
//       );
//       _passportNumberController = TextEditingController(
//         text: passenger.passportNumber,
//       );
//       _issuingCountryController = TextEditingController(
//         text: getCountryNameFromCode(passenger.issuingCountry),
//       );
//       _passportExpiryController = TextEditingController(
//         text: passenger.passportExpiry,
//       );
//       _nationalityController = TextEditingController(
//         text: getCountryNameFromCode(passenger.nationality),
//       );
//     } else {
//       _selectedTitle = 'Mr';
//       _firstNameController = TextEditingController();
//       _lastNameController = TextEditingController();
//       _dateOfBirthController = TextEditingController();
//       _passportNumberController = TextEditingController();
//       _issuingCountryController = TextEditingController();
//       _passportExpiryController = TextEditingController();
//       _nationalityController = TextEditingController();
//     }
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _dateOfBirthController.dispose();
//     _passportNumberController.dispose();
//     _issuingCountryController.dispose();
//     _passportExpiryController.dispose();
//     _nationalityController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.passengerIndex >= widget.cubit.state.passengers.length) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(24.0),
//           child: Text("Passenger not found"),
//         ),
//       );
//     }

//     final passenger = widget.cubit.state.passengers[widget.passengerIndex];

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const SizedBox(height: 16),
//                 Text(
//                   'Passenger ${widget.passengerIndex + 1} - ${passenger.type.displayName}',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Form
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Title selection
//                   // Align(
//                   //   alignment: Alignment.centerLeft,
//                   //   child: Text(
//                   //     'Title *',
//                   //     style: TextStyle(
//                   //       fontSize: 14,
//                   //       fontWeight: FontWeight.w600,
//                   //       color: Colors.grey[700],
//                   //     ),
//                   //   ),
//                   // ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     children: [
//                       _buildTitleChip(
//                         label: 'Mr',
//                         isSelected: _selectedTitle == 'Mr',
//                         icon: Icons.person,
//                         onTap: () => setState(() => _selectedTitle = 'Mr'),
//                       ),
//                       _buildTitleChip(
//                         label: 'Mrs',
//                         isSelected: _selectedTitle == 'Mrs',
//                         icon: Icons.person,
//                         onTap: () => setState(() => _selectedTitle = 'Mrs'),
//                       ),
//                       _buildTitleChip(
//                         label: 'Ms',
//                         isSelected: _selectedTitle == 'Ms',
//                         icon: Icons.person,
//                         onTap: () => setState(() => _selectedTitle = 'Ms'),
//                       ),
//                       _buildTitleChip(
//                         label: 'Miss',
//                         isSelected: _selectedTitle == 'Miss',
//                         icon: Icons.person,
//                         onTap: () => setState(() => _selectedTitle = 'Miss'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // First Name
//                   TextFormField(
//                     controller: _firstNameController,
//                     decoration: const InputDecoration(
//                       labelText: 'First Name *',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter first name';
//                       }
//                       if (value.length < 2) {
//                         return 'First name must be at least 2 characters';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Last Name
//                   TextFormField(
//                     controller: _lastNameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Last Name *',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter last name';
//                       }
//                       if (value.length < 2) {
//                         return 'Last name must be at least 2 characters';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Date of Birth
//                   TextFormField(
//                     controller: _dateOfBirthController,
//                     decoration: const InputDecoration(
//                       labelText: 'Date of Birth *',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.calendar_today),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectDate(context),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter date of birth';
//                       }
//                       if (!_isValidDate(value)) {
//                         return 'Please enter a valid date (YYYY-MM-DD)';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Nationality
//                   TextFormField(
//                     controller: _nationalityController,
//                     decoration: const InputDecoration(
//                       labelText: 'Nationality *',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.arrow_drop_down),
//                     ),
//                     readOnly: true,
//                     onTap: () =>
//                         _showCountrySelection(context, isNationality: true),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please select nationality';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Passport Number
//                   TextFormField(
//                     controller: _passportNumberController,
//                     decoration: const InputDecoration(
//                       labelText: 'Passport Number *',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter passport number';
//                       }
//                       if (value.length < 6) {
//                         return 'Passport number must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Issuing Country
//                   TextFormField(
//                     controller: _issuingCountryController,
//                     decoration: const InputDecoration(
//                       labelText: 'Issuing Country *',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.arrow_drop_down),
//                     ),
//                     readOnly: true,
//                     onTap: () =>
//                         _showCountrySelection(context, isNationality: false),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please select issuing country';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Passport Expiry Date
//                   TextFormField(
//                     controller: _passportExpiryController,
//                     decoration: const InputDecoration(
//                       labelText: 'Expiry Date *',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.calendar_today),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectExpiryDate(context),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter expiry date';
//                       }
//                       if (!_isValidDate(value)) {
//                         return 'Please enter a valid date (YYYY-MM-DD)';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 24),

//                   // Save Button
//                   GradientButton(
//                     onPressed: _savePassengerInfo,
//                     text: 'Save Passenger',
//                     height: 50,
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCountrySelection(
//     BuildContext context, {
//     required bool isNationality,
//   }) async {
//     final selectedCountry = await showModalBottomSheet<Map<String, dynamic>>(
//       context: context,
//       backgroundColor: Colors.white,
//       builder: (context) =>
//           CountrySelectionBottomSheet(showNationality: isNationality),
//     );

//     if (selectedCountry != null && mounted) {
//       setState(() {
//         if (isNationality) {
//           _nationalityController.text = selectedCountry['code']!;
//         } else {
//           _issuingCountryController.text = selectedCountry['code']!;
//         }
//       });
//     }
//   }

//   Widget _buildTitleChip({
//     required String label,
//     required bool isSelected,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.splashBackgroundColorEnd
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected
//                 ? AppColors.splashBackgroundColorEnd
//                 : Colors.grey.shade300,
//             width: isSelected ? 0 : 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color: isSelected ? Colors.white : Colors.grey[600],
//             ),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: isSelected ? Colors.white : Colors.grey[700],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   bool _isValidDate(String date) {
//     final parsed = DateTime.tryParse(date);
//     return parsed != null;
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _dateOfBirthController.text =
//             "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//       });
//     }
//   }

//   Future<void> _selectExpiryDate(BuildContext context) async {
//     final DateTime today = DateTime.now();
//     final DateTime firstDate = DateTime(
//       today.year,
//       today.month,
//       today.day,
//     ); // Midnight today

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: firstDate,
//       firstDate: firstDate, // Prevent selecting dates before today
//       lastDate: firstDate.add(const Duration(days: 3650)), // Up to ~10 years
//     );

//     if (picked != null) {
//       setState(() {
//         _passportExpiryController.text =
//             "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//       });
//     }
//   }

//   void _savePassengerInfo() {
//     if (_formKey.currentState!.validate()) {
//       widget.cubit
//         ..updatePassengerTitle(widget.passengerIndex, _selectedTitle)
//         ..updatePassengerFirstName(
//           widget.passengerIndex,
//           _firstNameController.text,
//         )
//         ..updatePassengerLastName(
//           widget.passengerIndex,
//           _lastNameController.text,
//         )
//         ..updatePassengerDateOfBirth(
//           widget.passengerIndex,
//           _dateOfBirthController.text,
//         )
//         ..updatePassengerNationality(
//           widget.passengerIndex,
//           _nationalityController.text,
//         )
//         ..updatePassengerPassportNumber(
//           widget.passengerIndex,
//           _passportNumberController.text,
//         )
//         ..updatePassengerIssuingCountry(
//           widget.passengerIndex,
//           _issuingCountryController.text,
//         )
//         ..updatePassengerPassportExpiry(
//           widget.passengerIndex,
//           _passportExpiryController.text,
//         );

//       Navigator.pop(context);
//     }
//   }
// }
// lib/presentation/passenger_info/widgets/passenger_form_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';
import 'package:tayyran_app/presentation/passenger_info/cubit/passenger_info_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/country_selection_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';

class PassengerFormBottomSheet extends StatefulWidget {
  final int passengerIndex;
  final PassengerInfoCubit cubit;

  const PassengerFormBottomSheet({
    super.key,
    required this.passengerIndex,
    required this.cubit,
  });

  @override
  State<PassengerFormBottomSheet> createState() =>
      _PassengerFormBottomSheetState();
}

class _PassengerFormBottomSheetState extends State<PassengerFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _passportNumberController;
  late TextEditingController _issuingCountryController;
  late TextEditingController _passportExpiryController;
  late TextEditingController _nationalityController;
  late String _selectedTitle;

  // Store country codes separately from display names
  String? _issuingCountryCode;
  String? _nationalityCode;

  @override
  void initState() {
    super.initState();

    if (widget.passengerIndex < widget.cubit.state.passengers.length) {
      final passenger = widget.cubit.state.passengers[widget.passengerIndex];

      _selectedTitle = passenger.title.isNotEmpty ? passenger.title : 'Mr';
      _firstNameController = TextEditingController(text: passenger.firstName);
      _lastNameController = TextEditingController(text: passenger.lastName);
      _dateOfBirthController = TextEditingController(
        text: passenger.dateOfBirth,
      );
      _passportNumberController = TextEditingController(
        text: passenger.passportNumber,
      );

      // Store both code and display name
      _issuingCountryCode = passenger.issuingCountry;
      _issuingCountryController = TextEditingController(
        text: getCountryNameFromCode(passenger.issuingCountry),
      );

      _passportExpiryController = TextEditingController(
        text: passenger.passportExpiry,
      );

      _nationalityCode = passenger.nationality;
      _nationalityController = TextEditingController(
        text: getCountryNameFromCode(passenger.nationality),
      );
    } else {
      _selectedTitle = 'Mr';
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _dateOfBirthController = TextEditingController();
      _passportNumberController = TextEditingController();
      _issuingCountryController = TextEditingController();
      _passportExpiryController = TextEditingController();
      _nationalityController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _passportNumberController.dispose();
    _issuingCountryController.dispose();
    _passportExpiryController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.passengerIndex >= widget.cubit.state.passengers.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("passenger_not_found".tr()),
        ),
      );
    }

    final passenger = widget.cubit.state.passengers[widget.passengerIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 16),
                Text(
                  'passenger_number_type'.tr(
                    namedArgs: {
                      'number': '${widget.passengerIndex + 1}',
                      'type': passenger.type.displayName.toLowerCase().tr(),
                    },
                  ),
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

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title selection
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTitleChip(
                        label: 'Mr'.tr(),
                        isSelected: _selectedTitle == 'Mr',
                        icon: Icons.person,
                        onTap: () => setState(() => _selectedTitle = 'Mr'),
                      ),
                      _buildTitleChip(
                        label: 'Mrs'.tr(),
                        isSelected: _selectedTitle == 'Mrs',
                        icon: Icons.person,
                        onTap: () => setState(() => _selectedTitle = 'Mrs'),
                      ),
                      _buildTitleChip(
                        label: 'Ms'.tr(),
                        isSelected: _selectedTitle == 'Ms',
                        icon: Icons.person,
                        onTap: () => setState(() => _selectedTitle = 'Ms'),
                      ),
                      _buildTitleChip(
                        label: 'Miss'.tr(),
                        isSelected: _selectedTitle == 'Miss',
                        icon: Icons.person,
                        onTap: () => setState(() => _selectedTitle = 'Miss'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'first_name'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_first_name'.tr();
                      }
                      if (value.length < 2) {
                        return 'first_name_min_length'.tr();
                      }
                      if (!_isEnglishText(value)) {
                        return 'english_only'.tr();
                      }
                      return null;
                    },
                    // Restrict to English characters only
                    inputFormatters: [EnglishTextInputFormatter()],
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'last_name'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_last_name'.tr();
                      }
                      if (value.length < 2) {
                        return 'last_name_min_length'.tr();
                      }
                      if (!_isEnglishText(value)) {
                        return 'english_only'.tr();
                      }
                      return null;
                    },
                    inputFormatters: [EnglishTextInputFormatter()],
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  TextFormField(
                    controller: _dateOfBirthController,
                    decoration: InputDecoration(
                      labelText: 'date_of_birth'.tr(),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_date_of_birth'.tr();
                      }
                      if (!_isValidDate(value)) {
                        return 'invalid_date_format'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nationality
                  TextFormField(
                    controller: _nationalityController,
                    decoration: InputDecoration(
                      labelText: 'nationality'.tr(),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: () =>
                        _showCountrySelection(context, isNationality: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'select_nationality_error'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Passport Number
                  TextFormField(
                    controller: _passportNumberController,
                    decoration: InputDecoration(
                      labelText: 'passport_number'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_passport_number'.tr();
                      }
                      if (value.length < 6) {
                        return 'passport_min_length'.tr();
                      }
                      if (!_isEnglishText(value)) {
                        return 'english_only'.tr();
                      }
                      return null;
                    },
                    inputFormatters: [EnglishTextInputFormatter()],
                  ),
                  const SizedBox(height: 16),

                  // Issuing Country
                  TextFormField(
                    controller: _issuingCountryController,
                    decoration: InputDecoration(
                      labelText: 'issuing_country'.tr(),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    readOnly: true,
                    onTap: () =>
                        _showCountrySelection(context, isNationality: false),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'select_issuing_country'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Passport Expiry Date
                  TextFormField(
                    controller: _passportExpiryController,
                    decoration: InputDecoration(
                      labelText: 'expiry_date'.tr(),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectExpiryDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_expiry_date'.tr();
                      }
                      if (!_isValidDate(value)) {
                        return 'invalid_date_format'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  GradientButton(
                    onPressed: _savePassengerInfo,
                    text: 'save_passenger'.tr(),
                    height: 50,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountrySelection(
    BuildContext context, {
    required bool isNationality,
  }) async {
    final selectedCountry = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) =>
          CountrySelectionBottomSheet(showNationality: isNationality),
    );

    if (selectedCountry != null && mounted) {
      setState(() {
        if (isNationality) {
          // Store both code and display name
          _nationalityCode = selectedCountry['code']!;
          _nationalityController.text = _getLocalizedCountryName(
            selectedCountry,
          );
        } else {
          // Store both code and display name
          _issuingCountryCode = selectedCountry['code']!;
          _issuingCountryController.text = _getLocalizedCountryName(
            selectedCountry,
          );
        }
      });
    }
  }

  String _getLocalizedCountryName(Map<String, dynamic> country) {
    final locale = context.locale;
    if (locale.languageCode == 'ar') {
      return country['name_ar'] ?? country['name_en'] ?? '';
    }
    return country['name_en'] ?? '';
  }

  Widget _buildTitleChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.splashBackgroundColorEnd
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.splashBackgroundColorEnd
                : Colors.grey.shade300,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label.tr(), // Translate title labels
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidDate(String date) {
    final parsed = DateTime.tryParse(date);
    return parsed != null;
  }

  bool _isEnglishText(String text) {
    // Regular expression to match only English letters, numbers, and basic punctuation
    final englishRegex = RegExp(r"^[a-zA-Z0-9\s\-\.',]+$");
    return englishRegex.hasMatch(text);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime firstDate = DateTime(today.year, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _passportExpiryController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _savePassengerInfo() {
    if (_formKey.currentState!.validate()) {
      // Use the stored country codes when saving to the cubit
      widget.cubit
        ..updatePassengerTitle(widget.passengerIndex, _selectedTitle)
        ..updatePassengerFirstName(
          widget.passengerIndex,
          _firstNameController.text.trim(),
        )
        ..updatePassengerLastName(
          widget.passengerIndex,
          _lastNameController.text.trim(),
        )
        ..updatePassengerDateOfBirth(
          widget.passengerIndex,
          _dateOfBirthController.text,
        )
        ..updatePassengerNationality(
          widget.passengerIndex,
          _nationalityCode ?? '', // Use the stored code
        )
        ..updatePassengerPassportNumber(
          widget.passengerIndex,
          _passportNumberController.text.trim(),
        )
        ..updatePassengerIssuingCountry(
          widget.passengerIndex,
          _issuingCountryCode ?? '', // Use the stored code
        )
        ..updatePassengerPassportExpiry(
          widget.passengerIndex,
          _passportExpiryController.text,
        );

      Navigator.pop(context);
    }
  }
}

// English Text Input Formatter
class EnglishTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check if the new value contains only English characters, numbers, and basic punctuation
    final englishRegex = RegExp(r"^[a-zA-Z0-9\s\-\.',]+$");
    if (englishRegex.hasMatch(newValue.text)) {
      return newValue;
    }

    // If not valid, return the old value
    return oldValue;
  }
}
