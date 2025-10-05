// lib/data/models/flight_pricing_response.dart

class FlightPricingResponse {
  final bool success;
  final FlightPricingData data;
  final Map<String, dynamic>? dictionaries;
  final double presentageCommission;
  final double presentageVat;
  final String? message;

  FlightPricingResponse({
    required this.success,
    required this.data,
    this.dictionaries,
    required this.presentageCommission,
    required this.presentageVat,
    this.message,
  });

  factory FlightPricingResponse.fromJson(Map<String, dynamic> json) {
    return FlightPricingResponse(
      success: json['success'] ?? false,
      data: FlightPricingData.fromJson(json['data'] ?? {}),
      dictionaries: json['dictionaries'] != null
          ? Map<String, dynamic>.from(json['dictionaries'])
          : null,
      presentageCommission:
          (json['presentageCommission'] as num?)?.toDouble() ?? 0.0,
      presentageVat: (json['presentageVat'] as num?)?.toDouble() ?? 0.0,

      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'dictionaries': dictionaries,
      'presentageCommission': presentageCommission,
      'presentageVat': presentageVat,
      'message': message,
    };
  }
}

class FlightPricingData {
  final String type;
  final List<FlightPricingOffer> flightOffers;
  final BookingRequirements bookingRequirements;

  FlightPricingData({
    required this.type,
    required this.flightOffers,
    required this.bookingRequirements,
  });

  factory FlightPricingData.fromJson(Map<String, dynamic> json) {
    return FlightPricingData(
      type: json['type'] ?? '',
      flightOffers: (json['flightOffers'] as List<dynamic>? ?? [])
          .map((offer) => FlightPricingOffer.fromJson(offer))
          .toList(),
      bookingRequirements: BookingRequirements.fromJson(
        json['bookingRequirements'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'flightOffers': flightOffers.map((offer) => offer.toJson()).toList(),
      'bookingRequirements': bookingRequirements.toJson(),
    };
  }
}

class FlightPricingOffer {
  final String type;
  final String id;
  final String source;
  final bool instantTicketingRequired;
  final bool nonHomogeneous;
  final bool paymentCardRequired;
  final String lastTicketingDate;
  final List<PricingItinerary> itineraries;
  final PricingPrice price;
  final PricingOptions pricingOptions;
  final List<String> validatingAirlineCodes;
  final List<TravelerPricing> travelerPricings;

  FlightPricingOffer({
    required this.type,
    required this.id,
    required this.source,
    required this.instantTicketingRequired,
    required this.nonHomogeneous,
    required this.paymentCardRequired,
    required this.lastTicketingDate,
    required this.itineraries,
    required this.price,
    required this.pricingOptions,
    required this.validatingAirlineCodes,
    required this.travelerPricings,
  });

  factory FlightPricingOffer.fromJson(Map<String, dynamic> json) {
    return FlightPricingOffer(
      type: json['type'] ?? '',
      id: json['id']?.toString() ?? '',
      source: json['source'] ?? '',
      instantTicketingRequired: json['instantTicketingRequired'] ?? false,
      nonHomogeneous: json['nonHomogeneous'] ?? false,
      paymentCardRequired: json['paymentCardRequired'] ?? false,
      lastTicketingDate: json['lastTicketingDate'] ?? '',
      itineraries: (json['itineraries'] as List<dynamic>? ?? [])
          .map((itinerary) => PricingItinerary.fromJson(itinerary))
          .toList(),
      price: PricingPrice.fromJson(json['price'] ?? {}),
      pricingOptions: PricingOptions.fromJson(json['pricingOptions'] ?? {}),
      validatingAirlineCodes: List<String>.from(
        json['validatingAirlineCodes'] ?? [],
      ),
      travelerPricings: (json['travelerPricings'] as List<dynamic>? ?? [])
          .map((pricing) => TravelerPricing.fromJson(pricing))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'source': source,
      'instantTicketingRequired': instantTicketingRequired,
      'nonHomogeneous': nonHomogeneous,
      'paymentCardRequired': paymentCardRequired,
      'lastTicketingDate': lastTicketingDate,
      'itineraries': itineraries
          .map((itinerary) => itinerary.toJson())
          .toList(),
      'price': price.toJson(),
      'pricingOptions': pricingOptions.toJson(),
      'validatingAirlineCodes': validatingAirlineCodes,
      'travelerPricings': travelerPricings
          .map((pricing) => pricing.toJson())
          .toList(),
    };
  }
}

class PricingItinerary {
  final List<PricingSegment> segments;

  PricingItinerary({required this.segments});

  factory PricingItinerary.fromJson(Map<String, dynamic> json) {
    return PricingItinerary(
      segments: (json['segments'] as List<dynamic>? ?? [])
          .map((segment) => PricingSegment.fromJson(segment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'segments': segments.map((segment) => segment.toJson()).toList()};
  }
}

class PricingSegment {
  final SegmentEndpoint departure;
  final SegmentEndpoint arrival;
  final String carrierCode;
  final String number;
  final Aircraft aircraft;
  final OperatingCarrier operating;
  final String duration;
  final String id;
  final int numberOfStops;

  PricingSegment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
    required this.aircraft,
    required this.operating,
    required this.duration,
    required this.id,
    required this.numberOfStops,
  });

  factory PricingSegment.fromJson(Map<String, dynamic> json) {
    return PricingSegment(
      departure: SegmentEndpoint.fromJson(json['departure'] ?? {}),
      arrival: SegmentEndpoint.fromJson(json['arrival'] ?? {}),
      carrierCode: json['carrierCode'] ?? '',
      number: json['number'] ?? '',
      aircraft: Aircraft.fromJson(json['aircraft'] ?? {}),
      operating: OperatingCarrier.fromJson(json['operating'] ?? {}),
      duration: json['duration'] ?? '',
      id: json['id']?.toString() ?? '',
      numberOfStops: (json['numberOfStops'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
      'carrierCode': carrierCode,
      'number': number,
      'aircraft': aircraft.toJson(),
      'operating': operating.toJson(),
      'duration': duration,
      'id': id,
      'numberOfStops': numberOfStops,
    };
  }
}

class PricingPrice {
  final String currency;
  final String total;
  final String base;
  final List<Fee> fees;
  final String grandTotal;
  final String billingCurrency;

  PricingPrice({
    required this.currency,
    required this.total,
    required this.base,
    required this.fees,
    required this.grandTotal,
    required this.billingCurrency,
  });

  factory PricingPrice.fromJson(Map<String, dynamic> json) {
    return PricingPrice(
      currency: json['currency'] ?? '',
      total: json['total']?.toString() ?? '',
      base: json['base']?.toString() ?? '',
      fees: (json['fees'] as List<dynamic>? ?? [])
          .map((fee) => Fee.fromJson(fee))
          .toList(),
      grandTotal: json['grandTotal']?.toString() ?? '',
      billingCurrency: json['billingCurrency'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'total': total,
      'base': base,
      'fees': fees.map((fee) => fee.toJson()).toList(),
      'grandTotal': grandTotal,
      'billingCurrency': billingCurrency,
    };
  }

  double get totalAsDouble => double.tryParse(total) ?? 0.0;
  double get grandTotalAsDouble => double.tryParse(grandTotal) ?? 0.0;
}

class Fee {
  final String amount;
  final String type;

  Fee({required this.amount, required this.type});

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      amount: json['amount']?.toString() ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'type': type};
  }
}

class PricingOptions {
  final List<String> fareType;
  final bool includedCheckedBagsOnly;

  PricingOptions({
    required this.fareType,
    required this.includedCheckedBagsOnly,
  });

  factory PricingOptions.fromJson(Map<String, dynamic> json) {
    return PricingOptions(
      fareType: List<String>.from(json['fareType'] ?? []),
      includedCheckedBagsOnly: json['includedCheckedBagsOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fareType': fareType,
      'includedCheckedBagsOnly': includedCheckedBagsOnly,
    };
  }
}

class TravelerPricing {
  final String travelerId;
  final String fareOption;
  final String travelerType;
  final TravelerPrice price;
  final List<FareDetailsBySegment> fareDetailsBySegment;

  TravelerPricing({
    required this.travelerId,
    required this.fareOption,
    required this.travelerType,
    required this.price,
    required this.fareDetailsBySegment,
  });

  factory TravelerPricing.fromJson(Map<String, dynamic> json) {
    return TravelerPricing(
      travelerId: json['travelerId']?.toString() ?? '',
      fareOption: json['fareOption'] ?? '',
      travelerType: json['travelerType'] ?? '',
      price: TravelerPrice.fromJson(json['price'] ?? {}),
      fareDetailsBySegment:
          (json['fareDetailsBySegment'] as List<dynamic>? ?? [])
              .map((segment) => FareDetailsBySegment.fromJson(segment))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelerId': travelerId,
      'fareOption': fareOption,
      'travelerType': travelerType,
      'price': price.toJson(),
      'fareDetailsBySegment': fareDetailsBySegment
          .map((segment) => segment.toJson())
          .toList(),
    };
  }
}

class TravelerPrice {
  final String currency;
  final String total;
  final String base;
  final List<Tax> taxes;

  TravelerPrice({
    required this.currency,
    required this.total,
    required this.base,
    required this.taxes,
  });

  factory TravelerPrice.fromJson(Map<String, dynamic> json) {
    return TravelerPrice(
      currency: json['currency'] ?? '',
      total: json['total']?.toString() ?? '',
      base: json['base']?.toString() ?? '',
      taxes: (json['taxes'] as List<dynamic>? ?? [])
          .map((tax) => Tax.fromJson(tax))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'total': total,
      'base': base,
      'taxes': taxes.map((tax) => tax.toJson()).toList(),
    };
  }
}

class Tax {
  final String amount;
  final String code;

  Tax({required this.amount, required this.code});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      amount: json['amount']?.toString() ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'code': code};
  }
}

class FareDetailsBySegment {
  final String segmentId;
  final String cabin;
  final String fareBasis;
  final String brandedFare;
  final String segmentClass;
  final IncludedCheckedBags includedCheckedBags;

  FareDetailsBySegment({
    required this.segmentId,
    required this.cabin,
    required this.fareBasis,
    required this.brandedFare,
    required this.segmentClass,
    required this.includedCheckedBags,
  });

  factory FareDetailsBySegment.fromJson(Map<String, dynamic> json) {
    return FareDetailsBySegment(
      segmentId: json['segmentId']?.toString() ?? '',
      cabin: json['cabin'] ?? '',
      fareBasis: json['fareBasis'] ?? '',
      brandedFare: json['brandedFare'] ?? '',
      segmentClass: json['class'] ?? '',
      includedCheckedBags: IncludedCheckedBags.fromJson(
        json['includedCheckedBags'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segmentId': segmentId,
      'cabin': cabin,
      'fareBasis': fareBasis,
      'brandedFare': brandedFare,
      'class': segmentClass,
      'includedCheckedBags': includedCheckedBags.toJson(),
    };
  }
}

class IncludedCheckedBags {
  final int quantity;
  final int? weight;
  final String? weightUnit;

  IncludedCheckedBags({required this.quantity, this.weight, this.weightUnit});

  factory IncludedCheckedBags.fromJson(Map<String, dynamic> json) {
    return IncludedCheckedBags(
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt(),
      weightUnit: json['weightUnit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      if (weight != null) 'weight': weight,
      if (weightUnit != null) 'weightUnit': weightUnit,
    };
  }
}

class BookingRequirements {
  final bool emailAddressRequired;
  final bool mobilePhoneNumberRequired;
  final List<TravelerRequirement> travelerRequirements;

  BookingRequirements({
    required this.emailAddressRequired,
    required this.mobilePhoneNumberRequired,
    required this.travelerRequirements,
  });

  factory BookingRequirements.fromJson(Map<String, dynamic> json) {
    return BookingRequirements(
      emailAddressRequired: json['emailAddressRequired'] ?? false,
      mobilePhoneNumberRequired: json['mobilePhoneNumberRequired'] ?? false,
      travelerRequirements:
          (json['travelerRequirements'] as List<dynamic>? ?? [])
              .map((req) => TravelerRequirement.fromJson(req))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailAddressRequired': emailAddressRequired,
      'mobilePhoneNumberRequired': mobilePhoneNumberRequired,
      'travelerRequirements': travelerRequirements
          .map((req) => req.toJson())
          .toList(),
    };
  }
}

class TravelerRequirement {
  final String travelerId;
  final bool genderRequired;
  final bool dateOfBirthRequired;
  final bool redressRequiredIfAny;
  final bool residenceRequired;

  TravelerRequirement({
    required this.travelerId,
    required this.genderRequired,
    required this.dateOfBirthRequired,
    required this.redressRequiredIfAny,
    required this.residenceRequired,
  });

  factory TravelerRequirement.fromJson(Map<String, dynamic> json) {
    return TravelerRequirement(
      travelerId: json['travelerId']?.toString() ?? '',
      genderRequired: json['genderRequired'] ?? false,
      dateOfBirthRequired: json['dateOfBirthRequired'] ?? false,
      redressRequiredIfAny: json['redressRequiredIfAny'] ?? false,
      residenceRequired: json['residenceRequired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelerId': travelerId,
      'genderRequired': genderRequired,
      'dateOfBirthRequired': dateOfBirthRequired,
      'redressRequiredIfAny': redressRequiredIfAny,
      'residenceRequired': residenceRequired,
    };
  }
}

// Missing classes that should be imported from flight_search_response.dart
// Make sure these exist in your flight_search_response.dart file:
class SegmentEndpoint {
  final String iataCode;
  final String? terminal;
  final String at;

  SegmentEndpoint({required this.iataCode, this.terminal, required this.at});

  factory SegmentEndpoint.fromJson(Map<String, dynamic> json) {
    return SegmentEndpoint(
      iataCode: json['iataCode'] ?? '',
      terminal: json['terminal'],
      at: json['at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iataCode': iataCode,
      if (terminal != null) 'terminal': terminal,
      'at': at,
    };
  }
}

class Aircraft {
  final String code;

  Aircraft({required this.code});

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(code: json['code'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'code': code};
  }
}

class OperatingCarrier {
  final String carrierCode;

  OperatingCarrier({required this.carrierCode});

  factory OperatingCarrier.fromJson(Map<String, dynamic> json) {
    return OperatingCarrier(carrierCode: json['carrierCode'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'carrierCode': carrierCode};
  }
}
