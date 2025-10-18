// lib/presentation/payment/cubit/payment_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfatoorah_flutter/MFUtils.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:tayyran_app/core/services/payment_service.dart';
import 'package:tayyran_app/data/models/flight_pricing_response.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _paymentRepository;
  final PaymentArguments args;

  late MFCardPaymentView mfCardView;
  String? sessionId;
  bool _isProcessing = false;
  PaymentCubit(this._paymentRepository, this.args)
    : super(PaymentInitial(args)) {
    _initPayment();
  }
  void _initPayment() {
    PaymentService.init();
    _initiateSession();
    mfCardView = MFCardPaymentView(cardViewStyle: _cardViewStyle());
  }

  MFCardViewStyle _cardViewStyle() {
    MFCardViewStyle cardViewStyle = MFCardViewStyle();
    cardViewStyle.hideCardIcons = false;
    cardViewStyle.input?.fontFamily = MFFontFamily.Monaco;
    cardViewStyle.label?.fontWeight = MFFontWeight.Heavy;
    cardViewStyle.input?.inputMargin = 5;
    cardViewStyle.label?.display = true;
    cardViewStyle.input?.borderColor = getColorHexFromStr("##016733");
    cardViewStyle.savedCardText?.addCardText = MFFontWeight.Heavy;
    cardViewStyle.backgroundColor = getColorHexFromStr("#f9fafb");
    return cardViewStyle;
  }

  Future<void> _initiateSession() async {
    emit(PaymentLoading(state.args));

    MFInitiateSessionRequest request = MFInitiateSessionRequest();

    try {
      await MFSDK
          .initiateSession(request, (bin) {
            debugPrint("BIN: $bin");
          })
          .then((sessionResponse) {
            sessionId = sessionResponse.sessionId;
            mfCardView.load(sessionResponse, (bin) {
              debugPrint("Card BIN: $bin");
            });
            emit(PaymentReady(state.args, mfCardView, sessionId));
          });
    } catch (error) {
      debugPrint(error.toString());
      emit(PaymentError(state.args, error.toString()));
    }
  }

  Future<void> processPayment() async {
    // Prevent multiple simultaneous payments
    debugPrint(
      "pricingResponse 🚀  ${args.pricingResponse.data.flightOffers.first}",
    );
    if (_isProcessing) {
      debugPrint("⚠️ Payment already in progress, ignoring duplicate call");
      return;
    }

    debugPrint("🚀 Starting payment process");
    _isProcessing = true;
    // emit(PaymentProcessing(state.args));
    try {
      var request = MFExecutePaymentRequest(invoiceValue: args.amount);
      request.sessionId = sessionId;
      request.processingDetails?.autoCapture = false;
      request.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;
      request.language = MFLanguage.ARABIC;

      await mfCardView
          .pay(request, MFLanguage.ENGLISH, (mfInvoiceId) {
            debugPrint("✅ MyFatoorah Payment start");
            final paymentData = preparePaymentData(
              mfInvoiceId.toString(),
              args.pricingResponse,
              args.passengers,
            );
            // _validatePaymentData(paymentData); // Debug validation
            final paymentResponse = _paymentRepository.saveFlightData(
              paymentData,
            );
            debugPrint("✅ paymentResponse : $paymentResponse");

            debugPrint("✅ MyFatoorah Invoice ID: $mfInvoiceId");
          })
          .then((MFGetPaymentStatusResponse value) async {
            emit(PaymentProcessing(state.args));

            debugPrint(
              "🎉 Payment authorization completed with status: ${value.invoiceStatus}",
            );

            if ((value.invoiceStatus == "Pending") ||
                (value.invoiceStatus == "Authorized") ||
                (value.invoiceStatus == "Paid")) {
              //              // Create payment record in backend
              // final paymentData = _preparePaymentData(value.invoiceId.toString());
              // final paymentResponse = await _paymentRepository.saveFlightData(
              //   paymentData,
              // );
              // debugPrint(paymentResponse.toString());
              debugPrint(
                "📋 Created payment record with invoiceId: ${value.invoiceId.toString()}",
              );
              debugPrint(
                "📋 Created payment record with invoice Transactions: ${value.invoiceTransactions?.first.paymentId}",
              );

              // Payment authorized but not captured - navigate to status page
              emit(
                PaymentAuthorized(
                  state.args,
                  value.invoiceId.toString(),
                  value,
                ),
              );
            } else {
              // Payment failed
              emit(PaymentFailed(state.args, value.invoiceStatus ?? "Failed"));
            }
          })
          .catchError((error, stackTrace) {
            debugPrint("❌ Payment error: ${error.message}");

            // Handle specific error cases without emitting error states
            if (error.message == "Card details are invalid or missing!") {
              debugPrint(
                "🔄 SDK will handle invalid card details - no action needed",
              );
              // Just reset to ready state, SDK shows error in the card fields
              // emit(PaymentValidating(state.args));
            } else if (error.message == "Invalid data") {
              debugPrint("🔄 Invalid data - reinitializing session");
              _initiateSession();
            } else if (error.message == "User clicked cancel button") {
              debugPrint(
                "🔄 User cancelled payment - resetting to ready state",
              );
              emit(PaymentReady(state.args, mfCardView, sessionId));
            } else if (error.message?.contains("SessionExpired") == true) {
              debugPrint("🔄 Session expired - reinitializing session");
              _initiateSession();
            } else {
              debugPrint(
                "⚠️ Other error - resetting to ready state: ${error.message}",
              );
              // emit(PaymentReady(state.args, mfCardView, sessionId));
            }
          });
    } catch (error) {
      debugPrint("🔥 Payment process error: $error");
      emit(PaymentError(state.args, error.toString()));
    } finally {
      _isProcessing = false;
      debugPrint("🏁 Payment process finished");
    }
  }

  Map<String, dynamic> preparePaymentData(
    String invoiceId,
    FlightPricingResponse pricingResponse,
    List<Passenger> passengers,
  ) {
    // Use the first flight offer from the pricing response
    final flightOfferFromPricing = pricingResponse.data.flightOffers.first;
    return {
      "invoiceId": invoiceId,
      "bookingType": "flight",
      "flightData": {
        "flightOffer": flightOfferFromPricing.toJson(),
        "travelers": passengers
            .asMap()
            .entries
            .map(
              (entry) => entry.value.toTravelerJson(
                entry.key + 1,
                args.email,
                args.countryCode,
                args.phoneNumber,
              ),
            )
            .toList(),
        "bookingType": "flight",
      },
      "status": "pending",
    };
  }

  void retryPayment() {
    _initiateSession();
  }
}
