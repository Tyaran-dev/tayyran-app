// lib/presentation/passenger_info/cubit/passenger_info_state.dart
part of 'passenger_info_cubit.dart';

class PassengerInfoState {
  final List<Passenger> passengers;
  final String contactEmail;
  final String contactPhone;
  final bool isSubmitting;
  final bool isSubmitted;

  const PassengerInfoState({
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  // Update the factory constructor
  factory PassengerInfoState.initial(FlightOffer flightOffer) {
    final passengers = <Passenger>[];

    // Add adults
    for (int i = 0; i < flightOffer.adults; i++) {
      passengers.add(
        Passenger(
          type: TravelerType.ADULT,
          title: 'Mr',
          firstName: '',
          lastName: '',
          dateOfBirth: '',
          passportNumber: '',
          issuingCountry: '',
          passportExpiry: '',
          nationality: '',
        ),
      );
    }

    // Add children
    for (int i = 0; i < flightOffer.children; i++) {
      passengers.add(
        Passenger(
          type: TravelerType.CHILD,
          title: 'Miss',
          firstName: '',
          lastName: '',
          dateOfBirth: '',
          passportNumber: '',
          issuingCountry: '',
          passportExpiry: '',
          nationality: '',
        ),
      );
    }

    // Add infants
    for (int i = 0; i < flightOffer.infants; i++) {
      passengers.add(
        Passenger(
          type: TravelerType.INFANT,
          title: 'Miss',
          firstName: '',
          lastName: '',
          dateOfBirth: '',
          passportNumber: '',
          issuingCountry: '',
          passportExpiry: '',
          nationality: '',
        ),
      );
    }

    return PassengerInfoState(
      passengers: passengers,
      contactEmail: '',
      contactPhone: '',
    );
  }
  // Update the isFormValid getter
  bool get isFormValid {
    // Check if all passenger fields are filled with valid data
    final allPassengersValid = passengers.every(
      (passenger) =>
          passenger.title.isNotEmpty &&
          passenger.firstName.length >= 2 &&
          passenger.lastName.length >= 2 &&
          passenger.dateOfBirth.isNotEmpty &&
          _isValidDate(passenger.dateOfBirth) &&
          passenger.nationality.isNotEmpty &&
          passenger.passportNumber.length >= 6 &&
          passenger.issuingCountry.isNotEmpty &&
          passenger.passportExpiry.isNotEmpty &&
          _isValidDate(passenger.passportExpiry),
    );

    // Check if contact information is filled
    final contactValid =
        contactEmail.isNotEmpty &&
        contactPhone.isNotEmpty &&
        _isValidEmail(contactEmail);

    return allPassengersValid && contactValid;
  }

  bool _isValidDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return false;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return year > 1900 && month >= 1 && month <= 12 && day >= 1 && day <= 31;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  PassengerInfoState copyWith({
    List<Passenger>? passengers,
    String? contactEmail,
    String? contactPhone,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return PassengerInfoState(
      passengers: passengers ?? this.passengers,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
