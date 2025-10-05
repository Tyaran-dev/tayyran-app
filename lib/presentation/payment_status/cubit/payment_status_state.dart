part of 'payment_status_cubit.dart';

abstract class PaymentStatusState {
  final String invoiceId;
  final int timerCount;
  final int checkAttempts;
  final DateTime? startTime;

  const PaymentStatusState({
    required this.invoiceId,
    required this.timerCount,
    required this.checkAttempts,
    this.startTime,
  });
}

class PaymentStatusInitial extends PaymentStatusState {
  PaymentStatusInitial({required super.invoiceId, required super.timerCount})
    : super(checkAttempts: 0);
}

class PaymentStatusChecking extends PaymentStatusState {
  PaymentStatusChecking({
    required super.invoiceId,
    required super.timerCount,
    required super.checkAttempts,
    required super.startTime,
  });
}

class PaymentStatusPending extends PaymentStatusState {
  final String message;

  PaymentStatusPending({
    required super.invoiceId,
    required this.message,
    required super.timerCount,
    required super.checkAttempts,
    required super.startTime,
  });
}

class PaymentStatusConfirmed extends PaymentStatusState {
  final OrderData orderData;
  final int totalDuration;

  PaymentStatusConfirmed({
    required super.invoiceId,
    required this.orderData,
    required super.timerCount,
    required super.checkAttempts,
    required super.startTime,
    required this.totalDuration,
  });
}

class PaymentStatusFailed extends PaymentStatusState {
  final String reason;
  final int totalDuration;

  PaymentStatusFailed({
    required super.invoiceId,
    required this.reason,
    required super.timerCount,
    required super.checkAttempts,
    required super.startTime,
    required this.totalDuration,
  });
}

class PaymentStatusError extends PaymentStatusState {
  final String errorMessage;

  PaymentStatusError({
    required super.invoiceId,
    required this.errorMessage,
    required super.timerCount,
    required super.checkAttempts,
    required super.startTime,
  });
}

class PaymentStatusCancelled extends PaymentStatusState {
  PaymentStatusCancelled({
    required super.invoiceId,
    required super.timerCount,
    required super.checkAttempts,
    required super.startTime,
  });
}
