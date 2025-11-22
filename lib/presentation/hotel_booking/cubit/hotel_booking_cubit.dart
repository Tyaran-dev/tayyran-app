// lib/presentation/hotel_booking/cubit/hotel_booking_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/api/hotel_api_service.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_booking_arguments.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/guest_info.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_price_details.dart';

part 'hotel_booking_state.dart';

class HotelBookingCubit extends Cubit<HotelBookingState> {
  final HotelApiService _hotelApiService;
  final HotelBookingArguments _arguments;

  HotelBookingCubit(this._hotelApiService, this._arguments)
    : super(
        HotelBookingInitial(
          hotel: _arguments.hotel,
          selectedRoom: _arguments.selectedRoom,
          searchParams: _arguments.searchParams,
          numberOfRooms: _arguments.numberOfRooms,
          totalAdults: _arguments.totalAdults,
          totalChildren: _arguments.totalChildren,
        ),
      ) {
    _fetchPriceDetails();
  }

  Future<void> _fetchPriceDetails() async {
    if (isClosed) return;

    emit((state as HotelBookingInitial).copyWith(isLoading: true));

    try {
      final requestData = {"BookingCode": _arguments.selectedRoom.bookingCode};
      final response = await _hotelApiService.getBookingPriceDetails(
        requestData,
      );

      if (!isClosed) {
        final currentState = state as HotelBookingInitial;
        emit(currentState.copyWith(isLoading: false, priceDetails: response));
      }
    } catch (e) {
      if (!isClosed) {
        final currentState = state as HotelBookingInitial;
        emit(currentState.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  void updateGuestInfo(int roomIndex, int guestIndex, GuestInfo guestInfo) {
    if (state is HotelBookingInitial) {
      final currentState = state as HotelBookingInitial;
      final updatedGuests = List<List<GuestInfo>>.from(currentState.guests);

      while (updatedGuests.length <= roomIndex) {
        updatedGuests.add([]);
      }

      while (updatedGuests[roomIndex].length <= guestIndex) {
        updatedGuests[roomIndex].add(const GuestInfo());
      }

      updatedGuests[roomIndex][guestIndex] = guestInfo;

      emit(currentState.copyWith(guests: updatedGuests));
    }
  }

  void updateContactInfo(String email, String phone) {
    if (state is HotelBookingInitial) {
      final currentState = state as HotelBookingInitial;
      emit(currentState.copyWith(contactEmail: email, contactPhone: phone));
    }
  }

  void updateGuestInfoFromSheet(
    int roomIndex,
    int guestIndex,
    GuestInfo guestInfo,
  ) {
    if (state is HotelBookingInitial) {
      final currentState = state as HotelBookingInitial;
      final updatedGuests = List<List<GuestInfo>>.from(currentState.guests);

      // Ensure we have enough rooms
      while (updatedGuests.length <= roomIndex) {
        updatedGuests.add([]);
      }

      // Ensure we have enough guests in this room
      while (updatedGuests[roomIndex].length <= guestIndex) {
        updatedGuests[roomIndex].add(const GuestInfo());
      }

      updatedGuests[roomIndex][guestIndex] = guestInfo;

      emit(currentState.copyWith(guests: updatedGuests));

      print('✅ Updated guest info for Room $roomIndex, Guest $guestIndex');
      print('   Title: ${guestInfo.title}');
      print('   First Name: ${guestInfo.firstName}');
      print('   Last Name: ${guestInfo.lastName}');
    }
  }

  void updateCountryCode(String countryCode) {
    if (state is HotelBookingInitial) {
      final currentState = state as HotelBookingInitial;
      emit(currentState.copyWith(countryCode: countryCode));
    }
  }

  void updateContactPhone(String phone) {
    if (state is HotelBookingInitial) {
      final currentState = state as HotelBookingInitial;
      emit(currentState.copyWith(contactPhone: phone));
    }
  }

  // Public phone validation method
  bool isValidPhone(String phone) {
    // Basic phone validation - at least 8 digits
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  // Public email validation method
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool get isFormValid {
    if (state is HotelBookingInitial) {
      final currentState = state as HotelBookingInitial;

      // Check contact info using public methods
      if (currentState.contactEmail.isEmpty ||
          currentState.contactPhone.isEmpty ||
          !isValidEmail(currentState.contactEmail) ||
          !isValidPhone(currentState.contactPhone)) {
        return false;
      }

      for (
        int roomIndex = 0;
        roomIndex < currentState.numberOfRooms;
        roomIndex++
      ) {
        final roomGuests = currentState.guests.length > roomIndex
            ? currentState.guests[roomIndex]
            : [];

        // Get the actual number of guests needed for this room
        final guestsNeeded = _getGuestsForRoom(currentState, roomIndex);

        if (roomGuests.length < guestsNeeded) {
          return false;
        }

        // Check each guest has required fields
        for (int i = 0; i < guestsNeeded; i++) {
          if (i >= roomGuests.length) return false;
          final guest = roomGuests[i];
          if (guest.title.isEmpty ||
              guest.firstName.isEmpty ||
              guest.lastName.isEmpty) {
            return false;
          }
        }
      }

      return true;
    }
    return false;
  }

  // Helper method to calculate guests per room with uneven distribution
  List<int> _calculateGuestsPerRoom(HotelBookingInitial state) {
    final guestsPerRoom = <int>[];
    var remainingAdults = state.totalAdults;

    for (int i = 0; i < state.numberOfRooms; i++) {
      if (i == state.numberOfRooms - 1) {
        // Last room gets all remaining adults
        guestsPerRoom.add(remainingAdults);
      } else {
        // Distribute adults evenly
        final guestsInThisRoom = (remainingAdults / (state.numberOfRooms - i))
            .ceil();
        guestsPerRoom.add(guestsInThisRoom);
        remainingAdults -= guestsInThisRoom;
      }
    }

    return guestsPerRoom;
  }

  // Helper method to get number of guests for a specific room
  int _getGuestsForRoom(HotelBookingInitial state, int roomIndex) {
    final guestsPerRoom = _calculateGuestsPerRoom(state);
    return roomIndex < guestsPerRoom.length ? guestsPerRoom[roomIndex] : 0;
  }
}
