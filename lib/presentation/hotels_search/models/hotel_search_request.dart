// models/hotel_search_request.dart
class HotelSearchRequest {
  final String checkIn;
  final String checkOut;
  final String language;
  final String cityCode;
  final String guestNationality;
  final String preferredCurrencyCode;
  final List<PaxRoom> paxRooms;
  final double responseTime;
  final bool isDetailedResponse;
  final Filters filters;

  HotelSearchRequest({
    required this.checkIn,
    required this.checkOut,
    required this.language,
    required this.cityCode,
    required this.guestNationality,
    required this.preferredCurrencyCode,
    required this.paxRooms,
    this.responseTime = 23.0,
    this.isDetailedResponse = true,
    required this.filters,
  });

  Map<String, dynamic> toJson() => {
    "CheckIn": checkIn,
    "CheckOut": checkOut,
    "Language": language,
    "CityCode": cityCode,
    "GuestNationality": guestNationality,
    "PreferredCurrencyCode": preferredCurrencyCode,
    "PaxRooms": paxRooms.map((room) => room.toJson()).toList(),
    "ResponseTime": responseTime,
    "IsDetailedResponse": isDetailedResponse,
    "Filters": filters.toJson(),
  };
}

class PaxRoom {
  final int adults;
  final int children;
  final List<int> childrenAges;

  PaxRoom({
    required this.adults,
    required this.children,
    required this.childrenAges,
  });

  Map<String, dynamic> toJson() => {
    "Adults": adults,
    "Children": children,
    "ChildrenAges": childrenAges,
  };
}

class Filters {
  final bool refundable;
  final int noOfRooms;
  final String mealType;

  Filters({
    this.refundable = false,
    this.noOfRooms = 50,
    this.mealType = "All",
  });

  Map<String, dynamic> toJson() => {
    "Refundable": refundable,
    "NoOfRooms": noOfRooms,
    "MealType": mealType,
  };
}
