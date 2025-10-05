// lib/data/models/payment_status_response.dart
class PaymentStatusResponse {
  final String status;
  final Order order;

  PaymentStatusResponse({required this.status, required this.order});

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      status: json['status'] as String? ?? '',
      order: Order.fromJson(json['order'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'order': order.toJson()};
  }
}

class Order {
  final Meta meta;
  final OrderData data;
  final Dictionaries dictionaries;
  final Map<String, Airline> airlines;
  final Map<String, Airport> airports;

  Order({
    required this.meta,
    required this.data,
    required this.dictionaries,
    required this.airlines,
    required this.airports,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      data: OrderData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
      dictionaries: Dictionaries.fromJson(
        json['dictionaries'] as Map<String, dynamic>? ?? {},
      ),
      airlines:
          (json['airlines'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(key, Airline.fromJson(value as Map<String, dynamic>)),
          ) ??
          {},
      airports:
          (json['airports'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(key, Airport.fromJson(value as Map<String, dynamic>)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.toJson(),
      'dictionaries': dictionaries.toJson(),
      'airlines': airlines.map((key, value) => MapEntry(key, value.toJson())),
      'airports': airports.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class Meta {
  final int count;
  final Links links;

  Meta({required this.count, required this.links});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      count: json['count'] as int? ?? 0,
      links: Links.fromJson(json['links'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'count': count, 'links': links.toJson()};
  }
}

class Links {
  final String self;

  Links({required this.self});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(self: json['self'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'self': self};
  }
}

class OrderData {
  final String type;
  final String id;
  final String queuingOfficeId;
  final List<AssociatedRecord> associatedRecords;
  final List<FlightOffer> flightOffers;
  final List<Traveler> travelers;
  final Remarks? remarks;
  final TicketingAgreement? ticketingAgreement;
  final List<Contact> contacts;
  final List<Ticket> tickets;
  final List<Commission> commissions;

  OrderData({
    required this.type,
    required this.id,
    required this.queuingOfficeId,
    required this.associatedRecords,
    required this.flightOffers,
    required this.travelers,
    this.remarks,
    this.ticketingAgreement,
    required this.contacts,
    required this.tickets,
    required this.commissions,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      type: json['type'] as String? ?? '',
      id: json['id'] as String? ?? '',
      queuingOfficeId: json['queuingOfficeId'] as String? ?? '',
      associatedRecords:
          (json['associatedRecords'] as List<dynamic>?)
              ?.map(
                (item) =>
                    AssociatedRecord.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      flightOffers:
          (json['flightOffers'] as List<dynamic>?)
              ?.map(
                (item) => FlightOffer.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      travelers:
          (json['travelers'] as List<dynamic>?)
              ?.map((item) => Traveler.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      remarks: json['remarks'] != null
          ? Remarks.fromJson(json['remarks'] as Map<String, dynamic>)
          : null,
      ticketingAgreement: json['ticketingAgreement'] != null
          ? TicketingAgreement.fromJson(
              json['ticketingAgreement'] as Map<String, dynamic>,
            )
          : null,
      contacts:
          (json['contacts'] as List<dynamic>?)
              ?.map((item) => Contact.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      tickets:
          (json['tickets'] as List<dynamic>?)
              ?.map((item) => Ticket.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      commissions:
          (json['commissions'] as List<dynamic>?)
              ?.map((item) => Commission.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'queuingOfficeId': queuingOfficeId,
      'associatedRecords': associatedRecords.map((x) => x.toJson()).toList(),
      'flightOffers': flightOffers.map((x) => x.toJson()).toList(),
      'travelers': travelers.map((x) => x.toJson()).toList(),
      'remarks': remarks?.toJson(),
      'ticketingAgreement': ticketingAgreement?.toJson(),
      'contacts': contacts.map((x) => x.toJson()).toList(),
      'tickets': tickets.map((x) => x.toJson()).toList(),
      'commissions': commissions.map((x) => x.toJson()).toList(),
    };
  }

  // Helper method to get ticket number for traveler
  String? getTicketNumberForTraveler(String travelerId) {
    try {
      final ticket = tickets.firstWhere(
        (ticket) => ticket.travelerId == travelerId,
        orElse: () => Ticket(
          documentType: '',
          documentNumber: '',
          documentStatus: '',
          travelerId: '',
          segmentIds: [],
        ),
      );
      return ticket.documentNumber.isNotEmpty ? ticket.documentNumber : null;
    } catch (e) {
      return null;
    }
  }
}

class AssociatedRecord {
  final String reference;
  final String? originSystemCode;
  final String? flightOfferId;
  final String? creationDate;

  AssociatedRecord({
    required this.reference,
    this.originSystemCode,
    this.flightOfferId,
    this.creationDate,
  });

  factory AssociatedRecord.fromJson(Map<String, dynamic> json) {
    return AssociatedRecord(
      reference: json['reference'] as String? ?? '',
      originSystemCode: json['originSystemCode'] as String?,
      flightOfferId: json['flightOfferId'] as String?,
      creationDate: json['creationDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      if (originSystemCode != null) 'originSystemCode': originSystemCode,
      if (flightOfferId != null) 'flightOfferId': flightOfferId,
      if (creationDate != null) 'creationDate': creationDate,
    };
  }
}

class FlightOffer {
  final String type;
  final String id;
  final String source;
  final bool nonHomogeneous;
  final String lastTicketingDate;
  final List<Itinerary> itineraries;
  final Price price;
  final PricingOptions pricingOptions;
  final List<String> validatingAirlineCodes;
  final List<TravelerPricing> travelerPricings;

  FlightOffer({
    required this.type,
    required this.id,
    required this.source,
    required this.nonHomogeneous,
    required this.lastTicketingDate,
    required this.itineraries,
    required this.price,
    required this.pricingOptions,
    required this.validatingAirlineCodes,
    required this.travelerPricings,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      type: json['type'] as String? ?? '',
      id: json['id'] as String? ?? '',
      source: json['source'] as String? ?? '',
      nonHomogeneous: json['nonHomogeneous'] as bool? ?? false,
      lastTicketingDate: json['lastTicketingDate'] as String? ?? '',
      itineraries:
          (json['itineraries'] as List<dynamic>?)
              ?.map((item) => Itinerary.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      price: Price.fromJson(json['price'] as Map<String, dynamic>? ?? {}),
      pricingOptions: PricingOptions.fromJson(
        json['pricingOptions'] as Map<String, dynamic>? ?? {},
      ),
      validatingAirlineCodes:
          (json['validatingAirlineCodes'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      travelerPricings:
          (json['travelerPricings'] as List<dynamic>?)
              ?.map(
                (item) =>
                    TravelerPricing.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'source': source,
      'nonHomogeneous': nonHomogeneous,
      'lastTicketingDate': lastTicketingDate,
      'itineraries': itineraries.map((x) => x.toJson()).toList(),
      'price': price.toJson(),
      'pricingOptions': pricingOptions.toJson(),
      'validatingAirlineCodes': validatingAirlineCodes,
      'travelerPricings': travelerPricings.map((x) => x.toJson()).toList(),
    };
  }
}

class Itinerary {
  final List<Segment> segments;

  Itinerary({required this.segments});

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map((item) => Segment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'segments': segments.map((x) => x.toJson()).toList()};
  }

  // Helper getters for easy access
  Segment get firstSegment =>
      segments.isNotEmpty ? segments.first : Segment.empty();
  Segment get lastSegment =>
      segments.isNotEmpty ? segments.last : Segment.empty();

  // Airport get fromAirport => firstSegment.departure;
  // Airport get toAirport => lastSegment.arrival;

  String get duration => firstSegment.duration;
}

class Segment {
  final Departure departure;
  final Arrival arrival;
  final String carrierCode;
  final String number;
  final Aircraft aircraft;
  final String duration;
  final String bookingStatus;
  final String segmentType;
  final bool isFlown;
  final String id;
  final int numberOfStops;
  final List<Co2Emission> co2Emissions;

  Segment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
    required this.aircraft,
    required this.duration,
    required this.bookingStatus,
    required this.segmentType,
    required this.isFlown,
    required this.id,
    required this.numberOfStops,
    required this.co2Emissions,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      departure: Departure.fromJson(
        json['departure'] as Map<String, dynamic>? ?? {},
      ),
      arrival: Arrival.fromJson(json['arrival'] as Map<String, dynamic>? ?? {}),
      carrierCode: json['carrierCode'] as String? ?? '',
      number: json['number'] as String? ?? '',
      aircraft: Aircraft.fromJson(
        json['aircraft'] as Map<String, dynamic>? ?? {},
      ),
      duration: json['duration'] as String? ?? '',
      bookingStatus: json['bookingStatus'] as String? ?? '',
      segmentType: json['segmentType'] as String? ?? '',
      isFlown: json['isFlown'] as bool? ?? false,
      id: json['id'] as String? ?? '',
      numberOfStops: json['numberOfStops'] as int? ?? 0,
      co2Emissions:
          (json['co2Emissions'] as List<dynamic>?)
              ?.map(
                (item) => Co2Emission.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departure': departure.toJson(),
      'arrival': arrival.toJson(),
      'carrierCode': carrierCode,
      'number': number,
      'aircraft': aircraft.toJson(),
      'duration': duration,
      'bookingStatus': bookingStatus,
      'segmentType': segmentType,
      'isFlown': isFlown,
      'id': id,
      'numberOfStops': numberOfStops,
      'co2Emissions': co2Emissions.map((x) => x.toJson()).toList(),
    };
  }

  static Segment empty() => Segment(
    departure: Departure.empty(),
    arrival: Arrival.empty(),
    carrierCode: '',
    number: '',
    aircraft: Aircraft.empty(),
    duration: '',
    bookingStatus: '',
    segmentType: '',
    isFlown: false,
    id: '',
    numberOfStops: 0,
    co2Emissions: [],
  );
}

class Departure {
  final String iataCode;
  final String at;

  Departure({required this.iataCode, required this.at});

  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      iataCode: json['iataCode'] as String? ?? '',
      at: json['at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'iataCode': iataCode, 'at': at};
  }

  static Departure empty() => Departure(iataCode: '', at: '');
}

class Arrival {
  final String iataCode;
  final String? terminal;
  final String at;

  Arrival({required this.iataCode, this.terminal, required this.at});

  factory Arrival.fromJson(Map<String, dynamic> json) {
    return Arrival(
      iataCode: json['iataCode'] as String? ?? '',
      terminal: json['terminal'] as String?,
      at: json['at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iataCode': iataCode,
      if (terminal != null) 'terminal': terminal,
      'at': at,
    };
  }

  static Arrival empty() => Arrival(iataCode: '', terminal: '', at: '');
}

class Aircraft {
  final String code;

  Aircraft({required this.code});

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(code: json['code'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'code': code};
  }

  static Aircraft empty() => Aircraft(code: '');
}

class Co2Emission {
  final int weight;
  final String weightUnit;
  final String cabin;

  Co2Emission({
    required this.weight,
    required this.weightUnit,
    required this.cabin,
  });

  factory Co2Emission.fromJson(Map<String, dynamic> json) {
    return Co2Emission(
      weight: json['weight'] as int? ?? 0,
      weightUnit: json['weightUnit'] as String? ?? '',
      cabin: json['cabin'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'weight': weight, 'weightUnit': weightUnit, 'cabin': cabin};
  }
}

class Price {
  final String currency;
  final String total;
  final String base;
  final String grandTotal;
  final List<Tax> taxes;
  final List<Fee>? fees;

  Price({
    required this.currency,
    required this.total,
    required this.base,
    required this.grandTotal,
    required this.taxes,
    this.fees,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      currency: json['currency'] as String? ?? '',
      total: json['total'] as String? ?? '',
      base: json['base'] as String? ?? '',
      grandTotal: json['grandTotal'] as String? ?? '',
      taxes:
          (json['taxes'] as List<dynamic>?)
              ?.map((item) => Tax.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      fees: (json['fees'] as List<dynamic>?)
          ?.map((item) => Fee.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'total': total,
      'base': base,
      'grandTotal': grandTotal,
      'taxes': taxes.map((x) => x.toJson()).toList(),
      if (fees != null) 'fees': fees!.map((x) => x.toJson()).toList(),
    };
  }
}

class Tax {
  final String amount;
  final String code;

  Tax({required this.amount, required this.code});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      amount: json['amount'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'code': code};
  }
}

class Fee {
  final String amount;
  final String type;

  Fee({required this.amount, required this.type});

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      amount: json['amount'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'type': type};
  }
}

class PricingOptions {
  final List<String> fareType;

  PricingOptions({required this.fareType});

  factory PricingOptions.fromJson(Map<String, dynamic> json) {
    return PricingOptions(
      fareType:
          (json['fareType'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'fareType': fareType};
  }
}

class TravelerPricing {
  final String travelerId;
  final String fareOption;
  final String travelerType;
  final Price price;
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
      travelerId: json['travelerId'] as String? ?? '',
      fareOption: json['fareOption'] as String? ?? '',
      travelerType: json['travelerType'] as String? ?? '',
      price: Price.fromJson(json['price'] as Map<String, dynamic>? ?? {}),
      fareDetailsBySegment:
          (json['fareDetailsBySegment'] as List<dynamic>?)
              ?.map(
                (item) =>
                    FareDetailsBySegment.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelerId': travelerId,
      'fareOption': fareOption,
      'travelerType': travelerType,
      'price': price.toJson(),
      'fareDetailsBySegment': fareDetailsBySegment
          .map((x) => x.toJson())
          .toList(),
    };
  }
}

class FareDetailsBySegment {
  final String segmentId;
  final String cabin;
  final String fareBasis;
  final String fareClass; // Changed from 'class' to avoid keyword conflict
  final IncludedCheckedBags includedCheckedBags;
  final List<MealService> mealServices;

  FareDetailsBySegment({
    required this.segmentId,
    required this.cabin,
    required this.fareBasis,
    required this.fareClass,
    required this.includedCheckedBags,
    required this.mealServices,
  });

  factory FareDetailsBySegment.fromJson(Map<String, dynamic> json) {
    return FareDetailsBySegment(
      segmentId: json['segmentId'] as String? ?? '',
      cabin: json['cabin'] as String? ?? '',
      fareBasis: json['fareBasis'] as String? ?? '',
      fareClass:
          json['class'] as String? ?? '', // Map from 'class' to fareClass
      includedCheckedBags: IncludedCheckedBags.fromJson(
        json['includedCheckedBags'] as Map<String, dynamic>? ?? {},
      ),
      mealServices:
          (json['mealServices'] as List<dynamic>?)
              ?.map(
                (item) => MealService.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segmentId': segmentId,
      'cabin': cabin,
      'fareBasis': fareBasis,
      'class': fareClass, // Map back to 'class' for JSON
      'includedCheckedBags': includedCheckedBags.toJson(),
      'mealServices': mealServices.map((x) => x.toJson()).toList(),
    };
  }
}

class IncludedCheckedBags {
  final int quantity;

  IncludedCheckedBags({required this.quantity});

  factory IncludedCheckedBags.fromJson(Map<String, dynamic> json) {
    return IncludedCheckedBags(quantity: json['quantity'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'quantity': quantity};
  }
}

class MealService {
  final String label;

  MealService({required this.label});

  factory MealService.fromJson(Map<String, dynamic> json) {
    return MealService(label: json['label'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'label': label};
  }
}

class Traveler {
  final String id;
  final String dateOfBirth;
  final String gender;
  final TravelerName name;
  final ContactInfo contact;

  Traveler({
    required this.id,
    required this.dateOfBirth,
    required this.gender,
    required this.name,
    required this.contact,
  });

  factory Traveler.fromJson(Map<String, dynamic> json) {
    return Traveler(
      id: json['id'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      name: TravelerName.fromJson(json['name'] as Map<String, dynamic>? ?? {}),
      contact: ContactInfo.fromJson(
        json['contact'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'name': name.toJson(),
      'contact': contact.toJson(),
    };
  }
}

class TravelerName {
  final String firstName;
  final String lastName;

  TravelerName({required this.firstName, required this.lastName});

  factory TravelerName.fromJson(Map<String, dynamic> json) {
    return TravelerName(
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'firstName': firstName, 'lastName': lastName};
  }

  String get fullName => '$firstName $lastName';
}

class ContactInfo {
  final String purpose;
  final List<Phone> phones;
  final String emailAddress;

  ContactInfo({
    required this.purpose,
    required this.phones,
    required this.emailAddress,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      purpose: json['purpose'] as String? ?? '',
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map((item) => Phone.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      emailAddress: json['emailAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purpose': purpose,
      'phones': phones.map((x) => x.toJson()).toList(),
      'emailAddress': emailAddress,
    };
  }
}

class Phone {
  final String deviceType;
  final String countryCallingCode;
  final String number;

  Phone({
    required this.deviceType,
    required this.countryCallingCode,
    required this.number,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      deviceType: json['deviceType'] as String? ?? '',
      countryCallingCode: json['countryCallingCode'] as String? ?? '',
      number: json['number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceType': deviceType,
      'countryCallingCode': countryCallingCode,
      'number': number,
    };
  }
}

class Remarks {
  final List<GeneralRemark> general;

  Remarks({required this.general});

  factory Remarks.fromJson(Map<String, dynamic> json) {
    return Remarks(
      general:
          (json['general'] as List<dynamic>?)
              ?.map(
                (item) => GeneralRemark.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'general': general.map((x) => x.toJson()).toList()};
  }
}

class GeneralRemark {
  final String subType;
  final String text;
  final List<String> flightOfferIds;

  GeneralRemark({
    required this.subType,
    required this.text,
    required this.flightOfferIds,
  });

  factory GeneralRemark.fromJson(Map<String, dynamic> json) {
    return GeneralRemark(
      subType: json['subType'] as String? ?? '',
      text: json['text'] as String? ?? '',
      flightOfferIds:
          (json['flightOfferIds'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'subType': subType, 'text': text, 'flightOfferIds': flightOfferIds};
  }
}

class TicketingAgreement {
  final String option;

  TicketingAgreement({required this.option});

  factory TicketingAgreement.fromJson(Map<String, dynamic> json) {
    return TicketingAgreement(option: json['option'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'option': option};
  }
}

class Contact {
  final AddresseeName addresseeName;
  final Address address;
  final String purpose;
  final List<Phone> phones;
  final String emailAddress;

  Contact({
    required this.addresseeName,
    required this.address,
    required this.purpose,
    required this.phones,
    required this.emailAddress,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      addresseeName: AddresseeName.fromJson(
        json['addresseeName'] as Map<String, dynamic>? ?? {},
      ),
      address: Address.fromJson(json['address'] as Map<String, dynamic>? ?? {}),
      purpose: json['purpose'] as String? ?? '',
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map((item) => Phone.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      emailAddress: json['emailAddress'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addresseeName': addresseeName.toJson(),
      'address': address.toJson(),
      'purpose': purpose,
      'phones': phones.map((x) => x.toJson()).toList(),
      'emailAddress': emailAddress,
    };
  }
}

class AddresseeName {
  final String firstName;

  AddresseeName({required this.firstName});

  factory AddresseeName.fromJson(Map<String, dynamic> json) {
    return AddresseeName(firstName: json['firstName'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'firstName': firstName};
  }
}

class Address {
  final List<String> lines;
  final String countryCode;
  final String cityName;
  final String stateName;

  Address({
    required this.lines,
    required this.countryCode,
    required this.cityName,
    required this.stateName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      lines:
          (json['lines'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      countryCode: json['countryCode'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      stateName: json['stateName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lines': lines,
      'countryCode': countryCode,
      'cityName': cityName,
      'stateName': stateName,
    };
  }
}

class Ticket {
  final String documentType;
  final String documentNumber;
  final String documentStatus;
  final String travelerId;
  final List<String> segmentIds;

  Ticket({
    required this.documentType,
    required this.documentNumber,
    required this.documentStatus,
    required this.travelerId,
    required this.segmentIds,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      documentType: json['documentType'] as String? ?? '',
      documentNumber: json['documentNumber'] as String? ?? '',
      documentStatus: json['documentStatus'] as String? ?? '',
      travelerId: json['travelerId'] as String? ?? '',
      segmentIds:
          (json['segmentIds'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'documentNumber': documentNumber,
      'documentStatus': documentStatus,
      'travelerId': travelerId,
      'segmentIds': segmentIds,
    };
  }
}

class Commission {
  final List<String> controls;
  final List<CommissionValue> values;

  Commission({required this.controls, required this.values});

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      controls:
          (json['controls'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      values:
          (json['values'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CommissionValue.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controls': controls,
      'values': values.map((x) => x.toJson()).toList(),
    };
  }
}

class CommissionValue {
  final String commissionType;
  final int percentage;

  CommissionValue({required this.commissionType, required this.percentage});

  factory CommissionValue.fromJson(Map<String, dynamic> json) {
    return CommissionValue(
      commissionType: json['commissionType'] as String? ?? '',
      percentage: json['percentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'commissionType': commissionType, 'percentage': percentage};
  }
}

class Dictionaries {
  final Map<String, Location> locations;

  Dictionaries({required this.locations});

  factory Dictionaries.fromJson(Map<String, dynamic> json) {
    return Dictionaries(
      locations:
          (json['locations'] as Map<String, dynamic>?)?.map(
            (key, value) =>
                MapEntry(key, Location.fromJson(value as Map<String, dynamic>)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locations': locations.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class Location {
  final String cityCode;
  final String countryCode;

  Location({required this.cityCode, required this.countryCode});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      cityCode: json['cityCode'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'cityCode': cityCode, 'countryCode': countryCode};
  }
}

class Airline {
  final String id;
  final String code;
  final AirlineName name;
  final String image;

  Airline({
    required this.id,
    required this.code,
    required this.name,
    required this.image,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: AirlineName.fromJson(json['name'] as Map<String, dynamic>? ?? {}),
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name.toJson(), 'image': image};
  }
}

class AirlineName {
  final String en;
  final String ar;

  AirlineName({required this.en, required this.ar});

  factory AirlineName.fromJson(Map<String, dynamic> json) {
    return AirlineName(
      en: json['en'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'ar': ar};
  }
}

class Airport {
  final String id;
  final String code;
  final AirportName name;
  final AirportCity city;

  Airport({
    required this.id,
    required this.code,
    required this.name,
    required this.city,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: AirportName.fromJson(json['name'] as Map<String, dynamic>? ?? {}),
      city: AirportCity.fromJson(json['city'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name.toJson(),
      'city': city.toJson(),
    };
  }
}

class AirportName {
  final String en;
  final String ar;

  AirportName({required this.en, required this.ar});

  factory AirportName.fromJson(Map<String, dynamic> json) {
    return AirportName(
      en: json['en'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'ar': ar};
  }
}

class AirportCity {
  final String en;
  final String ar;

  AirportCity({required this.en, required this.ar});

  factory AirportCity.fromJson(Map<String, dynamic> json) {
    return AirportCity(
      en: json['en'] as String? ?? '',
      ar: json['ar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'ar': ar};
  }
}
