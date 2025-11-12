// lib/presentation/hotels/cubit/hotel_search_state.dart
part of 'hotel_search_cubit.dart';

abstract class HotelSearchState {
  const HotelSearchState();
}

class HotelSearchInitial extends HotelSearchState {}

class HotelSearchLoading extends HotelSearchState {}

class HotelSearchLoaded extends HotelSearchState {
  final List<HotelData> hotels;

  const HotelSearchLoaded({required this.hotels});
}

class HotelSearchError extends HotelSearchState {
  final String error;

  const HotelSearchError({required this.error});
}
