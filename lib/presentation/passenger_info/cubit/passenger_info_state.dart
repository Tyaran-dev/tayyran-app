part of 'passenger_info_cubit.dart';

class PassengerInfoState {
  final List<Passenger> passengers;
  final String contactEmail;
  final String contactPhone;
  final String countryCode;
  final bool isLoading;
  final bool isSubmitted;
  final FlightOffer originalFlightOffer;
  final FlightOffer currentFlightOffer;
  final String? errorMessage;
  final FlightPricingResponse? pricingResponse;
  final double? updatedPrice;
  final double? administrationFee;
  final double? grandTotal;

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
    this.pricingResponse,
    this.updatedPrice,
    this.administrationFee,
    this.grandTotal,
  });

  factory PassengerInfoState.initial(FlightOffer flightOffer) {
    final passengers = <Passenger>[];

    // Add adults
    for (int i = 0; i < flightOffer.adults; i++) {
      passengers.add(
        Passenger(
          type: TravelerType.ADULT,
          title: '',
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
          title: '',
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
          title: '',
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
      pricingResponse: null,
      updatedPrice: flightOffer.price,
      administrationFee: 0.0,
      grandTotal: flightOffer.price,
    );
  }

  bool get isFormValid {
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
    FlightPricingResponse? pricingResponse,
    double? updatedPrice,
    double? administrationFee,
    double? grandTotal,
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
      pricingResponse: pricingResponse ?? this.pricingResponse,
      updatedPrice: updatedPrice ?? this.updatedPrice,
      administrationFee: administrationFee ?? this.administrationFee,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }

  @override
  String toString() {
    return 'PassengerInfoState{'
        'passengers: ${passengers.length}, '
        'isLoading: $isLoading, '
        'countryCode: $countryCode, '
        'pricingResponse: ${pricingResponse != null}, '
        'errorMessage: $errorMessage'
        '}';
  }
}
