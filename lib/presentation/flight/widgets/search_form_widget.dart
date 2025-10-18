// lib/presentation/flight/widgets/search_form_widget.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/airport_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/date_text_field.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight/widgets/passenger_selection_modal.dart';

class SearchFormWidget extends StatefulWidget {
  const SearchFormWidget({super.key});

  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  bool _showDateError = false;
  final GlobalKey _returnDateKey = GlobalKey();

  void _validateDates(FlightState state) {
    if (state.tripType == "round" &&
        state.departureDate.isNotEmpty &&
        state.returnDate.isNotEmpty) {
      final departure = parseDate(state.departureDate);
      final returnDate = parseDate(state.returnDate);

      if (mounted) {
        setState(() {
          _showDateError = returnDate.isBefore(
            departure.add(const Duration(days: 1)),
          );
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _showDateError = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlightCubit, FlightState>(
      builder: (context, state) {
        // Validate dates when state changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _validateDates(state);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripTypeSelector(state, context),
            const SizedBox(height: 16),
            _buildFlightForm(state, context),
            const SizedBox(height: 20),
            Center(
              child: state.isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.splashBackgroundColorEnd,
                      ),
                    )
                  : GradientButton(
                      text: 'search_flights'.tr(),
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.90,
                      onPressed: () {
                        _validateAndSearch(context, state);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _validateAndSearch(BuildContext context, FlightState state) {
    final cubit = context.read<FlightCubit>();

    if (state.tripType == "multi") {
      for (final segment in state.flightSegments) {
        if (segment.from.isEmpty ||
            segment.to.isEmpty ||
            segment.date.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("fill_flight_segments".tr())));
          return;
        }
      }
    } else {
      if (state.from.isEmpty ||
          state.to.isEmpty ||
          state.departureDate.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("fill_required_fields".tr())));
        return;
      }

      if (state.tripType == "round" && state.returnDate.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("select_return_date".tr())));
        return;
      }

      if (state.tripType == "round" &&
          state.departureDate.isNotEmpty &&
          state.returnDate.isNotEmpty) {
        final departure = parseDate(state.departureDate);
        final returnDate = parseDate(state.returnDate);

        if (returnDate.isBefore(departure.add(const Duration(days: 1)))) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("return_date_error".tr())));
          return;
        }
      }
    }
    cubit.search(context);
  }

  Widget _buildTripTypeSelector(FlightState state, BuildContext context) {
    final cubit = context.read<FlightCubit>();

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
            label: "one_way".tr(),
            isSelected: state.tripType == "oneway",
            icon: Icons.flight_takeoff,
            onTap: () => cubit.changeTripType("oneway"),
          ),
          _buildTripTypeChip(
            label: "round_trip".tr(),
            isSelected: state.tripType == "round",
            icon: Icons.flight,
            onTap: () => cubit.changeTripType("round"),
          ),
          _buildTripTypeChip(
            label: "multi_city".tr(),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontFamily: "Almarai",
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightForm(FlightState state, BuildContext context) {
    final cubit = context.read<FlightCubit>();

    if (state.tripType == "multi") {
      return _buildMultiCityForm(state, context);
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
                  label: "from".tr(),
                  value: state.from,
                  icon: Icons.flight_takeoff,
                  onTap: () async {
                    final selectedAirport = await cubit.showAirportSelection(
                      context,
                      true,
                      state.from,
                    );
                    if (selectedAirport != null && mounted) {
                      cubit.setAirportSelection(true, selectedAirport);
                    }
                  },
                ),
                const SizedBox(height: 12),
                AirportTextField(
                  isOrigin: false,
                  label: "to".tr(),
                  value: state.to,
                  icon: Icons.flight_land,
                  onTap: () async {
                    final selectedAirport = await cubit.showAirportSelection(
                      context,
                      false,
                      state.to,
                    );
                    if (selectedAirport != null && mounted) {
                      cubit.setAirportSelection(false, selectedAirport);
                    }
                  },
                ),
              ],
            ),
            // Swap button - handles RTL automatically
            Positioned(
              right: isRTL(context) ? null : 0,
              left: isRTL(context) ? 16 : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
                      foregroundColor: AppColors.splashBackgroundColorEnd,
                      side: BorderSide(
                        color: AppColors.splashBackgroundColorEnd,
                      ),
                    ),
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
          DateTextField(
            label: "departure".tr(),
            value: state.departureDate,
            icon: Icons.calendar_today,
            onTap: () => _selectDate(context, isDeparture: true),
          )
        else
          Column(
            children: [
              DateTextField(
                label: "departure".tr(),
                value: state.departureDate,
                icon: Icons.calendar_today,
                onTap: () => _selectDate(context, isDeparture: true),
              ),
              const SizedBox(height: 12),
              Stack(
                key: _returnDateKey,
                children: [
                  DateTextField(
                    label: "return".tr(),
                    value: state.returnDate,
                    icon: Icons.calendar_today,
                    onTap: () => _selectDate(context, isDeparture: false),
                    hasError: _showDateError,
                  ),
                  if (_showDateError)
                    Positioned(
                      right: isRTL(context) ? null : 8,
                      left: isRTL(context) ? 8 : null,
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
                    "return_date_error".tr(),
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 12),
        _buildPassengerField(state, context),
      ],
    );
  }

  Widget _buildMultiCityForm(FlightState state, BuildContext context) {
    final cubit = context.read<FlightCubit>();

    return Column(
      children: [
        ...state.flightSegments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final displayIndex = index + 1;

          return _buildFlightSegment(
            segment,
            context,
            state.flightSegments.length > 2,
            displayIndex,
          );
        }),

        if (state.flightSegments.length < 8)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: OutlinedButton.icon(
              onPressed: () => cubit.addFlightSegment(),
              icon: const Icon(Icons.add),
              label: Text("add_another_flight".tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.splashBackgroundColorEnd,
                side: BorderSide(color: AppColors.splashBackgroundColorEnd),
                backgroundColor: Colors.white,
              ),
            ),
          ),

        const SizedBox(height: 20),
        _buildPassengerField(state, context),
      ],
    );
  }

  Widget _buildFlightSegment(
    FlightSegment segment,
    BuildContext context,
    bool canDelete,
    int displayIndex,
  ) {
    final cubit = context.read<FlightCubit>();

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
                    "${'flight'.tr()} $displayIndex",
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
                          label: "from".tr(),
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
                          label: "to".tr(),
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
                    // Swap button for multi-city - handles RTL
                    Positioned(
                      right: isRTL(context) ? null : 16,
                      left: isRTL(context) ? 16 : null,
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
                              color: Colors.black.withValues(alpha: 0.1),
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
                                englishDate: segment.englishDate,
                              );
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DateTextField(
                  label: "departure".tr(),
                  value: segment.date,
                  icon: Icons.calendar_today,
                  onTap: () => _selectMultiCityDate(context, segment.id),
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
    String segmentId,
  ) async {
    final cubit = context.read<FlightCubit>();
    final segment = cubit.state.flightSegments.firstWhere(
      (s) => s.id == segmentId,
    );

    // Get the segment index to determine minimum date
    final segmentIndex = cubit.getSegmentIndex(segmentId);
    final minDate = cubit.getMinDateForSegment(segmentIndex);

    DateTime initialDate = minDate;

    // If the segment already has a date, use it as initial date
    if (segment.date.isNotEmpty) {
      try {
        final currentDate = parseDate(segment.date);
        initialDate = currentDate.isBefore(minDate) ? minDate : currentDate;
      } catch (e) {
        print('Error parsing segment date: $e');
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
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

    if (picked != null && mounted) {
      final formattedDate = formatDateForDisplay(picked, context);
      final englishFormatDate = formatDateForBackend(picked);

      print('📅 Multi-city date selected:');
      print('   Display (Arabic): $formattedDate');
      print('   Backend (English): $englishFormatDate');

      cubit.updateFlightSegment(
        segmentId,
        segment.from,
        segment.to,
        formattedDate,
        englishDate: englishFormatDate, // Ensure English date is set
      );
    }
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isDeparture,
  }) async {
    final cubit = context.read<FlightCubit>();
    final state = cubit.state;

    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();

    if (isDeparture && state.departureDate.isNotEmpty) {
      initialDate = parseDate(state.departureDate);
    } else if (!isDeparture && state.returnDate.isNotEmpty) {
      initialDate = parseDate(state.returnDate);
      if (state.departureDate.isNotEmpty) {
        final departureDate = parseDate(state.departureDate);
        firstDate = departureDate.add(const Duration(days: 1));
        if (initialDate.isBefore(firstDate)) {
          initialDate = firstDate;
        }
      }
    }

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

    if (picked != null && mounted) {
      final formattedDate = formatDateForDisplay(picked, context);
      final englishFormatDate = formatDateForBackend(picked);

      print('📅 Date selected:');
      print('   Display (Arabic): $formattedDate');
      print('   Backend (English): $englishFormatDate');
      print('   Is Departure: $isDeparture');

      if (isDeparture) {
        cubit.setDepartureDate(formattedDate, englishDate: englishFormatDate);
        if (state.tripType == "round") {
          final nextDay = picked.add(const Duration(days: 1));
          final nextDayFormatted = formatDateForDisplay(nextDay, context);
          final nextDayEnglish = formatDateForBackend(nextDay);

          cubit.setReturnDate(nextDayFormatted, englishDate: nextDayEnglish);

          print('🔄 Auto-set return date:');
          print('   Display: $nextDayFormatted');
          print('   Backend: $nextDayEnglish');
        }
      } else {
        cubit.setReturnDate(formattedDate, englishDate: englishFormatDate);
      }
    }
  }

  Widget _buildPassengerField(FlightState state, BuildContext context) {
    final cubit = context.read<FlightCubit>();

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
                    "${state.totalPassengers} ${'passengers'.tr()} • ${state.cabinClass.toCabinClassDisplayName.tr()}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${state.adults} ${'adults'.tr()}, "
                    "${state.children} ${'children'.tr()}, "
                    "${state.infants} ${'infants'.tr()}",
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
