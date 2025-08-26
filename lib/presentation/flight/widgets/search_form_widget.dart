// search_form_widget.dart - Updated multi-city design
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
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
                    if (state.tripType == "multi") {
                      for (final segment in state.flightSegments) {
                        if (segment.from.isEmpty ||
                            segment.to.isEmpty ||
                            segment.date.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all flight segments"),
                            ),
                          );
                          return;
                        }
                      }
                    } else {
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

                      if (state.tripType == "round" &&
                          state.returnDate.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select return date"),
                          ),
                        );
                        return;
                      }
                    }
                    cubit.search();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTripTypeSelector(FlightState state, FlightCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTripTypeChip(
            label: "One-way",
            isSelected: state.tripType == "oneway",
            icon: Icons.flight_takeoff,
            onTap: () => cubit.changeTripType("oneway"),
          ),
          _buildTripTypeChip(
            label: "Round-trip",
            isSelected: state.tripType == "round",
            icon: Icons.flight,
            onTap: () => cubit.changeTripType("round"),
          ),
          _buildTripTypeChip(
            label: "Multi-city",
            isSelected: state.tripType == "multi",
            icon: Icons.airline_stops,
            onTap: () => cubit.changeTripType("multi"),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightForm(
    FlightState state,
    FlightCubit cubit,
    BuildContext context,
  ) {
    if (state.tripType == "multi") {
      return _buildMultiCityForm(state, cubit, context);
    }

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
                    icon: const Icon(
                      Icons.swap_vert,
                      size: 20,
                      color: Colors.black,
                    ),
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

  Widget _buildMultiCityForm(
    FlightState state,
    FlightCubit cubit,
    BuildContext context,
  ) {
    return Column(
      children: [
        ...state.flightSegments.map((segment) {
          return _buildFlightSegment(
            segment,
            cubit,
            context,
            state.flightSegments.length > 2,
          );
        }),

        if (state.flightSegments.length < 8)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: OutlinedButton.icon(
              onPressed: () => cubit.addFlightSegment(),
              icon: const Icon(Icons.add),
              label: const Text("Add Another Flight"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.splashBackgroundColorEnd,
                side: BorderSide(color: AppColors.splashBackgroundColorEnd),
                backgroundColor: Colors.white, // Light gray background
              ),
            ),
          ),

        const SizedBox(height: 20),
        _buildPassengerField(state, cubit, context),
      ],
    );
  }

  Widget _buildFlightSegment(
    FlightSegment segment,
    FlightCubit cubit,
    BuildContext context,
    bool canDelete,
  ) {
    final index = state.flightSegments.indexOf(segment) + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Light gray background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with flight icon and number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.splashBackgroundColorEnd,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.flight, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Flight $index",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (canDelete)
                  Container(
                    width: 28, // Fixed width to prevent container expansion
                    height: 28, // Fixed height
                    decoration: BoxDecoration(
                      color: Colors.white, // Red background
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ), // Circular button
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => cubit.removeFlightSegment(segment.id),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(), // Remove default constraints
                      iconSize: 18, // Smaller icon
                      tooltip: 'Remove this flight',
                    ),
                  ),
              ],
            ),
          ),

          // Rest of the method remains the same...
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        _buildMultiCityTextField(
                          "From",
                          segment.from,
                          Icons.flight_takeoff,
                          true,
                          context,
                          cubit,
                          segment.id,
                        ),
                        const SizedBox(height: 12),
                        _buildMultiCityTextField(
                          "To",
                          segment.to,
                          Icons.flight_land,
                          false,
                          context,
                          cubit,
                          segment.id,
                        ),
                      ],
                    ),
                    Positioned(
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: IconButton(
                            icon: Icon(
                              Icons.swap_vert,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            onPressed: () {
                              cubit.updateFlightSegment(
                                segment.id,
                                segment.to,
                                segment.from,
                                segment.date,
                              );
                            },
                            padding: EdgeInsets.zero,
                            tooltip: 'Swap airports',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMultiCityDateField(
                  "Departure Date",
                  segment.date,
                  Icons.calendar_today,
                  () => _selectMultiCityDate(context, cubit, segment.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiCityTextField(
    String label,
    String value,
    IconData icon,
    bool isOrigin,
    BuildContext context,
    FlightCubit cubit,
    String segmentId,
  ) {
    return GestureDetector(
      onTap: () {
        cubit.showMultiCityAirportBottomSheet(context, isOrigin, segmentId);
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: const TextStyle(color: Colors.deepPurple),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiCityDateField(
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
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: const TextStyle(color: Colors.deepPurple),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectMultiCityDate(
    BuildContext context,
    FlightCubit cubit,
    String segmentId,
  ) async {
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

      final segment = state.flightSegments.firstWhere((s) => s.id == segmentId);
      cubit.updateFlightSegment(
        segmentId,
        segment.from,
        segment.to,
        formattedDate,
      );
    }
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

  // Update the _buildPassengerField method in search_form_widget.dart

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
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
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
                    "${state.totalPassengers} Passenger${state.totalPassengers > 1 ? 's' : ''} • ${state.cabinClass}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
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
