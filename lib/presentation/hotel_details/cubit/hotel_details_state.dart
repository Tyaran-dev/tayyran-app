// // lib/presentation/hotel_details/cubit/hotel_details_state.dart
// part of 'hotel_details_cubit.dart';

// abstract class HotelDetailsState {
//   const HotelDetailsState();
// }

// class HotelDetailsInitial extends HotelDetailsState {}

// class HotelDetailsLoaded extends HotelDetailsState {
//   final HotelData hotel;
//   final HotelRoom? selectedRoom;
//   final Map<String, dynamic> searchParams;

//   const HotelDetailsLoaded({
//     required this.hotel,
//     this.selectedRoom,
//     required this.searchParams,
//   });

//   HotelDetailsLoaded copyWith({HotelRoom? selectedRoom}) {
//     return HotelDetailsLoaded(
//       hotel: hotel,
//       selectedRoom: selectedRoom ?? this.selectedRoom,
//       searchParams: searchParams,
//     );
//   }
// }
// lib/presentation/hotel_details/cubit/hotel_details_state.dart
part of 'hotel_details_cubit.dart';

abstract class HotelDetailsState {
  const HotelDetailsState();
}

class HotelDetailsLoading extends HotelDetailsState {}

class HotelDetailsLoaded extends HotelDetailsState {
  final HotelData hotel;
  final HotelRoom? selectedRoom;
  final Map<String, dynamic> searchParams;

  const HotelDetailsLoaded({
    required this.hotel,
    this.selectedRoom,
    required this.searchParams,
  });

  HotelDetailsLoaded copyWith({HotelRoom? selectedRoom}) {
    return HotelDetailsLoaded(
      hotel: hotel,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      searchParams: searchParams,
    );
  }
}
