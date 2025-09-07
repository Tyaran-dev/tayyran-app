// lib/presentation/flight/cubit/airport_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/repositories/airport_repository.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_state.dart';

class AirportSearchCubit extends Cubit<AirportSearchState> {
  final AirportRepository _repository;

  AirportSearchCubit(this._repository) : super(AirportSearchInitial());

  Future<void> searchAirports(String query) async {
    if (query.isEmpty) {
      emit(AirportSearchInitial());
      return;
    }

    emit(AirportSearchLoading());

    try {
      // Detect language here and pass to repository
      final airports = await _repository.searchAirports(query);
      emit(AirportSearchLoaded(airports));
    } catch (e) {
      emit(AirportSearchError(e.toString()));
    }
  }

  void clearSearch() {
    emit(AirportSearchInitial());
  }
}
