import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/payment_status_response.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';

part 'payment_status_state.dart';

class PaymentStatusCubit extends Cubit<PaymentStatusState> {
  final PaymentRepository _paymentRepository;
  final String invoiceId;
  Timer? _statusCheckTimer;
  int _timerCount = 0;
  int _checkAttempts = 0;
  DateTime? _startTime;

  PaymentStatusCubit(this._paymentRepository, this.invoiceId)
    : super(PaymentStatusInitial(invoiceId: invoiceId, timerCount: 0)) {
    _startTime = DateTime.now();
    debugPrint("🟦 PaymentStatusCubit created - Invoice: $invoiceId");
    _startStatusMonitoring();
  }

  void _startStatusMonitoring() {
    debugPrint("🟦 Starting status monitoring");
    emit(
      PaymentStatusChecking(
        invoiceId: invoiceId,
        timerCount: _timerCount,
        checkAttempts: _checkAttempts,
        startTime: _startTime,
      ),
    );
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    _checkAttempts++;
    _timerCount = 0; // Reset timer count for each check

    debugPrint(
      "🟦 Checking payment status - Attempt: $_checkAttempts, Timer Count: $_timerCount",
    );

    try {
      final statusData = _prepareCheckPaymentData();
      debugPrint("🟦 Sending API request with data: $statusData");

      final response = await _paymentRepository.checkPaymentStatus(statusData);

      debugPrint(
        "✅ Payment status response received - Attempt: $_checkAttempts",
      );
      debugPrint("✅ Response status: ${response['status']}");
      debugPrint("✅ Full response: $response");

      final paymentStatusResponse = PaymentStatusResponse.fromJson(response);
      final status = paymentStatusResponse.status;

      debugPrint("✅ Payment status parsed: $status");

      switch (status.toUpperCase()) {
        case "PENDING":
          debugPrint("🟨 Payment is PENDING - Will check again in 8 seconds");
          emit(
            PaymentStatusPending(
              invoiceId: invoiceId,
              message: "Payment is being processed",
              timerCount: _timerCount,
              checkAttempts: _checkAttempts,
              startTime: _startTime,
            ),
          );
          _scheduleNextCheck();
          break;

        case "CONFIRMED":
          debugPrint("🟩 Payment CONFIRMED - Stopping timer");
          _statusCheckTimer?.cancel();
          emit(
            PaymentStatusConfirmed(
              invoiceId: invoiceId,
              orderData: paymentStatusResponse.order.data,
              timerCount: _timerCount,
              checkAttempts: _checkAttempts,
              startTime: _startTime,
              totalDuration: DateTime.now().difference(_startTime!).inSeconds,
            ),
          );
          break;

        case "FAILED":
          debugPrint("🟥 Payment FAILED - Stopping timer");
          _statusCheckTimer?.cancel();
          emit(
            PaymentStatusFailed(
              invoiceId: invoiceId,
              reason: "Payment failed. Your money will be refunded.",
              timerCount: _timerCount,
              checkAttempts: _checkAttempts,
              startTime: _startTime,
              totalDuration: DateTime.now().difference(_startTime!).inSeconds,
            ),
          );
          break;

        default:
          debugPrint("🟧 Unknown status: $status");
          emit(
            PaymentStatusError(
              invoiceId: invoiceId,
              errorMessage: "Unknown status: $status",
              timerCount: _timerCount,
              checkAttempts: _checkAttempts,
              startTime: _startTime,
            ),
          );
      }
    } catch (error, stackTrace) {
      debugPrint("❌ Status check error: $error");
      debugPrint("❌ Stack trace: $stackTrace");
      emit(
        PaymentStatusError(
          invoiceId: invoiceId,
          errorMessage: "Failed to check payment status. Please try again.",
          timerCount: _timerCount,
          checkAttempts: _checkAttempts,
          startTime: _startTime,
        ),
      );
      _scheduleNextCheck();
    }
  }

  void _scheduleNextCheck() {
    debugPrint(
      "🟦 Scheduling next check - Timer will run every second, API call every 8 seconds",
    );
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerCount++;

      debugPrint("⏰ Timer tick: $_timerCount seconds elapsed");

      // Check status every 8 seconds
      if (_timerCount % 8 == 0) {
        debugPrint("🟦 8 seconds reached - Calling API check");
        _checkPaymentStatus();
      } else {
        // Update UI with current timer count for any "waiting" state
        final currentState = state;
        if (currentState is PaymentStatusPending) {
          debugPrint(
            "⏳ Pending state update - Timer: $_timerCount, Next check in: ${8 - (_timerCount % 8)} seconds",
          );
          emit(
            PaymentStatusPending(
              invoiceId: invoiceId,
              message: currentState.message,
              timerCount: _timerCount,
              checkAttempts: _checkAttempts,
              startTime: _startTime,
            ),
          );
        } else if (currentState is PaymentStatusError) {
          debugPrint("🟧 Error state update - Timer: $_timerCount");
          emit(
            PaymentStatusError(
              invoiceId: invoiceId,
              errorMessage: currentState.errorMessage,
              timerCount: _timerCount,
              checkAttempts: _checkAttempts,
              startTime: _startTime,
            ),
          );
        }
      }
    });
  }

  Map<String, dynamic> _prepareCheckPaymentData() {
    return {"invoiceId": invoiceId};
  }

  void checkStatusManually() {
    debugPrint("🟦 Manual status check triggered");
    _statusCheckTimer?.cancel();
    _checkPaymentStatus();
  }

  void cancelMonitoring() {
    debugPrint("🟦 Monitoring cancelled");
    _statusCheckTimer?.cancel();
    emit(
      PaymentStatusCancelled(
        invoiceId: invoiceId,
        timerCount: _timerCount,
        checkAttempts: _checkAttempts,
        startTime: _startTime,
      ),
    );
  }

  @override
  Future<void> close() {
    debugPrint("🟦 PaymentStatusCubit closed");
    _statusCheckTimer?.cancel();
    return super.close();
  }
}
