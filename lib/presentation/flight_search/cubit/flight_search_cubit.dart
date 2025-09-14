// lib/presentation/flight_search/cubit/flight_search_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/repositories/flight_search_repository.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

class FlightSearchCubit extends Cubit<FlightSearchState> {
  final FlightSearchRepository _repository;
  bool _isLoading = false;
  bool _isDisposed = false;
  Timer? _loadingTimer;

  FlightSearchCubit(this._repository) : super(FlightSearchState.initial());

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

  void selectFlightOffer(FlightOffer flightOffer) {
    if (isClosed || _isDisposed) return;

    _safeEmit(state.copyWith(selectedFlightOffer: flightOffer));
  }

  void clearSelectedFlight() {
    if (isClosed || _isDisposed) return;

    _safeEmit(state.copyWith(selectedFlightOffer: null));
  }

  Future<void> loadFlights(Map<String, dynamic> searchData) async {
    if (_isLoading || isClosed || _isDisposed) return;
    _isLoading = true;

    _safeEmit(
      state.copyWith(
        isLoading: true,
        searchData: searchData,
        errorMessage: null,
      ),
    );

    try {
      final apiRequestData = _prepareApiRequestData(searchData);
      final response = await _repository.searchFlights(apiRequestData);

      if (response.success) {
        final availableCarriers = response.getAvailableCarriers();
        final priceRange = response.getPriceRange();

        final tickets = response.data.map((offer) {
          return _createFlightTicket(offer, response.filters);
        }).toList();

        _safeEmit(
          state.copyWith(
            isLoading: false,
            tickets: tickets,
            filteredTickets: tickets,
            searchData: searchData,
            availableCarriers: availableCarriers,
            minTicketPrice: priceRange['min'] ?? 0, // Store for reference
            maxTicketPrice: priceRange['max'] ?? 10000, // Store for reference
            filters: FilterOptions(
              // RESET FILTERS TO DEFAULT
              minPrice: 0, // DEFAULT MIN
              maxPrice: 10000, // DEFAULT MAX
            ),
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Failed to load flights',
            searchData: searchData,
          ),
        );
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load flights: $e',
          searchData: searchData,
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  FlightTicket _createFlightTicket(FlightOffer offer, Filters filters) {
    final firstItinerary = offer.itineraries.isNotEmpty
        ? offer.itineraries.first
        : null;
    final firstSegment = firstItinerary?.segments.isNotEmpty == true
        ? firstItinerary!.segments.first
        : null;

    // GET CARRIER FULL NAME FROM FILTERS
    final carrierCode = firstSegment?.carrierCode ?? "";
    final carrier = filters.findCarrierByCode(carrierCode);

    String safeValue(String? value, String fallback) {
      return (value ?? "").isNotEmpty ? value! : fallback;
    }

    final airlineName = safeValue(carrier?.airLineName, carrierCode);
    final airlineLogo = safeValue(carrier?.image, "");

    // Use English format by default (remove context dependency)
    final departureTime = _formatTimeEnglish(firstSegment?.departure.at);
    final arrivalTime = _formatTimeEnglish(firstSegment?.arrival.at);
    final departureDateFormatted = _formatDateEnglish(
      firstSegment?.departure.at,
    );
    final arrivalDateFormatted = _formatDateEnglish(firstSegment?.arrival.at);

    return FlightTicket(
      id: offer.mapping,
      airline: airlineName,
      airlineLogo: airlineLogo,
      airlineCode: carrierCode, // ADD THIS LINE
      from: '${offer.fromLocation} - ${offer.fromName}',
      to: '${offer.toLocation} - ${offer.toName}',
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      departureDateFormatted: departureDateFormatted,
      arrivalDateFormatted: arrivalDateFormatted,
      duration: firstItinerary?.duration ?? "",
      stops: offer.stops,
      price: offer.price,
      basePrice: offer.basePrice,
      currency: offer.currency,
      hasBaggage: offer.allowedBags.isNotEmpty,
      isDirect: offer.stops == 0,
      departureDate: firstSegment?.departure.at ?? DateTime.now(),
      arrivalDate: firstSegment?.arrival.at ?? DateTime.now(),
      seatsRemaining: offer.numberOfBookableSeats,
      flightOffer: offer,
    );
  }

  String _formatTimeEnglish(DateTime? dateTime) {
    if (dateTime == null) return "";

    final hour = dateTime.hour;
    final minute = dateTime.minute;

    // English time format (12-hour with AM/PM)
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12;
    final hourDisplay = hour12 == 0 ? 12 : hour12;

    return '$hourDisplay:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDateEnglish(DateTime? dateTime) {
    if (dateTime == null) return "";

    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Map<String, dynamic> _prepareApiRequestData(Map<String, dynamic> searchData) {
    final tripType = searchData['type'] ?? 'oneway';

    if (tripType == 'multi') {
      // Multi-city request
      final segments = searchData['segments'] as List<dynamic>? ?? [];

      return {
        'destinations': segments.map((segment) {
          return {
            'id': segment['id'] ?? '',
            'from': _extractAirportCode(segment['from'] ?? ''),
            'to': _extractAirportCode(segment['to'] ?? ''),
            'date': _formatDateForApi(segment['date'] ?? ''),
          };
        }).toList(),
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
      };
    } else if (tripType == 'round') {
      // Round-trip request
      return {
        'destinations': [
          {
            'id': '1',
            'from': _extractAirportCode(searchData['from'] ?? ''),
            'to': _extractAirportCode(searchData['to'] ?? ''),
            'date': _formatDateForApi(searchData['departureDate'] ?? ''),
          },
          {
            'id': '2',
            'from': _extractAirportCode(searchData['to'] ?? ''),
            'to': _extractAirportCode(searchData['from'] ?? ''),
            'date': _formatDateForApi(searchData['returnDate'] ?? ''),
          },
        ],
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
      };
    } else {
      // One-way request
      return {
        'destinations': [
          {
            'id': '1',
            'from': _extractAirportCode(searchData['from'] ?? ''),
            'to': _extractAirportCode(searchData['to'] ?? ''),
            'date': _formatDateForApi(searchData['departureDate'] ?? ''),
          },
        ],
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
      };
    }
  }

  String _extractAirportCode(String airportInfo) {
    // Extract airport code from "DXB - Dubai International"
    final parts = airportInfo.split(' - ');
    return parts.isNotEmpty ? parts[0] : airportInfo;
  }

  String _formatDateForApi(String displayDate) {
    // Convert "28-Sep-2025" to "2025-09-28"
    try {
      final parts = displayDate.split('-');
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

        final day = parts[0].padLeft(2, '0');
        final month = (monthNames.indexOf(parts[1]) + 1).toString().padLeft(
          2,
          '0',
        );
        final year = parts[2];

        return '$year-$month-$day';
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return displayDate;
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
        // 1. Price Filter - ONLY APPLY IF ACTIVE
        if (ticket.price < newFilters.minPrice ||
            ticket.price > newFilters.maxPrice) {
          return false;
        }

        // 2. Airlines Filter (use carrier codes)
        if (newFilters.airlines.isNotEmpty) {
          final ticketCarrierCode = ticket.airlineCode;
          final hasMatchingCarrier = newFilters.airlines.any(
            (carrier) => carrier.airLineCode == ticketCarrierCode,
          );
          if (!hasMatchingCarrier) {
            return false;
          }
        }

        // 3. Departure Time Filter
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

        // 4. Stops Filter
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

        // 5. Baggage Filter
        if (newFilters.hasBaggageOnly && !ticket.hasBaggage) {
          return false;
        }

        return true;
      }).toList();

      _safeEmit(state.copyWith(filteredTickets: filtered, filters: newFilters));
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

    final newFilters = FilterOptions(
      departureTimes: List.from(state.filters.departureTimes),
      stops: List.from(state.filters.stops),
      airlines: List.from(state.filters.airlines),
      minPrice: state.filters.minPrice, // Keep current values
      maxPrice: state.filters.maxPrice, // Keep current values
      hasBaggageOnly: state.filters.hasBaggageOnly,
    );

    switch (filterType) {
      case 'price':
        // Reset price to default range (0-10000)
        newFilters.minPrice = 0;
        newFilters.maxPrice = 10000;
        break;
      case 'stops':
        newFilters.stops.remove(value);
        break;
      case 'airlines':
        if (value is String) {
          newFilters.airlines.removeWhere(
            (carrier) => carrier.airLineCode == value,
          );
        } else if (value is Carrier) {
          newFilters.airlines.remove(value);
        }
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

    final newFilters = FilterOptions(
      minPrice: 0, // Reset to default min
      maxPrice: 10000, // Reset to default max
    );

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
