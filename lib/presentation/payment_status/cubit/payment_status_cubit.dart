// lib/presentation/payment_status/cubit/payment_status_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/payment_status_response.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';

part 'payment_status_state.dart';

class PaymentStatusCubit extends Cubit<PaymentStatusState> {
  final PaymentRepository _paymentRepository;
  final String invoiceId;
  final PaymentArguments args;
  Timer? _statusCheckTimer;

  PaymentStatusCubit(this._paymentRepository, this.invoiceId, this.args)
    : super(PaymentStatusInitial(invoiceId: invoiceId, args: args)) {
    // Start status monitoring immediately
    _startStatusMonitoring();
  }

  void _startStatusMonitoring() {
    emit(PaymentStatusChecking(invoiceId: invoiceId, args: args));
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final statusData = _prepareCheckPaymentData();
      final response = await _paymentRepository.checkPaymentStatus(statusData);

      debugPrint("🔍 Payment status response received");
      debugPrint("🔍 Response type: ${response.runtimeType}");
      debugPrint("🔍 Response keys: ${response.keys}");

      // Parse the response using the updated model
      final paymentStatusResponse = PaymentStatusResponse.fromJson(response);
      final status = paymentStatusResponse.status;

      debugPrint("🔍 Payment status parsed: $status");

      switch (status.toUpperCase()) {
        case "PENDING":
          emit(
            PaymentStatusPending(
              invoiceId: invoiceId,
              args: args,
              message: "Payment is being processed",
            ),
          );
          // Schedule next check after 8 seconds
          _scheduleNextCheck();
          break;

        case "CONFIRMED":
          _statusCheckTimer?.cancel();
          emit(
            PaymentStatusConfirmed(
              invoiceId: invoiceId,
              args: args,
              orderData: paymentStatusResponse.order.data,
            ),
          );
          break;

        case "FAILED":
          _statusCheckTimer?.cancel();
          emit(
            PaymentStatusFailed(
              invoiceId: invoiceId,
              args: args,
              reason: "Payment failed. Your money will be refunded.",
            ),
          );
          break;

        default:
          emit(
            PaymentStatusError(
              invoiceId: invoiceId,
              args: args,
              errorMessage: "Unknown status: $status",
            ),
          );
      }
    } catch (error, stackTrace) {
      debugPrint("❌ Status check error: $error");
      debugPrint("❌ Stack trace: $stackTrace");
      emit(
        PaymentStatusError(
          invoiceId: invoiceId,
          args: args,
          errorMessage: "Failed to check payment status. Please try again.",
        ),
      );
      // Continue monitoring even if there's an error
      _scheduleNextCheck();
    }
  }

  void _scheduleNextCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer(Duration(seconds: 8), _checkPaymentStatus);
  }

  Map<String, dynamic> _prepareCheckPaymentData() {
    return {"invoiceId": invoiceId};
  }

  void checkStatusManually() {
    _statusCheckTimer?.cancel();
    _checkPaymentStatus();
  }

  void cancelMonitoring() {
    _statusCheckTimer?.cancel();
    emit(PaymentStatusCancelled(invoiceId: invoiceId, args: args));
  }

  @override
  Future<void> close() {
    _statusCheckTimer?.cancel();
    return super.close();
  }
}

// lib/presentation/payment_status/cubit/payment_status_cubit.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tayyran_app/data/models/payment_status_response.dart';
// import 'package:tayyran_app/data/repositories/payment_repository.dart';
// import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';

// part 'payment_status_state.dart';

// class PaymentStatusCubit extends Cubit<PaymentStatusState> {
//   final PaymentRepository _paymentRepository;
//   final String invoiceId;
//   final PaymentArguments args;
//   Timer? _statusCheckTimer;
//   int _retryCount = 0;
//   static const int _maxRetries = 60; // 5 minutes at 5-second intervals
//   static const Duration _checkInterval = Duration(seconds: 5);

//   PaymentStatusCubit(this._paymentRepository, this.invoiceId, this.args)
//     : super(PaymentStatusInitial(invoiceId: invoiceId, args: args)) {
//     // Start automatic status monitoring immediately
//     _startAutomaticStatusMonitoring();
//   }

//   void _startAutomaticStatusMonitoring() {
//     emit(PaymentStatusChecking(invoiceId: invoiceId, args: args));
//     _checkPaymentStatus();
//   }

//   Future<void> _checkPaymentStatus() async {
//     try {
//       final statusData = _prepareCheckPaymentData();
//       final response = await _paymentRepository.checkPaymentStatus(statusData);

//       debugPrint("🔍 Payment status response received");
//       debugPrint("🔍 Response type: ${response.runtimeType}");
//       debugPrint("🔍 Response keys: ${response.keys}");

//       // Parse the response using the updated model
//       final paymentStatusResponse = PaymentStatusResponse.fromJson(response);
//       final status = paymentStatusResponse.status;

//       debugPrint("🔍 Payment status parsed: $status");

//       switch (status.toUpperCase()) {
//         case "PENDING":
//           _retryCount++;
//           if (_retryCount >= _maxRetries) {
//             _statusCheckTimer?.cancel();
//             emit(
//               PaymentStatusFailed(
//                 invoiceId: invoiceId,
//                 args: args,
//                 reason: "Payment timeout. Please contact support.",
//               ),
//             );
//           } else {
//             emit(
//               PaymentStatusPending(
//                 invoiceId: invoiceId,
//                 args: args,
//                 message: "Payment is being processed",
//               ),
//             );
//             _scheduleNextCheck();
//           }
//           break;

//         case "CONFIRMED":
//           _statusCheckTimer?.cancel();
//           emit(
//             PaymentStatusConfirmed(
//               invoiceId: invoiceId,
//               args: args,
//               orderData: paymentStatusResponse.order.data,
//             ),
//           );
//           break;

//         case "FAILED":
//           _statusCheckTimer?.cancel();
//           emit(
//             PaymentStatusFailed(
//               invoiceId: invoiceId,
//               args: args,
//               reason: "Payment failed. Your money will be refunded.",
//             ),
//           );
//           break;

//         default:
//           _retryCount++;
//           if (_retryCount >= _maxRetries) {
//             _statusCheckTimer?.cancel();
//             emit(
//               PaymentStatusError(
//                 invoiceId: invoiceId,
//                 args: args,
//                 errorMessage:
//                     "Maximum retry attempts reached. Please contact support.",
//               ),
//             );
//           } else {
//             emit(
//               PaymentStatusError(
//                 invoiceId: invoiceId,
//                 args: args,
//                 errorMessage: "Unknown status: $status",
//               ),
//             );
//             _scheduleNextCheck();
//           }
//       }
//     } catch (error, stackTrace) {
//       debugPrint("❌ Status check error: $error");
//       debugPrint("❌ Stack trace: $stackTrace");

//       _retryCount++;
//       if (_retryCount >= _maxRetries) {
//         _statusCheckTimer?.cancel();
//         emit(
//           PaymentStatusError(
//             invoiceId: invoiceId,
//             args: args,
//             errorMessage:
//                 "Unable to verify payment status. Please check your email or contact support.",
//           ),
//         );
//       } else {
//         emit(
//           PaymentStatusError(
//             invoiceId: invoiceId,
//             args: args,
//             errorMessage: "Failed to check payment status. Retrying...",
//           ),
//         );
//         _scheduleNextCheck();
//       }
//     }
//   }

//   void _scheduleNextCheck() {
//     _statusCheckTimer?.cancel();
//     _statusCheckTimer = Timer(_checkInterval, _checkPaymentStatus);
//   }

//   Map<String, dynamic> _prepareCheckPaymentData() {
//     return {"invoiceId": invoiceId};
//   }

//   void checkStatusManually() {
//     _statusCheckTimer?.cancel();
//     _retryCount = 0;
//     _checkPaymentStatus();
//   }

//   void cancelMonitoring() {
//     _statusCheckTimer?.cancel();
//     emit(PaymentStatusCancelled(invoiceId: invoiceId, args: args));
//   }

//   @override
//   Future<void> close() {
//     _statusCheckTimer?.cancel();
//     return super.close();
//   }
// }
