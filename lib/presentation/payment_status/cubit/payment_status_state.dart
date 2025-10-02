// lib/presentation/payment_status/cubit/payment_status_state.dart
part of 'payment_status_cubit.dart';

abstract class PaymentStatusState {
  final String invoiceId;
  final PaymentArguments args;

  const PaymentStatusState({required this.invoiceId, required this.args});
}

class PaymentStatusInitial extends PaymentStatusState {
  PaymentStatusInitial({required super.invoiceId, required super.args});
}

class PaymentStatusChecking extends PaymentStatusState {
  PaymentStatusChecking({required super.invoiceId, required super.args});
}

class PaymentStatusPending extends PaymentStatusState {
  final String message;

  PaymentStatusPending({
    required super.invoiceId,
    required super.args,
    required this.message,
  });
}

class PaymentStatusConfirmed extends PaymentStatusState {
  final OrderData orderData;

  PaymentStatusConfirmed({
    required super.invoiceId,
    required super.args,
    required this.orderData,
  });
}

class PaymentStatusFailed extends PaymentStatusState {
  final String reason;

  PaymentStatusFailed({
    required super.invoiceId,
    required super.args,
    required this.reason,
  });
}

class PaymentStatusError extends PaymentStatusState {
  final String errorMessage;

  PaymentStatusError({
    required super.invoiceId,
    required super.args,
    required this.errorMessage,
  });
}

class PaymentStatusCancelled extends PaymentStatusState {
  PaymentStatusCancelled({required super.invoiceId, required super.args});
}
