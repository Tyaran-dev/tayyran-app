// lib/data/api/flight_search_api_service.dart
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart'; // Import new model

class FlightSearchApiService {
  final DioClient _dioClient;

  FlightSearchApiService(this._dioClient);

  Future<FlightSearchResponse> searchFlights(
    Map<String, dynamic> searchData,
  ) async {
    try {
      print('🔍 Flight Search API Request:');
      print('   URL: ${ApiEndpoints.searchFlights}');
      print('   Request Body:');
      prettyPrintJson(searchData);

      final response = await _dioClient.post(
        ApiEndpoints.searchFlights,
        data: searchData,
      );

      print('✅ Flight Search Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return FlightSearchResponse.fromJson(response.data);
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Flight Search API Error: $e');
      rethrow;
    }
  }
}
