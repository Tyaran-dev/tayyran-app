// flight_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/flight_search_screen.dart';
import 'package:tayyran_app/presentation/home/model/recentsearch_model.dart';
import 'package:tayyran_app/presentation/home/widgets/airport_bottom_sheet.dart';

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
    emit(state.copyWith(tripType: type));
    if (type == "multi") {
      initializeFlightSegments();
    } else {
      emit(state.copyWith(flightSegments: []));
    }
  }

  void initializeFlightSegments() {
    if (state.tripType == "multi" && state.flightSegments.isEmpty) {
      final segments = [
        FlightSegment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          from: "",
          to: "",
          date: "",
        ),
        FlightSegment(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          from: "",
          to: "",
          date: "",
        ),
      ];
      emit(state.copyWith(flightSegments: segments));
    }
  }

  void addFlightSegment() {
    if (state.flightSegments.length < 8) {
      final newSegment = FlightSegment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: "",
        to: "",
        date: "",
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
    emit(state.copyWith(flightSegments: updatedSegments));
  }

  void setFrom(String value) {
    emit(state.copyWith(from: value));
  }

  void setTo(String value) {
    emit(state.copyWith(to: value));
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
    emit(state.copyWith(cabinClass: cabinClass));
  }

  Future<void> search(BuildContext context) async {
    if (state.tripType == "multi") {
      for (final segment in state.flightSegments) {
        if (segment.from.isEmpty ||
            segment.to.isEmpty ||
            segment.date.isEmpty) {
          return;
        }
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

        if (_isDuplicateSearch(newSearch)) {
          return;
        }

        final allSearches = await SharedPreferencesService.loadRecentSearches();
        final flightSearches = allSearches
            .where((search) => search['type'] == 'flight')
            .map((json) => RecentSearchModel.fromJson(json))
            .toList();

        final updatedFlightSearches = List<RecentSearchModel>.from(
          flightSearches,
        )..insert(0, newSearch);

        if (updatedFlightSearches.length > 10) {
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

        // Prepare multi-city data for backend
        final multiCityData = {
          "destinations": state.flightSegments.map((segment) {
            String fromCode = segment.from.split(' - ')[0];
            String toCode = segment.to.split(' - ')[0];

            List<String> dateParts = segment.date.split('-');
            String day = dateParts[0];
            String month = dateParts[1];
            String year = dateParts[2];

            Map<String, String> monthMap = {
              "Jan": "01",
              "Feb": "02",
              "Mar": "03",
              "Apr": "04",
              "May": "05",
              "Jun": "06",
              "Jul": "07",
              "Aug": "08",
              "Sep": "09",
              "Oct": "10",
              "Nov": "11",
              "Dec": "12",
            };

            String formattedDate =
                "$year-${monthMap[month]}-${day.padLeft(2, '0')}";

            return {
              "id": segment.id,
              "from": fromCode,
              "to": toCode,
              "date": formattedDate,
            };
          }).toList(),
          "adults": state.adults,
          "children": state.children,
          "infants": state.infants,
          "cabinClass": state.cabinClass,
        };

        if (kDebugMode) {
          print('Multi-city search data: $multiCityData');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving flight search: $e');
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

        if (_isDuplicateSearch(newSearch)) {
          return;
        }

        final allSearches = await SharedPreferencesService.loadRecentSearches();
        final flightSearches = allSearches
            .where((search) => search['type'] == 'flight')
            .map((json) => RecentSearchModel.fromJson(json))
            .toList();

        final updatedFlightSearches = List<RecentSearchModel>.from(
          flightSearches,
        )..insert(0, newSearch);

        if (updatedFlightSearches.length > 10) {
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
      } catch (e) {
        if (kDebugMode) {
          print('Error saving flight search: $e');
        }
      }
      navigateToSearchResults(
        context,
      ); // You'll need to pass context to this method
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
    emit(
      state.copyWith(
        from: search.from,
        to: search.to,
        departureDate: search.date,
        returnDate: search.returnDate,
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
        value: this, // Provide the existing cubit instance
        child: AirportBottomSheet(
          isOrigin: isOrigin,
          currentValue: isOrigin ? state.from : state.to,
        ),
      ),
    );
  }

  void navigateToSearchResults(BuildContext context) {
    if (state.tripType == "multi") {
      // Prepare multi-city data
      final searchData = {
        "type": "multi",
        "segments": state.flightSegments.map((segment) {
          return {"from": segment.from, "to": segment.to, "date": segment.date};
        }).toList(),
        "adults": state.adults,
        "children": state.children,
        "infants": state.infants,
        "passengers": state.totalPassengers,
        "cabinClass": state.cabinClass,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => FlightSearchCubit(),
            child: FlightSearchScreen(searchData: searchData),
          ),
        ),
      );
    } else {
      final searchData = {
        "type": state.tripType,
        "from": state.from,
        "to": state.to,
        "departureDate": state.departureDate,
        "returnDate": state.returnDate,
        "adults": state.adults,
        "children": state.children,
        "infants": state.infants,
        "passengers": state.totalPassengers,
        "cabinClass": state.cabinClass,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => FlightSearchCubit(),
            child: FlightSearchScreen(searchData: searchData),
          ),
        ),
      );
    }
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
        value: this, // Provide the existing cubit instance
        child: AirportBottomSheet(
          isOrigin: isOrigin,
          currentValue: currentValue,
          segmentId: segmentId,
        ),
      ),
    );
  }
}
