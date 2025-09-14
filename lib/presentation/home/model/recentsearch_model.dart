// recentsearch_model.dart
// import 'dart:convert';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';

class RecentSearchModel {
  final String from;
  final String to;
  final String date;
  final String returnDate;
  final int passengers;
  final String flightClass;
  final DateTime timestamp;
  final String type;
  final String? tripType;
  final int? rooms;

  RecentSearchModel({
    required this.from,
    required this.to,
    required this.date,
    required this.returnDate,
    required this.passengers,
    required this.flightClass,
    required this.timestamp,
    required this.type,
    this.tripType,
    this.rooms,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'date': date,
      'returnDate': returnDate,
      'passengers': passengers,
      'flightClass': flightClass.toCabinClassBackendValue,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'tripType': tripType,
      'rooms': rooms,
    };
  }

  // Create from JSON for retrieval
  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
      returnDate: json['returnDate'] ?? '',
      passengers: json['passengers'] ?? 1,
      flightClass: json['flightClass'] ?? 'Economy',
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] ?? 'flight',
      tripType: json['tripType'],
      rooms: json['rooms'],
    );
  }

  // Convert to Map for shared preferences
  Map<String, dynamic> toMap() {
    return toJson();
  }

  // Create from Map for shared preferences
  factory RecentSearchModel.fromMap(Map<String, dynamic> map) {
    return RecentSearchModel.fromJson(map);
  }

  // Copy with method for updates
  RecentSearchModel copyWith({
    String? from,
    String? to,
    String? date,
    String? returnDate,
    int? passengers,
    String? flightClass,
    DateTime? timestamp,
    String? type,
    String? tripType,
    int? rooms,
  }) {
    return RecentSearchModel(
      from: from ?? this.from,
      to: to ?? this.to,
      date: date ?? this.date,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      flightClass: flightClass ?? this.flightClass,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      tripType: tripType ?? this.tripType,
      rooms: rooms ?? this.rooms,
    );
  }

  @override
  String toString() {
    return 'RecentSearchModel{from: $from, to: $to, date: $date, returnDate: $returnDate, passengers: $passengers, flightClass: $flightClass, timestamp: $timestamp, type: $type, tripType: $tripType, rooms: $rooms}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecentSearchModel &&
        other.from == from &&
        other.to == to &&
        other.date == date &&
        other.returnDate == returnDate &&
        other.passengers == passengers &&
        other.flightClass == flightClass &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.tripType == tripType &&
        other.rooms == rooms;
  }

  @override
  int get hashCode {
    return from.hashCode ^
        to.hashCode ^
        date.hashCode ^
        returnDate.hashCode ^
        passengers.hashCode ^
        flightClass.hashCode ^
        timestamp.hashCode ^
        type.hashCode ^
        tripType.hashCode ^
        rooms.hashCode;
  }
}
