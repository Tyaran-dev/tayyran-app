// lib/presentation/flight_search/cubit/flight_search_state.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
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
  final Map<String, dynamic> searchData; // Formatted for UI
  final Map<String, dynamic> originalSearchData; // Original for API calls
  final FlightOffer? selectedFlightOffer;
  final List<FlightOffer> flightOffers;
  final List<Carrier> availableCarriers;
  final double minTicketPrice;
  final double maxTicketPrice;

  const FlightSearchState({
    this.tickets = const [],
    this.filteredTickets = const [],
    this.flightOffers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedSorts = const {},
    required this.filters,
    this.searchData = const {},
    this.originalSearchData = const {}, // Add this
    this.selectedFlightOffer,
    this.availableCarriers = const [],
    this.minTicketPrice = 0,
    this.maxTicketPrice = 10000,
  });

  factory FlightSearchState.initial() {
    return FlightSearchState(
      tickets: const [],
      filteredTickets: const [],
      isLoading: false,
      flightOffers: const [],
      selectedSorts: const {},
      filters: FilterOptions(),
      searchData: const {},
      originalSearchData: const {}, // Initialize
      selectedFlightOffer: null,
      availableCarriers: const [],
      minTicketPrice: 0,
      maxTicketPrice: 10000,
    );
  }

  FlightSearchState copyWith({
    List<FlightTicket>? tickets,
    List<FlightTicket>? filteredTickets,
    List<FlightOffer>? flightOffers,
    bool? isLoading,
    String? errorMessage,
    Set<SortOption>? selectedSorts,
    FilterOptions? filters,
    Map<String, dynamic>? searchData,
    Map<String, dynamic>? originalSearchData, // Add this
    FlightOffer? selectedFlightOffer,
    List<Carrier>? availableCarriers,
    double? minTicketPrice,
    double? maxTicketPrice,
  }) {
    return FlightSearchState(
      tickets: tickets ?? this.tickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      flightOffers: flightOffers ?? this.flightOffers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedSorts: selectedSorts ?? this.selectedSorts,
      filters: filters ?? this.filters,
      searchData: searchData ?? this.searchData,
      originalSearchData:
          originalSearchData ?? this.originalSearchData, // Add this
      selectedFlightOffer: selectedFlightOffer ?? this.selectedFlightOffer,
      availableCarriers: availableCarriers ?? this.availableCarriers,
      minTicketPrice: minTicketPrice ?? this.minTicketPrice,
      maxTicketPrice: maxTicketPrice ?? this.maxTicketPrice,
    );
  }
}

enum SortOption { cheapest, shortest, earliestTakeoff, earliestArrival }

enum DepartureTimeFilter { before6am, sixToTwelve, twelveToSix, after6pm }

enum StopFilter { any, direct, oneStop, twoPlusStops }
