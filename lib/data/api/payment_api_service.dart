// lib/data/api/payment_api_service.dart
import 'package:tayyran_app/core/network/api_endpoints.dart';
import 'package:tayyran_app/core/network/dio_client.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';

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
}
