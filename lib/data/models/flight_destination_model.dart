// lib/data/models/flight_destination_model.dart
class FlightDestination {
  final String id;
  final String from;
  final String to;
  final String date;

  FlightDestination({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
  });

  FlightDestination copyWith({
    String? id,
    String? from,
    String? to,
    String? date,
  }) {
    return FlightDestination(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to, // Fixed: should be 'to' not 'from'
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'from': from, 'to': to, 'date': date};
  }

  factory FlightDestination.fromJson(Map<String, dynamic> json) {
    return FlightDestination(
      id: json['id']?.toString() ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
    );
  }

  @override
  String toString() {
    return 'FlightDestination{id: $id, from: $from, to: $to, date: $date}';
  }
}
