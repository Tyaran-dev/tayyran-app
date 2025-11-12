// lib/presentation/hotels/cubit/hotel_search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/api/hotel_api_service.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';

part 'hotel_search_state.dart';

class HotelSearchCubit extends Cubit<HotelSearchState> {
  final HotelApiService _hotelApiService;

  HotelSearchCubit(this._hotelApiService) : super(HotelSearchInitial());

  Future<void> searchHotels(Map<String, dynamic> searchParams) async {
    if (isClosed) return; // Check if cubit is closed

    emit(HotelSearchLoading());

    try {
      final result = await _hotelApiService.searchHotels(searchParams);

      if (!isClosed) {
        // Check again before emitting
        emit(HotelSearchLoaded(hotels: result.data));
      }
    } catch (e) {
      if (!isClosed) {
        // Check again before emitting error
        emit(HotelSearchError(error: e.toString()));
      }
    }
  }

  void clearSearch() {
    if (!isClosed) {
      emit(HotelSearchInitial());
    }
  }
}
