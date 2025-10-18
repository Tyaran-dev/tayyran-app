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
          )
          .toList(),
      filters: filters,
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
    try {
      return filters.carriers.firstWhere(
        (carrier) => carrier.airLineCode == code,
      );
    } catch (e) {
      return null;
    }
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
    try {
      return carriers.firstWhere((carrier) => carrier.airLineCode == code);
    } catch (e) {
      return null;
    }
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
      id: json['_id']?.toString() ?? '',
      airLineCode: json['airLineCode']?.toString() ?? '',
      airLineName: json['airLineName']?.toString() ?? '',
      airlineNameAr: json['airlineNameAr']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
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
    // Helper function to safely parse numeric values from both String and num
    double safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    // Helper function to safely parse baggage information
    String parseAllowedBags(dynamic bagsData) {
      if (bagsData == null) return '';
      if (bagsData is String) return bagsData;
      if (bagsData is Map<String, dynamic>) {
        // Handle both piece and weight systems
        if (bagsData['text'] != null) return bagsData['text'].toString();
        if (bagsData['quantity'] != null) {
          return bagsData['quantity'].toString();
        }
        if (bagsData['weight'] != null) return bagsData['weight'].toString();
      }
      return bagsData.toString();
    }

    int parseAllowedCabinBags(dynamic cabinBagsData) {
      if (cabinBagsData == null) return 0;
      if (cabinBagsData is int) return cabinBagsData;
      if (cabinBagsData is String) {
        // Handle "1 PC" format
        if (cabinBagsData.contains('PC')) {
          final match = RegExp(r'(\d+)').firstMatch(cabinBagsData);
          return match != null ? int.parse(match.group(1)!) : 0;
        }
        return int.tryParse(cabinBagsData) ?? 0;
      }
      return 0;
    }

    final firstItinerary =
        (json["itineraries_formated"] as List<dynamic>? ?? []).isNotEmpty
        ? Itinerary.fromJson(json["itineraries_formated"][0])
        : Itinerary.empty();

    final firstSegment = firstItinerary.segments.isNotEmpty
        ? firstItinerary.segments[0]
        : null;

    final carrierCode =
        firstSegment?.carrierCode ?? json['airline']?.toString() ?? '';

    // Get carrier information if filters are provided
    Carrier? carrier;
    String airlineNameFromCarrier = json['airlineName']?.toString() ?? '';
    String airlineLogoFromCarrier = '';

    if (filters != null && carrierCode.isNotEmpty) {
      carrier = filters.findCarrierByCode(carrierCode);
      if (carrier != null) {
        airlineNameFromCarrier = carrier.airLineName.isNotEmpty
            ? carrier.airLineName
            : carrierCode;
        airlineLogoFromCarrier = carrier.image;
      } else {
        airlineNameFromCarrier = json['airlineName']?.toString() ?? carrierCode;
      }
    }

    return FlightOffer(
      id: json['id']?.toString() ?? '',
      mapping: json['mapping']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      agent: json['agent']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      fromLocation: firstItinerary.fromAirport.code,
      toLocation: firstItinerary.toAirport.code,
      fromName: firstItinerary.fromAirport.name,
      toName: firstItinerary.toAirport.name,
      flightType: json['flightType']?.toString() ?? '',
      adults: safeParseInt(json['adults']),
      children: safeParseInt(json['children']),
      infants: safeParseInt(json['infants']),
      numberOfBookableSeats: safeParseInt(json['numberOfBookableSeats']),
      airline: json['airline']?.toString() ?? '',
      airlineName: airlineNameFromCarrier,
      airlineLogo: airlineLogoFromCarrier,
      flightNumber: json['flightNumber']?.toString() ?? '',
      stops: safeParseInt(json['stops']),
      originalPrice: safeParseDouble(json['original_price']),
      basePrice: safeParseDouble(json['basePrice']),
      price: safeParseDouble(json['price']),
      currency: json['currency']?.toString() ?? 'SAR',
      refund: json['refund'] ?? false,
      exchange: json['exchange'] ?? false,
      cabinClass: json['cabinClass']?.toString() ?? '',
      allowedBags: parseAllowedBags(json['allowedBags']),
      allowedCabinBags: parseAllowedCabinBags(json['allowedCabinBags']),
      provider: json['provider']?.toString() ?? '',
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
      presentageCommission: safeParseDouble(
        json['presentageCommission'] ?? presentageCommission,
      ),
      presentageVat: safeParseDouble(json['presentageVat'] ?? presentageVat),
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

  // Get consistent baggage information
  String get displayAllowedBags {
    // Check baggage details first for consistent information
    if (baggageDetails.isNotEmpty) {
      final totalCheckedBags = baggageDetails.fold(
        0,
        (sum, detail) => sum + detail.checkedBagsAllowed,
      );
      if (totalCheckedBags > 0) return '$totalCheckedBags PC';
    }

    // Fall back to allowedBags field
    return allowedBags;
  }

  int get displayAllowedCabinBags {
    // Check baggage details first for consistent information
    if (baggageDetails.isNotEmpty) {
      final totalCabinBags = baggageDetails.fold(
        0,
        (sum, detail) => sum + detail.cabinBagsAllowed,
      );
      if (totalCabinBags > 0) return totalCabinBags;
    }

    // Fall back to allowedCabinBags field
    return allowedCabinBags;
  }
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
    duration: json['duration']?.toString() ?? '',
    fromLocation: json['fromLocation']?.toString() ?? '',
    toLocation: json['toLocation']?.toString() ?? '',
    fromName: json['fromName']?.toString() ?? '',
    toName: json['toName']?.toString() ?? '',
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
      json['departure_date_time']?.toString() ?? '2025-01-01T00:00:00',
    ),
    departureDate: json['departure_date']?.toString() ?? '',
    departureTime: json['departure_time']?.toString() ?? '',
    departureTerminal: json['departure_terminal']?.toString(),
    arrivalDateTime: DateTime.parse(
      json['arrival_date_time']?.toString() ?? '2025-01-01T00:00:00',
    ),
    arrivalDate: json['arrival_date']?.toString() ?? '',
    arrivalTime: json['arrival_time']?.toString() ?? '',
    arrivalTerminal: json['arrival_terminal']?.toString(),
    stops: _safeParseInt(json['stops']),
    duration: json['duration']?.toString() ?? '',
    flightNumber: json['flightNumber']?.toString() ?? '',
    airlineCode: json['airlineCode']?.toString() ?? '',
    airlineName: json['airlineName']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
  );

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
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
    carrierCode: json['carrierCode']?.toString() ?? '',
    number: json['number']?.toString() ?? '',
    aircraft: json['aircraft'] != null
        ? Aircraft.fromJson(json['aircraft'])
        : null,
    operating: json['operating'] != null
        ? OperatingCarrier.fromJson(json['operating'])
        : null,
    duration: json['duration']?.toString() ?? '',
    id: json['id']?.toString() ?? '',
    numberOfStops: _safeParseInt(json['numberOfStops']),
    blacklistedInEU: json['blacklistedInEU'] ?? false,
    departureDate: json['departure_date']?.toString() ?? '',
    departureTime: json['departure_time']?.toString() ?? '',
    arrivalDate: json['arrival_date']?.toString() ?? '',
    arrivalTime: json['arrival_time']?.toString() ?? '',
    stopDuration: json['stopDuration']?.toString(),
    stopLocation: json['stopLocation']?.toString(),
    fromName: json['fromName']?.toString() ?? '',
    toName: json['toName']?.toString() ?? '',
    fromAirport: Airport.fromJson(json['fromAirport'] ?? {}),
    toAirport: Airport.fromJson(json['toAirport'] ?? {}),
    segmentClass: json['class']?.toString() ?? '',
    image: json['image']?.toString(),
  );

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class SegmentEndpoint {
  final String iataCode;
  final DateTime at;
  final String? terminal;

  SegmentEndpoint({required this.iataCode, required this.at, this.terminal});

  factory SegmentEndpoint.fromJson(Map<String, dynamic> json) =>
      SegmentEndpoint(
        iataCode: json['iataCode']?.toString() ?? '',
        at: DateTime.parse(json['at']?.toString() ?? '2025-01-01T00:00:00'),
        terminal: json['terminal']?.toString(),
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
      Aircraft(code: json['code']?.toString() ?? '');

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
      OperatingCarrier(carrierCode: json['carrierCode']?.toString() ?? '');
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
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
  );

  factory Airport.empty() {
    return Airport(id: "", name: "", code: "", city: "");
  }
}

class FareRule {
  final String category;
  final String? maxPenaltyAmount;
  final bool? notApplicable;

  FareRule({required this.category, this.maxPenaltyAmount, this.notApplicable});

  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "maxPenaltyAmount": maxPenaltyAmount,
      "notApplicable": notApplicable,
    };
  }

  factory FareRule.fromJson(Map<String, dynamic> json) => FareRule(
    category: json['category']?.toString() ?? '',
    maxPenaltyAmount: json['maxPenaltyAmount']?.toString(),
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

  factory TravellerPricing.fromJson(Map<String, dynamic> json) {
    // Handle different baggage allowance formats
    dynamic bagsData = json['allowedBags'];
    BaggageAllowance baggageAllowance;

    if (bagsData is Map<String, dynamic>) {
      baggageAllowance = BaggageAllowance.fromJson(bagsData);
    } else if (bagsData is String) {
      // Convert string format to BaggageAllowance
      baggageAllowance = BaggageAllowance(quantity: bagsData, weight: bagsData);
    } else {
      baggageAllowance = BaggageAllowance(quantity: '', weight: '');
    }

    return TravellerPricing(
      travelerType: json['travelerType']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      base: json['base']?.toString() ?? '',
      tax: _safeParseDouble(json['tax']),
      travelClass: json['class']?.toString() ?? '',
      allowedBags: baggageAllowance,
      cabinBagsAllowed: _safeParseInt(json['cabinBagsAllowed']),
      fareDetails: List<FareDetail>.from(
        (json['fareDetails'] as List<dynamic>? ?? []).map(
          (x) => FareDetail.fromJson(x),
        ),
      ),
    );
  }

  static double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class BaggageAllowance {
  final String quantity;
  final String weight;

  BaggageAllowance({required this.quantity, required this.weight});

  Map<String, dynamic> toJson() {
    return {"quantity": quantity, "weight": weight};
  }

  factory BaggageAllowance.fromJson(Map<String, dynamic> json) {
    return BaggageAllowance(
      quantity: json['quantity']?.toString() ?? json['text']?.toString() ?? '',
      weight: json['weight']?.toString() ?? json['text']?.toString() ?? '',
    );
  }
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
    segmentId: json['segmentId']?.toString() ?? '',
    cabin: json['cabin']?.toString() ?? '',
    fareBasis: json['fareBasis']?.toString() ?? '',
    fareClass: json['class']?.toString() ?? '',
    bagsAllowed: json['bagsAllowed']?.toString() ?? '',
    cabinBagsAllowed: _safeParseInt(json['cabinBagsAllowed']),
  );

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
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
    flightNumber: json['Flight Number']?.toString() ?? '',
    from: json['From']?.toString() ?? '',
    to: json['To']?.toString() ?? '',
    airline: json['Airline']?.toString() ?? '',
    checkedBagsAllowed: _safeParseInt(json['Checked Bags Allowed']),
    cabinBagsAllowed: _safeParseInt(json['Cabin Bags Allowed']),
  );

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
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
    exchange: json['exchange']?.toString() ?? '',
    refund: json['refund']?.toString() ?? '',
    revalidation: json['revalidation']?.toString() ?? '',
  );
}

class BaggageFormatter {
  static String formatCheckedBags(FlightOffer flight) {
    // Use the display getter first
    final displayBags = flight.displayAllowedBags;
    if (displayBags.isNotEmpty) return displayBags;

    // Fallback logic
    if (flight.baggageDetails.isNotEmpty) {
      final totalChecked = flight.baggageDetails.fold(
        0,
        (sum, detail) => sum + detail.checkedBagsAllowed,
      );
      return totalChecked > 0 ? '$totalChecked PC' : '0 PC';
    }

    // Final fallback
    return flight.allowedBags.isNotEmpty ? flight.allowedBags : '0 PC';
  }

  static String formatCabinBags(FlightOffer flight) {
    final displayCabin = flight.displayAllowedCabinBags;
    if (displayCabin > 0) return '$displayCabin PC';

    if (flight.baggageDetails.isNotEmpty) {
      final totalCabin = flight.baggageDetails.fold(
        0,
        (sum, detail) => sum + detail.cabinBagsAllowed,
      );
      return totalCabin > 0 ? '$totalCabin PC' : '0 PC';
    }

    return flight.allowedCabinBags > 0
        ? '${flight.allowedCabinBags} PC'
        : '0 PC';
  }
}
