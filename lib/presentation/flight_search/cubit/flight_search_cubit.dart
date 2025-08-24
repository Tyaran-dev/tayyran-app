import 'package:flutter_bloc/flutter_bloc.dart';

part 'flight_search_state.dart';

class FlightSearchCubit extends Cubit<FlightSearchState> {
  final String from;
  final String to;
  final String date;
  final String returnDate;
  final int passengers;
  final String cabinClass;
  final String tripType;

  FlightSearchCubit({
    required this.from,
    required this.to,
    required this.date,
    required this.returnDate,
    required this.passengers,
    required this.cabinClass,
    required this.tripType,
  }) : super(FlightSearchState.initial()) {
    _searchFlights();
  }

  Future<void> _searchFlights() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock results
      final mockResults = _generateMockResults();

      emit(state.copyWith(isLoading: false, flights: mockResults));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load flights. Please try again.',
        ),
      );
    }
  }

  List<FlightTicket> _generateMockResults() {
    return List.generate(
      10,
      (index) => FlightTicket(
        id: 'FL${index + 1}',
        airline: _getAirline(index),
        flightNumber: '${_getAirlineCode(index)}${index + 1}',
        departureTime: '08:${(index * 5).toString().padLeft(2, '0')}',
        arrivalTime: '12:${(index * 5).toString().padLeft(2, '0')}',
        duration: '${index + 2}h ${index * 10}m',
        price: 1200 + (index * 100),
        stops: index % 3,
        departureAirport: from.split(' - ')[0],
        arrivalAirport: to.split(' - ')[0],
      ),
    );
  }

  String _getAirline(int index) {
    final airlines = [
      'Emirates',
      'Etihad',
      'Qatar Airways',
      'Fly Dubai',
      'Air Arabia',
    ];
    return airlines[index % airlines.length];
  }

  String _getAirlineCode(int index) {
    final codes = ['EK', 'EY', 'QR', 'FZ', 'G9'];
    return codes[index % codes.length];
  }

  void retrySearch() {
    _searchFlights();
  }

  void sortByPrice() {
    final sorted = List<FlightTicket>.from(state.flights)
      ..sort((a, b) => a.price.compareTo(b.price));
    emit(state.copyWith(flights: sorted, sortBy: 'price'));
  }

  void sortByDuration() {
    final sorted = List<FlightTicket>.from(state.flights)
      ..sort((a, b) => a.duration.compareTo(b.duration));
    emit(state.copyWith(flights: sorted, sortBy: 'duration'));
  }

  void filterByStops(int maxStops) {
    // Implement filter logic if needed
  }
}
