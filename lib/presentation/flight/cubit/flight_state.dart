// flight_state.dart
part of 'flight_cubit.dart';

@immutable
class FlightState {
  final String tripType;
  final String from;
  final String to;
  final String departureDate;
  final String returnDate;
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;
  final bool isLoading;
  final String? errorMessage;
  final List<RecentSearchModel> recentSearches;

  const FlightState({
    this.tripType = "oneway",
    this.from = "",
    this.to = "",
    this.departureDate = "",
    this.returnDate = "",
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = "Economy",
    this.isLoading = false,
    this.errorMessage,
    this.recentSearches = const [],
  });

  int get totalPassengers => adults + children + infants;

  FlightState copyWith({
    String? tripType,
    String? from,
    String? to,
    String? departureDate,
    String? returnDate,
    int? adults,
    int? children,
    int? infants,
    String? cabinClass,
    bool? isLoading,
    String? errorMessage,
    List<RecentSearchModel>? recentSearches,
  }) {
    return FlightState(
      tripType: tripType ?? this.tripType,
      from: from ?? this.from,
      to: to ?? this.to,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      cabinClass: cabinClass ?? this.cabinClass,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FlightState &&
        other.tripType == tripType &&
        other.from == from &&
        other.to == to &&
        other.departureDate == departureDate &&
        other.returnDate == returnDate &&
        other.adults == adults &&
        other.children == children &&
        other.infants == infants &&
        other.cabinClass == cabinClass &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        listEquals(other.recentSearches, recentSearches);
  }

  @override
  int get hashCode {
    return tripType.hashCode ^
        from.hashCode ^
        to.hashCode ^
        departureDate.hashCode ^
        returnDate.hashCode ^
        adults.hashCode ^
        children.hashCode ^
        infants.hashCode ^
        cabinClass.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode ^
        recentSearches.hashCode;
  }

  static FlightState initial() {
    return const FlightState();
  }
}
