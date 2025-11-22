// lib/presentation/hotel_booking/cubit/hotel_booking_state.dart
part of 'hotel_booking_cubit.dart';

abstract class HotelBookingState {
  const HotelBookingState();
}

class HotelBookingInitial extends HotelBookingState {
  final HotelData hotel;
  final HotelRoom selectedRoom;
  final Map<String, dynamic> searchParams;
  final int numberOfRooms;
  final int totalAdults;
  final int totalChildren;
  final HotelPriceDetails? priceDetails;
  final List<List<GuestInfo>> guests;
  final String contactEmail;
  final String contactPhone;
  final String countryCode;
  final bool isLoading;
  final String? error;

  const HotelBookingInitial({
    required this.hotel,
    required this.selectedRoom,
    required this.searchParams,
    required this.numberOfRooms,
    required this.totalAdults,
    required this.totalChildren,
    this.priceDetails,
    this.guests = const [],
    this.contactEmail = '',
    this.contactPhone = '',
    this.countryCode = '+966',
    this.isLoading = false,
    this.error,
  });

  HotelBookingInitial copyWith({
    HotelData? hotel,
    HotelRoom? selectedRoom,
    Map<String, dynamic>? searchParams,
    int? numberOfRooms,
    int? totalAdults,
    int? totalChildren,
    HotelPriceDetails? priceDetails,
    List<List<GuestInfo>>? guests,
    String? contactEmail,
    String? contactPhone,
    String? countryCode,
    bool? isLoading,
    String? error,
  }) {
    return HotelBookingInitial(
      hotel: hotel ?? this.hotel,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      searchParams: searchParams ?? this.searchParams,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      totalAdults: totalAdults ?? this.totalAdults,
      totalChildren: totalChildren ?? this.totalChildren,
      priceDetails: priceDetails ?? this.priceDetails,
      guests: guests ?? this.guests,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      countryCode: countryCode ?? this.countryCode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Calculate final price with admin fee and VAT
  double get finalPrice {
    if (priceDetails == null) return selectedRoom.totalPrice;

    final basePrice = priceDetails!.totalFare;
    final adminFee = basePrice * 0.10; // 10% admin fee
    final vat = (basePrice + adminFee) * 0.15; // 15% VAT
    return basePrice + adminFee + vat;
  }

  // Get price breakdown
  Map<String, double> get priceBreakdown {
    if (priceDetails == null) {
      // Fallback to selected room calculations
      final breakdown = selectedRoom.getPriceBreakdown(
        hotel.percentageCommission,
      );
      return {
        'base_price': selectedRoom.totalPrice,
        'tax': 0.0,
        'admin_fee': breakdown.administrationFee,
        'vat': breakdown.vat,
        'total': breakdown.total,
      };
    }

    // Use the existing calculation logic from HotelRoom model
    final breakdown = selectedRoom.getPriceBreakdown(
      hotel.percentageCommission,
    );

    return {
      'base_price': selectedRoom.totalPrice,
      'tax': priceDetails!.totalTax,
      'admin_fee': breakdown.administrationFee,
      'vat': breakdown.vat,
      'total': breakdown.total,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HotelBookingInitial &&
        other.hotel == hotel &&
        other.selectedRoom == selectedRoom &&
        other.searchParams == searchParams &&
        other.numberOfRooms == numberOfRooms &&
        other.totalAdults == totalAdults &&
        other.totalChildren == totalChildren &&
        other.priceDetails == priceDetails &&
        _deepEquals(other.guests, guests) &&
        other.contactEmail == contactEmail &&
        other.contactPhone == contactPhone &&
        other.countryCode == countryCode &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      hotel,
      selectedRoom,
      searchParams,
      numberOfRooms,
      totalAdults,
      totalChildren,
      priceDetails,
      Object.hashAll(guests.expand((e) => e)),
      contactEmail,
      contactPhone,
      countryCode,
      isLoading,
      error,
    );
  }

  bool _deepEquals(List<List<GuestInfo>> list1, List<List<GuestInfo>> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].length != list2[i].length) return false;
      for (int j = 0; j < list1[i].length; j++) {
        if (list1[i][j] != list2[i][j]) return false;
      }
    }
    return true;
  }
}
