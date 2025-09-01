// flight_search_cubit.dart - FIXED
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

class FlightSearchCubit extends Cubit<FlightSearchState> {
  bool _isLoading = false;
  bool _isDisposed = false;
  Timer? _loadingTimer;

  FlightSearchCubit() : super(FlightSearchState.initial());

  // Safe emit method
  void _safeEmit(FlightSearchState newState) {
    if (!isClosed && !_isDisposed) {
      emit(newState);
    }
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    _isLoading = false;
    _loadingTimer?.cancel();
    return super.close();
  }

  void loadFlights(Map<String, dynamic> searchData) async {
    if (_isLoading || isClosed || _isDisposed) return;
    _isLoading = true;

    // FIXED: Update searchData in state immediately
    _safeEmit(
      state.copyWith(
        isLoading: true,
        searchData: searchData, // This is crucial!
        errorMessage: null,
      ),
    );

    // Cancel any existing timer
    _loadingTimer?.cancel();

    // Simulate API call with a timer
    _loadingTimer = Timer(const Duration(seconds: 2), () {
      if (isClosed || _isDisposed) return;

      try {
        final tickets = _generateFlightTickets(searchData);

        // FIXED: Make sure to update searchData here too
        _safeEmit(
          state.copyWith(
            isLoading: false,
            tickets: tickets,
            filteredTickets: tickets,
            searchData: searchData, // This is crucial!
          ),
        );

        _isLoading = false;
      } catch (e) {
        if (isClosed || _isDisposed) return;
        _safeEmit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to load flights: $e',
            searchData: searchData, // Keep the search data even on error
          ),
        );
        _isLoading = false;
      }
    });
  }

  // Rest of the file remains the same...
  List<FlightTicket> _generateFlightTickets(Map<String, dynamic> searchData) {
    final airlines = [
      {
        'name': 'Flynas',
        'logo': 'https://logo.clearbit.com/flynas.com',
        'basePrice': 450.0,
      },
      {
        'name': 'Flyadeal',
        'logo': 'https://logo.clearbit.com/flyadeal.com',
        'basePrice': 420.0,
      },
      {
        'name': 'Saudia',
        'logo': 'https://logo.clearbit.com/saudia.com',
        'basePrice': 550.0,
      },
      {
        'name': 'Hahn Air',
        'logo': 'https://logo.clearbit.com/hahnair.com',
        'basePrice': 600.0,
      },
      {
        'name': 'Egypt Air',
        'logo': 'https://logo.clearbit.com/egyptair.com',
        'basePrice': 500.0,
      },
    ];

    final List<FlightTicket> tickets = [];

    for (int i = 0; i < 12; i++) {
      final airline = airlines[i % airlines.length];

      // Generate random seats remaining (1-10) for demo
      final seatsRemaining = (i % 10) + 1;

      // Parse from and to information
      final from = searchData['from'] ?? 'DXB - Dubai International';
      final to = searchData['to'] ?? 'JED - Jeddah International';

      // Parse departure date or use current date
      DateTime departureDate;
      if (searchData['departureDate'] != null &&
          searchData['departureDate'].toString().isNotEmpty) {
        departureDate = _parseDisplayDate(
          searchData['departureDate'].toString(),
        );
      } else {
        departureDate = DateTime.now().add(Duration(days: i % 7));
      }

      // Calculate arrival date (2-5 hours later)
      final flightHours = 2 + (i % 4);
      final arrivalDate = departureDate.add(
        Duration(hours: flightHours, minutes: (i * 15) % 60),
      );

      tickets.add(
        FlightTicket(
          id: 'flight_${DateTime.now().millisecondsSinceEpoch}_$i',
          airline: airline['name'] as String,
          airlineLogo: airline['logo'] as String,
          from: from,
          to: to,
          departureTime:
              '${departureDate.hour.toString().padLeft(2, '0')}:${departureDate.minute.toString().padLeft(2, '0')}',
          arrivalTime:
              '${arrivalDate.hour.toString().padLeft(2, '0')}:${arrivalDate.minute.toString().padLeft(2, '0')}',
          duration: '${flightHours}h ${(i * 15) % 60}m',
          stops: i % 5 == 0 ? 0 : (i % 5 == 1 ? 1 : 2),
          price: (airline['basePrice'] as double) + ((i % 4) * 75.0),
          currency: 'SAR',
          hasBaggage: i % 3 != 0,
          isDirect: i % 5 == 0,
          departureDate: departureDate,
          arrivalDate: arrivalDate,
          seatsRemaining: seatsRemaining,
        ),
      );
    }

    return tickets;
  }

  DateTime _parseDisplayDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final monthNames = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ];

        final day = int.parse(parts[0]);
        final month = monthNames.indexOf(parts[1]) + 1;
        final year = int.parse(parts[2]);

        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  // Apply multiple sort options
  void applySorts(Set<SortOption> sortOptions) {
    if (isClosed || _isDisposed) return;

    List<FlightTicket> sortedTickets = List.from(state.filteredTickets);

    if (sortOptions.isNotEmpty) {
      // Create a custom comparator that considers all selected sort options
      sortedTickets.sort((a, b) {
        int compareResult = 0;

        // Convert set to list to maintain consistent order
        final sortList = sortOptions.toList();

        // Apply each sort option in order until we find a difference
        for (final sortOption in sortList) {
          switch (sortOption) {
            case SortOption.cheapest:
              compareResult = a.price.compareTo(b.price);
              break;
            case SortOption.shortest:
              final aDuration = _parseDuration(a.duration);
              final bDuration = _parseDuration(b.duration);
              compareResult = aDuration.compareTo(bDuration);
              break;
            case SortOption.earliestTakeoff:
              compareResult = a.departureDate.compareTo(b.departureDate);
              break;
            case SortOption.earliestArrival:
              compareResult = a.arrivalDate.compareTo(b.arrivalDate);
              break;
          }

          // If we found a difference with this sort criteria, return it
          if (compareResult != 0) {
            return compareResult;
          }
        }

        return compareResult;
      });
    }

    _safeEmit(
      state.copyWith(
        filteredTickets: sortedTickets,
        selectedSorts: sortOptions,
      ),
    );
  }

  int _parseDuration(String duration) {
    try {
      final parts = duration.split('h');
      final hours = int.parse(parts[0]);
      final minutes = parts.length > 1
          ? int.parse(parts[1].replaceAll('m', '').trim())
          : 0;
      return hours * 60 + minutes;
    } catch (e) {
      return 0; // Default value if parsing fails
    }
  }

  void applyFilters(FilterOptions newFilters) {
    if (isClosed || _isDisposed) return;

    try {
      List<FlightTicket> filtered = state.tickets.where((ticket) {
        // 1. Price Filter
        if (ticket.price < newFilters.minPrice ||
            ticket.price > newFilters.maxPrice) {
          return false;
        }

        // 2. Departure Time Filter
        if (newFilters.departureTimes.isNotEmpty) {
          final hour = ticket.departureDate.hour;
          bool matchesTime = false;

          for (var timeFilter in newFilters.departureTimes) {
            switch (timeFilter) {
              case DepartureTimeFilter.before6am:
                matchesTime = matchesTime || hour < 6;
                break;
              case DepartureTimeFilter.sixToTwelve:
                matchesTime = matchesTime || (hour >= 6 && hour < 12);
                break;
              case DepartureTimeFilter.twelveToSix:
                matchesTime = matchesTime || (hour >= 12 && hour < 18);
                break;
              case DepartureTimeFilter.after6pm:
                matchesTime = matchesTime || hour >= 18;
                break;
            }
          }
          if (!matchesTime) return false;
        }

        // 3. Stops Filter
        if (newFilters.stops.isNotEmpty) {
          bool matchesStops = false;

          for (var stopFilter in newFilters.stops) {
            switch (stopFilter) {
              case StopFilter.any:
                matchesStops = true;
                break;
              case StopFilter.direct:
                matchesStops = matchesStops || ticket.stops == 0;
                break;
              case StopFilter.oneStop:
                matchesStops = matchesStops || ticket.stops == 1;
                break;
              case StopFilter.twoPlusStops:
                matchesStops = matchesStops || ticket.stops >= 2;
                break;
            }
          }
          if (!matchesStops) return false;
        }

        // 4. Airlines Filter
        if (newFilters.airlines.isNotEmpty) {
          if (!newFilters.airlines.contains(ticket.airline)) {
            return false;
          }
        }

        // 5. Baggage Filter
        if (newFilters.hasBaggageOnly && !ticket.hasBaggage) {
          return false;
        }

        return true;
      }).toList();

      _safeEmit(state.copyWith(filteredTickets: filtered, filters: newFilters));

      // Reapply current sorts to the filtered results
      applySorts(state.selectedSorts);
    } catch (e) {
      print('Error applying filters: $e');
      _safeEmit(
        state.copyWith(filteredTickets: state.tickets, filters: newFilters),
      );
    }
  }

  void removeFilter(String filterType, dynamic value) {
    if (isClosed || _isDisposed) return;

    // Create a new copy of the current filters
    final newFilters = FilterOptions(
      departureTimes: List.from(state.filters.departureTimes),
      stops: List.from(state.filters.stops),
      airlines: List.from(state.filters.airlines),
      minPrice: state.filters.minPrice,
      maxPrice: state.filters.maxPrice,
      hasBaggageOnly: state.filters.hasBaggageOnly,
    );

    switch (filterType) {
      case 'price':
        newFilters.minPrice = 0;
        newFilters.maxPrice = 10000;
        break;
      case 'stops':
        newFilters.stops.remove(value);
        break;
      case 'airlines':
        newFilters.airlines.remove(value);
        break;
      case 'departureTimes':
        newFilters.departureTimes.remove(value);
        break;
      case 'hasBaggageOnly':
        newFilters.hasBaggageOnly = false;
        break;
    }

    applyFilters(newFilters);
  }

  void clearFilters() {
    if (isClosed || _isDisposed) return;

    final newFilters = FilterOptions();
    _safeEmit(
      state.copyWith(filteredTickets: state.tickets, filters: newFilters),
    );
    applySorts(state.selectedSorts);
  }

  void clearSorts() {
    if (isClosed || _isDisposed) return;

    _safeEmit(
      state.copyWith(selectedSorts: {}, filteredTickets: state.tickets),
    );
  }
}
