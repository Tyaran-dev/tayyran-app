// lib/data/api/hotel_api_service.dart
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_price_details.dart';

class HotelApiService {
  final DioClient _dioClient;

  HotelApiService(this._dioClient);

  Future<HotelSearchModel> searchHotels(
    Map<String, dynamic> searchParams,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.hotelSearch,
        data: searchParams,
      );

      if (response.statusCode == 200) {
        return HotelSearchModel.fromJson(response.data);
      } else {
        throw Exception('Failed to search hotels: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Hotel Search API Error: $e');
      rethrow;
    }
  }

  Future<HotelData> getHotelDetails(
    String hotelCode,
    Map<String, dynamic> searchParams,
  ) async {
    try {
      // You might need to adjust this endpoint based on your API
      final response = await _dioClient.post(
        '${ApiEndpoints.hotelDetails}/$hotelCode',
        data: searchParams,
      );

      if (response.statusCode == 200) {
        return HotelData.fromJson(response.data['data'] ?? response.data);
      } else {
        throw Exception('Failed to load hotel details: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Hotel Details API Error: $e');
      rethrow;
    }
  }

  Future<HotelPriceDetails> getBookingPriceDetails(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.getHotelPriceDetails,
        data: requestData,
      );

      if (response.statusCode == 200) {
        return HotelPriceDetails.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Failed to fetch price details: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('🔥 Hotel Price Details API Error: $e');
      rethrow;
    }
  }
}
