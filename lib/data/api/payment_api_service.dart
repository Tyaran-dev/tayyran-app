// lib/data/api/payment_api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_price_details.dart';

class PaymentApiService {
  final DioClient _dioClient;

  PaymentApiService(this._dioClient);

  Future<Map<String, dynamic>> saveFlightData({
    required Map<String, dynamic> paymentData,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.saveFlight,
      data: paymentData,
    );
    prettyPrintJson(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> checkPaymentStatus({
    required Map<String, dynamic> paymentData,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.getPaymentStatus,
      data: paymentData,
    );
    prettyPrintJson(response.data);
    return response.data;
  }

  Future<HotelPriceDetails> getBookingPriceDetails(
    Map<String, dynamic> requestData,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints
            .getHotelPriceDetails, // Add this endpoint to your ApiEndpoints
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

  Future<Map<String, dynamic>> sendConfirmationEmail({
    required Map<String, dynamic> emailData,
  }) async {
    try {
      debugPrint("📤 API Service - Sending email data:");
      debugPrint("  - To: ${emailData['to']}");
      debugPrint(
        "  - Ticket info type: ${emailData['ticketInfo'].runtimeType}",
      );

      // Don't use postWithFullUrl, use the regular post method with correct baseUrl
      final response = await _dioClient.post(
        ApiEndpoints.sendConfirmationEmail,
        data: emailData,
        baseUrl: ApiEndpoints.sendEmailBaseUrl, // Use baseUrl parameter
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      prettyPrintJson(response.data);
      return response.data;
    } catch (e) {
      debugPrint("❌ API Service Error in sendConfirmationEmail: $e");
      rethrow;
    }
  }
}
