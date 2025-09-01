// filter_options.dart
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';

class FilterOptions {
  List<DepartureTimeFilter> departureTimes;
  List<StopFilter> stops;
  List<String> airlines;
  double minPrice;
  double maxPrice;
  bool hasBaggageOnly;

  FilterOptions({
    List<DepartureTimeFilter>? departureTimes,
    List<StopFilter>? stops,
    List<String>? airlines,
    double? minPrice,
    double? maxPrice,
    bool? hasBaggageOnly,
  }) : departureTimes = departureTimes ?? [],
       stops = stops ?? [],
       airlines = airlines ?? [],
       minPrice = minPrice ?? 0,
       maxPrice = maxPrice ?? 10000,
       hasBaggageOnly = hasBaggageOnly ?? false;

  FilterOptions copyWith({
    List<DepartureTimeFilter>? departureTimes,
    List<StopFilter>? stops,
    List<String>? airlines,
    double? minPrice,
    double? maxPrice,
    bool? hasBaggageOnly,
  }) {
    return FilterOptions(
      departureTimes: departureTimes ?? List.from(this.departureTimes),
      stops: stops ?? List.from(this.stops),
      airlines: airlines ?? List.from(this.airlines),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasBaggageOnly: hasBaggageOnly ?? this.hasBaggageOnly,
    );
  }

  // Helper method to check if any filters are active
  bool get hasActiveFilters {
    return departureTimes.isNotEmpty ||
        stops.isNotEmpty ||
        airlines.isNotEmpty ||
        minPrice > 0 ||
        maxPrice < 10000 ||
        hasBaggageOnly;
  }

  // Helper method to get filter summary
  String get summary {
    final filters = <String>[];

    if (departureTimes.isNotEmpty) {
      filters.add('Departure: ${departureTimes.length} selected');
    }

    if (stops.isNotEmpty) {
      filters.add('Stops: ${stops.length} selected');
    }

    if (airlines.isNotEmpty) {
      filters.add('Airlines: ${airlines.length} selected');
    }

    if (minPrice > 0 || maxPrice < 10000) {
      filters.add('Price: \$$minPrice - \$$maxPrice');
    }

    if (hasBaggageOnly) {
      filters.add('Baggage only');
    }

    return filters.isEmpty ? 'No filters' : filters.join(', ');
  }
}
