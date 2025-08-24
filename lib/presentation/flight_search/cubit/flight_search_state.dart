part of 'flight_search_cubit.dart';

class FlightSearchState {
  final bool isLoading;
  final List<FlightTicket> flights;
  final String? error;
  final String sortBy;

  const FlightSearchState({
    this.isLoading = false,
    this.flights = const [],
    this.error,
    this.sortBy = 'price',
  });

  FlightSearchState copyWith({
    bool? isLoading,
    List<FlightTicket>? flights,
    String? error,
    String? sortBy,
  }) {
    return FlightSearchState(
      isLoading: isLoading ?? this.isLoading,
      flights: flights ?? this.flights,
      error: error,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static FlightSearchState initial() {
    return const FlightSearchState();
  }
}

class FlightTicket {
  final String id;
  final String airline;
  final String flightNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int price;
  final int stops;
  final String departureAirport;
  final String arrivalAirport;

  FlightTicket({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.stops,
    required this.departureAirport,
    required this.arrivalAirport,
  });
}
