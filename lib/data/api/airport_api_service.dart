// lib/data/api/airport_api_service.dart
import 'package:dio/dio.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/core/utils/helpers/language_detector.dart';
import 'package:tayyran_app/data/models/airport_model.dart';

class AirportApiService {
  final DioClient _dioClient;

  AirportApiService(this._dioClient);

  Future<List<AirportModel>> searchAirports(String query) async {
    try {
      final detectedLanguage = LanguageDetector.detectLanguage(query);
      // _dioClient.setLanguage(detectedLanguage);

      print('🔍 API Call: keyword=$query');
      print('🌐 Language Header: $detectedLanguage');

      final response = await _dioClient.get(
        ApiEndpoints.getAirport,
        queryParameters: {'keyword': query},
      );

      print('✅ Response Status: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data ?? [];
        print('📊 Parsed ${data.length} airports');
        return data.map((json) => AirportModel.fromJson(json)).toList();
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load airports: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 API Error Details:');
      print('   Error Type: ${e.runtimeType}');
      print('   Error Message: $e');
      if (e is DioException) {
        print('   Dio Error Type: ${e.type}');
        print('   Dio Error Message: ${e.message}');
      }
      rethrow;
    }
  }
}
