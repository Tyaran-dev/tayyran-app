// lib/presentation/passenger_info/cubit/passenger_info_state.dart
part of 'passenger_info_cubit.dart';

class PassengerInfoState {
  final List<Passenger> passengers;
  final String contactEmail;
  final String contactPhone;
  final String countryCode; // Add this field
  final bool isLoading;
  final bool isSubmitted;
  final FlightOffer originalFlightOffer;
  final FlightOffer currentFlightOffer;
  final String? errorMessage;

  const PassengerInfoState({
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
    required this.countryCode,
    required this.originalFlightOffer,
    required this.currentFlightOffer,
    this.isLoading = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

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
      countryCode: '+966',
      originalFlightOffer: flightOffer,
      currentFlightOffer: flightOffer,
    );
  }

  bool get isFormValid {
    // Check if all passenger fields are filled with valid data
    final allPassengersValid = passengers.every(
      (passenger) =>
          passenger.title.isNotEmpty &&
          passenger.firstName.length >= 2 &&
          passenger.lastName.length >= 2 &&
          passenger.dateOfBirth.isNotEmpty &&
          isValidDate(passenger.dateOfBirth) &&
          passenger.nationality.isNotEmpty &&
          passenger.passportNumber.length >= 6 &&
          passenger.issuingCountry.isNotEmpty &&
          passenger.passportExpiry.isNotEmpty &&
          isValidDate(passenger.passportExpiry),
    );

    // Check if contact information is filled
    final contactValid =
        contactEmail.isNotEmpty &&
        contactPhone.isNotEmpty &&
        isValidEmail(contactEmail);

    return allPassengersValid && contactValid;
  }

  PassengerInfoState copyWith({
    List<Passenger>? passengers,
    String? contactEmail,
    String? contactPhone,
    String? countryCode,
    bool? isLoading,
    bool? isSubmitted,
    FlightOffer? currentFlightOffer,
    String? errorMessage,
  }) {
    return PassengerInfoState(
      passengers: passengers ?? this.passengers,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      countryCode: countryCode ?? this.countryCode,
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      originalFlightOffer: originalFlightOffer,
      currentFlightOffer: currentFlightOffer ?? this.currentFlightOffer,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'PassengerInfoState{'
        'passengers: ${passengers.length}, '
        'isLoading: $isLoading, '
        'countryCode: $countryCode, '
        'errorMessage: $errorMessage'
        '}';
  }
}
