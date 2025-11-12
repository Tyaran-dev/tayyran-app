// lib/data/models/hotel_search_model.dart
class HotelSearchModel {
  final bool success;
  final List<HotelData> data;

  HotelSearchModel({required this.success, required this.data});

  factory HotelSearchModel.fromJson(Map<String, dynamic> json) {
    return HotelSearchModel(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => HotelData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class HotelData {
  final String hotelCode;
  final String hotelName;
  final String description;
  final List<String> hotelFacilities;
  final Map<String, String> attractions;
  final String image;
  final List<String> images;
  final String address;
  final String cityName;
  final String countryName;
  final double hotelRating;
  final String checkInTime;
  final String checkOutTime;
  final String currency;
  final List<HotelRoom> rooms;
  final double minHotelPrice;

  HotelData({
    required this.hotelCode,
    required this.hotelName,
    required this.description,
    required this.hotelFacilities,
    required this.attractions,
    required this.image,
    required this.images,
    required this.address,
    required this.cityName,
    required this.countryName,
    required this.hotelRating,
    required this.checkInTime,
    required this.checkOutTime,
    required this.currency,
    required this.rooms,
    required this.minHotelPrice,
  });

  factory HotelData.fromJson(Map<String, dynamic> json) {
    return HotelData(
      hotelCode: json['HotelCode'] ?? '',
      hotelName: json['HotelName'] ?? '',
      description: json['Description'] ?? '',
      hotelFacilities:
          (json['HotelFacilities'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      attractions: Map<String, String>.from(json['Attractions'] ?? {}),
      image: json['Image'] ?? '',
      images:
          (json['Images'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      address: json['Address'] ?? '',
      cityName: json['CityName'] ?? '',
      countryName: json['CountryName'] ?? '',
      hotelRating: (json['HotelRating'] as num?)?.toDouble() ?? 0.0,
      checkInTime: json['CheckInTime'] ?? '',
      checkOutTime: json['CheckOutTime'] ?? '',
      currency: json['Currency'] ?? 'USD',
      rooms:
          (json['Rooms'] as List<dynamic>?)
              ?.map((item) => HotelRoom.fromJson(item))
              .toList() ??
          [],
      minHotelPrice: (json['MinHotelPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HotelRoom {
  final List<String> name;
  final String bookingCode;
  final String inclusion;
  final double totalFare;
  final double totalTax;
  final String mealType;
  final bool isRefundable;
  final List<CancelPolicy> cancelPolicies;
  final List<String>? roomPromotion;

  HotelRoom({
    required this.name,
    required this.bookingCode,
    required this.inclusion,
    required this.totalFare,
    required this.totalTax,
    required this.mealType,
    required this.isRefundable,
    required this.cancelPolicies,
    this.roomPromotion,
  });

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      name:
          (json['Name'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      bookingCode: json['BookingCode'] ?? '',
      inclusion: json['Inclusion'] ?? '',
      totalFare: (json['TotalFare'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['TotalTax'] as num?)?.toDouble() ?? 0.0,
      mealType: json['MealType'] ?? '',
      isRefundable: json['IsRefundable'] ?? false,
      cancelPolicies:
          (json['CancelPolicies'] as List<dynamic>?)
              ?.map((item) => CancelPolicy.fromJson(item))
              .toList() ??
          [],
      roomPromotion: (json['RoomPromotion'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  double get totalPrice => totalFare + totalTax;
}

class CancelPolicy {
  final String fromDate;
  final String chargeType;
  final double cancellationCharge;

  CancelPolicy({
    required this.fromDate,
    required this.chargeType,
    required this.cancellationCharge,
  });

  factory CancelPolicy.fromJson(Map<String, dynamic> json) {
    return CancelPolicy(
      fromDate: json['FromDate'] ?? '',
      chargeType: json['ChargeType'] ?? '',
      cancellationCharge:
          (json['CancellationCharge'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
