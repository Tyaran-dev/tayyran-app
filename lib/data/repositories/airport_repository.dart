// lib/data/repositories/airport_repository.dart
import 'package:tayyran_app/data/api/airport_api_service.dart';
import 'package:tayyran_app/data/models/airport_model.dart';

class AirportRepository {
  final AirportApiService _apiService;

  AirportRepository(this._apiService);

  Future<List<AirportModel>> searchAirports(String query) async {
    try {
      return await _apiService.searchAirports(query);
    } catch (e) {
      // Explicitly rethrow to ensure non-null return
      rethrow;
    }
  }
}
