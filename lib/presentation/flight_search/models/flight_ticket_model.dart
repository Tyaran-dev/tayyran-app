// lib/presentation/flight_search/models/flight_ticket_model.dart (updated)
import 'package:tayyran_app/data/models/flight_search_response.dart';

// lib/presentation/flight_search/models/flight_ticket_model.dart
class FlightTicket {
  final String id;
  final String airline;
  final String airlineLogo;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String departureDateFormatted; // REQUIRED
  final String arrivalDateFormatted; // REQUIRED
  final String duration;
  final int stops;
  final double price;
  final String currency;
  final bool hasBaggage;
  final bool isDirect;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final int seatsRemaining;
  final FlightOffer? flightOffer;

  const FlightTicket({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDateFormatted, // REQUIRED
    required this.arrivalDateFormatted, // REQUIRED
    required this.duration,
    required this.stops,
    required this.price,
    required this.currency,
    required this.hasBaggage,
    required this.isDirect,
    required this.departureDate,
    required this.arrivalDate,
    required this.seatsRemaining,
    this.flightOffer,
  });

  // Helper method to check if arrival is on a different day
  bool get arrivesNextDay => arrivalDate.day != departureDate.day;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'airlineLogo': airlineLogo,
      'from': from,
      'to': to,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'departureDateFormatted': departureDateFormatted,
      'arrivalDateFormatted': arrivalDateFormatted,
      'duration': duration,
      'stops': stops,
      'price': price,
      'currency': currency,
      'hasBaggage': hasBaggage,
      'isDirect': isDirect,
      'departureDate': departureDate.toIso8601String(),
      'arrivalDate': arrivalDate.toIso8601String(),
      'seatsRemaining': seatsRemaining,
    };
  }
}
