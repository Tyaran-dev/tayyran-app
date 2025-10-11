class MultiFlightSegment {
  final String from;
  final String to;
  final String fromCode;
  final String toCode;
  final String fromCity;
  final String toCity;
  final String airline;
  final String airlineLogo;
  final String airlineCode;
  final String departureTime;
  final String arrivalTime;
  final String departureDateFormatted;
  final String arrivalDateFormatted;
  final String duration;
  final int stops;
  final bool isDirect;
  final bool arrivesNextDay;
  final DateTime departureDate;
  final DateTime arrivalDate;

  MultiFlightSegment({
    required this.from,
    required this.to,
    required this.fromCode,
    required this.toCode,
    required this.fromCity,
    required this.toCity,
    required this.airline,
    required this.airlineLogo,
    required this.airlineCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDateFormatted,
    required this.arrivalDateFormatted,
    required this.duration,
    required this.stops,
    required this.isDirect,
    required this.arrivesNextDay,
    required this.departureDate,
    required this.arrivalDate,
  });

  factory MultiFlightSegment.empty() {
    return MultiFlightSegment(
      from: '',
      to: '',
      fromCode: '',
      toCode: '',
      fromCity: '',
      toCity: '',
      airline: '',
      airlineLogo: '',
      airlineCode: '',
      departureTime: '',
      arrivalTime: '',
      departureDateFormatted: '',
      arrivalDateFormatted: '',
      duration: '',
      stops: 0,
      isDirect: true,
      arrivesNextDay: false,
      departureDate: DateTime.now(),
      arrivalDate: DateTime.now(),
    );
  }
}
