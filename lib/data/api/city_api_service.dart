// lib/data/api/city_api_service.dart - SIMPLIFIED VERSION
import 'package:dio/dio.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/data/models/city_model.dart';

class CityApiService {
  final DioClient _dioClient;

  CityApiService(this._dioClient);

  Future<List<CityModel>> getCitiesByCountryCode(String countryCode) async {
    try {
      print('🌍 Fetching cities for country code: $countryCode');

      final response = await _dioClient.post(
        ApiEndpoints.getCities,
        data: {"CountryCode": countryCode},
        baseUrl: ApiEndpoints.baseUrl,
      );

      print('✅ Cities API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Your API response structure: {data: [{Code: ..., Name: ...}, ...]}
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> cityData = responseData['data'] ?? [];

        final cities = cityData
            .map((json) => CityModel.fromJson(json))
            .toList();

        print(
          '🏙️ Successfully loaded ${cities.length} cities for $countryCode',
        );
        return cities;
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🔥 Dio Error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🔥 Cities API Error: $e');
      throw Exception('Failed to load cities: $e');
    }
  }
}
