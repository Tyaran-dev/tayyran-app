// lib/data/repositories/flight_pricing_repository.dart
import 'package:tayyran_app/data/api/flight_pricing_api_service.dart';

class FlightPricingRepository {
  final FlightPricingApiService _apiService;

  FlightPricingRepository(this._apiService);

  Future<Map<String, dynamic>> getFlightPricing(
    Map<String, dynamic> pricingData,
  ) async {
    try {
      return await _apiService.getFlightPricing(pricingData);
    } catch (e) {
      rethrow;
    }
  }
}
