// lib/presentation/flight/cubit/airport_search_state.dart

import 'package:tayyran_app/data/models/airport_model.dart';

abstract class AirportSearchState {
  const AirportSearchState();
}

class AirportSearchInitial extends AirportSearchState {}

class AirportSearchLoading extends AirportSearchState {}

class AirportSearchLoaded extends AirportSearchState {
  final List<AirportModel> airports;

  const AirportSearchLoaded(this.airports);
}

class AirportSearchError extends AirportSearchState {
  final String message;

  const AirportSearchError(this.message);
}
