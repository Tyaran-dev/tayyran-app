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
  final String pinCode;
  final String cityId;
  final String cityName;
  final String countryName;
  final String countryCode;
  final String phoneNumber;
  final String email;
  final String hotelWebsiteUrl;
  final String faxNumber;
  final String map;
  final double hotelRating;
  final String checkInTime;
  final String checkOutTime;
  final HotelFees hotelFees;
  final String currency;
  final List<HotelRoom> rooms;
  final double minHotelPrice;
  final double percentageCommission;

  HotelData({
    required this.hotelCode,
    required this.hotelName,
    required this.description,
    required this.hotelFacilities,
    required this.attractions,
    required this.image,
    required this.images,
    required this.address,
    required this.pinCode,
    required this.cityId,
    required this.cityName,
    required this.countryName,
    required this.countryCode,
    required this.phoneNumber,
    required this.email,
    required this.hotelWebsiteUrl,
    required this.faxNumber,
    required this.map,
    required this.hotelRating,
    required this.checkInTime,
    required this.checkOutTime,
    required this.hotelFees,
    required this.currency,
    required this.rooms,
    required this.minHotelPrice,
    required this.percentageCommission,
  });
  HotelData copyWith({
    String? hotelCode,
    String? hotelName,
    String? description,
    List<String>? hotelFacilities,
    Map<String, String>? attractions,
    String? image,
    List<String>? images,
    String? address,
    String? pinCode,
    String? cityId,
    String? cityName,
    String? countryName,
    String? countryCode,
    String? phoneNumber,
    String? email,
    String? hotelWebsiteUrl,
    String? faxNumber,
    String? map,
    double? hotelRating,
    String? checkInTime,
    String? checkOutTime,
    HotelFees? hotelFees,
    String? currency,
    List<HotelRoom>? rooms,
    double? minHotelPrice,
    double? percentageCommission,
  }) {
    return HotelData(
      hotelCode: hotelCode ?? this.hotelCode,
      hotelName: hotelName ?? this.hotelName,
      description: description ?? this.description,
      hotelFacilities: hotelFacilities ?? this.hotelFacilities,
      attractions: attractions ?? this.attractions,
      image: image ?? this.image,
      images: images ?? this.images,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      hotelWebsiteUrl: hotelWebsiteUrl ?? this.hotelWebsiteUrl,
      faxNumber: faxNumber ?? this.faxNumber,
      map: map ?? this.map,
      hotelRating: hotelRating ?? this.hotelRating,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      hotelFees: hotelFees ?? this.hotelFees,
      currency: currency ?? this.currency,
      rooms: rooms ?? this.rooms,
      minHotelPrice: minHotelPrice ?? this.minHotelPrice,
      percentageCommission: percentageCommission ?? this.percentageCommission,
    );
  }

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
      pinCode: json['PinCode'] ?? '',
      cityId: json['CityId'] ?? '',
      cityName: json['CityName'] ?? '',
      countryName: json['CountryName'] ?? '',
      countryCode: json['CountryCode'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      email: json['Email'] ?? '',
      hotelWebsiteUrl: json['HotelWebsiteUrl'] ?? '',
      faxNumber: json['FaxNumber'] ?? '',
      map: json['Map'] ?? '',
      hotelRating: (json['HotelRating'] as num?)?.toDouble() ?? 0.0,
      checkInTime: json['CheckInTime'] ?? '',
      checkOutTime: json['CheckOutTime'] ?? '',
      hotelFees: HotelFees.fromJson(json['HotelFees'] ?? {}),
      currency: json['Currency'] ?? 'USD',
      rooms:
          (json['Rooms'] as List<dynamic>?)
              ?.map((item) => HotelRoom.fromJson(item))
              .toList() ??
          [],
      minHotelPrice: (json['MinHotelPrice'] as num?)?.toDouble() ?? 0.0,
      percentageCommission:
          (json['presentageCommission'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Helper methods
  String get fullAddress {
    return '$address, $cityName, $countryName';
  }

  bool get hasContactInfo => phoneNumber.isNotEmpty || email.isNotEmpty;

  bool get hasWebsite => hotelWebsiteUrl.isNotEmpty;

  List<String> get coordinates {
    if (map.isEmpty) return [];
    return map.split('|');
  }

  double? get latitude {
    final coords = coordinates;
    if (coords.isNotEmpty) return double.tryParse(coords[0]);
    return null;
  }

  double? get longitude {
    final coords = coordinates;
    if (coords.length >= 2) return double.tryParse(coords[1]);
    return null;
  }
}

class HotelFees {
  final String hotelId;
  final List<dynamic> optional;
  final List<dynamic> mandatory;

  HotelFees({
    required this.hotelId,
    required this.optional,
    required this.mandatory,
  });

  factory HotelFees.fromJson(Map<String, dynamic> json) {
    return HotelFees(
      hotelId: json['HotelId']?.toString() ?? '',
      optional: json['Optional'] as List<dynamic>? ?? [],
      mandatory: json['Mandatory'] as List<dynamic>? ?? [],
    );
  }
}

class HotelRoom {
  final List<String> name;
  final String bookingCode;
  final String inclusion;
  final List<List<DayRate>> dayRates;
  final double totalFare;
  final double totalTax;
  final String mealType;
  final bool isRefundable;
  final List<CancelPolicy> cancelPolicies;
  final bool withTransfers;

  HotelRoom({
    required this.name,
    required this.bookingCode,
    required this.inclusion,
    required this.dayRates,
    required this.totalFare,
    required this.totalTax,
    required this.mealType,
    required this.isRefundable,
    required this.cancelPolicies,
    required this.withTransfers,
  });

  double calculateAdministrationFee(double percentageCommission) {
    return totalPrice *
        (percentageCommission / 100); // Use totalPrice, not totalFare
  }

  double calculateVAT(double administrationFee, {double vatRate = 15.0}) {
    return administrationFee * (vatRate / 100);
  }

  double calculateTotalWithFees(double percentageCommission) {
    final adminFee = calculateAdministrationFee(percentageCommission);
    final vat = calculateVAT(adminFee);
    return totalPrice + adminFee + vat; // Add to totalPrice
  }

  PriceBreakdown getPriceBreakdown(double percentageCommission) {
    final adminFee = calculateAdministrationFee(percentageCommission);
    final vat = calculateVAT(adminFee);
    final totalWithFees = totalPrice + adminFee + vat;
    print('=== PRICE CALCULATION DEBUG ===');
    print('Base Fare: $totalFare');
    print('totalTax: $totalTax');

    print('Admin Fee ($percentageCommission%): $adminFee');
    print('VAT (15% on admin fee): $vat');
    print('Original totalPrice: $totalPrice');
    print('New calculated totalWithFees: $totalWithFees');
    print('==============================');
    return PriceBreakdown(
      subtotal: totalPrice, // This is the provider's total (base + their taxes)
      administrationFee: adminFee,
      vat: vat,
      total: totalWithFees,
    );
  }

  factory HotelRoom.fromJson(Map<String, dynamic> json) {
    return HotelRoom(
      name:
          (json['Name'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      bookingCode: json['BookingCode'] ?? '',
      inclusion: json['Inclusion'] ?? '',
      dayRates: _parseDayRates(json['DayRates']),
      totalFare: (json['TotalFare'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['TotalTax'] as num?)?.toDouble() ?? 0.0,
      mealType: json['MealType'] ?? '',
      isRefundable: json['IsRefundable'] ?? false,
      cancelPolicies:
          (json['CancelPolicies'] as List<dynamic>?)
              ?.map((item) => CancelPolicy.fromJson(item))
              .toList() ??
          [],
      withTransfers: json['WithTransfers'] ?? false,
    );
  }

  static List<List<DayRate>> _parseDayRates(dynamic dayRatesData) {
    if (dayRatesData is! List) return [];

    return dayRatesData.map((period) {
      if (period is List) {
        return period.map((rate) => DayRate.fromJson(rate)).toList();
      }
      return <DayRate>[];
    }).toList();
  }

  double get totalPrice => totalFare + totalTax;

  String get displayName => name.isNotEmpty ? name.first : 'Standard Room';

  CancelPolicy? get freeCancellationPolicy {
    return cancelPolicies.firstWhere(
      (policy) => policy.cancellationCharge == 0,
      orElse: () => cancelPolicies.first,
    );
  }
}

class DayRate {
  final double basePrice;

  DayRate({required this.basePrice});

  factory DayRate.fromJson(Map<String, dynamic> json) {
    return DayRate(basePrice: (json['BasePrice'] as num?)?.toDouble() ?? 0.0);
  }
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

  bool get isFreeCancellation => cancellationCharge == 0;

  String get displayText {
    if (isFreeCancellation) {
      return 'Free cancellation until $fromDate';
    } else if (chargeType == 'Percentage') {
      return '$cancellationCharge% charge after $fromDate';
    } else {
      return '${cancellationCharge.toStringAsFixed(2)} charge after $fromDate';
    }
  }
}

class PriceBreakdown {
  final double subtotal;
  final double administrationFee;
  final double vat;
  final double total;

  PriceBreakdown({
    required this.subtotal,
    required this.administrationFee,
    required this.vat,
    required this.total,
  });
}
