// lib/presentation/flight/cubit/flight_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/flight_search_screen.dart';
import 'package:tayyran_app/presentation/home/model/recentsearch_model.dart';
import 'package:tayyran_app/presentation/airport_search/airport_bottom_sheet.dart';

part 'flight_state.dart';

class FlightCubit extends Cubit<FlightState> {
  FlightCubit() : super(FlightState.initial()) {
    _initializeRecentSearches();
  }

  void _initializeRecentSearches() {
    _loadRecentSearches()
        .then((_) {
          if (kDebugMode) {
            print('Recent searches loaded successfully');
          }
        })
        .catchError((error) {
          if (kDebugMode) {
            print('Error initializing recent searches: $error');
          }
        });
  }

  Future<void> _loadRecentSearches() async {
    try {
      final savedSearches = await SharedPreferencesService.loadRecentSearches();
      final flightSearches = savedSearches
          .where((search) => search['type'] == 'flight')
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();
      emit(state.copyWith(recentSearches: flightSearches));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent searches: $e');
      }
      emit(state.copyWith(recentSearches: []));
    }
  }

  bool _isDuplicateSearch(RecentSearchModel newSearch) {
    return state.recentSearches.any(
      (existingSearch) =>
          existingSearch.from == newSearch.from &&
          existingSearch.to == newSearch.to &&
          existingSearch.date == newSearch.date &&
          existingSearch.returnDate == newSearch.returnDate &&
          existingSearch.passengers == newSearch.passengers &&
          existingSearch.flightClass == newSearch.flightClass &&
          existingSearch.tripType == newSearch.tripType,
    );
  }

  Future<void> clearAllRecentSearches() async {
    try {
      final allSearches = await SharedPreferencesService.loadRecentSearches();
      final nonFlightSearches = allSearches
          .where((search) => search['type'] != 'flight')
          .toList();

      await SharedPreferencesService.saveRecentSearches(nonFlightSearches);
      emit(state.copyWith(recentSearches: []));
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all recent searches: $e');
      }
      emit(state.copyWith(recentSearches: []));
    }
  }

  void changeTripType(String type) {
    final currentState = state;

    if (type == "multi") {
      // Always initialize segments when switching to multi-city
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final segments = [
        FlightSegment(
          id: "1_$timestamp",
          from: "",
          to: "",
          date: currentState.departureDate.isNotEmpty
              ? currentState.departureDate
              : "",
        ),
        FlightSegment(
          id: "2_$timestamp",
          from: "",
          to: "",
          date: currentState.departureDate.isNotEmpty
              ? _formatDate(
                  _parseDate(
                    currentState.departureDate,
                  ).add(const Duration(days: 1)),
                )
              : "",
        ),
      ];

      emit(state.copyWith(tripType: type, flightSegments: segments));
    }
    // If switching from one-way to round-trip and we have a departure date
    else if (currentState.tripType == "oneway" &&
        type == "round" &&
        currentState.departureDate.isNotEmpty) {
      // Parse the departure date and add one day
      final departure = _parseDate(currentState.departureDate);
      final nextDay = departure.add(const Duration(days: 1));
      final formattedReturnDate = _formatDate(nextDay);

      emit(state.copyWith(tripType: type, returnDate: formattedReturnDate));
    }
    // If switching from round-trip to one-way, clear return date
    else if (currentState.tripType == "round" && type == "oneway") {
      emit(state.copyWith(tripType: type, returnDate: "", flightSegments: []));
    }
    // For other cases, just change the trip type
    else {
      emit(state.copyWith(tripType: type, flightSegments: []));
    }
  }

  // Helper methods for date parsing and formatting
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
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
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

  // Check if a date string is in the past
  bool _isDateInPast(String dateString) {
    try {
      final date = _parseDate(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return date.isBefore(today);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if date is in past: $e');
      }
      return false;
    }
  }

  // Get current date formatted
  String get _currentDateFormatted {
    return _formatDate(DateTime.now());
  }

  void initializeFlightSegments() {
    if (state.tripType == "multi") {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final segments = [
        FlightSegment(
          id: "1_$timestamp",
          from: "",
          to: "",
          date: state.departureDate.isNotEmpty ? state.departureDate : "",
        ),
        FlightSegment(
          id: "2_$timestamp",
          from: "",
          to: "",
          date: state.departureDate.isNotEmpty
              ? _formatDate(
                  _parseDate(state.departureDate).add(const Duration(days: 1)),
                )
              : "",
        ),
      ];
      emit(state.copyWith(flightSegments: segments));
    }
  }

  void addFlightSegment() {
    if (state.flightSegments.length < 8) {
      String nextDate = "";
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Set the date to the day after the last segment if available
      if (state.flightSegments.isNotEmpty) {
        final lastSegment = state.flightSegments.last;
        if (lastSegment.date.isNotEmpty) {
          final lastDate = _parseDate(lastSegment.date);
          final nextDay = lastDate.add(const Duration(days: 1));
          nextDate = _formatDate(nextDay);
        }
      }

      // Get the next sequential ID
      final nextId = "${state.flightSegments.length + 1}_$timestamp";

      final newSegment = FlightSegment(
        id: nextId,
        from: "",
        to: "",
        date: nextDate,
      );

      final updatedSegments = List<FlightSegment>.from(state.flightSegments)
        ..add(newSegment);
      emit(state.copyWith(flightSegments: updatedSegments));
    }
  }

  void removeFlightSegment(String id) {
    if (state.flightSegments.length > 2) {
      final updatedSegments = state.flightSegments
          .where((segment) => segment.id != id)
          .toList();

      // After removal, validate and adjust dates of remaining segments
      _validateAndAdjustSegmentDates(updatedSegments);

      emit(state.copyWith(flightSegments: updatedSegments));
    }
  }

  void updateFlightSegment(String id, String from, String to, String date) {
    final updatedSegments = state.flightSegments.map((segment) {
      if (segment.id == id) {
        return segment.copyWith(from: from, to: to, date: date);
      }
      return segment;
    }).toList();

    // After updating, validate and adjust subsequent dates if needed
    _validateAndAdjustSegmentDates(updatedSegments);

    emit(state.copyWith(flightSegments: updatedSegments));
  }

  void _validateAndAdjustSegmentDates(List<FlightSegment> segments) {
    for (int i = 1; i < segments.length; i++) {
      final currentSegment = segments[i];
      final previousSegment = segments[i - 1];

      if (currentSegment.date.isNotEmpty && previousSegment.date.isNotEmpty) {
        final currentDate = _parseDate(currentSegment.date);
        final previousDate = _parseDate(previousSegment.date);

        // If current date is before or same as previous date, adjust it
        if (!currentDate.isAfter(previousDate)) {
          final nextDay = previousDate.add(const Duration(days: 1));
          final formattedNextDay = _formatDate(nextDay);

          segments[i] = currentSegment.copyWith(date: formattedNextDay);
        }
      }
    }
  }

  DateTime getMinDateForSegment(int segmentIndex) {
    if (segmentIndex == 0) {
      return DateTime.now(); // First segment can be any date from today
    }

    // Ensure we don't go out of bounds
    if (segmentIndex >= state.flightSegments.length) {
      return DateTime.now().add(const Duration(days: 1));
    }

    // Get the previous segment
    final previousSegment = state.flightSegments[segmentIndex - 1];

    // If previous segment has a date, return the day after that date
    if (previousSegment.date.isNotEmpty) {
      try {
        final previousDate = _parseDate(previousSegment.date);
        return previousDate.add(const Duration(days: 1));
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing previous segment date: $e');
        }
      }
    }

    // Fallback: return tomorrow if previous segment has no date
    return DateTime.now().add(const Duration(days: 1));
  }

  int getSegmentIndex(String segmentId) {
    for (int i = 0; i < state.flightSegments.length; i++) {
      if (state.flightSegments[i].id == segmentId) {
        return i;
      }
    }
    return -1;
  }

  bool validateMultiCityDates() {
    for (int i = 1; i < state.flightSegments.length; i++) {
      final currentSegment = state.flightSegments[i];
      final previousSegment = state.flightSegments[i - 1];

      if (currentSegment.date.isNotEmpty && previousSegment.date.isNotEmpty) {
        final currentDate = _parseDate(currentSegment.date);
        final previousDate = _parseDate(previousSegment.date);

        if (!currentDate.isAfter(previousDate)) {
          return false;
        }
      }
    }
    return true;
  }

  // Helper method to get sequence number from ID
  int getSequenceNumber(String id) {
    try {
      return int.parse(id.split('_')[0]);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing sequence number from ID: $id');
      }
      return 0;
    }
  }

  void setFrom(String value) {
    emit(state.copyWith(from: value));
  }

  void setTo(String value) {
    emit(state.copyWith(to: value));
  }

  void setAirportSelection(
    bool isOrigin,
    String airportCode, {
    String? segmentId,
  }) {
    if (segmentId != null) {
      // Multi-city segment
      final segment = state.flightSegments.firstWhere(
        (s) => s.id == segmentId,
        orElse: () => FlightSegment(id: '', from: '', to: '', date: ''),
      );

      if (isOrigin) {
        updateFlightSegment(segmentId, airportCode, segment.to, segment.date);
      } else {
        updateFlightSegment(segmentId, segment.from, airportCode, segment.date);
      }
    } else {
      // Regular search
      if (isOrigin) {
        setFrom(airportCode);
      } else {
        setTo(airportCode);
      }
    }
  }

  // Optional: Helper method to show airport bottom sheet
  Future<String?> showAirportSelection(
    BuildContext context,
    bool isOrigin,
    String currentValue, {
    String? segmentId,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AirportBottomSheet(
        isOrigin: isOrigin,
        currentValue: currentValue,
        segmentId: segmentId,
      ),
    );
  }

  void switchFromTo() {
    emit(state.copyWith(from: state.to, to: state.from));
  }

  void setDepartureDate(String date) {
    emit(state.copyWith(departureDate: date));
  }

  void setReturnDate(String date) {
    emit(state.copyWith(returnDate: date));
  }

  void setPassengers(int adults, int children, int infants) {
    emit(state.copyWith(adults: adults, children: children, infants: infants));
  }

  void setCabinClass(String cabinClass) {
    emit(state.copyWith(cabinClass: cabinClass.toCabinClassBackendValue));
  }

  Future<void> search(BuildContext context) async {
    if (state.tripType == "multi") {
      // Validate all segments have required data
      for (final segment in state.flightSegments) {
        if (segment.from.isEmpty ||
            segment.to.isEmpty ||
            segment.date.isEmpty) {
          return;
        }
      }

      // Validate date sequence
      if (!validateMultiCityDates()) {
        return;
      }

      try {
        final newSearch = RecentSearchModel(
          from: state.flightSegments.first.from,
          to: state.flightSegments.last.to,
          date: state.flightSegments.first.date,
          returnDate: "",
          passengers: state.totalPassengers,
          flightClass: state.cabinClass,
          timestamp: DateTime.now(),
          type: 'flight',
          tripType: state.tripType,
        );

        // Only save to recent searches if it's not a duplicate
        if (!_isDuplicateSearch(newSearch)) {
          final allSearches =
              await SharedPreferencesService.loadRecentSearches();
          final flightSearches = allSearches
              .where((search) => search['type'] == 'flight')
              .map((json) => RecentSearchModel.fromJson(json))
              .toList();

          final updatedFlightSearches = List<RecentSearchModel>.from(
            flightSearches,
          )..insert(0, newSearch);

          if (updatedFlightSearches.length > 5) {
            updatedFlightSearches.removeLast();
          }

          final nonFlightSearches = allSearches
              .where((search) => search['type'] != 'flight')
              .toList();

          final allUpdatedSearches = [
            ...updatedFlightSearches.map((search) => search.toJson()),
            ...nonFlightSearches,
          ];

          await SharedPreferencesService.saveRecentSearches(allUpdatedSearches);
          emit(state.copyWith(recentSearches: updatedFlightSearches));
        }

        navigateToSearchResults(context);
      } catch (e) {
        if (kDebugMode) {
          print('Error in multi-city search: $e');
        }
      }
    } else {
      if (state.from.isEmpty ||
          state.to.isEmpty ||
          state.departureDate.isEmpty) {
        return;
      }

      if (state.tripType == "round" && state.returnDate.isEmpty) {
        return;
      }

      try {
        final newSearch = RecentSearchModel(
          from: state.from,
          to: state.to,
          date: state.departureDate,
          returnDate: state.tripType == "round" ? state.returnDate : "",
          passengers: state.totalPassengers,
          flightClass: state.cabinClass,
          timestamp: DateTime.now(),
          type: 'flight',
          tripType: state.tripType,
        );

        // Only save to recent searches if it's not a duplicate
        if (!_isDuplicateSearch(newSearch)) {
          final allSearches =
              await SharedPreferencesService.loadRecentSearches();
          final flightSearches = allSearches
              .where((search) => search['type'] == 'flight')
              .map((json) => RecentSearchModel.fromJson(json))
              .toList();

          final updatedFlightSearches = List<RecentSearchModel>.from(
            flightSearches,
          )..insert(0, newSearch);

          if (updatedFlightSearches.length > 5) {
            updatedFlightSearches.removeLast();
          }

          final nonFlightSearches = allSearches
              .where((search) => search['type'] != 'flight')
              .toList();

          final allUpdatedSearches = [
            ...updatedFlightSearches.map((search) => search.toJson()),
            ...nonFlightSearches,
          ];

          await SharedPreferencesService.saveRecentSearches(allUpdatedSearches);
          emit(state.copyWith(recentSearches: updatedFlightSearches));
        }

        // ALWAYS navigate to search results, even for duplicates
        navigateToSearchResults(context);
      } catch (e) {
        if (kDebugMode) {
          print('Error in regular search: $e');
        }
      }
    }
  }

  Future<void> removeRecentSearch(int index) async {
    try {
      final updatedSearches = List<RecentSearchModel>.from(
        state.recentSearches,
      );
      if (index >= 0 && index < updatedSearches.length) {
        updatedSearches.removeAt(index);

        final allSearches = await SharedPreferencesService.loadRecentSearches();
        final nonFlightSearches = allSearches
            .where((search) => search['type'] != 'flight')
            .toList();

        final allUpdatedSearches = [
          ...updatedSearches.map((search) => search.toJson()),
          ...nonFlightSearches,
        ];

        await SharedPreferencesService.saveRecentSearches(allUpdatedSearches);
        emit(state.copyWith(recentSearches: updatedSearches));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing recent search: $e');
      }
    }
  }

  void prefillFromRecentSearch(RecentSearchModel search) {
    // Check if dates are in past and replace with current date if needed
    String departureDate = search.date;
    String returnDate = search.returnDate;

    if (_isDateInPast(departureDate)) {
      departureDate = _currentDateFormatted;
    }

    if (returnDate.isNotEmpty && _isDateInPast(returnDate)) {
      // For return date, set it to one day after departure date
      final departure = _parseDate(departureDate);
      final nextDay = departure.add(const Duration(days: 1));
      returnDate = _formatDate(nextDay);
    }

    emit(
      state.copyWith(
        from: search.from,
        to: search.to,
        departureDate: departureDate,
        returnDate: returnDate,
        adults: search.passengers,
        cabinClass: search.flightClass,
        tripType: search.tripType ?? "oneway",
      ),
    );
  }

  void showAirportBottomSheet(BuildContext context, bool isOrigin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<AirportSearchCubit>(context),
        child: AirportBottomSheet(
          isOrigin: isOrigin,
          currentValue: isOrigin ? state.from : state.to,
        ),
      ),
    );
  }

  void navigateToSearchResults(BuildContext context) {
    Map<String, dynamic> searchData;

    if (state.tripType == "multi") {
      searchData = {
        "type": "multi",
        "segments": state.flightSegments.map((segment) {
          return {
            "id": segment.id,
            "from": segment.from,
            "to": segment.to,
            "date": segment.date,
          };
        }).toList(),
        "adults": state.adults,
        "children": state.children,
        "infants": state.infants,
        "cabinClass": state.cabinClass,
      };
    } else {
      searchData = {
        "type": state.tripType,
        "from": state.from,
        "to": state.to,
        "departureDate": state.departureDate,
        "returnDate": state.returnDate,
        "adults": state.adults,
        "children": state.children,
        "infants": state.infants,
        "cabinClass": state.cabinClass,
      };
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<FlightSearchCubit>(), // FIXED: Use getIt
          child: FlightSearchScreen(searchData: searchData),
        ),
      ),
    );
  }

  void showMultiCityAirportBottomSheet(
    BuildContext context,
    bool isOrigin,
    String segmentId,
  ) {
    final segment = state.flightSegments.firstWhere((s) => s.id == segmentId);
    final currentValue = isOrigin ? segment.from : segment.to;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: this,
        child: AirportBottomSheet(
          isOrigin: isOrigin,
          currentValue: currentValue,
          segmentId: segmentId,
        ),
      ),
    );
  }
}
