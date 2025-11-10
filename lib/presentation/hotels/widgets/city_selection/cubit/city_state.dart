// lib/presentation/hotels/cubit/city_state.dart
part of 'city_cubit.dart';

abstract class CityState {
  const CityState();
}

class CityInitial extends CityState {}

class CityLoading extends CityState {}

class CityTranslating extends CityState {
  final List<CityModel> cities;

  const CityTranslating(this.cities);
}

class CityLoaded extends CityState {
  final List<CityModel> cities;

  const CityLoaded(this.cities);
}

class CityError extends CityState {
  final String message;

  const CityError(this.message);
}
