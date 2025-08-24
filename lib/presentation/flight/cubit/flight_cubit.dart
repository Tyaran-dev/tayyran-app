// flight_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
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

  // Future<void> _saveRecentSearches(List<RecentSearchModel> searches) async {
  //   try {
  //     final searchesJson = searches.map((search) => search.toJson()).toList();
  //     await SharedPreferencesService.saveRecentSearches(searchesJson);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error saving recent searches: $e');
  //     }
  //   }
  // }

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
      // Get all searches
      final allSearches = await SharedPreferencesService.loadRecentSearches();
      // Filter out flight searches
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

  Future<void> search() async {
    if (state.from.isEmpty || state.to.isEmpty || state.departureDate.isEmpty) {
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

      // Load all existing searches
      final allSearches = await SharedPreferencesService.loadRecentSearches();
      final flightSearches = allSearches
          .where((search) => search['type'] == 'flight')
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();

      // Add new search to flight searches
      final updatedFlightSearches = List<RecentSearchModel>.from(flightSearches)
        ..insert(0, newSearch);

      // Limit to 10 searches
      if (updatedFlightSearches.length > 10) {
        updatedFlightSearches.removeLast();
      }

      // Update all searches (preserve non-flight searches)
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
  }

  Future<void> removeRecentSearch(int index) async {
    try {
      final updatedSearches = List<RecentSearchModel>.from(
        state.recentSearches,
      );
      if (index >= 0 && index < updatedSearches.length) {
        updatedSearches.removeAt(index);

        // Update all searches
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
            isOrigin: isOrigin,
            currentValue: isOrigin ? state.from : state.to,
            onAirportSelected: (airport) {
              if (isOrigin) {
                setFrom(airport);
              } else {
                setTo(airport);
              }
            },
          ),
        ),
      ),
    );
  }
}
