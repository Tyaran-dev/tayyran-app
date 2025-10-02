// lib/presentation/payment/cubit/payment_state.dart
part of 'payment_cubit.dart';

abstract class PaymentState {
  final PaymentArguments args;

  const PaymentState(this.args);
}

class PaymentInitial extends PaymentState {
  PaymentInitial(super.args);
}

class PaymentLoading extends PaymentState {
  PaymentLoading(super.args);
}

class PaymentReady extends PaymentState {
  final MFCardPaymentView cardView;
  final String? sessionId;

  PaymentReady(super.args, this.cardView, this.sessionId);
}

// NEW: Payment validation state
class PaymentValidating extends PaymentState {
  PaymentValidating(super.args);
}

// NEW: Payment validation failed state
class PaymentValidationFailed extends PaymentState {
  final String message;

  PaymentValidationFailed(super.args, this.message);
}

class PaymentProcessing extends PaymentState {
  PaymentProcessing(super.args);
}

class PaymentAuthorized extends PaymentState {
  final String invoiceId;
  final dynamic paymentResponse;

  PaymentAuthorized(super.args, this.invoiceId, this.paymentResponse);
}

class PaymentFailed extends PaymentState {
  final String reason;

  PaymentFailed(super.args, this.reason);
}

class PaymentError extends PaymentState {
  final String errorMessage;

  PaymentError(super.args, this.errorMessage);
}
