// flight_search_state.dart - FIXED
import 'package:flutter/material.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

@immutable
class FlightSearchState {
  final List<FlightTicket> tickets;
  final List<FlightTicket> filteredTickets;
  final bool isLoading;
  final String? errorMessage;
  final Set<SortOption> selectedSorts;
  final FilterOptions filters;
  final Map<String, dynamic> searchData;

  const FlightSearchState({
    this.tickets = const [],
    this.filteredTickets = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSorts = const {},
    required this.filters,
    this.searchData = const {},
  });

  // Factory method to create initial state
  factory FlightSearchState.initial() {
    return FlightSearchState(
      tickets: const [],
      filteredTickets: const [],
      isLoading: false,
      selectedSorts: const {},
      filters: FilterOptions(),
      searchData: const {},
    );
  }

  // Add a method to ensure searchData always has required keys
  Map<String, dynamic> get safeSearchData {
    return {
      'from': searchData['from'] ?? '',
      'to': searchData['to'] ?? '',
      'departureDate': searchData['departureDate'] ?? '',
      'returnDate': searchData['returnDate'] ?? '',
      'adults': searchData['adults'] is int ? searchData['adults'] : 1,
      'children': searchData['children'] is int ? searchData['children'] : 0,
      'infants': searchData['infants'] is int ? searchData['infants'] : 0,
      'cabinClass': searchData['cabinClass'] is String
          ? searchData['cabinClass']
          : 'Economy',
      'tripType': searchData['tripType'] is String
          ? searchData['tripType']
          : 'oneway',
    };
  }

  @override
  String toString() {
    return 'FlightSearchState{'
        'isLoading: $isLoading, '
        'tickets: ${tickets.length}, '
        'filteredTickets: ${filteredTickets.length}, '
        'searchData: $searchData, '
        'errorMessage: $errorMessage'
        '}';
  }

  FlightSearchState copyWith({
    List<FlightTicket>? tickets,
    List<FlightTicket>? filteredTickets,
    bool? isLoading,
    String? errorMessage,
    Set<SortOption>? selectedSorts,
    FilterOptions? filters,
    Map<String, dynamic>? searchData,
  }) {
    print('Copying state with searchData: $searchData');

    return FlightSearchState(
      tickets: tickets ?? this.tickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedSorts: selectedSorts ?? this.selectedSorts,
      filters: filters ?? this.filters,
      searchData: searchData ?? this.searchData, // FIXED: This was missing
    );
  }
}

enum SortOption { cheapest, shortest, earliestTakeoff, earliestArrival }

enum DepartureTimeFilter { before6am, sixToTwelve, twelveToSix, after6pm }

enum StopFilter { any, direct, oneStop, twoPlusStops }
