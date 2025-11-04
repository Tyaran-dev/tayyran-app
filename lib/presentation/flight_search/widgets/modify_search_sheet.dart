// // modify_search_sheet.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:tayyran_app/core/constants/color_constants.dart';
// import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
// import 'package:tayyran_app/core/utils/helpers/helpers.dart';
// import 'package:tayyran_app/core/utils/widgets/airport_text_field.dart';
// import 'package:tayyran_app/core/utils/widgets/date_text_field.dart';
// import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
// import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
// import 'package:tayyran_app/presentation/flight_search/widgets/modify_search/modify_search_cubit.dart';
// import 'package:tayyran_app/presentation/flight_search/widgets/modify_search/modify_search_state.dart';
// import 'package:tayyran_app/presentation/airport_search/airport_bottom_sheet.dart';
// import 'package:tayyran_app/presentation/flight/widgets/passenger_selection_modal.dart';

// class ModifySearchSheet extends StatefulWidget {
//   final Map<String, dynamic> initialData;
//   final FlightSearchCubit flightSearchCubit;

//   const ModifySearchSheet({
//     super.key,
//     required this.initialData,
//     required this.flightSearchCubit,
//   });

//   @override
//   _ModifySearchSheetState createState() => _ModifySearchSheetState();
// }

// class _ModifySearchSheetState extends State<ModifySearchSheet>
//     with TickerProviderStateMixin {
//   late GlobalKey _returnDateKey;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _returnDateKey = GlobalKey();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   DateTime _parseDate(String dateString) {
//     try {
//       final parts = dateString.split('-');
//       if (parts.length == 3) {
//         final monthNames = [
//           "Jan",
//           "Feb",
//           "Mar",
//           "Apr",
//           "May",
//           "Jun",
//           "Jul",
//           "Aug",
//           "Sep",
//           "Oct",
//           "Nov",
//           "Dec",
//         ];
//         final day = int.parse(parts[0]);
//         final month = monthNames.indexOf(parts[1]) + 1;
//         final year = int.parse(parts[2]);
//         return DateTime(year, month, day);
//       }
//     } catch (e) {
//       print('Error parsing date: $e');
//     }
//     return DateTime.now();
//   }

//   void _shakeReturnDateField() {
//     _animationController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _animationController.reverse();
//       }
//     });
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ModifySearchCubit(widget.initialData),
//       child: BlocBuilder<ModifySearchCubit, ModifySearchState>(
//         builder: (context, state) {
//           final modifyCubit = context.read<ModifySearchCubit>();

//           return Container(
//             height: MediaQuery.of(context).size.height * 0.62,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Header with title and cancel button
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const SizedBox(width: 48),
//                     Text(
//                       'modifySearch.title'.tr(),
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Form fields container
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Column(
//                         children: [
//                           // From and To fields with swap button
//                           Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               Column(
//                                 children: [
//                                   AirportTextField(
//                                     isOrigin: true,
//                                     label: 'modifySearch.from'.tr(),
//                                     value: state.from,
//                                     icon: Icons.flight_takeoff,
//                                     onTap: () => _showAirportBottomSheet(
//                                       context,
//                                       true,
//                                       modifyCubit,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   AirportTextField(
//                                     isOrigin: false,
//                                     label: 'modifySearch.to'.tr(),
//                                     value: state.to,
//                                     icon: Icons.flight_land,
//                                     onTap: () => _showAirportBottomSheet(
//                                       context,
//                                       false,
//                                       modifyCubit,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 right: isRTL(context) ? null : 0,
//                                 left: isRTL(context) ? 16 : null,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.black,
//                                       width: 1.5,
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withValues(
//                                           alpha: 0.1,
//                                         ),
//                                         blurRadius: 6,
//                                         offset: const Offset(0, 3),
//                                       ),
//                                     ],
//                                   ),
//                                   child: CircleAvatar(
//                                     backgroundColor: Colors.white,
//                                     radius: 20,
//                                     child: IconButton(
//                                       style: OutlinedButton.styleFrom(
//                                         foregroundColor:
//                                             AppColors.splashBackgroundColorEnd,
//                                         side: BorderSide(
//                                           color: AppColors
//                                               .splashBackgroundColorEnd,
//                                         ),
//                                       ),
//                                       icon: const Icon(
//                                         Icons.swap_vert,
//                                         size: 20,
//                                         color: Colors.black,
//                                       ),
//                                       onPressed: () => modifyCubit.swapFromTo(),
//                                       padding: EdgeInsets.zero,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),

//                           // Departure Date
//                           DateTextField(
//                             label: 'modifySearch.departure'.tr(),
//                             value: state.departureDate,
//                             icon: Icons.calendar_today,
//                             onTap: () =>
//                                 _selectDate(context, true, modifyCubit, state),
//                           ),
//                           const SizedBox(height: 12),

//                           // Return Date (if added)
//                           if (state.hasReturnDate) ...[
//                             Stack(
//                               key: _returnDateKey,
//                               children: [
//                                 DateTextField(
//                                   label: 'modifySearch.return'.tr(),
//                                   value: state.returnDate,
//                                   icon: Icons.calendar_today,
//                                   onTap: () => _selectDate(
//                                     context,
//                                     false,
//                                     modifyCubit,
//                                     state,
//                                   ),
//                                   hasError: state.showDateError,
//                                 ),
//                                 Positioned(
//                                   right: isRTL(context) ? null : 0,
//                                   left: isRTL(context) ? 16 : null,
//                                   top: 14,
//                                   child: Row(
//                                     children: [
//                                       if (state.showDateError)
//                                         const Icon(
//                                           Icons.error_outline,
//                                           color: Colors.red,
//                                           size: 18,
//                                         ),
//                                       const SizedBox(width: 4),
//                                       GestureDetector(
//                                         onTap: () =>
//                                             modifyCubit.resetReturnDate(),
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey[300],
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(
//                                             Icons.close,
//                                             size: 18,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (state.showDateError)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4.0),
//                                 child: Text(
//                                   'modifySearch.returnDateError'.tr(),
//                                   style: TextStyle(
//                                     color: Colors.red[700],
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             const SizedBox(height: 12),
//                           ],

//                           // Add Return Date Button
//                           if (!state.hasReturnDate)
//                             SizedBox(
//                               width: double.infinity,
//                               child: OutlinedButton.icon(
//                                 onPressed: () {
//                                   modifyCubit.setHasReturnDate(true);
//                                   // If departure date is set, set return date to next day
//                                   if (state.departureDate.isNotEmpty) {
//                                     final departure = _parseDate(
//                                       state.departureDate,
//                                     );
//                                     final nextDay = departure.add(
//                                       const Duration(days: 1),
//                                     );
//                                     final monthNames = [
//                                       "Jan",
//                                       "Feb",
//                                       "Mar",
//                                       "Apr",
//                                       "May",
//                                       "Jun",
//                                       "Jul",
//                                       "Aug",
//                                       "Sep",
//                                       "Oct",
//                                       "Nov",
//                                       "Dec",
//                                     ];
//                                     modifyCubit.updateReturnDate(
//                                       "${nextDay.day}-${monthNames[nextDay.month - 1]}-${nextDay.year}",
//                                     );
//                                   }
//                                 },
//                                 icon: const Icon(Icons.add, size: 18),
//                                 label: Text('modifySearch.addReturnDate'.tr()),
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor:
//                                       AppColors.splashBackgroundColorEnd,
//                                   side: BorderSide(
//                                     color: AppColors.splashBackgroundColorEnd,
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 14,
//                                   ),
//                                 ),
//                               ),
//                             ),

//                           const SizedBox(height: 12),

//                           // Passenger field
//                           _buildPassengerField(context, state, modifyCubit),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Apply button
//                 GradientButton(
//                   onPressed: () => _applySearch(context, state),
//                   text: 'modifySearch.applyChanges'.tr(),
//                   height: 50,
//                 ),
//                 SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 30),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPassengerField(
//     BuildContext context,
//     ModifySearchState state,
//     ModifySearchCubit cubit,
//   ) {
//     final totalPassengers = state.adults + state.children + state.infants;

//     return GestureDetector(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (context) => Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).viewInsets.bottom,
//             ),
//             child: DraggableScrollableSheet(
//               initialChildSize: 0.77,
//               minChildSize: 0.6,
//               maxChildSize: 0.9,
//               builder: (_, controller) => PassengerSelectionModal(
//                 adults: state.adults,
//                 children: state.children,
//                 infants: state.infants,
//                 cabinClass: state.cabinClass,
//                 onPassengersChanged: (adults, children, infants) {
//                   cubit.updatePassengers(adults, children, infants);
//                 },
//                 onCabinClassChanged: (cabinClass) {
//                   cubit.updateCabinClass(cabinClass);
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.white,
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.people, color: Colors.grey[600]),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _getPassengerSummary(totalPassengers, state.cabinClass),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _getPassengerBreakdown(
//                       state.adults,
//                       state.children,
//                       state.infants,
//                     ),
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper methods for passenger text
//   String _getPassengerSummary(int totalPassengers, String cabinClass) {
//     if (totalPassengers == 1) {
//       return 'modifySearch.passengerSummarySingle'.tr(
//         namedArgs: {'class': cabinClass.toCabinClassDisplayName.tr()},
//       );
//     } else {
//       return 'modifySearch.passengerSummaryMultiple'.tr(
//         namedArgs: {
//           'count': totalPassengers.toString(),
//           'class': cabinClass.toCabinClassDisplayName.tr(),
//         },
//       );
//     }
//   }

//   String _getPassengerBreakdown(int adults, int children, int infants) {
//     final parts = <String>[];

//     if (adults > 0) {
//       parts.add(
//         'modifySearch.adults'.tr(namedArgs: {'count': adults.toString()}),
//       );
//     }

//     if (children > 0) {
//       parts.add(
//         'modifySearch.children'.tr(namedArgs: {'count': children.toString()}),
//       );
//     }

//     if (infants > 0) {
//       parts.add(
//         'modifySearch.infants'.tr(namedArgs: {'count': infants.toString()}),
//       );
//     }

//     return parts.join(', ');
//   }

//   Future<void> _selectDate(
//     BuildContext context,
//     bool isDeparture,
//     ModifySearchCubit cubit,
//     ModifySearchState state,
//   ) async {
//     DateTime initialDate = DateTime.now();
//     DateTime firstDate = DateTime.now();

//     // Set initial date based on existing selection
//     if (isDeparture && state.departureDate.isNotEmpty) {
//       initialDate = _parseDate(state.departureDate);
//     } else if (!isDeparture && state.returnDate.isNotEmpty) {
//       initialDate = _parseDate(state.returnDate);

//       // For return date, ensure firstDate is at least the day after departure
//       if (state.departureDate.isNotEmpty) {
//         final departureDate = _parseDate(state.departureDate);
//         firstDate = departureDate.add(const Duration(days: 1));

//         // Ensure initialDate is not before firstDate
//         if (initialDate.isBefore(firstDate)) {
//           initialDate = firstDate;
//         }
//       }
//     }

//     // Ensure initialDate is not before firstDate
//     if (initialDate.isBefore(firstDate)) {
//       initialDate = firstDate;
//     }

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: DateTime(DateTime.now().year + 1),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.splashBackgroundColorEnd,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.splashBackgroundColorEnd,
//               ),
//             ),
//             dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       final monthNames = [
//         "Jan",
//         "Feb",
//         "Mar",
//         "Apr",
//         "May",
//         "Jun",
//         "Jul",
//         "Aug",
//         "Sep",
//         "Oct",
//         "Nov",
//         "Dec",
//       ];
//       final formattedDate =
//           "${picked.day}-${monthNames[picked.month - 1]}-${picked.year}";

//       if (isDeparture) {
//         cubit.updateDepartureDate(formattedDate);
//         // If return date is before new departure date, clear it and show error
//         if (state.hasReturnDate && state.returnDate.isNotEmpty) {
//           final returnDate = _parseDate(state.returnDate);
//           if (returnDate.isBefore(picked)) {
//             cubit.updateReturnDate('');
//             cubit.setShowDateError(true);
//             _shakeReturnDateField();
//           } else {
//             cubit.setShowDateError(false);
//           }
//         }
//       } else {
//         cubit.updateReturnDate(formattedDate);
//         // Validate return date is after departure
//         if (state.departureDate.isNotEmpty) {
//           final departureDate = _parseDate(state.departureDate);
//           if (picked.isBefore(departureDate.add(const Duration(days: 1)))) {
//             cubit.setShowDateError(true);
//             _shakeReturnDateField();
//           } else {
//             cubit.setShowDateError(false);
//           }
//         }
//       }
//     }
//   }

//   void _showAirportBottomSheet(
//     BuildContext context,
//     bool isOrigin,
//     ModifySearchCubit cubit,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: DraggableScrollableSheet(
//           initialChildSize: 0.8,
//           minChildSize: 0.5,
//           maxChildSize: 0.9,
//           builder: (_, controller) => AirportBottomSheet(
//             segmentId: "1",
//             isOrigin: isOrigin,
//             currentValue: isOrigin ? cubit.state.from : cubit.state.to,
//             onAirportSelected: (airport) {
//               if (isOrigin) {
//                 cubit.updateFrom(airport);
//               } else {
//                 cubit.updateTo(airport);
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _applySearch(BuildContext context, ModifySearchState state) {
//     // Validate dates
//     if (state.hasReturnDate && state.returnDate.isNotEmpty) {
//       final departure = _parseDate(state.departureDate);
//       final returnDate = _parseDate(state.returnDate);

//       if (returnDate.isBefore(departure.add(const Duration(days: 1)))) {
//         context.read<ModifySearchCubit>().setShowDateError(true);
//         _shakeReturnDateField();
//         return;
//       }
//     }

//     try {
//       // Call loadFlights WITHOUT context parameter
//       widget.flightSearchCubit.loadFlights(state.toSearchData(), context);

//       // Close the modal sheet
//       Navigator.pop(context);
//     } catch (e) {
//       // Show error message if loading fails
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('modifySearch.searchFailed'.tr(args: [e.toString()])),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/airport_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/date_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/modify_search/modify_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/widgets/modify_search/modify_search_state.dart';
import 'package:tayyran_app/presentation/airport_search/airport_bottom_sheet.dart';
import 'package:tayyran_app/presentation/flight/widgets/passenger_selection_modal.dart';

class ModifySearchSheet extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final FlightSearchCubit flightSearchCubit;

  const ModifySearchSheet({
    super.key,
    required this.initialData,
    required this.flightSearchCubit,
  });

  @override
  _ModifySearchSheetState createState() => _ModifySearchSheetState();
}

class _ModifySearchSheetState extends State<ModifySearchSheet>
    with TickerProviderStateMixin {
  late GlobalKey _returnDateKey;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _returnDateKey = GlobalKey();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final monthNames = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ];
        final day = int.parse(parts[0]);
        final month = monthNames.indexOf(parts[1]) + 1;
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  void _shakeReturnDateField() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModifySearchCubit(widget.initialData),
      child: BlocBuilder<ModifySearchCubit, ModifySearchState>(
        builder: (context, state) {
          final modifyCubit = context.read<ModifySearchCubit>();

          return Container(
            height: MediaQuery.of(context).size.height * 0.62,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with title and cancel button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    Text(
                      'modifySearch.title'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form fields container
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // From and To fields with swap button
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                children: [
                                  AirportTextField(
                                    isOrigin: true,
                                    label: 'modifySearch.from'.tr(),
                                    value: state.from,
                                    icon: Icons.flight_takeoff,
                                    onTap: () => _showAirportBottomSheet(
                                      context,
                                      true,
                                      modifyCubit,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AirportTextField(
                                    isOrigin: false,
                                    label: 'modifySearch.to'.tr(),
                                    value: state.to,
                                    icon: Icons.flight_land,
                                    onTap: () => _showAirportBottomSheet(
                                      context,
                                      false,
                                      modifyCubit,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: isRTL(context) ? null : 0,
                                left: isRTL(context) ? 16 : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 20,
                                    child: IconButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AppColors.splashBackgroundColorEnd,
                                        side: BorderSide(
                                          color: AppColors
                                              .splashBackgroundColorEnd,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.swap_vert,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => modifyCubit.swapFromTo(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Departure Date
                          DateTextField(
                            label: 'modifySearch.departure'.tr(),
                            value: state.departureDate,
                            icon: Icons.calendar_today,
                            onTap: () =>
                                _selectDate(context, true, modifyCubit, state),
                          ),
                          const SizedBox(height: 12),

                          // Return Date (if added)
                          if (state.hasReturnDate) ...[
                            Stack(
                              key: _returnDateKey,
                              children: [
                                DateTextField(
                                  label: 'modifySearch.return'.tr(),
                                  value: state.returnDate,
                                  icon: Icons.calendar_today,
                                  onTap: () => _selectDate(
                                    context,
                                    false,
                                    modifyCubit,
                                    state,
                                  ),
                                  hasError: state.showDateError,
                                ),
                                Positioned(
                                  right: isRTL(context) ? null : 0,
                                  left: isRTL(context) ? 16 : null,
                                  top: 14,
                                  child: Row(
                                    children: [
                                      if (state.showDateError)
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () =>
                                            modifyCubit.resetReturnDate(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (state.showDateError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'modifySearch.returnDateError'.tr(),
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                          ],

                          // Add Return Date Button
                          if (!state.hasReturnDate)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  modifyCubit.setHasReturnDate(true);
                                  // If departure date is set, set return date to next day
                                  if (state.departureDate.isNotEmpty) {
                                    final departure = _parseDate(
                                      state.departureDate,
                                    );
                                    final nextDay = departure.add(
                                      const Duration(days: 1),
                                    );
                                    final monthNames = [
                                      "Jan",
                                      "Feb",
                                      "Mar",
                                      "Apr",
                                      "May",
                                      "Jun",
                                      "Jul",
                                      "Aug",
                                      "Sep",
                                      "Oct",
                                      "Nov",
                                      "Dec",
                                    ];
                                    modifyCubit.updateReturnDate(
                                      "${nextDay.day}-${monthNames[nextDay.month - 1]}-${nextDay.year}",
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: Text('modifySearch.addReturnDate'.tr()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppColors.splashBackgroundColorEnd,
                                  side: BorderSide(
                                    color: AppColors.splashBackgroundColorEnd,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Passenger field
                          _buildPassengerField(context, state, modifyCubit),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Apply button
                GradientButton(
                  onPressed: () => _applySearch(context, state),
                  text: 'modifySearch.applyChanges'.tr(),
                  height: 50,
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPassengerField(
    BuildContext context,
    ModifySearchState state,
    ModifySearchCubit cubit,
  ) {
    final totalPassengers = state.adults + state.children + state.infants;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.77,
              minChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) => PassengerSelectionModal(
                adults: state.adults,
                children: state.children,
                infants: state.infants,
                cabinClass: state.cabinClass,
                onPassengersChanged: (adults, children, infants) {
                  cubit.updatePassengers(adults, children, infants);
                },
                onCabinClassChanged: (cabinClass) {
                  cubit.updateCabinClass(cabinClass);
                },
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.people, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPassengerSummary(totalPassengers, state.cabinClass),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPassengerBreakdown(
                      state.adults,
                      state.children,
                      state.infants,
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  // Helper methods for passenger text
  String _getPassengerSummary(int totalPassengers, String cabinClass) {
    if (totalPassengers == 1) {
      return 'modifySearch.passengerSummarySingle'.tr(
        namedArgs: {'class': cabinClass.toCabinClassDisplayName.tr()},
      );
    } else {
      return 'modifySearch.passengerSummaryMultiple'.tr(
        namedArgs: {
          'count': totalPassengers.toString(),
          'class': cabinClass.toCabinClassDisplayName.tr(),
        },
      );
    }
  }

  String _getPassengerBreakdown(int adults, int children, int infants) {
    final parts = <String>[];

    if (adults > 0) {
      parts.add(
        'modifySearch.adults'.tr(namedArgs: {'count': adults.toString()}),
      );
    }

    if (children > 0) {
      parts.add(
        'modifySearch.children'.tr(namedArgs: {'count': children.toString()}),
      );
    }

    if (infants > 0) {
      parts.add(
        'modifySearch.infants'.tr(namedArgs: {'count': infants.toString()}),
      );
    }

    return parts.join(', ');
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isDeparture,
    ModifySearchCubit cubit,
    ModifySearchState state,
  ) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    // Set initial date based on existing selection
    if (isDeparture && state.departureDate.isNotEmpty) {
      initialDate = _parseDate(state.departureDate);
    } else if (!isDeparture && state.returnDate.isNotEmpty) {
      initialDate = _parseDate(state.returnDate);

      // For return date, ensure firstDate is at least the day after departure
      if (state.departureDate.isNotEmpty) {
        final departureDate = _parseDate(state.departureDate);
        firstDate = departureDate.add(const Duration(days: 1));

        // Ensure initialDate is not before firstDate
        if (initialDate.isBefore(firstDate)) {
          initialDate = firstDate;
        }
      }
    }

    // Ensure initialDate is not before firstDate
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.splashBackgroundColorEnd,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.splashBackgroundColorEnd,
              ),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      final formattedDate =
          "${picked.day}-${monthNames[picked.month - 1]}-${picked.year}";

      if (isDeparture) {
        cubit.updateDepartureDate(formattedDate);
        // If return date is before new departure date, clear it and show error
        if (state.hasReturnDate && state.returnDate.isNotEmpty) {
          final returnDate = _parseDate(state.returnDate);
          if (returnDate.isBefore(picked)) {
            cubit.updateReturnDate('');
            cubit.setShowDateError(true);
            _shakeReturnDateField();
          } else {
            cubit.setShowDateError(false);
          }
        }
      } else {
        cubit.updateReturnDate(formattedDate);
        // Validate return date is after departure
        if (state.departureDate.isNotEmpty) {
          final departureDate = _parseDate(state.departureDate);
          if (picked.isBefore(departureDate.add(const Duration(days: 1)))) {
            cubit.setShowDateError(true);
            _shakeReturnDateField();
          } else {
            cubit.setShowDateError(false);
          }
        }
      }
    }
  }

  void _showAirportBottomSheet(
    BuildContext context,
    bool isOrigin,
    ModifySearchCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => AirportBottomSheet(
            segmentId: "1",
            isOrigin: isOrigin,
            currentValue: isOrigin ? cubit.state.from : cubit.state.to,
            onAirportSelected: (airport) {
              if (isOrigin) {
                cubit.updateFrom(airport);
              } else {
                cubit.updateTo(airport);
              }
            },
          ),
        ),
      ),
    );
  }

  void _applySearch(BuildContext context, ModifySearchState state) {
    // Validate dates
    if (state.hasReturnDate && state.returnDate.isNotEmpty) {
      final departure = _parseDate(state.departureDate);
      final returnDate = _parseDate(state.returnDate);

      if (returnDate.isBefore(departure.add(const Duration(days: 1)))) {
        context.read<ModifySearchCubit>().setShowDateError(true);
        _shakeReturnDateField();
        return;
      }
    }

    try {
      // Call loadFlights WITHOUT context parameter
      widget.flightSearchCubit.loadFlights(state.toSearchData());

      // Close the modal sheet
      Navigator.pop(context);
    } catch (e) {
      // Show error message if loading fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('modifySearch.searchFailed'.tr(args: [e.toString()])),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
