class FlightSearchResponse {
  final bool success;
  final List<FlightOffer> data;
  final Filters filters; // ADD THIS
  final String? message;

  FlightSearchResponse({
    required this.success,
    required this.data,
    required this.filters, // ADD THIS
    this.message,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((x) => FlightOffer.fromJson(x))
          .toList(),
      filters: Filters.fromJson(json['filters'] ?? {}), // ADD THIS
      message: json['message'],
    );
  }
  Map<String, double> getPriceRange() {
    if (data.isEmpty) return {'min': 0, 'max': 10000};

    final prices = data.map((offer) => offer.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    return {'min': minPrice, 'max': maxPrice};
  }

  List<Carrier> getAvailableCarriers() {
    // Get all unique airline codes from the flight data
    final Set<String> availableAirlineCodes = data
        .expand((flight) => flight.itineraries)
        .expand((itinerary) => itinerary.segments)
        .map((segment) => segment.carrierCode)
        .where((code) => code.isNotEmpty)
        .toSet();

    // Filter carriers to only include those with available flights
    return filters.carriers
        .where((carrier) => availableAirlineCodes.contains(carrier.airLineCode))
        .toList();
  }

  // You might also want this helper method
  Carrier? getCarrierByCode(String code) {
    return filters.carriers.firstWhere(
      (carrier) => carrier.airLineCode == code,
      orElse: () => Carrier.empty(),
    );
  }
}

class Filters {
  final List<Carrier> carriers;

  Filters({required this.carriers});

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      carriers: List<Carrier>.from(
        (json['carriers'] as List<dynamic>? ?? []).map(
          (x) => Carrier.fromJson(x),
        ),
      ),
    );
  }

  // Helper method to find carrier by code
  Carrier? findCarrierByCode(String code) {
    return carriers.firstWhere(
      (carrier) => carrier.airLineCode == code,
      orElse: () => Carrier.empty(),
    );
  }
}

// ADD CARRIER MODEL
class Carrier {
  final String id;
  final String airLineCode;
  final String airLineName;
  final String airlineNameAr;
  final String name;
  final String image;

  Carrier({
    required this.id,
    required this.airLineCode,
    required this.airLineName,
    required this.airlineNameAr,
    required this.name,
    required this.image,
  });

  factory Carrier.fromJson(Map<String, dynamic> json) {
    return Carrier(
      id: json['_id'] ?? '',
      airLineCode: json['airLineCode'] ?? '',
      airLineName: json['airLineName'] ?? '',
      airlineNameAr: json['airlineNameAr'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  factory Carrier.empty() {
    return Carrier(
      id: '',
      airLineCode: '',
      airLineName: '',
      airlineNameAr: '',
      name: '',
      image: '',
    );
  }
}

class FlightOffer {
  final String mapping;
  final double price;
  final String currency;
  final String fromLocation;
  final String toLocation;
  final String fromName;
  final String toName;
  final int stops;
  final bool refund;
  final bool exchange;
  final String cabinClass;
  final String allowedBags;
  final int allowedCabinBags;
  final int numberOfBookableSeats;
  final List<Itinerary> itineraries;
  final List<FareRule> fareRules;
  final List<TravellerPricing> travellerPricing;

  FlightOffer({
    required this.mapping,
    required this.price,
    required this.currency,
    required this.fromLocation,
    required this.toLocation,
    required this.fromName,
    required this.toName,
    required this.stops,
    required this.refund,
    required this.exchange,
    required this.cabinClass,
    required this.allowedBags,
    required this.allowedCabinBags,
    required this.numberOfBookableSeats,
    required this.itineraries,
    required this.fareRules,
    required this.travellerPricing,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    // Get direction from first itinerary
    final firstItinerary =
        (json["itineraries_formated"] as List<dynamic>? ?? []).isNotEmpty
        ? Itinerary.fromJson(json["itineraries_formated"][0])
        : Itinerary.empty();

    return FlightOffer(
      mapping: json["mapping"] ?? "",
      price: (json["price"] as num?)?.toDouble() ?? 0.0,
      currency: json["currency"] ?? "SAR",
      fromLocation: firstItinerary.fromAirport.code, // FROM ITINERARY
      toLocation: firstItinerary.toAirport.code, // FROM ITINERARY
      fromName: firstItinerary.fromAirport.name, // FROM ITINERARY
      toName: firstItinerary.toAirport.name, // FROM ITINERARY
      stops: json["stops"] ?? 0,
      refund: json["refund"] ?? false,
      exchange: json["exchange"] ?? false,
      cabinClass: json["cabinClass"] ?? "Economy",
      allowedBags: json["allowedBags"] ?? "",
      allowedCabinBags: json["allowedCabinBags"] ?? 0,
      numberOfBookableSeats: json["numberOfBookableSeats"] ?? 0,
      itineraries: List<Itinerary>.from(
        (json["itineraries_formated"] as List<dynamic>? ?? []).map(
          (x) => Itinerary.fromJson(x),
        ),
      ),
      fareRules: List<FareRule>.from(
        (json["fare_rules"] as List<dynamic>? ?? []).map(
          (x) => FareRule.fromJson(x),
        ),
      ),
      travellerPricing: List<TravellerPricing>.from(
        (json["traveller_pricing"] as List<dynamic>? ?? []).map(
          (x) => TravellerPricing.fromJson(x),
        ),
      ),
    );
  }
}

class Itinerary {
  final String duration;
  final String fromName;
  final String toName;
  final Airport fromAirport;
  final Airport toAirport;
  final List<Segment> segments;
  final List<StopDetail> stops;

  Itinerary({
    required this.duration,
    required this.fromName,
    required this.toName,
    required this.fromAirport,
    required this.toAirport,
    required this.segments,
    required this.stops,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
    duration: json["duration"] ?? "",
    fromName: json["fromName"] ?? "",
    toName: json["toName"] ?? "",
    fromAirport: Airport.fromJson(json["fromAirport"] ?? {}),
    toAirport: Airport.fromJson(json["toAirport"] ?? {}),
    segments: List<Segment>.from(
      (json["segments"] as List<dynamic>? ?? []).map(
        (x) => Segment.fromJson(x),
      ),
    ),
    stops: List<StopDetail>.from(
      (json["stops"] as List<dynamic>? ?? []).map(
        (x) => StopDetail.fromJson(x),
      ),
    ),
  );

  // ADD EMPTY CONSTRUCTOR
  factory Itinerary.empty() {
    return Itinerary(
      duration: "",
      fromName: "",
      toName: "",
      fromAirport: Airport.empty(),
      toAirport: Airport.empty(),
      segments: [],
      stops: [],
    );
  }
}

class Segment {
  final SegmentEndpoint departure;
  final SegmentEndpoint arrival;
  final String carrierCode;
  final String number;
  final String duration;
  final String fromName;
  final String toName;
  final Airport fromAirport;
  final Airport toAirport;
  final String? image;
  final String? stopDuration;

  Segment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
    required this.duration,
    required this.fromName,
    required this.toName,
    required this.fromAirport,
    required this.toAirport,
    this.image,
    this.stopDuration,
  });

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
    departure: SegmentEndpoint.fromJson(json["departure"] ?? {}),
    arrival: SegmentEndpoint.fromJson(json["arrival"] ?? {}),
    carrierCode: json["carrierCode"] ?? "",
    number: json["number"] ?? "",
    duration: json["duration"] ?? "",
    fromName: json["fromName"] ?? "",
    toName: json["toName"] ?? "",
    fromAirport: Airport.fromJson(json["fromAirport"] ?? {}),
    toAirport: Airport.fromJson(json["toAirport"] ?? {}),
    image: json["image"],
    stopDuration: json["stopDuration"],
  );
}

class Airport {
  final String id;
  final String name;
  final String code;
  final String city;

  Airport({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
  });

  factory Airport.fromJson(Map<String, dynamic> json) => Airport(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    code: json["code"] ?? "",
    city: json["city"] ?? "",
  );

  // ADD EMPTY CONSTRUCTOR
  factory Airport.empty() {
    return Airport(id: "", name: "", code: "", city: "");
  }
}

class SegmentEndpoint {
  final String iataCode;
  final String? terminal;
  final DateTime at;

  SegmentEndpoint({required this.iataCode, this.terminal, required this.at});

  factory SegmentEndpoint.fromJson(Map<String, dynamic> json) =>
      SegmentEndpoint(
        iataCode: json["iataCode"] ?? "",
        terminal: json["terminal"],
        at: json["at"] != null
            ? DateTime.parse(json["at"])
            : DateTime.now(), // Fallback to now
      );
}

class StopDetail {
  final Airport airport;
  final String duration;

  StopDetail({required this.airport, required this.duration});

  factory StopDetail.fromJson(Map<String, dynamic> json) => StopDetail(
    airport: Airport.fromJson(json["airport"] ?? {}),
    duration: json["duration"] ?? "",
  );
}

class FareRule {
  final String category;
  final String? maxPenaltyAmount;
  final bool? notApplicable;

  FareRule({required this.category, this.maxPenaltyAmount, this.notApplicable});

  factory FareRule.fromJson(Map<String, dynamic> json) => FareRule(
    category: json["category"] ?? "",
    maxPenaltyAmount: json["maxPenaltyAmount"],
    notApplicable: json["notApplicable"],
  );
}

class TravellerPricing {
  final String travelerType;
  final String total;
  final String base;
  final double tax;

  TravellerPricing({
    required this.travelerType,
    required this.total,
    required this.base,
    required this.tax,
  });

  factory TravellerPricing.fromJson(Map<String, dynamic> json) =>
      TravellerPricing(
        travelerType: json["travelerType"] ?? "",
        total: json["total"] ?? "",
        base: json["base"] ?? "",
        tax: (json["tax"] as num?)?.toDouble() ?? 0.0,
      );
}
