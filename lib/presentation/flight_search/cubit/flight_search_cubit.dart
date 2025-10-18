import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/repositories/flight_search_repository.dart';
import 'package:tayyran_app/presentation/flight/models/multi_flight_segment.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/flight_search/models/filter_options.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';

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

  Future<void> loadFlights(
    Map<String, dynamic> searchData,
    BuildContext context,
  ) async {
    if (_isLoading || isClosed || _isDisposed) return;
    _isLoading = true;

    print('🔍 [CUBIT] ========== STARTING FLIGHT SEARCH ==========');
    print('🔍 [CUBIT] Original searchData received: $searchData');

    // Format for UI display
    final formattedSearchData = formatSearchDataForAppBar(searchData);

    print('🔍 [CUBIT] Formatted searchData: $formattedSearchData');

    _safeEmit(
      state.copyWith(
        isLoading: true,
        searchData: formattedSearchData, // For UI
        originalSearchData: searchData, // For API calls and retry
        errorMessage: null,
      ),
    );

    try {
      // Use original searchData for API call
      final apiRequestData = _prepareApiRequestData(searchData);

      print('🔍 [CUBIT] Final API request data: $apiRequestData');

      final response = await _repository.searchFlights(apiRequestData);

      if (response.success) {
        final availableCarriers = response.getAvailableCarriers();
        final priceRange = response.getPriceRange();

        final tickets = response.data.map((offer) {
          return _createFlightTicket(offer, response.filters, context);
        }).toList();

        _safeEmit(
          state.copyWith(
            isLoading: false,
            tickets: tickets,
            filteredTickets: tickets,
            availableCarriers: availableCarriers,
            minTicketPrice: priceRange['min'] ?? 0,
            maxTicketPrice: priceRange['max'] ?? 10000,
            filters: FilterOptions(minPrice: 0, maxPrice: 10000),
          ),
        );

        print('✅ [CUBIT] Flight search completed successfully');
      } else {
        _safeEmit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.message ?? 'Failed to load flights',
          ),
        );

        print('❌ [CUBIT] Flight search failed: ${response.message}');
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load flights: $e',
        ),
      );

      print('❌ [CUBIT] Flight search error: $e');
    } finally {
      _isLoading = false;
      print('🔍 [CUBIT] ========== FLIGHT SEARCH COMPLETED ==========');
    }
  }

  // Format search data for app bar display
  Map<String, dynamic> formatSearchDataForAppBar(
    Map<String, dynamic> searchData,
  ) {
    final tripType = searchData['flightType'] ?? 'oneway';
    print("SEARCH DATA ON FORMAT SEARCH DATA $searchData");

    if (tripType == 'multi') {
      final segments = searchData['segments'] as List<dynamic>? ?? [];
      final multiCityRoutes = segments.map((segment) {
        return {
          'from': segment['from']?.toString() ?? '',
          'to': segment['to']?.toString() ?? '',
          'date': segment['date']?.toString() ?? '',
        };
      }).toList();

      return {
        'flightType': 'multi',
        'multiCityRoutes': multiCityRoutes,
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
      };
    } else {
      return {
        'flightType': tripType,
        'from': searchData['from']?.toString() ?? '',
        'to': searchData['to']?.toString() ?? '',
        'departureDate': searchData['departureDate']?.toString() ?? '',
        'returnDate': searchData['returnDate']?.toString() ?? '',
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
      };
    }
  }

  FlightTicket _createFlightTicket(
    FlightOffer offer,
    Filters filters,
    BuildContext context,
  ) {
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

    // Use Arabic name if locale is Arabic
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final airlineName = isArabic
        ? safeValue(carrier?.airlineNameAr, carrier?.airLineName ?? carrierCode)
        : safeValue(carrier?.airLineName, carrierCode);

    final airlineLogo = safeValue(carrier?.image, "");

    // Use localized time formatting
    final departureTime = _formatTimeLocalized(
      firstSegment?.departure.at,
      context,
    );
    final arrivalTime = _formatTimeLocalized(firstSegment?.arrival.at, context);
    final departureDateFormatted = _formatDateLocalized(
      firstSegment?.departure.at,
      context,
    );
    final arrivalDateFormatted = _formatDateLocalized(
      firstSegment?.arrival.at,
      context,
    );

    // CREATE FLIGHT SEGMENTS FROM ALL ITINERARIES
    final flightSegments = _createFlightSegments(offer, filters, context);

    return FlightTicket(
      id: offer.mapping,
      airline: airlineName,
      airlineLogo: airlineLogo,
      airlineCode: carrierCode,
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
      filterCarrier: filters,
      flightType: offer.flightType,
      flightSegments: flightSegments,
    );
  }

  // Create flight segments from all itineraries with localization
  List<MultiFlightSegment> _createFlightSegments(
    FlightOffer offer,
    Filters filters,
    BuildContext context,
  ) {
    final segments = <MultiFlightSegment>[];
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    for (final itinerary in offer.itineraries) {
      for (final segment in itinerary.segments) {
        final carrier = filters.findCarrierByCode(segment.carrierCode);

        // Extract airport codes and cities
        final fromParts = segment.fromName.split(' - ');
        final toParts = segment.toName.split(' - ');
        final fromCode = fromParts.isNotEmpty
            ? fromParts[0]
            : segment.fromAirport.code;
        final toCode = toParts.isNotEmpty ? toParts[0] : segment.toAirport.code;
        final fromCity = fromParts.length > 1
            ? fromParts[1]
            : segment.fromAirport.city;
        final toCity = toParts.length > 1 ? toParts[1] : segment.toAirport.city;

        // Use Arabic airline name if available
        final airlineName = isArabic
            ? (carrier?.airlineNameAr ??
                  carrier?.airLineName ??
                  segment.carrierCode)
            : (carrier?.airLineName ?? segment.carrierCode);

        final flightSegment = MultiFlightSegment(
          from: segment.fromName,
          to: segment.toName,
          fromCode: fromCode,
          toCode: toCode,
          fromCity: fromCity,
          toCity: toCity,
          airline: airlineName,
          airlineLogo: carrier?.image ?? '',
          airlineCode: segment.carrierCode,
          departureTime: _formatTimeLocalized(segment.departure.at, context),
          arrivalTime: _formatTimeLocalized(segment.arrival.at, context),
          departureDateFormatted: _formatDateLocalized(
            segment.departure.at,
            context,
          ),
          arrivalDateFormatted: _formatDateLocalized(
            segment.arrival.at,
            context,
          ),
          duration: segment.duration,
          stops: segment.numberOfStops,
          isDirect: segment.numberOfStops == 0,
          arrivesNextDay: segment.arrival.at.day != segment.departure.at.day,
          departureDate: segment.departure.at,
          arrivalDate: segment.arrival.at,
        );

        segments.add(flightSegment);
      }
    }

    return segments;
  }

  // Localized time formatting
  String _formatTimeLocalized(DateTime? dateTime, BuildContext context) {
    if (dateTime == null) return "";

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return _formatTimeArabic(dateTime);
    } else {
      return _formatTimeEnglish(dateTime);
    }
  }

  // Arabic time format
  String _formatTimeArabic(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    // Arabic time format (12-hour with ص/م)
    final period = hour >= 12 ? 'م' : 'ص';
    final hour12 = hour % 12;
    final hourDisplay = hour12 == 0 ? 12 : hour12;

    return '$hourDisplay:${minute.toString().padLeft(2, '0')} $period';
  }

  // English time format
  String _formatTimeEnglish(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12;
    final hourDisplay = hour12 == 0 ? 12 : hour12;

    return '$hourDisplay:${minute.toString().padLeft(2, '0')} $period';
  }

  // Localized date formatting
  String _formatDateLocalized(DateTime? dateTime, BuildContext context) {
    if (dateTime == null) return "";

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return _formatDateArabic(dateTime);
    } else {
      return _formatDateEnglish(dateTime);
    }
  }

  // Arabic date format
  String _formatDateArabic(DateTime dateTime) {
    final day = dateTime.day;
    final month = _getArabicMonth(dateTime.month);
    final year = dateTime.year;

    return '$day $month $year';
  }

  String _getArabicMonth(int month) {
    final months = {
      1: 'يناير',
      2: 'فبراير',
      3: 'مارس',
      4: 'أبريل',
      5: 'مايو',
      6: 'يونيو',
      7: 'يوليو',
      8: 'أغسطس',
      9: 'سبتمبر',
      10: 'أكتوبر',
      11: 'نوفمبر',
      12: 'ديسمبر',
    };
    return months[month] ?? '';
  }

  // English date format
  String _formatDateEnglish(DateTime dateTime) {
    return formatDateForBackend(dateTime);
  }

  Map<String, dynamic> _prepareApiRequestData(Map<String, dynamic> searchData) {
    final tripType = searchData['flightType'] ?? 'oneway';

    print('🔍 [CUBIT] Preparing API request data:');
    print('   Trip Type: $tripType');
    print('   Original Search Data: $searchData');

    if (tripType == 'multi') {
      // Multi-city request
      final segments = searchData['segments'] as List<dynamic>? ?? [];

      print('   Multi-city segments:');
      for (final segment in segments) {
        print(
          '     Segment: ${segment['from']} -> ${segment['to']} on ${segment['date']}',
        );
      }

      return {
        'destinations': segments.map((segment) {
          final fromCode = _extractAirportCode(segment['from'] ?? '');
          final toCode = _extractAirportCode(segment['to'] ?? '');
          final date = _formatDateForApi(segment['date'] ?? '');

          print('   🚀 Sending segment to API:');
          print('     From: ${segment['from']} -> $fromCode');
          print('     To: ${segment['to']} -> $toCode');
          print('     Date: ${segment['date']} -> $date');

          return {
            'id': segment['id'] ?? '',
            'from': fromCode,
            'to': toCode,
            'date': date,
          };
        }).toList(),
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
        'flightType': "multi",
      };
    } else if (tripType == 'round') {
      // Round-trip request
      final fromCode = _extractAirportCode(searchData['from'] ?? '');
      final toCode = _extractAirportCode(searchData['to'] ?? '');
      final departureDate = _formatDateForApi(
        searchData['departureDate'] ?? '',
      );
      final returnDate = _formatDateForApi(searchData['returnDate'] ?? '');

      print('   🚀 Sending round-trip to API:');
      print('     From: ${searchData['from']} -> $fromCode');
      print('     To: ${searchData['to']} -> $toCode');
      print('     Departure: ${searchData['departureDate']} -> $departureDate');
      print('     Return: ${searchData['returnDate']} -> $returnDate');

      return {
        'destinations': [
          {'id': '1', 'from': fromCode, 'to': toCode, 'date': departureDate},
          {'id': '2', 'from': toCode, 'to': fromCode, 'date': returnDate},
        ],
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
        'flightType': "round",
      };
    } else {
      // One-way request
      final fromCode = _extractAirportCode(searchData['from'] ?? '');
      final toCode = _extractAirportCode(searchData['to'] ?? '');
      final departureDate = _formatDateForApi(
        searchData['departureDate'] ?? '',
      );

      print('   🚀 Sending one-way to API:');
      print('     From: ${searchData['from']} -> $fromCode');
      print('     To: ${searchData['to']} -> $toCode');
      print('     Date: ${searchData['departureDate']} -> $departureDate');

      return {
        'destinations': [
          {'id': '1', 'from': fromCode, 'to': toCode, 'date': departureDate},
        ],
        'adults': searchData['adults'] ?? 1,
        'children': searchData['children'] ?? 0,
        'infants': searchData['infants'] ?? 0,
        'cabinClass': searchData['cabinClass'] ?? 'Economy',
        'flightType': 'oneway',
      };
    }
  }

  String _extractAirportCode(String airportInfo) {
    // Extract airport code from "DXB - Dubai International"
    final parts = airportInfo.split(' - ');
    return parts.isNotEmpty ? parts[0] : airportInfo;
  }

  String _formatDateForApi(String displayDate) {
    print('🔧 [CUBIT] Formatting date for API: "$displayDate"');

    try {
      // Use the helper function to parse the date
      final dateTime = parseDate(displayDate);

      // Use the helper function to format for backend
      final result = formatDateForBackend(dateTime);

      print(
        '✅ [CUBIT] Date converted using helpers: "$displayDate" -> "$result"',
      );
      return result;
    } catch (e) {
      print('❌ [CUBIT] Error formatting date "$displayDate" using helpers: $e');

      // Fallback: try manual parsing if helper fails
      try {
        final parts = displayDate.split('-');
        if (parts.length == 3) {
          // Handle both Arabic and English month names using helper
          final monthNumber = getMonthNumberFromLocalizedName(parts[1]);

          // ignore: unnecessary_null_comparison
          if (monthNumber != null) {
            final day = parts[0].padLeft(2, '0');
            final month = monthNumber.toString().padLeft(2, '0');
            final year = parts[2];

            final result = '$year-$month-$day';
            print(
              '✅ [CUBIT] Date converted manually: "$displayDate" -> "$result"',
            );
            return result;
          }
        }
      } catch (e2) {
        print('❌ [CUBIT] Manual conversion also failed: $e2');
      }
    }

    print('⚠️ [CUBIT] Returning original date: "$displayDate"');
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

  // Helper method to convert numbers to Arabic numerals
  String _convertToArabicNumerals(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // Method to format price based on locale
  String formatPriceForLocale(double price, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return _convertToArabicNumerals(price.toStringAsFixed(0));
    } else {
      return price.toStringAsFixed(0);
    }
  }

  // Method to format any number based on locale
  String formatNumberForLocale(int number, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic
        ? _convertToArabicNumerals(number.toString())
        : number.toString();
  }

  // Retry flight search with current search data
  Future<void> retrySearch(BuildContext context) async {
    await loadFlights(state.originalSearchData, context);
  }

  // Refresh flights with current search data
  Future<void> refreshFlights(BuildContext context) async {
    await loadFlights(state.originalSearchData, context);
  }

  // Check if search is in progress
  bool get isLoading => _isLoading;

  // Get current search state
  FlightSearchState get currentState => state;
}
