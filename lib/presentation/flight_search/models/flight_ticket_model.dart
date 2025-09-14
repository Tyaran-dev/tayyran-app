// lib/presentation/flight_search/models/flight_ticket_model.dart (updated)
import 'package:tayyran_app/data/models/flight_search_response.dart';

// lib/presentation/flight_search/models/flight_ticket_model.dart
class FlightTicket {
  final String id;
  final String airline;
  final String airlineLogo;
  final String airlineCode; // ADD THIS FIELD
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String departureDateFormatted;
  final String arrivalDateFormatted;
  final String duration;
  final int stops;
  final double price;
  final double basePrice;
  final String currency;
  final bool hasBaggage;
  final bool isDirect;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final int seatsRemaining;
  final FlightOffer flightOffer;

  FlightTicket({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.airlineCode, // ADD THIS
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDateFormatted,
    required this.arrivalDateFormatted,
    required this.duration,
    required this.stops,
    required this.price,
    required this.basePrice,
    required this.currency,
    required this.hasBaggage,
    required this.isDirect,
    required this.departureDate,
    required this.arrivalDate,
    required this.seatsRemaining,
    required this.flightOffer,
  });

  // Add copyWith method if you don't have it
  FlightTicket copyWith({
    String? id,
    String? airline,
    String? airlineLogo,
    String? airlineCode, // ADD THIS
    String? from,
    String? to,
    String? departureTime,
    String? arrivalTime,
    String? departureDateFormatted,
    String? arrivalDateFormatted,
    String? duration,
    int? stops,
    double? price,
    double? basePrice,
    String? currency,
    bool? hasBaggage,
    bool? isDirect,
    DateTime? departureDate,
    DateTime? arrivalDate,
    int? seatsRemaining,
    FlightOffer? flightOffer,
  }) {
    return FlightTicket(
      id: id ?? this.id,
      airline: airline ?? this.airline,
      airlineLogo: airlineLogo ?? this.airlineLogo,
      airlineCode: airlineCode ?? this.airlineCode, // ADD THIS
      from: from ?? this.from,
      to: to ?? this.to,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureDateFormatted:
          departureDateFormatted ?? this.departureDateFormatted,
      arrivalDateFormatted: arrivalDateFormatted ?? this.arrivalDateFormatted,
      duration: duration ?? this.duration,
      stops: stops ?? this.stops,
      price: price ?? this.price,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      hasBaggage: hasBaggage ?? this.hasBaggage,
      isDirect: isDirect ?? this.isDirect,
      departureDate: departureDate ?? this.departureDate,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      seatsRemaining: seatsRemaining ?? this.seatsRemaining,
      flightOffer: flightOffer ?? this.flightOffer,
    );
  }

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
      'basePrice': basePrice,
      'currency': currency,
      'hasBaggage': hasBaggage,
      'isDirect': isDirect,
      'departureDate': departureDate.toIso8601String(),
      'arrivalDate': arrivalDate.toIso8601String(),
      'seatsRemaining': seatsRemaining,
    };
  }
}
