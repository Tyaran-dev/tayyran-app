// lib/presentation/hotels/cubit/city_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/repositories/city_repository.dart';
import 'package:tayyran_app/data/models/city_model.dart';

part 'city_state.dart';

class CityCubit extends Cubit<CityState> {
  final CityRepository _cityRepository;

  CityCubit(this._cityRepository) : super(CityInitial());

  Future<void> loadCities(String countryCode) async {
    if (countryCode.isEmpty) {
      emit(CityError('Please select a country first'));
      return;
    }

    emit(CityLoading());

    try {
      final cities = await _cityRepository.getCitiesByCountryCode(countryCode);
      emit(CityLoaded(cities));
    } catch (e) {
      emit(CityError('Failed to load cities: ${e.toString()}'));
    }
  }

  void clearCities() {
    emit(CityInitial());
  }
}
