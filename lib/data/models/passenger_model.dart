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
  final String? gender;

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
    this.gender,
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
    String? gender,
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
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.toString().split('.').last, // Convert enum to string
      "title": title,
      "firstName": firstName,
      "lastName": lastName,
      "dateOfBirth": dateOfBirth,
      "passportNumber": passportNumber,
      "issuingCountry": issuingCountry,
      "passportExpiry": passportExpiry,
      "nationality": nationality,
      "gender": gender ?? "MALE", // Default to MALE if not specified
    };
  }

  Map<String, dynamic> toTravelerJson(
    int id,
    String email,
    String phoneCode,
    String phoneNumber,
  ) {
    return {
      "travelerId": id,
      "title": title, // assuming you have a `title` property like "Mr"
      "firstName": firstName,
      "lastName": lastName,
      "dateOfBirth": _splitDate(dateOfBirth),
      "nationality": nationality,
      "documentType": "PASSPORT",
      "passportNumber": passportNumber,
      "issuanceCountry": issuingCountry,
      "passportExpiry": _splitDate(passportExpiry),
      "email": email,
      "phoneCode": phoneCode,
      "phoneNumber": phoneNumber,
      "isCompleted": true,
      "travelerType": "ADULT", // you can make this dynamic if needed
    };
  }

  Map<String, String>? _splitDate(dynamic dateObj) {
    if (dateObj == null) return null;

    // Handle already formatted date
    if (dateObj is Map<String, dynamic> &&
        dateObj.containsKey('day') &&
        dateObj.containsKey('month') &&
        dateObj.containsKey('year')) {
      return {
        'day': dateObj['day'].toString(),
        'month': dateObj['month'].toString(),
        'year': dateObj['year'].toString(),
      };
    }

    // Parse DateTime from string or use directly
    DateTime? date;
    if (dateObj is String) {
      date = DateTime.tryParse(dateObj);
    } else if (dateObj is DateTime) {
      date = dateObj;
    }

    return date != null
        ? {
            'day': date.day.toString().padLeft(2, '0'),
            'month': date.month.toString().padLeft(2, '0'),
            'year': date.year.toString(),
          }
        : null;
  }
}
