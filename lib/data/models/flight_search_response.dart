// lib/data/models/flight_search_response.dart
class FlightSearchResponse {
  final bool success;
  final List<FlightOffer> data;
  final Filters filters;
  final String? message;
  final double presentageCommission;
  final double presentageVat;

  FlightSearchResponse({
    required this.success,
    required this.data,
    required this.filters,
    required this.presentageCommission,
    required this.presentageVat,

    this.message,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    final filters = Filters.fromJson(json['filters'] ?? {});
    return FlightSearchResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map(
            (x) => FlightOffer.fromJson(
              x,
              filters: filters,
              presentageCommission:
                  (json['presentageCommission'] as num?)?.toDouble() ?? 0.0,
              presentageVat: (json['presentageVat'] as num?)?.toDouble() ?? 0.0,
            ),
          ) // Pass filters here
          .toList(),
      filters: Filters.fromJson(json['filters'] ?? {}),
      message: json['message'],
      presentageCommission:
          (json['presentageCommission'] as num?)?.toDouble() ?? 0.0,
      presentageVat: (json['presentageVat'] as num?)?.toDouble() ?? 0.0,
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
    final Set<String> availableAirlineCodes = data
        .expand((flight) => flight.itineraries)
        .expand((itinerary) => itinerary.segments)
        .map((segment) => segment.carrierCode)
        .where((code) => code.isNotEmpty)
        .toSet();

    return filters.carriers
        .where((carrier) => availableAirlineCodes.contains(carrier.airLineCode))
        .toList();
  }

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

  Carrier? findCarrierByCode(String code) {
    return carriers.firstWhere(
      (carrier) => carrier.airLineCode == code,
      orElse: () => Carrier.empty(),
    );
  }
}

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
  final String id;
  final String mapping;
  final String type;
  final String agent;
  final String source;
  final String fromLocation;
  final String toLocation;
  final String fromName;
  final String toName;
  final String flightType;
  final int adults;
  final int children;
  final int infants;
  final int numberOfBookableSeats;
  final String airline;
  final String airlineLogo;
  final String airlineName;
  final String flightNumber;
  final int stops;
  final double originalPrice;
  final double basePrice;
  final double price;
  final String currency;
  final bool refund;
  final bool exchange;
  final String cabinClass;
  final String allowedBags;
  final int allowedCabinBags;
  final String provider;
  final List<Itinerary> itineraries;
  final List<FareRule> fareRules;
  final PricingOptions pricingOptions;
  final List<TravellerPricing> travellerPricing;
  final List<BaggageDetail> baggageDetails;
  final Map<String, dynamic> totalPricingByTravellerType;
  final Charges charges;
  final List<String> origins;
  final List<String> destinations;
  final Map<String, dynamic> originalResponse;
  final double presentageCommission;
  final double presentageVat;
  final List<String> validatingAirlineCodes;

  FlightOffer({
    required this.id,
    required this.mapping,
    required this.type,
    required this.agent,
    required this.source,
    required this.fromLocation,
    required this.toLocation,
    required this.fromName,
    required this.toName,
    required this.flightType,
    required this.adults,
    required this.children,
    required this.infants,
    required this.numberOfBookableSeats,
    required this.airline,
    required this.airlineName,
    required this.airlineLogo,
    required this.flightNumber,
    required this.stops,
    required this.originalPrice,
    required this.basePrice,
    required this.price,
    required this.currency,
    required this.refund,
    required this.exchange,
    required this.cabinClass,
    required this.allowedBags,
    required this.allowedCabinBags,
    required this.provider,
    required this.itineraries,
    required this.fareRules,
    required this.pricingOptions,
    required this.travellerPricing,
    required this.baggageDetails,
    required this.totalPricingByTravellerType,
    required this.charges,
    required this.origins,
    required this.destinations,
    required this.originalResponse,
    required this.presentageCommission,
    required this.presentageVat,
    required this.validatingAirlineCodes,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "mapping": mapping,
      "type": type,
      "agent": agent,
      "source": source,
      "fromLocation": fromLocation,
      "toLocation": toLocation,
      "fromName": fromName,
      "toName": toName,
      "flightType": flightType,
      "adults": adults,
      "children": children,
      "infants": infants,
      "numberOfBookableSeats": numberOfBookableSeats,
      "airline": airline,
      "airlineLogo": airlineLogo,
      "airlineName": airlineName,
      "flightNumber": flightNumber,
      "stops": stops,
      "originalPrice": originalPrice,
      "basePrice": basePrice,
      "price": price,
      "currency": currency,
      "refund": refund,
      "exchange": exchange,
      "cabinClass": cabinClass,
      "allowedBags": allowedBags,
      "allowedCabinBags": allowedCabinBags,
      "provider": provider,
      "itineraries": itineraries
          .map((itinerary) => itinerary.toJson())
          .toList(),
      "fareRules": fareRules.map((rule) => rule.toJson()).toList(),
      "pricingOptions": pricingOptions.toJson(),
      "travellerPricing": travellerPricing
          .map((pricing) => pricing.toJson())
          .toList(),
      "baggageDetails": baggageDetails
          .map((detail) => detail.toJson())
          .toList(),
      "totalPricingByTravellerType": totalPricingByTravellerType,
      "charges": charges.toJson(),
      "origins": origins,
      "destinations": destinations,
      "originalResponse": originalResponse,
      "presentageCommission": presentageCommission,
      "presentageVat": presentageVat,

      "validatingAirlineCodes": validatingAirlineCodes,
    };
  }

  FlightOffer copyWith({
    double? presentageCommission,
    double? presentageVat,
    String? id,
    String? mapping,
    String? type,
    String? agent,
    String? source,
    String? fromLocation,
    String? toLocation,
    String? fromName,
    String? toName,
    String? flightType,
    int? adults,
    int? children,
    int? infants,
    int? numberOfBookableSeats,
    String? airline,
    String? airlineLogo,
    String? airlineName,
    String? flightNumber,
    int? stops,
    double? originalPrice,
    double? basePrice,
    double? price,
    String? currency,
    bool? refund,
    bool? exchange,
    String? cabinClass,
    String? allowedBags,
    int? allowedCabinBags,
    String? provider,
    List<Itinerary>? itineraries,
    List<FareRule>? fareRules,
    PricingOptions? pricingOptions,
    List<TravellerPricing>? travellerPricing,
    List<BaggageDetail>? baggageDetails,
    Map<String, dynamic>? totalPricingByTravellerType,
    Charges? charges,
    List<String>? origins,
    List<String>? destinations,
    Map<String, dynamic>? originalResponse,
    List<String>? validatingAirlineCodes,
  }) {
    return FlightOffer(
      presentageCommission: presentageCommission ?? this.presentageCommission,
      presentageVat: presentageVat ?? this.presentageVat,
      id: id ?? this.id,
      mapping: mapping ?? this.mapping,
      type: type ?? this.type,
      agent: agent ?? this.agent,
      source: source ?? this.source,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      fromName: fromName ?? this.fromName,
      toName: toName ?? this.toName,
      flightType: flightType ?? this.flightType,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      numberOfBookableSeats:
          numberOfBookableSeats ?? this.numberOfBookableSeats,
      airline: airline ?? this.airline,
      airlineName: airlineName ?? this.airlineName,
      airlineLogo: airlineLogo ?? this.airlineLogo,
      flightNumber: flightNumber ?? this.flightNumber,
      stops: stops ?? this.stops,
      originalPrice: originalPrice ?? this.originalPrice,
      basePrice: basePrice ?? this.basePrice,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      refund: refund ?? this.refund,
      exchange: exchange ?? this.exchange,
      cabinClass: cabinClass ?? this.cabinClass,
      allowedBags: allowedBags ?? this.allowedBags,
      allowedCabinBags: allowedCabinBags ?? this.allowedCabinBags,
      provider: provider ?? this.provider,
      itineraries: itineraries ?? this.itineraries,
      fareRules: fareRules ?? this.fareRules,
      pricingOptions: pricingOptions ?? this.pricingOptions,
      travellerPricing: travellerPricing ?? this.travellerPricing,
      baggageDetails: baggageDetails ?? this.baggageDetails,
      totalPricingByTravellerType:
          totalPricingByTravellerType ?? this.totalPricingByTravellerType,
      charges: charges ?? this.charges,
      origins: origins ?? this.origins,
      destinations: destinations ?? this.destinations,
      originalResponse: originalResponse ?? this.originalResponse,
      validatingAirlineCodes:
          validatingAirlineCodes ?? this.validatingAirlineCodes,
    );
  }

  factory FlightOffer.fromJson(
    Map<String, dynamic> json, {
    Filters? filters,
    double presentageCommission = 0.0,
    double presentageVat = 0.0,
  }) {
    final firstItinerary =
        (json["itineraries_formated"] as List<dynamic>? ?? []).isNotEmpty
        ? Itinerary.fromJson(json["itineraries_formated"][0])
        : Itinerary.empty();
    final firstSegment = firstItinerary.segments.isNotEmpty
        ? firstItinerary.segments[0]
        : null;

    final carrierCode = firstSegment?.carrierCode ?? "";
    // Helper function to safely get values
    String safeValue(String? value, String fallback) {
      return (value ?? "").isNotEmpty ? value! : fallback;
    }

    // Get carrier information if filters are provided
    Carrier? carrier;
    String airlineNameFromCarrier = json['airlineName'] ?? '';
    String airlineLogoFromCarrier = '';

    if (filters != null && carrierCode.isNotEmpty) {
      carrier = filters.findCarrierByCode(carrierCode);
      airlineNameFromCarrier = safeValue(carrier?.airLineName, carrierCode);
      airlineLogoFromCarrier = safeValue(carrier?.image, "");
    }
    return FlightOffer(
      id: json['id']?.toString() ?? '',
      mapping: json['mapping'] ?? '',
      type: json['type'] ?? '',
      agent: json['agent'] ?? '',
      source: json['source'] ?? '',
      fromLocation: firstItinerary.fromAirport.code,
      toLocation: firstItinerary.toAirport.code,
      fromName: firstItinerary.fromAirport.name,
      toName: firstItinerary.toAirport.name,
      flightType: json['flightType'] ?? '',
      adults: (json['adults'] as num?)?.toInt() ?? 0,
      children: (json['children'] as num?)?.toInt() ?? 0,
      infants: (json['infants'] as num?)?.toInt() ?? 0,
      numberOfBookableSeats:
          (json['numberOfBookableSeats'] as num?)?.toInt() ?? 0,
      airline: json['airline'] ?? '',
      airlineName: airlineNameFromCarrier,
      airlineLogo: airlineLogoFromCarrier,
      flightNumber: json['flightNumber'] ?? '',
      stops: (json['stops'] as num?)?.toInt() ?? 0,
      originalPrice:
          double.tryParse(json['original_price']?.toString() ?? '0') ?? 0.0,
      basePrice: double.tryParse(json['basePrice']?.toString() ?? '0') ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'SAR',
      refund: json['refund'] ?? false,
      exchange: json['exchange'] ?? false,
      cabinClass: json['cabinClass'] ?? '',
      allowedBags: json['allowedBags'] ?? '',
      allowedCabinBags: (json['allowedCabinBags'] as num?)?.toInt() ?? 0,
      provider: json['provider'] ?? '',
      itineraries: List<Itinerary>.from(
        (json['itineraries_formated'] as List<dynamic>? ?? []).map(
          (x) => Itinerary.fromJson(x),
        ),
      ),
      fareRules: List<FareRule>.from(
        (json['fare_rules'] as List<dynamic>? ?? []).map(
          (x) => FareRule.fromJson(x),
        ),
      ),
      pricingOptions: PricingOptions.fromJson(json['pricing_options'] ?? {}),
      travellerPricing: List<TravellerPricing>.from(
        (json['traveller_pricing'] as List<dynamic>? ?? []).map(
          (x) => TravellerPricing.fromJson(x),
        ),
      ),
      baggageDetails: List<BaggageDetail>.from(
        (json['baggage_details'] as List<dynamic>? ?? []).map(
          (x) => BaggageDetail.fromJson(x),
        ),
      ),
      totalPricingByTravellerType: Map<String, dynamic>.from(
        json['total_pricing_by_traveller_type'] ?? {},
      ),
      charges: Charges.fromJson(json['charges'] ?? {}),
      origins: List<String>.from(json['origins'] ?? []),
      destinations: List<String>.from(json['destinations'] ?? []),
      originalResponse: Map<String, dynamic>.from(
        json['originalResponse'] ?? {},
      ),
      presentageCommission:
          (json['presentageCommission'] as num?)?.toDouble() ??
          presentageCommission,
      presentageVat:
          (json['presentageVat'] as num?)?.toDouble() ?? presentageVat,
      validatingAirlineCodes: List<String>.from(
        json['validatingAirlineCodes'] ?? [],
      ),
    );
  }

  // Helper methods
  bool get isDirect => stops == 0;
  bool get hasStops => stops > 0;
  int get totalSegments =>
      itineraries.fold(0, (sum, itinerary) => sum + itinerary.segments.length);

  Duration get totalDuration {
    if (itineraries.isEmpty) return Duration.zero;

    final firstSegment = itineraries.first.segments.first;
    final lastSegment = itineraries.last.segments.last;

    return lastSegment.arrival.at.difference(firstSegment.departure.at);
  }

  String get formattedTotalDuration {
    final duration = totalDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Null get passengers => null;
}

class Itinerary {
  final String duration;
  final String fromLocation;
  final String toLocation;
  final String fromName;
  final String toName;
  final Airport fromAirport;
  final Airport toAirport;
  final DepartureInfo? departure;
  final List<Segment> segments;
  final List<dynamic> stops;

  Itinerary({
    required this.duration,
    required this.fromLocation,
    required this.toLocation,
    required this.fromName,
    required this.toName,
    required this.fromAirport,
    required this.toAirport,
    this.departure,
    required this.segments,
    required this.stops,
  });

  Map<String, dynamic> toJson() {
    return {
      "duration": duration,
      "fromLocation": fromLocation,
      "toLocation": toLocation,
      "fromName": fromName,
      "toName": toName,
      "fromAirport": fromAirport.toJson(),
      "toAirport": toAirport.toJson(),
      "departure": departure?.toJson(),
      "segments": segments.map((segment) => segment.toJson()).toList(),
      "stops": stops,
    };
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
    duration: json['duration'] ?? '',
    fromLocation: json['fromLocation'] ?? '',
    toLocation: json['toLocation'] ?? '',
    fromName: json['fromName'] ?? '',
    toName: json['toName'] ?? '',
    fromAirport: Airport.fromJson(json['fromAirport'] ?? {}),
    toAirport: Airport.fromJson(json['toAirport'] ?? {}),
    departure: json['departure'] != null
        ? DepartureInfo.fromJson(json['departure'])
        : null,
    segments: List<Segment>.from(
      (json['segments'] as List<dynamic>? ?? []).map(
        (x) => Segment.fromJson(x),
      ),
    ),
    stops: json['stops'] as List<dynamic>? ?? [],
  );

  factory Itinerary.empty() {
    return Itinerary(
      duration: "",
      fromLocation: "",
      toLocation: "",
      fromName: "",
      toName: "",
      fromAirport: Airport.empty(),
      toAirport: Airport.empty(),
      departure: null,
      segments: [],
      stops: [],
    );
  }
}

class DepartureInfo {
  final DateTime departureDateTime;
  final String departureDate;
  final String departureTime;
  final String? departureTerminal;
  final DateTime arrivalDateTime;
  final String arrivalDate;
  final String arrivalTime;
  final String? arrivalTerminal;
  final int stops;
  final String duration;
  final String flightNumber;
  final String airlineCode;
  final String airlineName;
  final String image;

  DepartureInfo({
    required this.departureDateTime,
    required this.departureDate,
    required this.departureTime,
    this.departureTerminal,
    required this.arrivalDateTime,
    required this.arrivalDate,
    required this.arrivalTime,
    this.arrivalTerminal,
    required this.stops,
    required this.duration,
    required this.flightNumber,
    required this.airlineCode,
    required this.airlineName,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      "departure_date_time": departureDateTime.toIso8601String(),
      "departure_date": departureDate,
      "departure_time": departureTime,
      "departure_terminal": departureTerminal,
      "arrival_date_time": arrivalDateTime.toIso8601String(),
      "arrival_date": arrivalDate,
      "arrival_time": arrivalTime,
      "arrival_terminal": arrivalTerminal,
      "stops": stops,
      "duration": duration,
      "flightNumber": flightNumber,
      "airlineCode": airlineCode,
      "airlineName": airlineName,
      "image": image,
    };
  }

  factory DepartureInfo.fromJson(Map<String, dynamic> json) => DepartureInfo(
    departureDateTime: DateTime.parse(
      json['departure_date_time'] ?? '2025-01-01T00:00:00',
    ),
    departureDate: json['departure_date'] ?? '',
    departureTime: json['departure_time'] ?? '',
    departureTerminal: json['departure_terminal'],
    arrivalDateTime: DateTime.parse(
      json['arrival_date_time'] ?? '2025-01-01T00:00:00',
    ),
    arrivalDate: json['arrival_date'] ?? '',
    arrivalTime: json['arrival_time'] ?? '',
    arrivalTerminal: json['arrival_terminal'],
    stops: (json['stops'] as num?)?.toInt() ?? 0,
    duration: json['duration'] ?? '',
    flightNumber: json['flightNumber'] ?? '',
    airlineCode: json['airlineCode'] ?? '',
    airlineName: json['airlineName'] ?? '',
    image: json['image'] ?? '',
  );
}

class Segment {
  final SegmentEndpoint departure;
  final SegmentEndpoint arrival;
  final String carrierCode;
  final String number;
  final Aircraft? aircraft;
  final OperatingCarrier? operating;
  final String duration;
  final String id;
  final int numberOfStops;
  final bool blacklistedInEU;
  final String departureDate;
  final String departureTime;
  final String arrivalDate;
  final String arrivalTime;
  final String? stopDuration;
  final String? stopLocation;
  final String fromName;
  final String toName;
  final Airport fromAirport;
  final Airport toAirport;
  final String segmentClass;
  final String? image;

  Segment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
    this.aircraft,
    this.operating,
    required this.duration,
    required this.id,
    required this.numberOfStops,
    required this.blacklistedInEU,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
    this.stopDuration,
    this.stopLocation,
    required this.fromName,
    required this.toName,
    required this.fromAirport,
    required this.toAirport,
    required this.segmentClass,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      "departure": departure.toJson(),
      "arrival": arrival.toJson(),
      "carrierCode": carrierCode,
      "number": number,
      "aircraft": aircraft?.toJson(),
      "operating": operating?.toJson(),
      "duration": duration,
      "id": id,
      "numberOfStops": numberOfStops,
      "blacklistedInEU": blacklistedInEU,
      "departure_date": departureDate,
      "departure_time": departureTime,
      "arrival_date": arrivalDate,
      "arrival_time": arrivalTime,
      "stopDuration": stopDuration,
      "stopLocation": stopLocation,
      "fromName": fromName,
      "toName": toName,
      "fromAirport": fromAirport.toJson(),
      "toAirport": toAirport.toJson(),
      "class": segmentClass,
      "image": image,
    };
  }

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
    departure: SegmentEndpoint.fromJson(json['departure'] ?? {}),
    arrival: SegmentEndpoint.fromJson(json['arrival'] ?? {}),
    carrierCode: json['carrierCode'] ?? '',
    number: json['number'] ?? '',
    aircraft: json['aircraft'] != null
        ? Aircraft.fromJson(json['aircraft'])
        : null,
    operating: json['operating'] != null
        ? OperatingCarrier.fromJson(json['operating'])
        : null,
    duration: json['duration'] ?? '',
    id: json['id']?.toString() ?? '',
    numberOfStops: (json['numberOfStops'] as num?)?.toInt() ?? 0,
    blacklistedInEU: json['blacklistedInEU'] ?? false,
    departureDate: json['departure_date'] ?? '',
    departureTime: json['departure_time'] ?? '',
    arrivalDate: json['arrival_date'] ?? '',
    arrivalTime: json['arrival_time'] ?? '',
    stopDuration: json['stopDuration'],
    stopLocation: json['stopLocation'],
    fromName: json['fromName'] ?? '',
    toName: json['toName'] ?? '',
    fromAirport: Airport.fromJson(json['fromAirport'] ?? {}),
    toAirport: Airport.fromJson(json['toAirport'] ?? {}),
    segmentClass: json['class'] ?? '',
    image: json['image'],
  );
}

class SegmentEndpoint {
  final String iataCode;
  final DateTime at;
  final String? terminal;

  SegmentEndpoint({required this.iataCode, required this.at, this.terminal});

  factory SegmentEndpoint.fromJson(Map<String, dynamic> json) =>
      SegmentEndpoint(
        iataCode: json['iataCode'] ?? '',
        at: DateTime.parse(json['at'] ?? '2025-01-01T00:00:00'),
        terminal: json['terminal'],
      );
  Map<String, dynamic> toJson() {
    return {
      "iataCode": iataCode,
      "at": at.toIso8601String(),
      "terminal": terminal,
    };
  }
}

class Aircraft {
  final String code;

  Aircraft({required this.code});

  factory Aircraft.fromJson(Map<String, dynamic> json) =>
      Aircraft(code: json['code'] ?? '');
  Map<String, dynamic> toJson() {
    return {"code": code};
  }
}

class OperatingCarrier {
  final String carrierCode;

  OperatingCarrier({required this.carrierCode});
  Map<String, dynamic> toJson() {
    return {"carrierCode": carrierCode};
  }

  factory OperatingCarrier.fromJson(Map<String, dynamic> json) =>
      OperatingCarrier(carrierCode: json['carrierCode'] ?? '');
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
  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "code": code, "city": city};
  }

  factory Airport.fromJson(Map<String, dynamic> json) => Airport(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    city: json['city'] ?? '',
  );

  factory Airport.empty() {
    return Airport(id: "", name: "", code: "", city: "");
  }
}

class StopDetail {
  final Airport airport;
  final String duration;

  StopDetail({required this.airport, required this.duration});

  factory StopDetail.fromJson(Map<String, dynamic> json) => StopDetail(
    airport: Airport.fromJson(json['airport'] ?? {}),
    duration: json['duration'] ?? '',
  );
}

class FareRule {
  final String category;
  final String? maxPenaltyAmount;
  final bool? notApplicable;
  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "maxPenaltyAmount": maxPenaltyAmount,
      "notApplicable": notApplicable,
    };
  }

  FareRule({required this.category, this.maxPenaltyAmount, this.notApplicable});

  factory FareRule.fromJson(Map<String, dynamic> json) => FareRule(
    category: json['category'] ?? '',
    maxPenaltyAmount: json['maxPenaltyAmount'],
    notApplicable: json['notApplicable'],
  );
}

class PricingOptions {
  final List<String> fareType;
  final bool includedCheckedBagsOnly;

  PricingOptions({
    required this.fareType,
    required this.includedCheckedBagsOnly,
  });
  Map<String, dynamic> toJson() {
    return {
      "fareType": fareType,
      "includedCheckedBagsOnly": includedCheckedBagsOnly,
    };
  }

  factory PricingOptions.fromJson(Map<String, dynamic> json) => PricingOptions(
    fareType: List<String>.from(json['fareType'] ?? []),
    includedCheckedBagsOnly: json['includedCheckedBagsOnly'] ?? false,
  );
}

class TravellerPricing {
  final String travelerType;
  final String total;
  final String base;
  final double tax;
  final String travelClass;
  final BaggageAllowance allowedBags;
  final int cabinBagsAllowed;
  final List<FareDetail> fareDetails;

  TravellerPricing({
    required this.travelerType,
    required this.total,
    required this.base,
    required this.tax,
    required this.travelClass,
    required this.allowedBags,
    required this.cabinBagsAllowed,
    required this.fareDetails,
  });
  Map<String, dynamic> toJson() {
    return {
      "travelerType": travelerType,
      "total": total,
      "base": base,
      "tax": tax,
      "class": travelClass,
      "allowedBags": allowedBags.toJson(),
      "cabinBagsAllowed": cabinBagsAllowed,
      "fareDetails": fareDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  factory TravellerPricing.fromJson(Map<String, dynamic> json) =>
      TravellerPricing(
        travelerType: json['travelerType'] ?? '',
        total: json['total'] ?? '',
        base: json['base'] ?? '',
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        travelClass: json['class'] ?? '',
        allowedBags: BaggageAllowance.fromJson(json['allowedBags'] ?? {}),
        cabinBagsAllowed: (json['cabinBagsAllowed'] as num?)?.toInt() ?? 0,
        fareDetails: List<FareDetail>.from(
          (json['fareDetails'] as List<dynamic>? ?? []).map(
            (x) => FareDetail.fromJson(x),
          ),
        ),
      );
}

class BaggageAllowance {
  final String quantity;
  final String weight;

  BaggageAllowance({required this.quantity, required this.weight});
  Map<String, dynamic> toJson() {
    return {"quantity": quantity, "weight": weight};
  }

  factory BaggageAllowance.fromJson(Map<String, dynamic> json) =>
      BaggageAllowance(
        quantity: json['quantity'] ?? '',
        weight: json['weight'] ?? '',
      );
}

class FareDetail {
  final String segmentId;
  final String cabin;
  final String fareBasis;
  final String fareClass;
  final String bagsAllowed;
  final int cabinBagsAllowed;

  FareDetail({
    required this.segmentId,
    required this.cabin,
    required this.fareBasis,
    required this.fareClass,
    required this.bagsAllowed,
    required this.cabinBagsAllowed,
  });
  Map<String, dynamic> toJson() {
    return {
      "segmentId": segmentId,
      "cabin": cabin,
      "fareBasis": fareBasis,
      "class": fareClass,
      "bagsAllowed": bagsAllowed,
      "cabinBagsAllowed": cabinBagsAllowed,
    };
  }

  factory FareDetail.fromJson(Map<String, dynamic> json) => FareDetail(
    segmentId: json['segmentId'] ?? '',
    cabin: json['cabin'] ?? '',
    fareBasis: json['fareBasis'] ?? '',
    fareClass: json['class'] ?? '',
    bagsAllowed: json['bagsAllowed'] ?? '',
    cabinBagsAllowed: (json['cabinBagsAllowed'] as num?)?.toInt() ?? 0,
  );
}

class BaggageDetail {
  final String flightNumber;
  final String from;
  final String to;
  final String airline;
  final int checkedBagsAllowed;
  final int cabinBagsAllowed;

  BaggageDetail({
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.airline,
    required this.checkedBagsAllowed,
    required this.cabinBagsAllowed,
  });
  Map<String, dynamic> toJson() {
    return {
      "Flight Number": flightNumber,
      "From": from,
      "To": to,
      "Airline": airline,
      "Checked Bags Allowed": checkedBagsAllowed,
      "Cabin Bags Allowed": cabinBagsAllowed,
    };
  }

  factory BaggageDetail.fromJson(Map<String, dynamic> json) => BaggageDetail(
    flightNumber: json['Flight Number'] ?? '',
    from: json['From'] ?? '',
    to: json['To'] ?? '',
    airline: json['Airline'] ?? '',
    checkedBagsAllowed: (json['Checked Bags Allowed'] as num?)?.toInt() ?? 0,
    cabinBagsAllowed: (json['Cabin Bags Allowed'] as num?)?.toInt() ?? 0,
  );
}

class Charges {
  final String exchange;
  final String refund;
  final String revalidation;

  Charges({
    required this.exchange,
    required this.refund,
    required this.revalidation,
  });
  Map<String, dynamic> toJson() {
    return {
      "exchange": exchange,
      "refund": refund,
      "revalidation": revalidation,
    };
  }

  factory Charges.fromJson(Map<String, dynamic> json) => Charges(
    exchange: json['exchange'] ?? '',
    refund: json['refund'] ?? '',
    revalidation: json['revalidation'] ?? '',
  );
}
