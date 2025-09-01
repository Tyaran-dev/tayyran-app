// search_form_widget.dart - Complete with date validation
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/airport_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/date_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/home/widgets/passenger_selection_modal.dart';

class SearchFormWidget extends StatefulWidget {
  final FlightState state;
  final FlightCubit cubit;

  const SearchFormWidget({super.key, required this.state, required this.cubit});

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  bool _showDateError = false;
  final GlobalKey _returnDateKey = GlobalKey();

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

  String _formatDate(DateTime date) {
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
    return "${date.day}-${monthNames[date.month - 1]}-${date.year}";
  }

  void _validateDates() {
    if (widget.state.tripType == "round" &&
        widget.state.departureDate.isNotEmpty &&
        widget.state.returnDate.isNotEmpty) {
      final departure = _parseDate(widget.state.departureDate);
      final returnDate = _parseDate(widget.state.returnDate);

      setState(() {
        _showDateError = returnDate.isBefore(
          departure.add(const Duration(days: 1)),
        );
      });
    } else {
      setState(() {
        _showDateError = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Validate dates when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateDates();
    });
  }

  @override
  void didUpdateWidget(SearchFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Validate dates when state changes
    _validateDates();

    // Auto-set return date when switching from oneway to round trip with existing departure date
    if (widget.state.tripType == "round" &&
        oldWidget.state.tripType == "oneway" &&
        widget.state.departureDate.isNotEmpty &&
        widget.state.returnDate.isEmpty) {
      final departure = _parseDate(widget.state.departureDate);
      final nextDay = departure.add(const Duration(days: 1));
      widget.cubit.setReturnDate(_formatDate(nextDay));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTripTypeSelector(widget.state, widget.cubit),
        const SizedBox(height: 16),
        _buildFlightForm(widget.state, widget.cubit, context),
        const SizedBox(height: 20),
        Center(
          child: widget.state.isLoading
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
                    // Validate all fields
                    if (widget.state.tripType == "multi") {
                      for (final segment in widget.state.flightSegments) {
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
                      if (widget.state.from.isEmpty ||
                          widget.state.to.isEmpty ||
                          widget.state.departureDate.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all required fields"),
                          ),
                        );
                        return;
                      }

                      if (widget.state.tripType == "round" &&
                          widget.state.returnDate.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select return date"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Validate that return date is after departure date
                      if (widget.state.tripType == "round" &&
                          widget.state.departureDate.isNotEmpty &&
                          widget.state.returnDate.isNotEmpty) {
                        final departure = _parseDate(
                          widget.state.departureDate,
                        );
                        final returnDate = _parseDate(widget.state.returnDate);

                        if (returnDate.isBefore(
                          departure.add(const Duration(days: 1)),
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Return date must be after departure date",
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                      }
                    }
                    widget.cubit.search(context);
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
                AirportTextField(
                  isOrigin: true,

                  label: "From",
                  value: state.from,
                  icon: Icons.flight_takeoff,
                  onTap: () => cubit.showAirportBottomSheet(context, true),
                ),
                const SizedBox(height: 12),
                AirportTextField(
                  isOrigin: false,
                  label: "To",
                  value: state.to,
                  icon: Icons.flight_land,
                  onTap: () => cubit.showAirportBottomSheet(context, false),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.splashBackgroundColorEnd,
                      side: BorderSide(
                        color: AppColors.splashBackgroundColorEnd,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (state.tripType == "oneway")
          DateTextField(
            label: "Departure",
            value: state.departureDate,
            icon: Icons.calendar_today,
            onTap: () => _selectDate(context, cubit, isDeparture: true),
          )
        else
          Column(
            children: [
              DateTextField(
                label: "Departure",
                value: state.departureDate,
                icon: Icons.calendar_today,
                onTap: () => _selectDate(context, cubit, isDeparture: true),
              ),
              const SizedBox(height: 12),
              Stack(
                key: _returnDateKey,
                children: [
                  DateTextField(
                    label: "Return",
                    value: state.returnDate,
                    icon: Icons.calendar_today,
                    onTap: () =>
                        _selectDate(context, cubit, isDeparture: false),
                    hasError: _showDateError,
                  ),
                  if (_showDateError)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                ],
              ),
              if (_showDateError)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Return date must be after departure date",
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
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
                backgroundColor: Colors.white,
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
    final index = widget.state.flightSegments.indexOf(segment) + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => cubit.removeFlightSegment(segment.id),
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        AirportTextField(
                          isOrigin: true,
                          label: "From",
                          value: segment.from,
                          icon: Icons.flight_takeoff,
                          onTap: () => cubit.showMultiCityAirportBottomSheet(
                            context,
                            true,
                            segment.id,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AirportTextField(
                          isOrigin: false,
                          label: "To",
                          value: segment.to,
                          icon: Icons.flight_land,
                          onTap: () => cubit.showMultiCityAirportBottomSheet(
                            context,
                            false,
                            segment.id,
                          ),
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
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppColors.splashBackgroundColorEnd,
                              side: BorderSide(
                                color: AppColors.splashBackgroundColorEnd,
                              ),
                            ),
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
                DateTextField(
                  label: "Departure Date",
                  value: segment.date,
                  icon: Icons.calendar_today,
                  onTap: () => _selectMultiCityDate(context, cubit, segment.id),
                ),
              ],
            ),
          ),
        ],
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
      final formattedDate = _formatDate(picked);

      final segment = widget.state.flightSegments.firstWhere(
        (s) => s.id == segmentId,
      );
      cubit.updateFlightSegment(
        segmentId,
        segment.from,
        segment.to,
        formattedDate,
      );
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    FlightCubit cubit, {
    required bool isDeparture,
  }) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    // Set initial date based on existing selection
    if (isDeparture && widget.state.departureDate.isNotEmpty) {
      initialDate = _parseDate(widget.state.departureDate);
    } else if (!isDeparture && widget.state.returnDate.isNotEmpty) {
      initialDate = _parseDate(widget.state.returnDate);

      // For return date, ensure firstDate is at least the day after departure
      if (widget.state.departureDate.isNotEmpty) {
        final departureDate = _parseDate(widget.state.departureDate);
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
      final formattedDate = _formatDate(picked);

      if (isDeparture) {
        cubit.setDepartureDate(formattedDate);

        // Auto-set return date to next day when departure date changes in round trip
        if (widget.state.tripType == "round") {
          final nextDay = picked.add(const Duration(days: 1));
          cubit.setReturnDate(_formatDate(nextDay));
        }

        // If return date exists and is before the new departure date, clear it and show error
        if (widget.state.tripType == "round" &&
            widget.state.returnDate.isNotEmpty) {
          final returnDate = _parseDate(widget.state.returnDate);
          if (returnDate.isBefore(picked.add(const Duration(days: 1)))) {
            setState(() {
              _showDateError = true;
            });
          } else {
            setState(() {
              _showDateError = false;
            });
          }
        }
      } else {
        cubit.setReturnDate(formattedDate);

        // Validate return date is after departure
        if (widget.state.departureDate.isNotEmpty) {
          final departureDate = _parseDate(widget.state.departureDate);
          if (picked.isBefore(departureDate.add(const Duration(days: 1)))) {
            setState(() {
              _showDateError = true;
            });
          } else {
            setState(() {
              _showDateError = false;
            });
          }
        }
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
