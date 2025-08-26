// flight_segment.dart
import 'package:flutter/foundation.dart';

@immutable
class FlightSegment {
  final String id;
  final String from;
  final String to;
  final String date;

  const FlightSegment({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
  });

  FlightSegment copyWith({String? id, String? from, String? to, String? date}) {
    return FlightSegment(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'from': from, 'to': to, 'date': date};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FlightSegment &&
        other.id == id &&
        other.from == from &&
        other.to == to &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^ from.hashCode ^ to.hashCode ^ date.hashCode;
  }

  @override
  String toString() {
    return 'FlightSegment{id: $id, from: $from, to: $to, date: $date}';
  }
}
