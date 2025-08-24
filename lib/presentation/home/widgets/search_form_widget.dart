// import 'package:flutter/material.dart';
// import 'package:tayyran_app/core/utils/widgets/index.dart';
// import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
// import 'package:tayyran_app/presentation/home/widgets/passenger_selection_modal.dart';

// class SearchFormWidget extends StatelessWidget {
//   final FlightState state; // Change to FlightState
//   final FlightCubit cubit; // Change to FlightCubit

//   const SearchFormWidget({super.key, required this.state, required this.cubit});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTripTypeSelector(state, cubit),
//         const SizedBox(height: 16),
//         _buildFlightForm(state, cubit, context),
//         const SizedBox(height: 20),
//         Center(
//           child: state.isLoading
//               ? CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).primaryColor,
//                   ),
//                 )
//               : GradientButton(
//                   text: 'Search Flights',
//                   height: 45,
//                   width: MediaQuery.of(context).size.width * 0.90,
//                   onPressed: () => cubit.search(),
//                 ),
//         ),
//       ],
//     );
//   }

//   // REMOVE the _buildTabs method entirely since tabs are now handled at HomeScreen level

//   Widget _buildTripTypeSelector(FlightState state, FlightCubit cubit) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         ChoiceChip(
//           label: const Text("One-way"),
//           selected: state.tripType == "oneway",
//           onSelected: (_) => cubit.changeTripType("oneway"),
//         ),
//         ChoiceChip(
//           label: const Text("Round-trip"),
//           selected: state.tripType == "round",
//           onSelected: (_) => cubit.changeTripType("round"),
//         ),
//         ChoiceChip(
//           label: const Text("Multi-city"),
//           selected: state.tripType == "multi",
//           onSelected: (_) => cubit.changeTripType("multi"),
//         ),
//       ],
//     );
//   }

//   Widget _buildFlightForm(
//     FlightState state,
//     FlightCubit cubit,
//     BuildContext context,
//   ) {
//     return Column(
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             Column(
//               children: [
//                 _buildTextField(
//                   "From",
//                   state.from,
//                   Icons.flight_takeoff,
//                   true,
//                   context,
//                   cubit, // Add cubit parameter
//                 ),
//                 const SizedBox(height: 12),
//                 _buildTextField(
//                   "To",
//                   state.to,
//                   Icons.flight_land,
//                   false,
//                   context,
//                   cubit, // Add cubit parameter
//                 ),
//               ],
//             ),
//             Positioned(
//               right: 16,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.black, width: 1.5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: CircleAvatar(
//                   backgroundColor: Colors.white,
//                   radius: 20,
//                   child: IconButton(
//                     icon: Icon(Icons.swap_vert, size: 20, color: Colors.black),
//                     onPressed: () => cubit.switchFromTo(),
//                     padding: EdgeInsets.zero,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         if (state.tripType == "oneway")
//           _buildDateField(
//             "Departure",
//             state.departureDate,
//             Icons.date_range,
//             () => _selectDate(context, cubit, isDeparture: true),
//           )
//         else
//           Row(
//             children: [
//               Expanded(
//                 child: _buildDateField(
//                   "Departure",
//                   state.departureDate,
//                   Icons.date_range,
//                   () => _selectDate(context, cubit, isDeparture: true),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildDateField(
//                   "Return",
//                   state.returnDate,
//                   Icons.date_range,
//                   () => _selectDate(context, cubit, isDeparture: false),
//                 ),
//               ),
//             ],
//           ),
//         const SizedBox(height: 12),
//         _buildPassengerField(state, cubit, context),
//       ],
//     );
//   }

//   Widget _buildTextField(
//     String label,
//     String value,
//     IconData icon,
//     bool isOrigin,
//     BuildContext context,
//     FlightCubit cubit, // Add cubit parameter
//   ) {
//     return GestureDetector(
//       onTap: () =>
//           cubit.showAirportBottomSheet(context, isOrigin), // Use passed cubit
//       child: AbsorbPointer(
//         child: TextField(
//           controller: TextEditingController(text: value),
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon),
//             labelText: label,
//             floatingLabelStyle: value.isEmpty
//                 ? TextStyle(color: Colors.deepPurple)
//                 : TextStyle(color: Colors.grey),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateField(
//     String label,
//     String value,
//     IconData icon,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AbsorbPointer(
//         child: TextField(
//           controller: TextEditingController(text: value),
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon),
//             labelText: label,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDate(
//     BuildContext context,
//     FlightCubit cubit, { // Change to FlightCubit
//     required bool isDeparture,
//   }) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 1),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).primaryColor,
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
//         cubit.setDepartureDate(formattedDate);
//       } else {
//         cubit.setReturnDate(formattedDate);
//       }
//     }
//   }

//   Widget _buildPassengerField(
//     FlightState state, // Change to FlightState
//     FlightCubit cubit, // Change to FlightCubit
//     BuildContext context,
//   ) {
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
//                 onPassengersChanged: (adults, children, infants) =>
//                     cubit.setPassengers(adults, children, infants),
//                 onCabinClassChanged: (cabinClass) =>
//                     cubit.setCabinClass(cabinClass),
//               ),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(12),
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
//                     "${state.totalPassengers} Passenger${state.totalPassengers > 1 ? 's' : ''}",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     "${state.adults} Adult${state.adults != 1 ? 's' : ''}, "
//                     "${state.children} Child${state.children != 1 ? 'ren' : ''}, "
//                     "${state.infants} Infant${state.infants != 1 ? 's' : ''}",
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
// }

// search_form_widget.dart (updated for FlightScreen)

import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/home/widgets/passenger_selection_modal.dart';

class SearchFormWidget extends StatelessWidget {
  final FlightState state;
  final FlightCubit cubit;

  const SearchFormWidget({super.key, required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTripTypeSelector(state, cubit),
        const SizedBox(height: 16),
        _buildFlightForm(state, cubit, context),
        const SizedBox(height: 20),
        Center(
          child: state.isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.splashBackgroundColorEnd,
                  ),
                )
              : GradientButton(
                  text: 'Search Flights',
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.90,
                  onPressed: () {
                    // Validate fields first
                    if (state.from.isEmpty ||
                        state.to.isEmpty ||
                        state.departureDate.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields"),
                        ),
                      );
                      return;
                    }
                    cubit.search();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTripTypeSelector(FlightState state, FlightCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ChoiceChip(
          label: const Text("One-way"),
          selected: state.tripType == "oneway",
          onSelected: (_) => cubit.changeTripType("oneway"),
        ),
        ChoiceChip(
          label: const Text("Round-trip"),
          selected: state.tripType == "round",
          onSelected: (_) => cubit.changeTripType("round"),
        ),
        ChoiceChip(
          label: const Text("Multi-city"),
          selected: state.tripType == "multi",
          onSelected: (_) => cubit.changeTripType("multi"),
        ),
      ],
    );
  }

  Widget _buildFlightForm(
    FlightState state,
    FlightCubit cubit,
    BuildContext context,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                _buildTextField(
                  "From",
                  state.from,
                  Icons.flight_takeoff,
                  true,
                  context,
                  cubit,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  "To",
                  state.to,
                  Icons.flight_land,
                  false,
                  context,
                  cubit,
                ),
              ],
            ),
            Positioned(
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: IconButton(
                    icon: Icon(Icons.swap_vert, size: 20, color: Colors.black),
                    onPressed: () => cubit.switchFromTo(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.tripType == "oneway")
          _buildDateField(
            "Departure",
            state.departureDate,
            Icons.date_range,
            () => _selectDate(context, cubit, isDeparture: true),
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  "Departure",
                  state.departureDate,
                  Icons.date_range,
                  () => _selectDate(context, cubit, isDeparture: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  "Return",
                  state.returnDate,
                  Icons.date_range,
                  () => _selectDate(context, cubit, isDeparture: false),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        _buildPassengerField(state, cubit, context),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    IconData icon,
    bool isOrigin,
    BuildContext context,
    FlightCubit cubit,
  ) {
    return GestureDetector(
      onTap: () => cubit.showAirportBottomSheet(context, isOrigin),
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: label,
            floatingLabelStyle: value.isEmpty
                ? const TextStyle(color: Colors.deepPurple)
                : const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    FlightCubit cubit, {
    required bool isDeparture,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
        cubit.setDepartureDate(formattedDate);
      } else {
        cubit.setReturnDate(formattedDate);
      }
    }
  }

  Widget _buildPassengerField(
    FlightState state,
    FlightCubit cubit,
    BuildContext context,
  ) {
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
                onPassengersChanged: (adults, children, infants) =>
                    cubit.setPassengers(adults, children, infants),
                onCabinClassChanged: (cabinClass) =>
                    cubit.setCabinClass(cabinClass),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
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
                    "${state.totalPassengers} Passenger${state.totalPassengers > 1 ? 's' : ''}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${state.adults} Adult${state.adults != 1 ? 's' : ''}, "
                    "${state.children} Child${state.children != 1 ? 'ren' : ''}, "
                    "${state.infants} Infant${state.infants != 1 ? 's' : ''}",
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
}
