// lib/presentation/hotel_booking/models/hotel_booking_arguments.dart
import 'package:tayyran_app/data/models/hotel_search_model.dart';

class HotelBookingArguments {
  final HotelData hotel;
  final HotelRoom selectedRoom;
  final Map<String, dynamic> searchParams;
  final int numberOfRooms;
  final int totalAdults;
  final int totalChildren;

  const HotelBookingArguments({
    required this.hotel,
    required this.selectedRoom,
    required this.searchParams,
    required this.numberOfRooms,
    required this.totalAdults,
    required this.totalChildren,
  });
}
