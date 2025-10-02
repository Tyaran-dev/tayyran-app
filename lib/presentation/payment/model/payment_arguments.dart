// lib/core/routes/payment_arguments.dart
import 'package:tayyran_app/data/models/flight_pricing_response.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';

class PaymentArguments {
  final double amount;
  final String email;
  final String phoneNumber;
  final String countryCode;
  final FlightOffer flightOffer;
  final List<Passenger> passengers; // Add this
  final String bookingType;
  final FlightPricingResponse pricingResponse;
  PaymentArguments({
    required this.amount,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
    required this.flightOffer,
    required this.passengers,
    required this.pricingResponse,
    this.bookingType = 'flight',
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'flightOffer': flightOffer.toJson(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'bookingType': bookingType,
      'pricingResponse': pricingResponse.toJson(), // Include full response
    };
  }

  @override
  String toString() {
    return 'PaymentArguments{amount: $amount, email: $email, phone: $countryCode$phoneNumber, passengers: ${passengers.length}}';
  }
}
