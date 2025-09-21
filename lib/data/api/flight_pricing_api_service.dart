// lib/data/api/flight_pricing_api_service.dart
import 'dart:convert';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';

class FlightPricingApiService {
  final DioClient _dioClient;

  FlightPricingApiService(this._dioClient);

  Future<Map<String, dynamic>> getFlightPricing(
    Map<String, dynamic> pricingData,
  ) async {
    try {
      print('🔄 FLIGHT PRICING API CALL INITIATED');
      print('💰 URL: ${ApiEndpoints.flightPricing}');
      print('📦 Request Data Keys: ${pricingData.keys.toList()}');
      print('📦 Mapping: ${pricingData['mapping']}');
      print(
        '📦 Flight: ${pricingData['airline']} ${pricingData['flightNumber']}',
      );
      _prettyPrintJson(pricingData);

      final response = await _dioClient.post(
        ApiEndpoints.flightPricing,
        data: pricingData,
      );

      print('✅ FLIGHT PRICING RESPONSE: ${response.statusCode}');
      print('📊 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        print('🎯 PRICING UPDATE SUCCESSFUL');
        return response.data;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to get flight pricing: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 FLIGHT PRICING API ERROR: $e');
      print('🔥 StackTrace: ${StackTrace.current}');
      rethrow;
    }
  }

  void _prettyPrintJson(Map<String, dynamic> json) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(json);
    final lines = prettyJson.split('\n');
    for (final line in lines) {
      print('  $line');
    }
  }
}
