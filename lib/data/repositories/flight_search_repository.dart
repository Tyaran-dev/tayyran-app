// lib/data/repositories/flight_search_repository.dart
import 'package:tayyran_app/data/api/flight_search_api_service.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';

class FlightSearchRepository {
  final FlightSearchApiService _apiService;

  FlightSearchRepository(this._apiService);

  Future<FlightSearchResponse> searchFlights(
    Map<String, dynamic> searchData,
  ) async {
    try {
      return await _apiService.searchFlights(searchData);
    } catch (e) {
      rethrow;
    }
  }
}
