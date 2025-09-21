// lib/data/models/passenger_model.dart
import 'package:tayyran_app/data/models/flight_search_response.dart';

enum TravelerType { ADULT, CHILD, INFANT }

extension TravelerTypeExtension on TravelerType {
  String get displayName {
    switch (this) {
      case TravelerType.ADULT:
        return 'Adult';
      case TravelerType.CHILD:
        return 'Child';
      case TravelerType.INFANT:
        return 'Infant';
    }
  }

  bool get requiresDateOfBirth => this != TravelerType.ADULT;
}

class Passenger {
  final TravelerType type;
  final String title;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String passportNumber;
  final String issuingCountry;
  final String passportExpiry;
  final String nationality;
  final FlightOffer? flightOffer;

  const Passenger({
    required this.type,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.passportNumber,
    required this.issuingCountry,
    required this.passportExpiry,
    required this.nationality,
    this.flightOffer,
  });

  Passenger copyWith({
    TravelerType? type,
    String? title,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? passportNumber,
    String? issuingCountry,
    String? passportExpiry,
    String? nationality,
    FlightOffer? flightOffer,
  }) {
    return Passenger(
      type: type ?? this.type,
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      passportNumber: passportNumber ?? this.passportNumber,
      issuingCountry: issuingCountry ?? this.issuingCountry,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      nationality: nationality ?? this.nationality,
      flightOffer: flightOffer ?? this.flightOffer,
    );
  }

  // Helper method to get gender from title
  String get gender {
    switch (title) {
      case 'Mr':
        return 'Male';
      case 'Mrs':
      case 'Ms':
      case 'Miss':
        return 'Female';
      default:
        return 'Male';
    }
  }
}
