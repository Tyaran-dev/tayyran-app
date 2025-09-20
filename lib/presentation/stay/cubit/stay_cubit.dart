// stay_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/presentation/home/model/recentsearch_model.dart';

part 'stay_state.dart';

class StayCubit extends Cubit<StayState> {
  StayCubit() : super(StayState.initial()) {
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final allSearches = await SharedPreferencesService.loadRecentSearches();
      final staySearches = allSearches
          .where((search) => search['type'] == 'stay')
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();

      emit(state.copyWith(recentSearches: staySearches));
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  void setDestination(String value) {
    emit(state.copyWith(to: value));
  }

  void setCheckInDate(String date) {
    emit(state.copyWith(checkInDate: date));
  }

  void setCheckOutDate(String date) {
    emit(state.copyWith(checkOutDate: date));
  }

  void setRoomsAndGuests(int rooms, int guests) {
    emit(state.copyWith(rooms: rooms, guests: guests));
  }

  Future<void> search() async {
    if (state.to.isEmpty ||
        state.checkInDate.isEmpty ||
        state.checkOutDate.isEmpty) {
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));

      final newSearch = RecentSearchModel(
        from: "",
        to: state.to,
        date: state.checkInDate,
        returnDate: state.checkOutDate,
        passengers: state.guests,
        infants: 0,
        adults: 0,
        children: 0,
        flightClass: "",
        timestamp: DateTime.now(),
        type: 'stay',
        rooms: state.rooms,
      );

      // Load all existing searches
      final allSearches = await SharedPreferencesService.loadRecentSearches();
      final staySearches = allSearches
          .where((search) => search['type'] == 'stay')
          .map((json) => RecentSearchModel.fromJson(json))
          .toList();

      // Check for duplicates
      final isDuplicate = staySearches.any(
        (existingSearch) =>
            existingSearch.to == newSearch.to &&
            existingSearch.date == newSearch.date &&
            existingSearch.returnDate == newSearch.returnDate &&
            existingSearch.passengers == newSearch.passengers &&
            existingSearch.rooms == newSearch.rooms,
      );

      if (!isDuplicate) {
        // Add new search to stay searches
        final updatedStaySearches = List<RecentSearchModel>.from(staySearches)
          ..insert(0, newSearch);

        // Limit to 10 searches
        if (updatedStaySearches.length > 10) {
          updatedStaySearches.removeLast();
        }

        // Update all searches (preserve non-stay searches)
        final nonStaySearches = allSearches
            .where((search) => search['type'] != 'stay')
            .toList();

        final allUpdatedSearches = [
          ...updatedStaySearches.map((search) => search.toJson()),
          ...nonStaySearches,
        ];

        await SharedPreferencesService.saveRecentSearches(allUpdatedSearches);
        emit(state.copyWith(recentSearches: updatedStaySearches));
      }

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      print('Error saving stay search: $e');
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
        final nonStaySearches = allSearches
            .where((search) => search['type'] != 'stay')
            .toList();

        final allUpdatedSearches = [
          ...updatedSearches.map((search) => search.toJson()),
          ...nonStaySearches,
        ];

        await SharedPreferencesService.saveRecentSearches(allUpdatedSearches);
        emit(state.copyWith(recentSearches: updatedSearches));
      }
    } catch (e) {
      print('Error removing recent search: $e');
    }
  }

  Future<void> clearAllRecentSearches() async {
    try {
      // Get all non-stay searches
      final allSearches = await SharedPreferencesService.loadRecentSearches();
      final nonStaySearches = allSearches
          .where((search) => search['type'] != 'stay')
          .toList();

      // Save only non-stay searches
      await SharedPreferencesService.saveRecentSearches(nonStaySearches);
      emit(state.copyWith(recentSearches: []));
    } catch (e) {
      print('Error clearing all recent searches: $e');
    }
  }

  void prefillFromRecentSearch(RecentSearchModel search) {
    emit(
      state.copyWith(
        to: search.to,
        checkInDate: search.date,
        checkOutDate: search.returnDate,
        guests: search.passengers,
        rooms: search.rooms ?? 1,
      ),
    );
  }
}
