// lib/presentation/flight/cubit/flight_cubit.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
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
          englishDate: currentState.departureDateEnglish.isNotEmpty
              ? currentState.departureDateEnglish
              : _currentDateFormattedEnglish,
        ),
        FlightSegment(
          id: "2_$timestamp",
          from: "",
          to: "",
          date: currentState.departureDate.isNotEmpty
              ? _getNextDayFormatted(currentState.departureDate)
              : _getNextDayFormatted(_currentDateFormattedEnglish),
          englishDate: currentState.departureDateEnglish.isNotEmpty
              ? _getNextDayEnglish(currentState.departureDateEnglish)
              : _getNextDayEnglish(_currentDateFormattedEnglish),
        ),
      ];

      emit(state.copyWith(tripType: type, flightSegments: segments));
    }
    // If switching from one-way to round-trip and we have a departure date
    else if (currentState.tripType == "oneway" &&
        type == "round" &&
        currentState.departureDate.isNotEmpty) {
      // Parse the departure date and add one day
      final nextDayEnglish = _getNextDayEnglish(
        currentState.departureDateEnglish.isNotEmpty
            ? currentState.departureDateEnglish
            : currentState.departureDate,
      );

      emit(
        state.copyWith(
          tripType: type,
          returnDate: _getNextDayFormatted(currentState.departureDate),
          returnDateEnglish: nextDayEnglish,
        ),
      );
    }
    // If switching from round-trip to one-way, clear return date
    else if (currentState.tripType == "round" && type == "oneway") {
      emit(
        state.copyWith(
          tripType: type,
          returnDate: "",
          returnDateEnglish: "",
          flightSegments: [],
        ),
      );
    }
    // For other cases, just change the trip type
    else {
      emit(state.copyWith(tripType: type, flightSegments: []));
    }
  }

  // Helper methods for date calculations
  String _getNextDayFormatted(String dateString) {
    try {
      final date = parseDate(dateString);
      final nextDay = date.add(const Duration(days: 1));
      // For display format, we'll use a simple format since this is internal
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
      return "${nextDay.day}-${monthNames[nextDay.month - 1]}-${nextDay.year}";
    } catch (e) {
      print('❌ Error getting next day formatted: $e');
      return _currentDateFormattedEnglish;
    }
  }

  String _getNextDayEnglish(String dateString) {
    try {
      final date = parseDate(dateString);
      final nextDay = date.add(const Duration(days: 1));
      return formatDateForBackend(nextDay);
    } catch (e) {
      print('❌ Error getting next day English: $e');
      return _getNextDayEnglish(_currentDateFormattedEnglish);
    }
  }

  // Check if a date string is in the past
  bool _isDateInPast(String dateString) {
    try {
      final date = parseDate(dateString);
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

  // Get current date formatted - NOW USING HELPER FUNCTIONS
  String get _currentDateFormatted {
    // For internal use, use simple English format
    final now = DateTime.now();
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
    return "${now.day}-${monthNames[now.month - 1]}-${now.year}";
  }

  String get _currentDateFormattedEnglish {
    return formatDateForBackend(DateTime.now());
  }

  void initializeFlightSegments() {
    if (state.tripType == "multi") {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final segments = [
        FlightSegment(
          id: "1_$timestamp",
          from: "",
          to: "",
          date: state.departureDate.isNotEmpty
              ? state.departureDate
              : _currentDateFormatted,
          englishDate: state.departureDateEnglish.isNotEmpty
              ? state.departureDateEnglish
              : _currentDateFormattedEnglish,
        ),
        FlightSegment(
          id: "2_$timestamp",
          from: "",
          to: "",
          date: state.departureDate.isNotEmpty
              ? _getNextDayFormatted(state.departureDate)
              : _getNextDayFormatted(_currentDateFormatted),
          englishDate: state.departureDateEnglish.isNotEmpty
              ? _getNextDayEnglish(state.departureDateEnglish)
              : _getNextDayEnglish(_currentDateFormattedEnglish),
        ),
      ];
      emit(state.copyWith(flightSegments: segments));
    }
  }

  void addFlightSegment() {
    if (state.flightSegments.length < 8) {
      String nextDate = _currentDateFormatted;
      String nextDateEnglish = _currentDateFormattedEnglish;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Set the date to the day after the last segment if available
      if (state.flightSegments.isNotEmpty) {
        final lastSegment = state.flightSegments.last;
        if (lastSegment.date.isNotEmpty) {
          nextDate = _getNextDayFormatted(lastSegment.date);
          nextDateEnglish = _getNextDayEnglish(
            lastSegment.englishDate.isNotEmpty
                ? lastSegment.englishDate
                : lastSegment.date,
          );
        }
      }

      // Get the next sequential ID
      final nextId = "${state.flightSegments.length + 1}_$timestamp";

      final newSegment = FlightSegment(
        id: nextId,
        from: "",
        to: "",
        date: nextDate,
        englishDate: nextDateEnglish,
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

  void updateFlightSegment(
    String id,
    String from,
    String to,
    String date, {
    String? englishDate,
  }) {
    print('🔄 Updating flight segment:');
    print('   ID: $id');
    print('   From: $from, To: $to');
    print('   Date Display: $date');
    print('   Date English: $englishDate');

    final updatedSegments = state.flightSegments.map((segment) {
      if (segment.id == id) {
        return segment.copyWith(
          from: from,
          to: to,
          date: date,
          englishDate: englishDate ?? _convertToEnglishFormat(date),
        );
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
        final currentDate = parseDate(currentSegment.date);
        final previousDate = parseDate(previousSegment.date);

        // If current date is before or same as previous date, adjust it
        if (!currentDate.isAfter(previousDate)) {
          final nextDay = previousDate.add(const Duration(days: 1));
          final formattedNextDay = _getNextDayFormatted(previousSegment.date);
          final formattedNextDayEnglish = formatDateForBackend(nextDay);

          segments[i] = currentSegment.copyWith(
            date: formattedNextDay,
            englishDate: formattedNextDayEnglish,
          );
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
        final previousDate = parseDate(previousSegment.date);
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
        final currentDate = parseDate(currentSegment.date);
        final previousDate = parseDate(previousSegment.date);

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
        orElse: () =>
            FlightSegment(id: '', from: '', to: '', date: '', englishDate: ''),
      );

      if (isOrigin) {
        updateFlightSegment(
          segmentId,
          airportCode,
          segment.to,
          segment.date,
          englishDate: segment.englishDate,
        );
      } else {
        updateFlightSegment(
          segmentId,
          segment.from,
          airportCode,
          segment.date,
          englishDate: segment.englishDate,
        );
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

  void setDepartureDate(String date, {String? englishDate}) {
    print('✈️ Setting departure date:');
    print('   Display: $date');
    print('   English provided: $englishDate');

    final finalEnglishDate = englishDate ?? _convertToEnglishFormat(date);
    print('   English final: $finalEnglishDate');

    emit(
      state.copyWith(
        departureDate: date,
        departureDateEnglish: finalEnglishDate,
      ),
    );
  }

  void setReturnDate(String date, {String? englishDate}) {
    print('✈️ Setting return date:');
    print('   Display: $date');
    print('   English provided: $englishDate');

    final finalEnglishDate = englishDate ?? _convertToEnglishFormat(date);
    print('   English final: $finalEnglishDate');

    emit(state.copyWith(returnDate: date, returnDateEnglish: finalEnglishDate));
  }

  // Helper to convert display date to English format
  String _convertToEnglishFormat(String displayDate) {
    if (displayDate.isEmpty) {
      print('❌ Empty display date provided for conversion');
      return "";
    }

    try {
      print('🔄 Converting display date to English: "$displayDate"');
      final date = parseDate(displayDate);
      final englishDate = formatDateForBackend(date);
      print('✅ Conversion successful: "$displayDate" -> "$englishDate"');
      return englishDate;
    } catch (e) {
      print('❌ Error converting "$displayDate" to English format: $e');
      // Fallback: try to extract date parts manually
      try {
        final parts = displayDate.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = getMonthNumberFromLocalizedName(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          final englishDate = formatDateForBackend(date);
          print('✅ Manual conversion successful: "$englishDate"');
          return englishDate;
        }
      } catch (e2) {
        print('❌ Manual conversion also failed: $e2');
      }
      return displayDate; // Last resort fallback
    }
  }

  void setPassengers(int adults, int children, int infants) {
    print(
      '🔧 Setting passengers: adults=$adults, children=$children, infants=$infants',
    );
    emit(state.copyWith(adults: adults, children: children, infants: infants));
  }

  void setCabinClass(String cabinClass) {
    print('🔧 Setting cabin class to: $cabinClass');
    emit(state.copyWith(cabinClass: cabinClass));
  }

  // MAIN SEARCH METHOD
  Future<void> search(BuildContext context) async {
    print('🚀 Starting search process...');

    if (state.tripType == "multi") {
      await _handleMultiCitySearch(context);
    } else {
      await _handleRegularSearch(context);
    }
  }

  Future<void> _handleMultiCitySearch(BuildContext context) async {
    // Validate all segments have required data
    for (final segment in state.flightSegments) {
      if (segment.from.isEmpty || segment.to.isEmpty || segment.date.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all flight segments".tr())),
        );
        return;
      }
    }

    // Validate date sequence
    if (!validateMultiCityDates()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Flight dates must be in chronological order".tr()),
        ),
      );
      return;
    }

    print('🔍 Multi-city search - skipping recent searches');
    navigateToSearchResults(context);
  }

  Future<void> _handleRegularSearch(BuildContext context) async {
    print('🔍 Handling regular search...');

    // Validate required fields
    if (state.from.isEmpty || state.to.isEmpty || state.departureDate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("fill_required_fields".tr())));
      return;
    }

    // Validate return date for round trips
    if (state.tripType == "round" && state.returnDate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("select_return_date".tr())));
      return;
    }

    // Validate date logic for round trips
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

    try {
      final newSearch = RecentSearchModel(
        from: state.from,
        to: state.to,
        date: state.departureDate,
        returnDate: state.tripType == "round" ? state.returnDate : "",
        passengers: state.totalPassengers,
        adults: state.adults,
        children: state.children,
        infants: state.infants,
        flightClass: state.cabinClass,
        timestamp: DateTime.now(),
        type: 'flight',
        tripType: state.tripType,
      );

      // Only save to recent searches if it's not a duplicate
      if (!_isDuplicateSearch(newSearch)) {
        final allSearches = await SharedPreferencesService.loadRecentSearches();
        final flightSearches = allSearches
            .where((search) => search['type'] == 'flight')
            .map((json) => RecentSearchModel.fromJson(json))
            .toList();

        final updatedFlightSearches = List<RecentSearchModel>.from(
          flightSearches,
        )..insert(0, newSearch);

        // Keep only the 5 most recent searches
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

        print('💾 Saved regular search to recent searches');
      } else {
        print('🔍 Duplicate search - not saving to recent searches');
      }

      // Navigate to search results
      navigateToSearchResults(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error in regular search: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search error: $e'.tr())));
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

  // void prefillFromRecentSearch(RecentSearchModel search) {
  //   // Check if dates are in past and replace with current date if needed
  //   String departureDate = search.date;
  //   String returnDate = search.returnDate;

  //   if (_isDateInPast(departureDate)) {
  //     departureDate = _currentDateFormatted;
  //   }

  //   if (returnDate.isNotEmpty && _isDateInPast(returnDate)) {
  //     final departure = parseDate(departureDate);
  //     final nextDay = departure.add(const Duration(days: 1));
  //     returnDate = _getNextDayFormatted(departureDate);
  //   }

  //   emit(
  //     state.copyWith(
  //       from: search.from,
  //       to: search.to,
  //       departureDate: departureDate,
  //       returnDate: returnDate,
  //       adults: search.adults,
  //       children: search.children,
  //       infants: search.infants,
  //       cabinClass: search.flightClass,
  //       tripType: search.tripType ?? "oneway",
  //     ),
  //   );
  // }
  // In FlightCubit - quick fix version
  void prefillFromRecentSearch(RecentSearchModel search, BuildContext context) {
    // Check if dates are in past and replace with current date if needed
    String departureDate = search.date;
    String returnDate = search.returnDate;

    if (_isDateInPast(departureDate)) {
      departureDate = _currentDateFormatted;
    }

    if (returnDate.isNotEmpty && _isDateInPast(returnDate)) {
      final departure = parseDate(departureDate);
      final nextDay = departure.add(const Duration(days: 1));
      returnDate = formatDateForDisplay(nextDay, context);
    }

    // Convert dates to current app locale using helper functions
    final formattedDepartureDate = _convertToAppLocale(departureDate, context);
    final formattedReturnDate = returnDate.isNotEmpty
        ? _convertToAppLocale(returnDate, context)
        : '';

    emit(
      state.copyWith(
        from: search.from,
        to: search.to,
        departureDate: formattedDepartureDate,
        returnDate: formattedReturnDate,
        adults: search.adults,
        children: search.children,
        infants: search.infants,
        cabinClass: search.flightClass,
        tripType: search.tripType ?? "oneway",
      ),
    );
  }

  String _convertToAppLocale(String dateString, BuildContext context) {
    if (dateString.isEmpty) return "";

    try {
      final dateTime = parseDate(dateString);
      // This will use your existing helper function that respects the current locale
      return formatDateForDisplay(dateTime, context);
    } catch (e) {
      print('❌ Error converting date to app locale: $e');
      return dateString;
    }
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
    print('🎯 Navigating to search results...');

    Map<String, dynamic> searchData;

    // Debug print to check what dates we have
    print('🔍 Checking dates before sending to backend:');
    print('   Departure Display: "${state.departureDate}"');
    print('   Departure English: "${state.departureDateEnglish}"');
    print('   Return Display: "${state.returnDate}"');
    print('   Return English: "${state.returnDateEnglish}"');

    for (final segment in state.flightSegments) {
      print('   Segment ${segment.id}:');
      print('     Display: "${segment.date}"');
      print('     English: "${segment.englishDate}"');
    }

    if (state.tripType == "multi") {
      searchData = {
        "flightType": "multi",
        "segments": state.flightSegments.map((segment) {
          // ALWAYS use englishDate for backend
          final backendDate = segment.englishDate.isNotEmpty
              ? segment.englishDate
              : _convertToEnglishFormat(segment.date);

          print('🚀 Sending segment ${segment.id} to backend: "$backendDate"');

          return {
            "id": segment.id,
            "from": segment.from,
            "to": segment.to,
            "date": backendDate,
          };
        }).toList(),
        "adults": state.adults,
        "children": state.children,
        "infants": state.infants,
        "cabinClass": state.cabinClass,
      };
    } else {
      // For regular searches, also ensure we use English dates
      final departureBackendDate = state.departureDateEnglish.isNotEmpty
          ? state.departureDateEnglish
          : _convertToEnglishFormat(state.departureDate);

      final returnBackendDate = state.returnDateEnglish.isNotEmpty
          ? state.returnDateEnglish
          : _convertToEnglishFormat(state.returnDate);

      print('🚀 Sending to backend:');
      print('   Departure: "$departureBackendDate"');
      print('   Return: "$returnBackendDate"');

      searchData = {
        "flightType": state.tripType,
        "from": state.from,
        "to": state.to,
        "departureDate": departureBackendDate,
        "returnDate": state.tripType == "round" ? returnBackendDate : "",
        "adults": state.adults,
        "children": state.children,
        "infants": state.infants,
        "cabinClass": state.cabinClass,
      };
    }

    print('🔍 Final search data for backend: $searchData');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<FlightSearchCubit>(),
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
