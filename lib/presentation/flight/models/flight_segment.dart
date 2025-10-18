// flight_segment.dart
import 'package:tayyran_app/data/models/flight_search_response.dart';

// flight_segment.dart
class FlightSegment {
  final String id;
  final String from;
  final String to;
  final String date;
  final String englishDate;

  const FlightSegment({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    this.englishDate = "",
  });

  FlightSegment copyWith({
    String? id,
    String? from,
    String? to,
    String? date,
    String? englishDate,
  }) {
    return FlightSegment(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      englishDate: englishDate ?? this.englishDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'date': date,
      'englishDate': englishDate,
    };
  }

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      id: json['id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
      englishDate: json['englishDate'] ?? '',
    );
  }
}

class TicketArguments {
  final FlightOffer flightOffer;
  final Filters filters;

  TicketArguments({required this.flightOffer, required this.filters});
}
