// lib/data/repositories/payment_repository.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/data/api/payment_api_service.dart';

class PaymentRepository {
  final PaymentApiService _apiService;

  PaymentRepository(this._apiService);

  Future<Map<String, dynamic>> saveFlightData(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      debugPrint("📤 Sending flight data to backend:");
      debugPrint("  - Invoice ID: ${paymentData['invoiceId']}");
      debugPrint(
        "  - Travelers count: ${paymentData['flightData']?['travelers']?.length ?? 0}",
      );

      // Print the entire payment data structure
      debugPrint("  - Full payment data keys: ${paymentData.keys.toList()}");
      debugPrint(
        "  - Flight data keys: ${paymentData['flightData']?.keys.toList()}",
      );

      if (paymentData['flightData']?['travelers'] != null) {
        final travelers = paymentData['flightData']?['travelers'] as List;
        debugPrint("  - Travelers array length: ${travelers.length}");
        for (int i = 0; i < travelers.length; i++) {
          final traveler = travelers[i] as Map<String, dynamic>;
          debugPrint(
            "    Traveler ${i + 1}: ${traveler['name']?['firstName']} ${traveler['name']?['lastName']}",
          );
        }
      }

      return await _apiService.saveFlightData(paymentData: paymentData);
    } catch (e) {
      debugPrint("❌ Error in saveFlightData: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPaymentStatus(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      debugPrint(
        "📤 Checking payment status for invoice: ${paymentData['invoiceId']}",
      );
      final response = await _apiService.checkPaymentStatus(
        paymentData: paymentData,
      );
      debugPrint("📥 Payment status response received");
      debugPrint("📥 Response type: ${response.runtimeType}");
      return response;
    } catch (e) {
      debugPrint("❌ Error in checkPaymentStatus: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendConfirmationEmail({
    required Map<String, dynamic> emailData,
  }) async {
    try {
      debugPrint("📤 Sending confirmation email:");
      debugPrint("  - To: ${emailData['to']}");
      debugPrint("  - Ticket info keys: ${emailData['ticketInfo']?.keys}");
      debugPrint("  - Full email data type: ${emailData.runtimeType}");

      return await _apiService.sendConfirmationEmail(emailData: emailData);
    } catch (e) {
      debugPrint("❌ Error in sendConfirmationEmail: $e");
      rethrow;
    }
  }
}
