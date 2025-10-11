// lib/presentation/flight_detail/cubit/flight_detail_state.dart
part of 'flight_detail_cubit.dart';

@immutable
class FlightDetailState {
  final FlightOffer flightOffer;
  final Filters filters;
  final int selectedOutboundItineraryIndex;
  final int selectedReturnItineraryIndex;
  final Set<SectionType> expandedSections;
  final bool isLoading;
  final String? errorMessage;
  final FlightTripType tripType;

  const FlightDetailState({
    required this.flightOffer,
    required this.filters,
    this.selectedOutboundItineraryIndex = 0,
    this.selectedReturnItineraryIndex = 0,
    this.expandedSections = const {},
    this.isLoading = false,
    this.errorMessage,
    required this.tripType,
  });

  factory FlightDetailState.initial({
    required FlightOffer flightOffer,
    required Filters filters,
  }) {
    final tripType = _determineTripType(flightOffer);

    return FlightDetailState(
      flightOffer: flightOffer,
      filters: filters,
      selectedOutboundItineraryIndex: 0,
      selectedReturnItineraryIndex: tripType == FlightTripType.roundTrip
          ? 1
          : 0,
      expandedSections: const {SectionType.segments},
      isLoading: false,
      errorMessage: null,
      tripType: tripType,
    );
  }

  static FlightTripType _determineTripType(FlightOffer flightOffer) {
    // Method 1: Check mapping for multi-city pattern (multiple || separators)
    final mapping = flightOffer.mapping;
    final hasMultipleCities = mapping.split('||').length > 2;

    // Method 2: Check if it's truly multi-city by analyzing the itineraries
    final isTrueMultiCity = _isTrueMultiCity(flightOffer);

    // Method 3: Check if we have multiple unique origins/destinations
    final hasMultipleOriginsDestinations = _hasMultipleOriginsDestinations(
      flightOffer,
    );

    // Method 4: Check if this is a complex route (not simple round trip)
    final isComplexRoute = _isComplexRoute(flightOffer);

    print('🔍 Trip Type Detection:');
    print('   - Mapping: $mapping');
    print('   - Has multiple cities in mapping: $hasMultipleCities');
    print('   - Is true multi-city: $isTrueMultiCity');
    print(
      '   - Has multiple origins/destinations: $hasMultipleOriginsDestinations',
    );
    print('   - Is complex route: $isComplexRoute');
    print('   - Backend flightType: ${flightOffer.flightType}');
    print('   - Number of itineraries: ${flightOffer.itineraries.length}');

    if (hasMultipleCities ||
        isTrueMultiCity ||
        hasMultipleOriginsDestinations ||
        isComplexRoute) {
      print('🎯 Detected as: Multi-City');
      return FlightTripType.multiCity;
    } else if (flightOffer.itineraries.length > 1) {
      print('🎯 Detected as: Round Trip');
      return FlightTripType.roundTrip;
    } else {
      print('🎯 Detected as: One Way');
      return FlightTripType.oneWay;
    }
  }

  static bool _isTrueMultiCity(FlightOffer flightOffer) {
    if (flightOffer.itineraries.length <= 2) return false;

    // If we have more than 2 itineraries, it's definitely multi-city
    return flightOffer.itineraries.length > 2;
  }

  static bool _hasMultipleOriginsDestinations(FlightOffer flightOffer) {
    final Set<String> origins = {};
    final Set<String> destinations = {};

    for (final itinerary in flightOffer.itineraries) {
      origins.add(itinerary.fromLocation);
      destinations.add(itinerary.toLocation);
    }

    print('   - Unique origins: $origins');
    print('   - Unique destinations: $destinations');

    // If we have more than 2 unique origins OR more than 2 unique destinations, it's multi-city
    return origins.length > 2 || destinations.length > 2;
  }

  static bool _isComplexRoute(FlightOffer flightOffer) {
    if (flightOffer.itineraries.length < 2) return false;

    // Check if this is a simple round trip (A→B and B→A)
    final firstItinerary = flightOffer.itineraries.first;
    final lastItinerary = flightOffer.itineraries.last;

    final isSimpleRoundTrip =
        firstItinerary.fromLocation == lastItinerary.toLocation &&
        firstItinerary.toLocation == lastItinerary.fromLocation;

    print('   - Is simple round trip: $isSimpleRoundTrip');

    // If it's NOT a simple round trip, it's multi-city
    return !isSimpleRoundTrip;
  }

  Itinerary get selectedOutboundItinerary =>
      flightOffer.itineraries[selectedOutboundItineraryIndex];

  Itinerary? get selectedReturnItinerary {
    if (tripType == FlightTripType.roundTrip &&
        flightOffer.itineraries.length > selectedReturnItineraryIndex) {
      return flightOffer.itineraries[selectedReturnItineraryIndex];
    }
    return null;
  }

  List<Itinerary> get allItineraries => flightOffer.itineraries;

  // Get route summary for multi-city
  String get routeSummary {
    switch (tripType) {
      case FlightTripType.oneWay:
        return '${flightOffer.fromLocation} → ${flightOffer.toLocation}';
      case FlightTripType.roundTrip:
        return '${flightOffer.fromLocation} → ${flightOffer.toLocation} → ${flightOffer.fromLocation}';
      case FlightTripType.multiCity:
        final cities = <String>[];
        for (final itinerary in flightOffer.itineraries) {
          if (cities.isEmpty || cities.last != itinerary.fromLocation) {
            cities.add(itinerary.fromLocation);
          }
          cities.add(itinerary.toLocation);
        }
        return cities.join(' → ');
    }
  }

  // Helper method to get airline name for a specific segment
  String getAirlineNameForSegment(Segment segment) {
    final carrier = filters.findCarrierByCode(segment.carrierCode);
    return carrier?.airLineName ?? segment.carrierCode;
  }

  // Helper method to get airline logo for a specific segment
  String getAirlineLogoForSegment(Segment segment) {
    final carrier = filters.findCarrierByCode(segment.carrierCode);
    return carrier?.image ?? '';
  }

  // Get all unique airlines in the flight
  List<Carrier> get allAirlines {
    final Set<String> airlineCodes = {};
    for (final itinerary in flightOffer.itineraries) {
      for (final segment in itinerary.segments) {
        if (segment.carrierCode.isNotEmpty) {
          airlineCodes.add(segment.carrierCode);
        }
      }
    }

    return airlineCodes
        .map((code) => filters.findCarrierByCode(code))
        .where((carrier) => carrier != null)
        .cast<Carrier>()
        .toList();
  }

  // Get display airline name for multi-airline flights
  String get displayAirlineName {
    final airlines = allAirlines;
    if (airlines.length == 1) {
      return airlines.first.airLineName;
    } else if (airlines.length > 1) {
      return 'Multiple Airlines';
    }
    return flightOffer.airlineName;
  }

  FlightDetailState copyWith({
    FlightOffer? flightOffer,
    Filters? filters,
    int? selectedOutboundItineraryIndex,
    int? selectedReturnItineraryIndex,
    Set<SectionType>? expandedSections,
    bool? isLoading,
    String? errorMessage,
    FlightTripType? tripType,
  }) {
    return FlightDetailState(
      flightOffer: flightOffer ?? this.flightOffer,
      filters: filters ?? this.filters,
      selectedOutboundItineraryIndex:
          selectedOutboundItineraryIndex ?? this.selectedOutboundItineraryIndex,
      selectedReturnItineraryIndex:
          selectedReturnItineraryIndex ?? this.selectedReturnItineraryIndex,
      expandedSections: expandedSections ?? this.expandedSections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      tripType: tripType ?? this.tripType,
    );
  }

  @override
  String toString() {
    return 'FlightDetailState{'
        'flightOffer: ${flightOffer.id}, '
        'tripType: $tripType, '
        'outboundIndex: $selectedOutboundItineraryIndex, '
        'returnIndex: $selectedReturnItineraryIndex, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage'
        '}';
  }
}

enum FlightTripType { oneWay, roundTrip, multiCity }
