// lib/presentation/flight_detail/cubit/flight_detail_state.dart
part of 'flight_detail_cubit.dart';

@immutable
class FlightDetailState {
  final FlightOffer flightOffer;
  final int selectedItineraryIndex;
  final Set<SectionType> expandedSections;
  final bool isLoading;

  const FlightDetailState({
    required this.flightOffer,
    this.selectedItineraryIndex = 0,
    this.expandedSections = const {},
    this.isLoading = false,
  });

  factory FlightDetailState.initial(FlightOffer flightOffer) {
    return FlightDetailState(
      flightOffer: flightOffer,
      selectedItineraryIndex: 0,
      expandedSections: const {SectionType.segments},
      isLoading: false,
    );
  }

  Itinerary get selectedItinerary =>
      flightOffer.itineraries[selectedItineraryIndex];

  FlightDetailState copyWith({
    FlightOffer? flightOffer,
    int? selectedItineraryIndex,
    Set<SectionType>? expandedSections,
    bool? isLoading,
  }) {
    return FlightDetailState(
      flightOffer: flightOffer ?? this.flightOffer,
      selectedItineraryIndex:
          selectedItineraryIndex ?? this.selectedItineraryIndex,
      expandedSections: expandedSections ?? this.expandedSections,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
