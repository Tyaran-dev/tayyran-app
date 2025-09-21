// lib/presentation/passenger_info/cubit/passenger_info_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';
import 'package:tayyran_app/data/repositories/flight_pricing_repository.dart';

part 'passenger_info_state.dart';

class PassengerInfoCubit extends Cubit<PassengerInfoState> {
  final FlightPricingRepository _pricingRepository;
  bool _hasPricingUpdated = false;

  PassengerInfoCubit({
    required FlightOffer flightOffer,
    required FlightPricingRepository pricingRepository,
  }) : _pricingRepository = pricingRepository,
       super(PassengerInfoState.initial(flightOffer)) {
    print('🚀 PassengerInfoCubit created');
    print('📊 Initial price: ${flightOffer.price}');
  }

  Future<void> updateFlightPricing() async {
    if (_hasPricingUpdated || state.isLoading) return;

    print('🔄 updateFlightPricing() called');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final pricingData = _preparePricingRequestData(state.currentFlightOffer);
      print('📤 Sending pricing request...');

      final pricingResponse = await _pricingRepository.getFlightPricing(
        pricingData,
      );

      print('✅ Received pricing response');
      print('📋 Response success: ${pricingResponse['success']}');

      if (pricingResponse['success'] == true) {
        final updatedFlightOffer = _mergeFlightOfferWithPricing(
          state.currentFlightOffer,
          pricingResponse,
        );

        _hasPricingUpdated = true;

        print('🎉 Pricing update completed:');
        print('   - New price: ${updatedFlightOffer.price}');
        print(
          '   - New commission: ${updatedFlightOffer.presentageCommission}%',
        );

        emit(
          state.copyWith(
            isLoading: false,
            currentFlightOffer: updatedFlightOffer,
            errorMessage: null,
          ),
        );
      } else {
        print('❌ Pricing API returned success: false');
        final errorMessage =
            pricingResponse['message'] ?? 'Failed to update pricing';
        emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
      }
    } catch (e, stackTrace) {
      print('🔥 Error in updateFlightPricing: $e');
      print('📋 Stack trace: $stackTrace');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update flight pricing: $e',
        ),
      );
    }
  }

  Map<String, dynamic> _preparePricingRequestData(FlightOffer flightOffer) {
    // Convert the entire flight offer to JSON and then back to Map
    // This ensures we send the exact same structure as the original response
    final Map<String, dynamic> requestData = {
      "mapping": flightOffer.mapping,
      "type": flightOffer.type,
      "id": flightOffer.id,
      "agent": "GDS", // Hardcoded as per your example
      "source": flightOffer.source,
      "fromLocation": flightOffer.fromLocation,
      "toLocation": flightOffer.toLocation,
      "fromName": flightOffer.fromName,
      "toName": flightOffer.toName,
      "flightType": flightOffer.flightType,
      "adults": flightOffer.adults,
      "children": flightOffer.children,
      "infants": flightOffer.infants,
      "numberOfBookableSeats": flightOffer.numberOfBookableSeats,
      "airline": flightOffer.airline,
      "airlineName": flightOffer.airlineName,
      "flightNumber": flightOffer.flightNumber,
      "stops": flightOffer.stops,
      "original_price": flightOffer.originalPrice.toString(),
      "basePrice": flightOffer.basePrice.toString(),
      "price": flightOffer.price,
      "currency": flightOffer.currency,
      "refund": flightOffer.refund,
      "exchange": flightOffer.exchange,
      "cabinClass": flightOffer.cabinClass,
      "allowedBags": flightOffer.allowedBags,
      "allowedCabinBags": flightOffer.allowedCabinBags,
      "provider": flightOffer.provider,
      "itineraries_formated": flightOffer.itineraries.map((itinerary) {
        return {
          "duration": itinerary.duration,
          "fromLocation": itinerary.fromLocation,
          "toLocation": itinerary.toLocation,
          "fromName": itinerary.fromName,
          "toName": itinerary.toName,
          "fromAirport": {
            "id": itinerary.fromAirport.id,
            "name": itinerary.fromAirport.name,
            "code": itinerary.fromAirport.code,
            "city": itinerary.fromAirport.city,
          },
          "toAirport": {
            "id": itinerary.toAirport.id,
            "name": itinerary.toAirport.name,
            "code": itinerary.toAirport.code,
            "city": itinerary.toAirport.city,
          },
          "departure": itinerary.departure != null
              ? {
                  "departure_date_time": itinerary.departure!.departureDateTime
                      .toIso8601String(),
                  "departure_date": itinerary.departure!.departureDate,
                  "departure_time": itinerary.departure!.departureTime,
                  "departure_terminal": itinerary.departure!.departureTerminal,
                  "arrival_date_time": itinerary.departure!.arrivalDateTime
                      .toIso8601String(),
                  "arrival_date": itinerary.departure!.arrivalDate,
                  "arrival_time": itinerary.departure!.arrivalTime,
                  "arrival_terminal": itinerary.departure!.arrivalTerminal,
                  "stops": itinerary.departure!.stops,
                  "duration": itinerary.departure!.duration,
                  "flightNumber": itinerary.departure!.flightNumber,
                  "airlineCode": itinerary.departure!.airlineCode,
                  "airlineName": itinerary.departure!.airlineName,
                  "image": itinerary.departure!.image,
                }
              : null,
          "segments": itinerary.segments.map((segment) {
            return {
              "departure": {
                "iataCode": segment.departure.iataCode,
                "terminal": segment.departure.terminal,
                "at": segment.departure.at.toIso8601String(),
              },
              "arrival": {
                "iataCode": segment.arrival.iataCode,
                "terminal": segment.arrival.terminal,
                "at": segment.arrival.at.toIso8601String(),
              },
              "carrierCode": segment.carrierCode,
              "number": segment.number,
              "aircraft": segment.aircraft != null
                  ? {"code": segment.aircraft!.code}
                  : null,
              "operating": segment.operating != null
                  ? {"carrierCode": segment.operating!.carrierCode}
                  : null,
              "duration": segment.duration,
              "id": segment.id,
              "numberOfStops": segment.numberOfStops,
              "blacklistedInEU": segment.blacklistedInEU,
              "departure_date": segment.departureDate,
              "departure_time": segment.departureTime,
              "arrival_date": segment.arrivalDate,
              "arrival_time": segment.arrivalTime,
              "stopDuration": segment.stopDuration,
              "stopLocation": segment.stopLocation,
              "fromName": segment.fromName,
              "toName": segment.toName,
              "fromAirport": {
                "id": segment.fromAirport.id,
                "name": segment.fromAirport.name,
                "code": segment.fromAirport.code,
                "city": segment.fromAirport.city,
              },
              "toAirport": {
                "id": segment.toAirport.id,
                "name": segment.toAirport.name,
                "code": segment.toAirport.code,
                "city": segment.toAirport.city,
              },
              "class": segment.segmentClass,
              "image": segment.image,
            };
          }).toList(),
          "stops": itinerary.stops,
        };
      }).toList(),
      "fare_rules": flightOffer.fareRules.map((rule) {
        return {
          "category": rule.category,
          "maxPenaltyAmount": rule.maxPenaltyAmount,
          "notApplicable": rule.notApplicable,
        };
      }).toList(),
      "pricing_options": {
        "fareType": flightOffer.pricingOptions.fareType,
        "includedCheckedBagsOnly":
            flightOffer.pricingOptions.includedCheckedBagsOnly,
      },
      "traveller_pricing": flightOffer.travellerPricing.map((pricing) {
        return {
          "travelerType": pricing.travelerType,
          "total": pricing.total,
          "base": pricing.base,
          "tax": pricing.tax,
          "class": pricing.travelClass,
          "allowedBags": {
            "quantity": pricing.allowedBags.quantity,
            "weight": pricing.allowedBags.weight,
          },
          "cabinBagsAllowed": pricing.cabinBagsAllowed,
          "fareDetails": pricing.fareDetails.map((detail) {
            return {
              "segmentId": detail.segmentId,
              "cabin": detail.cabin,
              "fareBasis": detail.fareBasis,
              "class": detail.fareClass,
              "bagsAllowed": detail.bagsAllowed,
              "cabinBagsAllowed": detail.cabinBagsAllowed,
            };
          }).toList(),
        };
      }).toList(),
      "baggage_details": flightOffer.baggageDetails.map((detail) {
        return {
          "Flight Number": detail.flightNumber,
          "From": detail.from,
          "To": detail.to,
          "Airline": detail.airline,
          "Checked Bags Allowed": detail.checkedBagsAllowed,
          "Cabin Bags Allowed": detail.cabinBagsAllowed,
        };
      }).toList(),
      "total_pricing_by_traveller_type":
          flightOffer.totalPricingByTravellerType,
      "charges": {
        "exchange": flightOffer.charges.exchange,
        "refund": flightOffer.charges.refund,
        "revalidation": flightOffer.charges.revalidation,
      },
      "origins": flightOffer.origins,
      "destinations": flightOffer.destinations,
      "originalResponse": flightOffer.originalResponse,
    };

    // Add debug print to see what's being sent
    print('📤 Sending complete flight offer to pricing API');
    print('📋 Request contains ${requestData.length} keys');
    print('💰 Mapping: ${requestData['mapping']}');
    print(
      '🛫 Airline: ${requestData['airline']} ${requestData['flightNumber']}',
    );
    print(
      '👥 Passengers: ${requestData['adults']} adults, ${requestData['children']} children, ${requestData['infants']} infants',
    );

    return requestData;
  }

  FlightOffer _mergeFlightOfferWithPricing(
    FlightOffer original,
    Map<String, dynamic> pricingResponse,
  ) {
    print('🔍 Starting _mergeFlightOfferWithPricing');

    final data = pricingResponse['data'];
    if (data == null) {
      print('❌ No data in pricing response');
      return original;
    }

    if (data['flightOffers'] == null) {
      print('❌ No flightOffers in data');
      return original;
    }

    final flightOffers = data['flightOffers'] as List;
    if (flightOffers.isEmpty) {
      print('❌ flightOffers list is empty');
      return original;
    }

    final pricingData = flightOffers.first;
    print('📦 First flight offer keys: ${pricingData.keys.toList()}');

    // Debug: Print the entire pricingData to see the structure
    print('🔍 Full pricing data structure:');
    printNestedMap(pricingData as Map<String, dynamic>);

    final priceData = pricingData['price'];
    if (priceData == null) {
      print('❌ No price data in flight offer');
      return original;
    }

    // SAFELY extract grandTotal
    final grandTotal =
        safeParseDouble(priceData['grandTotal']) ?? original.price;
    print('💰 grandTotal: $grandTotal');

    // SAFELY extract presentageCommission - check multiple possible locations
    double presentageCommission = original.presentageCommission;

    // Check multiple possible locations for the commission
    if (pricingData.containsKey('presentageCommission')) {
      presentageCommission =
          safeParseDouble(pricingData['presentageCommission']) ??
          original.presentageCommission;
      print(
        '✅ Found presentageCommission in flight offer: $presentageCommission',
      );
    } else if (data.containsKey('presentageCommission')) {
      presentageCommission =
          safeParseDouble(data['presentageCommission']) ??
          original.presentageCommission;

      print('✅ Found presentageCommission in data: $presentageCommission');
    } else if (pricingResponse.containsKey('presentageCommission')) {
      presentageCommission =
          safeParseDouble(pricingResponse['presentageCommission']) ??
          original.presentageCommission;
      print('✅ Found presentageCommission in root: $presentageCommission');
    } else {
      print('❌ presentageCommission not found in any location');
    }

    // SAFELY extract traveler pricing
    final travelerPricings =
        pricingData['travelerPricings'] as List<dynamic>? ?? [];
    final updatedTravelerPricing = _extractUpdatedTravelerPricing(
      travelerPricings,
    );

    final updatedOffer = original.copyWith(
      price: grandTotal,
      presentageCommission: presentageCommission,
      travellerPricing: updatedTravelerPricing.isNotEmpty
          ? updatedTravelerPricing
          : original.travellerPricing,
    );

    print('🎯 Final updated offer:');
    print('   - Price: ${updatedOffer.price}');
    print('   - Commission: ${updatedOffer.presentageCommission}%');

    return updatedOffer;
  }

  List<TravellerPricing> _extractUpdatedTravelerPricing(
    List<dynamic> travelerPricings,
  ) {
    return travelerPricings.map((pricing) {
      final priceData = pricing['price'];

      // SAFELY extract values - handle both string and numeric values
      final total =
          safeParseDouble(priceData?['total'])?.toString() ??
          (priceData?['total']?.toString() ?? '0');
      final base =
          safeParseDouble(priceData?['base'])?.toString() ??
          (priceData?['base']?.toString() ?? '0');
      final tax = safeParseDouble(priceData?['tax']) ?? 0.0;

      return TravellerPricing(
        travelerType: pricing['travelerType']?.toString() ?? '',
        total: total,
        base: base,
        tax: tax,
        travelClass:
            pricing['fareDetailsBySegment']?[0]?['cabin']?.toString() ??
            pricing['class']?.toString() ??
            '',
        allowedBags: BaggageAllowance(quantity: '', weight: ''),
        cabinBagsAllowed: 0,
        fareDetails: [],
      );
    }).toList();
  }

  void updatePassengerFirstName(int index, String firstName) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      firstName: firstName,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerLastName(int index, String lastName) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      lastName: lastName,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerDateOfBirth(int index, String dateOfBirth) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      dateOfBirth: dateOfBirth,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerPassportNumber(int index, String passportNumber) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      passportNumber: passportNumber,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerPassportExpiry(int index, String passportExpiry) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      passportExpiry: passportExpiry,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerNationality(int index, String nationality) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      nationality: nationality,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerTitle(int index, String title) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(title: title);
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updatePassengerIssuingCountry(int index, String issuingCountry) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      issuingCountry: issuingCountry,
    );
    emit(state.copyWith(passengers: updatedPassengers));
  }

  void updateContactEmail(String email) {
    emit(state.copyWith(contactEmail: email));
  }

  void updateContactPhone(String phone) {
    emit(state.copyWith(contactPhone: phone));
  }

  void updateCountryCode(String countryCode) {
    emit(state.copyWith(countryCode: countryCode));
  }

  String getFullPhoneNumber() {
    return '${state.countryCode}${state.contactPhone}';
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void retryPricingUpdate() {
    clearError();
    updateFlightPricing();
  }

  void submitPassengerInfo() {
    if (!state.isFormValid || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      emit(state.copyWith(isLoading: false, isSubmitted: true));
      // Navigate to payment screen
    });
  }

  @override
  Future<void> close() {
    // Clean up any resources if needed
    return super.close();
  }
}
