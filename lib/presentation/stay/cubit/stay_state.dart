// stay_state.dart
part of 'stay_cubit.dart';

@immutable
class StayState {
  final String to;
  final String checkInDate;
  final String checkOutDate;
  final int rooms;
  final int guests;
  final bool isLoading;
  final String? errorMessage;
  final List<RecentSearchModel> recentSearches;

  const StayState({
    this.to = "",
    this.checkInDate = "",
    this.checkOutDate = "",
    this.rooms = 1,
    this.guests = 2,
    this.isLoading = false,
    this.errorMessage,
    this.recentSearches = const [],
  });

  StayState copyWith({
    String? to,
    String? checkInDate,
    String? checkOutDate,
    int? rooms,
    int? guests,
    bool? isLoading,
    String? errorMessage,
    List<RecentSearchModel>? recentSearches,
  }) {
    return StayState(
      to: to ?? this.to,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      rooms: rooms ?? this.rooms,
      guests: guests ?? this.guests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StayState &&
        other.to == to &&
        other.checkInDate == checkInDate &&
        other.checkOutDate == checkOutDate &&
        other.rooms == rooms &&
        other.guests == guests &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        listEquals(other.recentSearches, recentSearches);
  }

  @override
  int get hashCode {
    return to.hashCode ^
        checkInDate.hashCode ^
        checkOutDate.hashCode ^
        rooms.hashCode ^
        guests.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode ^
        recentSearches.hashCode;
  }

  static StayState initial() {
    return const StayState();
  }
}
