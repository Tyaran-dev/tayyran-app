// lib/data/repositories/city_repository.dart
import 'package:tayyran_app/data/api/city_api_service.dart';
import 'package:tayyran_app/data/models/city_model.dart';

class CityRepository {
  final CityApiService _apiService;

  CityRepository(this._apiService);

  Future<List<CityModel>> getCitiesByCountryCode(String countryCode) async {
    try {
      final cities = await _apiService.getCitiesByCountryCode(countryCode);
      return cities;
    } catch (e) {
      rethrow;
    }
  }
}
