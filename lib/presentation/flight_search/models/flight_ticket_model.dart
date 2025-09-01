// flight_ticket_model.dart
class FlightTicket {
  final String id;
  final String airline;
  final String airlineLogo;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int stops;
  final double price;
  final String currency;
  final bool hasBaggage;
  final bool isDirect;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final int? seatsRemaining; // Add this field

  const FlightTicket({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    required this.price,
    required this.currency,
    required this.hasBaggage,
    required this.isDirect,
    required this.departureDate,
    required this.arrivalDate,
    this.seatsRemaining, // Make it optional
  });

  factory FlightTicket.fromJson(Map<String, dynamic> json) {
    return FlightTicket(
      id: json['id'],
      airline: json['airline'],
      airlineLogo: json['airlineLogo'],
      from: json['from'],
      to: json['to'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      duration: json['duration'],
      stops: json['stops'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      hasBaggage: json['hasBaggage'] ?? false,
      isDirect: json['isDirect'] ?? json['stops'] == 0,
      departureDate: DateTime.parse(json['departureDate']),
      arrivalDate: DateTime.parse(json['arrivalDate']),
      seatsRemaining: json['seatsRemaining'], // Map from API
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'airlineLogo': airlineLogo,
      'from': from,
      'to': to,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'stops': stops,
      'price': price,
      'currency': currency,
      'hasBaggage': hasBaggage,
      'isDirect': isDirect,
      'departureDate': departureDate.toIso8601String(),
      'arrivalDate': arrivalDate.toIso8601String(),
    };
  }
}
