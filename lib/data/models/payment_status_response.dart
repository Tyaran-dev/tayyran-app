// // lib/data/models/payment_status_response.dart
// import 'package:tayyran_app/data/models/flight_search_response.dart';

// class PaymentStatusResponse {
//   final String status;
//   final Order order;

//   PaymentStatusResponse({required this.status, required this.order});

//   factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
//     return PaymentStatusResponse(
//       status: json['status'] ?? 'PENDING',
//       order: Order.fromJson(json['order'] ?? {}),
//     );
//   }
// }

// class Order {
//   final Meta meta;
//   final OrderData data;
//   final Map<String, dynamic> dictionaries;
//   final Map<String, dynamic> airlines;
//   final Map<String, dynamic> airports;

//   Order({
//     required this.meta,
//     required this.data,
//     required this.dictionaries,
//     required this.airlines,
//     required this.airports,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       meta: Meta.fromJson(json['meta'] ?? {}),
//       data: OrderData.fromJson(json['data'] ?? {}),
//       dictionaries: Map<String, dynamic>.from(json['dictionaries'] ?? {}),
//       airlines: Map<String, dynamic>.from(json['airlines'] ?? {}),
//       airports: Map<String, dynamic>.from(json['airports'] ?? {}),
//     );
//   }
// }

// class Meta {
//   final int count;
//   final Links links;

//   Meta({required this.count, required this.links});

//   factory Meta.fromJson(Map<String, dynamic> json) {
//     return Meta(
//       count: json['count'] ?? 0,
//       links: Links.fromJson(json['links'] ?? {}),
//     );
//   }
// }

// class Links {
//   final String self;

//   Links({required this.self});

//   factory Links.fromJson(Map<String, dynamic> json) {
//     return Links(self: json['self'] ?? '');
//   }
// }

// class OrderData {
//   final String type;
//   final String id;
//   final String queuingOfficeId;
//   final List<AssociatedRecord> associatedRecords;
//   final List<FlightOffer> flightOffers;
//   final List<Traveler> travelers;
//   final List<Ticket> tickets;
//   final List<String> validatingAirlineCodes; // ADD THIS

//   OrderData({
//     required this.type,
//     required this.id,
//     required this.queuingOfficeId,
//     required this.associatedRecords,
//     required this.flightOffers,
//     required this.travelers,
//     required this.tickets,
//     required this.validatingAirlineCodes, // ADD THIS
//   });

//   factory OrderData.fromJson(Map<String, dynamic> json) {
//     return OrderData(
//       type: json['type'] ?? '',
//       id: json['id'] ?? '',
//       queuingOfficeId: json['queuingOfficeId'] ?? '',
//       associatedRecords: List<AssociatedRecord>.from(
//         (json['associatedRecords'] ?? []).map(
//           (x) => AssociatedRecord.fromJson(x),
//         ),
//       ),
//       flightOffers: List<FlightOffer>.from(
//         (json['flightOffers'] ?? []).map((x) => FlightOffer.fromJson(x)),
//       ),
//       travelers: List<Traveler>.from(
//         (json['travelers'] ?? []).map((x) => Traveler.fromJson(x)),
//       ),
//       tickets: List<Ticket>.from(
//         (json['tickets'] ?? []).map((x) => Ticket.fromJson(x)),
//       ),
//       validatingAirlineCodes: List<String>.from(
//         // ADD THIS
//         json['validatingAirlineCodes'] ?? [],
//       ),
//     );
//   }

//   String? getTicketNumberForTraveler(String travelerId) {
//     final ticket = tickets.firstWhere(
//       (t) => t.travelerId == travelerId,
//       orElse: () => Ticket.empty(),
//     );
//     return ticket.documentNumber.isNotEmpty ? ticket.documentNumber : null;
//   }
// }

// class AssociatedRecord {
//   final String reference;
//   final String originSystemCode;
//   final String flightOfferId;

//   AssociatedRecord({
//     required this.reference,
//     required this.originSystemCode,
//     required this.flightOfferId,
//   });

//   factory AssociatedRecord.fromJson(Map<String, dynamic> json) {
//     return AssociatedRecord(
//       reference: json['reference'] ?? '',
//       originSystemCode: json['originSystemCode'] ?? '',
//       flightOfferId: json['flightOfferId'] ?? '',
//     );
//   }
// }

// class Traveler {
//   final String id;
//   final String dateOfBirth;
//   final String gender;
//   final TravelerName name;
//   final List<Document> documents;
//   final Contact contact;

//   Traveler({
//     required this.id,
//     required this.dateOfBirth,
//     required this.gender,
//     required this.name,
//     required this.documents,
//     required this.contact,
//   });

//   factory Traveler.fromJson(Map<String, dynamic> json) {
//     return Traveler(
//       id: json['id'] ?? '',
//       dateOfBirth: json['dateOfBirth'] ?? '',
//       gender: json['gender'] ?? '',
//       name: TravelerName.fromJson(json['name'] ?? {}),
//       documents: List<Document>.from(
//         (json['documents'] ?? []).map((x) => Document.fromJson(x)),
//       ),
//       contact: Contact.fromJson(json['contact'] ?? {}),
//     );
//   }
// }

// class TravelerName {
//   final String firstName;
//   final String lastName;

//   TravelerName({required this.firstName, required this.lastName});

//   factory TravelerName.fromJson(Map<String, dynamic> json) {
//     return TravelerName(
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//     );
//   }

//   String get fullName => '$firstName $lastName';
// }

// class Document {
//   final String number;
//   final String expiryDate;
//   final String issuanceCountry;
//   final String nationality;
//   final String documentType;
//   final bool holder;

//   Document({
//     required this.number,
//     required this.expiryDate,
//     required this.issuanceCountry,
//     required this.nationality,
//     required this.documentType,
//     required this.holder,
//   });

//   factory Document.fromJson(Map<String, dynamic> json) {
//     return Document(
//       number: json['number'] ?? '',
//       expiryDate: json['expiryDate'] ?? '',
//       issuanceCountry: json['issuanceCountry'] ?? '',
//       nationality: json['nationality'] ?? '',
//       documentType: json['documentType'] ?? '',
//       holder: json['holder'] ?? false,
//     );
//   }
// }

// class Contact {
//   final String purpose;
//   final List<Phone> phones;
//   final String emailAddress;

//   Contact({
//     required this.purpose,
//     required this.phones,
//     required this.emailAddress,
//   });

//   factory Contact.fromJson(Map<String, dynamic> json) {
//     return Contact(
//       purpose: json['purpose'] ?? '',
//       phones: List<Phone>.from(
//         (json['phones'] ?? []).map((x) => Phone.fromJson(x)),
//       ),
//       emailAddress: json['emailAddress'] ?? '',
//     );
//   }
// }

// class Phone {
//   final String deviceType;
//   final String countryCallingCode;
//   final String number;

//   Phone({
//     required this.deviceType,
//     required this.countryCallingCode,
//     required this.number,
//   });

//   factory Phone.fromJson(Map<String, dynamic> json) {
//     return Phone(
//       deviceType: json['deviceType'] ?? '',
//       countryCallingCode: json['countryCallingCode'] ?? '',
//       number: json['number'] ?? '',
//     );
//   }
// }

// class Ticket {
//   final String documentType;
//   final String documentNumber;
//   final String documentStatus;
//   final String travelerId;
//   final List<String> segmentIds;

//   Ticket({
//     required this.documentType,
//     required this.documentNumber,
//     required this.documentStatus,
//     required this.travelerId,
//     required this.segmentIds,
//   });

//   factory Ticket.fromJson(Map<String, dynamic> json) {
//     return Ticket(
//       documentType: json['documentType'] ?? '',
//       documentNumber: json['documentNumber'] ?? '',
//       documentStatus: json['documentStatus'] ?? '',
//       travelerId: json['travelerId'] ?? '',
//       segmentIds: List<String>.from(json['segmentIds'] ?? []),
//     );
//   }

//   factory Ticket.empty() {
//     return Ticket(
//       documentType: '',
//       documentNumber: '',
//       documentStatus: '',
//       travelerId: '',
//       segmentIds: [],
//     );
//   }
// }

// lib/data/models/payment_status_response.dart
// class PaymentStatusResponse {
//   final String status;
//   final OrderResponse order;

//   PaymentStatusResponse({required this.status, required this.order});

//   factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
//     return PaymentStatusResponse(
//       status: json['status'] ?? 'UNKNOWN',
//       order: OrderResponse.fromJson(json['order'] ?? {}),
//     );
//   }
// }

// class OrderResponse {
//   final OrderData data;
//   final Map<String, dynamic>? dictionaries;
//   final Map<String, dynamic>? airlines;
//   final Map<String, dynamic>? airports;

//   OrderResponse({
//     required this.data,
//     this.dictionaries,
//     this.airlines,
//     this.airports,
//   });

//   factory OrderResponse.fromJson(Map<String, dynamic> json) {
//     return OrderResponse(
//       data: OrderData.fromJson(json['data'] ?? {}),
//       dictionaries: json['dictionaries'],
//       airlines: json['airlines'],
//       airports: json['airports'],
//     );
//   }
// }

// class OrderData {
//   final String type;
//   final String id;
//   final String queuingOfficeId;
//   final List<FlightOffer> flightOffers;
//   final List<Traveler> travelers;
//   final List<Ticket> tickets;
//   final List<AssociatedRecord> associatedRecords;

//   OrderData({
//     required this.type,
//     required this.id,
//     required this.queuingOfficeId,
//     required this.flightOffers,
//     required this.travelers,
//     required this.tickets,
//     required this.associatedRecords,
//   });

//   factory OrderData.fromJson(Map<String, dynamic> json) {
//     return OrderData(
//       type: json['type'] ?? '',
//       id: json['id'] ?? '',
//       queuingOfficeId: json['queuingOfficeId'] ?? '',
//       flightOffers: (json['flightOffers'] as List? ?? [])
//           .map((item) => FlightOffer.fromJson(item))
//           .toList(),
//       travelers: (json['travelers'] as List? ?? [])
//           .map((item) => Traveler.fromJson(item))
//           .toList(),
//       tickets: (json['tickets'] as List? ?? [])
//           .map((item) => Ticket.fromJson(item))
//           .toList(),
//       associatedRecords: (json['associatedRecords'] as List? ?? [])
//           .map((item) => AssociatedRecord.fromJson(item))
//           .toList(),
//     );
//   }

//   // Helper method to get ticket number for a traveler
//   String? getTicketNumberForTraveler(String travelerId) {
//     try {
//       final ticket = tickets.firstWhere(
//         (ticket) => ticket.travelerId == travelerId,
//         orElse: () => Ticket.empty(),
//       );
//       return ticket.documentNumber.isNotEmpty ? ticket.documentNumber : null;
//     } catch (e) {
//       return null;
//     }
//   }
// }

// class AssociatedRecord {
//   final String reference;
//   final String originSystemCode;
//   final String flightOfferId;

//   AssociatedRecord({
//     required this.reference,
//     required this.originSystemCode,
//     required this.flightOfferId,
//   });

//   factory AssociatedRecord.fromJson(Map<String, dynamic> json) {
//     return AssociatedRecord(
//       reference: json['reference'] ?? '',
//       originSystemCode: json['originSystemCode'] ?? '',
//       flightOfferId: json['flightOfferId'] ?? '',
//     );
//   }
// }

// class FlightOffer {
//   final String type;
//   final String id;
//   final String source;
//   final bool nonHomogeneous;
//   final String lastTicketingDate;
//   final List<Itinerary> itineraries;
//   final Price price;
//   final List<String> validatingAirlineCodes;
//   final List<TravelerPricing> travelerPricings;

//   FlightOffer({
//     required this.type,
//     required this.id,
//     required this.source,
//     required this.nonHomogeneous,
//     required this.lastTicketingDate,
//     required this.itineraries,
//     required this.price,
//     required this.validatingAirlineCodes,
//     required this.travelerPricings,
//   });

//   factory FlightOffer.fromJson(Map<String, dynamic> json) {
//     return FlightOffer(
//       type: json['type'] ?? '',
//       id: json['id'] ?? '',
//       source: json['source'] ?? '',
//       nonHomogeneous: json['nonHomogeneous'] ?? false,
//       lastTicketingDate: json['lastTicketingDate'] ?? '',
//       itineraries: (json['itineraries'] as List? ?? [])
//           .map((item) => Itinerary.fromJson(item))
//           .toList(),
//       price: Price.fromJson(json['price'] ?? {}),
//       validatingAirlineCodes: (json['validatingAirlineCodes'] as List? ?? [])
//           .map((item) => item.toString())
//           .toList(),
//       travelerPricings: (json['travelerPricings'] as List? ?? [])
//           .map((item) => TravelerPricing.fromJson(item))
//           .toList(),
//     );
//   }
// }

// class Itinerary {
//   final List<Segment> segments;

//   Itinerary({required this.segments});

//   factory Itinerary.fromJson(Map<String, dynamic> json) {
//     return Itinerary(
//       segments: (json['segments'] as List? ?? [])
//           .map((item) => Segment.fromJson(item))
//           .toList(),
//     );
//   }

//   // Helper getters for easy access to first segment
//   Segment get firstSegment =>
//       segments.isNotEmpty ? segments.first : Segment.empty();

//   Airport get fromAirport => Airport(
//     code: firstSegment.departure.iataCode,
//     city: firstSegment
//         .departure
//         .iataCode, // You might want to map this from dictionaries
//   );

//   Airport get toAirport => Airport(
//     code: firstSegment.arrival.iataCode,
//     city: firstSegment
//         .arrival
//         .iataCode, // You might want to map this from dictionaries
//   );

//   String get duration => firstSegment.duration;
// }

// class Segment {
//   final Departure departure;
//   final Arrival arrival;
//   final String carrierCode;
//   final String number;
//   final String duration;
//   final String bookingStatus;
//   final String segmentType;

//   Segment({
//     required this.departure,
//     required this.arrival,
//     required this.carrierCode,
//     required this.number,
//     required this.duration,
//     required this.bookingStatus,
//     required this.segmentType,
//   });

//   factory Segment.fromJson(Map<String, dynamic> json) {
//     return Segment(
//       departure: Departure.fromJson(json['departure'] ?? {}),
//       arrival: Arrival.fromJson(json['arrival'] ?? {}),
//       carrierCode: json['carrierCode'] ?? '',
//       number: json['number'] ?? '',
//       duration: json['duration'] ?? '',
//       bookingStatus: json['bookingStatus'] ?? '',
//       segmentType: json['segmentType'] ?? '',
//     );
//   }

//   static Segment empty() => Segment(
//     departure: Departure.empty(),
//     arrival: Arrival.empty(),
//     carrierCode: '',
//     number: '',
//     duration: '',
//     bookingStatus: '',
//     segmentType: '',
//   );
// }

// class Departure {
//   final String iataCode;
//   final String at;

//   Departure({required this.iataCode, required this.at});

//   factory Departure.fromJson(Map<String, dynamic> json) {
//     return Departure(iataCode: json['iataCode'] ?? '', at: json['at'] ?? '');
//   }

//   static Departure empty() => Departure(iataCode: '', at: '');
// }

// class Arrival {
//   final String iataCode;
//   final String terminal;
//   final String at;

//   Arrival({required this.iataCode, required this.terminal, required this.at});

//   factory Arrival.fromJson(Map<String, dynamic> json) {
//     return Arrival(
//       iataCode: json['iataCode'] ?? '',
//       terminal: json['terminal'] ?? '',
//       at: json['at'] ?? '',
//     );
//   }

//   static Arrival empty() => Arrival(iataCode: '', terminal: '', at: '');
// }

// class Price {
//   final String currency;
//   final String total;
//   final String base;
//   final String grandTotal;

//   Price({
//     required this.currency,
//     required this.total,
//     required this.base,
//     required this.grandTotal,
//   });

//   factory Price.fromJson(Map<String, dynamic> json) {
//     return Price(
//       currency: json['currency'] ?? '',
//       total: json['total'] ?? '',
//       base: json['base'] ?? '',
//       grandTotal: json['grandTotal'] ?? '',
//     );
//   }
// }

// class TravelerPricing {
//   final String travelerId;
//   final String fareOption;
//   final String travelerType;
//   final Price price;

//   TravelerPricing({
//     required this.travelerId,
//     required this.fareOption,
//     required this.travelerType,
//     required this.price,
//   });

//   factory TravelerPricing.fromJson(Map<String, dynamic> json) {
//     return TravelerPricing(
//       travelerId: json['travelerId'] ?? '',
//       fareOption: json['fareOption'] ?? '',
//       travelerType: json['travelerType'] ?? '',
//       price: Price.fromJson(json['price'] ?? {}),
//     );
//   }
// }

// class Traveler {
//   final String id;
//   final String dateOfBirth;
//   final String gender;
//   final TravelerName name;
//   final List<Document> documents;
//   final Contact contact;

//   Traveler({
//     required this.id,
//     required this.dateOfBirth,
//     required this.gender,
//     required this.name,
//     required this.documents,
//     required this.contact,
//   });

//   factory Traveler.fromJson(Map<String, dynamic> json) {
//     return Traveler(
//       id: json['id'] ?? '',
//       dateOfBirth: json['dateOfBirth'] ?? '',
//       gender: json['gender'] ?? '',
//       name: TravelerName.fromJson(json['name'] ?? {}),
//       documents: (json['documents'] as List? ?? [])
//           .map((item) => Document.fromJson(item))
//           .toList(),
//       contact: Contact.fromJson(json['contact'] ?? {}),
//     );
//   }
// }

// class TravelerName {
//   final String firstName;
//   final String lastName;

//   TravelerName({required this.firstName, required this.lastName});

//   factory TravelerName.fromJson(Map<String, dynamic> json) {
//     return TravelerName(
//       firstName: json['firstName'] ?? '',
//       lastName: json['lastName'] ?? '',
//     );
//   }

//   String get fullName => '$firstName $lastName';
// }

// class Document {
//   final String number;
//   final String expiryDate;
//   final String issuanceCountry;
//   final String nationality;
//   final String documentType;
//   final bool holder;

//   Document({
//     required this.number,
//     required this.expiryDate,
//     required this.issuanceCountry,
//     required this.nationality,
//     required this.documentType,
//     required this.holder,
//   });

//   factory Document.fromJson(Map<String, dynamic> json) {
//     return Document(
//       number: json['number'] ?? '',
//       expiryDate: json['expiryDate'] ?? '',
//       issuanceCountry: json['issuanceCountry'] ?? '',
//       nationality: json['nationality'] ?? '',
//       documentType: json['documentType'] ?? '',
//       holder: json['holder'] ?? false,
//     );
//   }
// }

// class Contact {
//   final String purpose;
//   final List<Phone> phones;
//   final String emailAddress;

//   Contact({
//     required this.purpose,
//     required this.phones,
//     required this.emailAddress,
//   });

//   factory Contact.fromJson(Map<String, dynamic> json) {
//     return Contact(
//       purpose: json['purpose'] ?? '',
//       phones: (json['phones'] as List? ?? [])
//           .map((item) => Phone.fromJson(item))
//           .toList(),
//       emailAddress: json['emailAddress'] ?? '',
//     );
//   }
// }

// class Phone {
//   final String deviceType;
//   final String countryCallingCode;
//   final String number;

//   Phone({
//     required this.deviceType,
//     required this.countryCallingCode,
//     required this.number,
//   });

//   factory Phone.fromJson(Map<String, dynamic> json) {
//     return Phone(
//       deviceType: json['deviceType'] ?? '',
//       countryCallingCode: json['countryCallingCode'] ?? '',
//       number: json['number'] ?? '',
//     );
//   }
// }

// class Ticket {
//   final String documentType;
//   final String documentNumber;
//   final String documentStatus;
//   final String travelerId;
//   final List<String> segmentIds;

//   Ticket({
//     required this.documentType,
//     required this.documentNumber,
//     required this.documentStatus,
//     required this.travelerId,
//     required this.segmentIds,
//   });

//   factory Ticket.fromJson(Map<String, dynamic> json) {
//     return Ticket(
//       documentType: json['documentType'] ?? '',
//       documentNumber: json['documentNumber'] ?? '',
//       documentStatus: json['documentStatus'] ?? '',
//       travelerId: json['travelerId'] ?? '',
//       segmentIds: (json['segmentIds'] as List? ?? [])
//           .map((item) => item.toString())
//           .toList(),
//     );
//   }

//   static Ticket empty() => Ticket(
//     documentType: '',
//     documentNumber: '',
//     documentStatus: '',
//     travelerId: '',
//     segmentIds: [],
//   );
// }

// // Helper class for airport data in UI
// class Airport {
//   final String code;
//   final String city;

//   Airport({required this.code, required this.city});
// }

// lib/data/models/payment_status_response.dart
class PaymentStatusResponse {
  final String status;
  final OrderResponse order;

  PaymentStatusResponse({required this.status, required this.order});

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      status: json['status']?.toString() ?? 'UNKNOWN',
      order: OrderResponse.fromJson(json['order'] ?? {}),
    );
  }
}

class OrderResponse {
  final OrderData data;
  final Map<String, dynamic>? dictionaries;
  final Map<String, dynamic>? airlines;
  final Map<String, dynamic>? airports;

  OrderResponse({
    required this.data,
    this.dictionaries,
    this.airlines,
    this.airports,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      data: OrderData.fromJson(json['data'] ?? {}),
      dictionaries: json['dictionaries'] as Map<String, dynamic>?,
      airlines: json['airlines'] as Map<String, dynamic>?,
      airports: json['airports'] as Map<String, dynamic>?,
    );
  }
}

class OrderData {
  final String type;
  final String id;
  final String queuingOfficeId;
  final List<FlightOffer> flightOffers;
  final List<Traveler> travelers;
  final List<Ticket> tickets;
  final List<AssociatedRecord> associatedRecords;

  OrderData({
    required this.type,
    required this.id,
    required this.queuingOfficeId,
    required this.flightOffers,
    required this.travelers,
    required this.tickets,
    required this.associatedRecords,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      type: json['type']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      queuingOfficeId: json['queuingOfficeId']?.toString() ?? '',
      flightOffers: (json['flightOffers'] as List? ?? [])
          .map((item) => FlightOffer.fromJson(item))
          .toList(),
      travelers: (json['travelers'] as List? ?? [])
          .map((item) => Traveler.fromJson(item))
          .toList(),
      tickets: (json['tickets'] as List? ?? [])
          .map((item) => Ticket.fromJson(item))
          .toList(),
      associatedRecords: (json['associatedRecords'] as List? ?? [])
          .map((item) => AssociatedRecord.fromJson(item))
          .toList(),
    );
  }

  // Helper method to get ticket number for a traveler
  String? getTicketNumberForTraveler(String travelerId) {
    try {
      final ticket = tickets.firstWhere(
        (ticket) => ticket.travelerId == travelerId,
        orElse: () => Ticket.empty(),
      );
      return ticket.documentNumber.isNotEmpty ? ticket.documentNumber : null;
    } catch (e) {
      return null;
    }
  }
}

class AssociatedRecord {
  final String reference;
  final String originSystemCode;
  final String flightOfferId;

  AssociatedRecord({
    required this.reference,
    required this.originSystemCode,
    required this.flightOfferId,
  });

  factory AssociatedRecord.fromJson(Map<String, dynamic> json) {
    return AssociatedRecord(
      reference: json['reference']?.toString() ?? '',
      originSystemCode: json['originSystemCode']?.toString() ?? '',
      flightOfferId: json['flightOfferId']?.toString() ?? '',
    );
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
    required this.validatingAirlineCodes,
    required this.travelerPricings,
  });

  factory FlightOffer.fromJson(Map<String, dynamic> json) {
    return FlightOffer(
      type: json['type']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      nonHomogeneous: json['nonHomogeneous'] as bool? ?? false,
      lastTicketingDate: json['lastTicketingDate']?.toString() ?? '',
      itineraries: (json['itineraries'] as List? ?? [])
          .map((item) => Itinerary.fromJson(item))
          .toList(),
      price: Price.fromJson(json['price'] ?? {}),
      validatingAirlineCodes: (json['validatingAirlineCodes'] as List? ?? [])
          .map((item) => item?.toString() ?? '')
          .toList(),
      travelerPricings: (json['travelerPricings'] as List? ?? [])
          .map((item) => TravelerPricing.fromJson(item))
          .toList(),
    );
  }
}

class Itinerary {
  final List<Segment> segments;

  Itinerary({required this.segments});

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      segments: (json['segments'] as List? ?? [])
          .map((item) => Segment.fromJson(item))
          .toList(),
    );
  }

  // Helper getters for easy access to first segment
  Segment get firstSegment =>
      segments.isNotEmpty ? segments.first : Segment.empty();

  Airport get fromAirport => Airport(
    code: firstSegment.departure.iataCode,
    city: firstSegment.departure.iataCode,
  );

  Airport get toAirport => Airport(
    code: firstSegment.arrival.iataCode,
    city: firstSegment.arrival.iataCode,
  );

  String get duration => firstSegment.duration;
}

class Segment {
  final Departure departure;
  final Arrival arrival;
  final String carrierCode;
  final String number;
  final String duration;
  final String bookingStatus;
  final String segmentType;

  Segment({
    required this.departure,
    required this.arrival,
    required this.carrierCode,
    required this.number,
    required this.duration,
    required this.bookingStatus,
    required this.segmentType,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      departure: Departure.fromJson(json['departure'] ?? {}),
      arrival: Arrival.fromJson(json['arrival'] ?? {}),
      carrierCode: json['carrierCode']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      bookingStatus: json['bookingStatus']?.toString() ?? '',
      segmentType: json['segmentType']?.toString() ?? '',
    );
  }

  static Segment empty() => Segment(
    departure: Departure.empty(),
    arrival: Arrival.empty(),
    carrierCode: '',
    number: '',
    duration: '',
    bookingStatus: '',
    segmentType: '',
  );
}

class Departure {
  final String iataCode;
  final String at;

  Departure({required this.iataCode, required this.at});

  factory Departure.fromJson(Map<String, dynamic> json) {
    return Departure(
      iataCode: json['iataCode']?.toString() ?? '',
      at: json['at']?.toString() ?? '',
    );
  }

  static Departure empty() => Departure(iataCode: '', at: '');
}

class Arrival {
  final String iataCode;
  final String terminal;
  final String at;

  Arrival({required this.iataCode, required this.terminal, required this.at});

  factory Arrival.fromJson(Map<String, dynamic> json) {
    return Arrival(
      iataCode: json['iataCode']?.toString() ?? '',
      terminal: json['terminal']?.toString() ?? '',
      at: json['at']?.toString() ?? '',
    );
  }

  static Arrival empty() => Arrival(iataCode: '', terminal: '', at: '');
}

class Price {
  final String currency;
  final String total;
  final String base;
  final String grandTotal;

  Price({
    required this.currency,
    required this.total,
    required this.base,
    required this.grandTotal,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      currency: json['currency']?.toString() ?? '',
      total: json['total']?.toString() ?? '',
      base: json['base']?.toString() ?? '',
      grandTotal: json['grandTotal']?.toString() ?? '',
    );
  }
}

class TravelerPricing {
  final String travelerId;
  final String fareOption;
  final String travelerType;
  final Price price;

  TravelerPricing({
    required this.travelerId,
    required this.fareOption,
    required this.travelerType,
    required this.price,
  });

  factory TravelerPricing.fromJson(Map<String, dynamic> json) {
    return TravelerPricing(
      travelerId: json['travelerId']?.toString() ?? '',
      fareOption: json['fareOption']?.toString() ?? '',
      travelerType: json['travelerType']?.toString() ?? '',
      price: Price.fromJson(json['price'] ?? {}),
    );
  }
}

class Traveler {
  final String id;
  final String dateOfBirth;
  final String gender;
  final TravelerName name;
  final List<Document> documents;
  final Contact contact;

  Traveler({
    required this.id,
    required this.dateOfBirth,
    required this.gender,
    required this.name,
    required this.documents,
    required this.contact,
  });

  factory Traveler.fromJson(Map<String, dynamic> json) {
    return Traveler(
      id: json['id']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      name: TravelerName.fromJson(json['name'] ?? {}),
      documents: (json['documents'] as List? ?? [])
          .map((item) => Document.fromJson(item))
          .toList(),
      contact: Contact.fromJson(json['contact'] ?? {}),
    );
  }
}

class TravelerName {
  final String firstName;
  final String lastName;

  TravelerName({required this.firstName, required this.lastName});

  factory TravelerName.fromJson(Map<String, dynamic> json) {
    return TravelerName(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}

class Document {
  final String number;
  final String expiryDate;
  final String issuanceCountry;
  final String nationality;
  final String documentType;
  final bool holder;

  Document({
    required this.number,
    required this.expiryDate,
    required this.issuanceCountry,
    required this.nationality,
    required this.documentType,
    required this.holder,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      number: json['number']?.toString() ?? '',
      expiryDate: json['expiryDate']?.toString() ?? '',
      issuanceCountry: json['issuanceCountry']?.toString() ?? '',
      nationality: json['nationality']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      holder: json['holder'] as bool? ?? false,
    );
  }
}

class Contact {
  final String purpose;
  final List<Phone> phones;
  final String emailAddress;

  Contact({
    required this.purpose,
    required this.phones,
    required this.emailAddress,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      purpose: json['purpose']?.toString() ?? '',
      phones: (json['phones'] as List? ?? [])
          .map((item) => Phone.fromJson(item))
          .toList(),
      emailAddress: json['emailAddress']?.toString() ?? '',
    );
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
      deviceType: json['deviceType']?.toString() ?? '',
      countryCallingCode: json['countryCallingCode']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
    );
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
      documentType: json['documentType']?.toString() ?? '',
      documentNumber: json['documentNumber']?.toString() ?? '',
      documentStatus: json['documentStatus']?.toString() ?? '',
      travelerId: json['travelerId']?.toString() ?? '',
      segmentIds: (json['segmentIds'] as List? ?? [])
          .map((item) => item?.toString() ?? '')
          .toList(),
    );
  }

  static Ticket empty() => Ticket(
    documentType: '',
    documentNumber: '',
    documentStatus: '',
    travelerId: '',
    segmentIds: [],
  );
}

// Helper class for airport data in UI
class Airport {
  final String code;
  final String city;

  Airport({required this.code, required this.city});
}
