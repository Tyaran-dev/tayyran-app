import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/data/models/flight_pricing_response.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/models/passenger_model.dart';
import 'package:tayyran_app/data/repositories/flight_pricing_repository.dart';

part 'passenger_info_state.dart';

class PassengerInfoCubit extends Cubit<PassengerInfoState> {
  final FlightPricingRepository _pricingRepository;
  bool _hasPricingUpdated = false;
  bool _hasSubmitted = false;
  PassengerInfoCubit({
    required FlightOffer flightOffer,
    required Filters filters,
    required FlightPricingRepository pricingRepository,
    Map<String, dynamic>? initialPassengerData,
  }) : _pricingRepository = pricingRepository,
       super(
         PassengerInfoState.initial(flightOffer: flightOffer, filters: filters),
       ) {
    print('🚀 PassengerInfoCubit created');
    print('📊 Initial price: ${flightOffer.price}');
  }

  // Add helper method to get airline name for segment
  String getAirlineNameForSegment(Segment segment, String currentLang) {
    final carrier = state.filters.findCarrierByCode(segment.carrierCode);
    if (carrier == null) {
      return segment.carrierCode;
    }
    return currentLang == 'ar'
        ? (carrier.airlineNameAr)
        : (carrier.airLineName);
  }

  // Add helper method to get airline logo for segment
  String getAirlineLogoForSegment(Segment segment) {
    final carrier = state.filters.findCarrierByCode(segment.carrierCode);
    return carrier?.image ?? '';
  }

  // Get display airline name for multi-airline flights
  String get displayAirlineName {
    final Set<String> airlineCodes = {};
    for (final itinerary in state.currentFlightOffer.itineraries) {
      for (final segment in itinerary.segments) {
        if (segment.carrierCode.isNotEmpty) {
          airlineCodes.add(segment.carrierCode);
        }
      }
    }

    final airlines = airlineCodes
        .map((code) => state.filters.findCarrierByCode(code))
        .where((carrier) => carrier != null)
        .cast<Carrier>()
        .toList();

    if (airlines.length == 1) {
      return airlines.first.airLineName;
    } else if (airlines.length > 1) {
      return 'Multiple Airlines';
    }
    return state.currentFlightOffer.airlineName;
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
      print('📋 Response success: ${pricingResponse.success}');

      if (pricingResponse.success) {
        final updatedFlightOffer = _mergeFlightOfferWithPricing(
          state.currentFlightOffer,
          pricingResponse,
        );

        final pricingOffer = pricingResponse.data.flightOffers.first;
        final presentageVat = pricingResponse.presentageVat;
        final presentageCommission = pricingResponse.presentageCommission;
        final updatedPrice = pricingOffer.price.grandTotalAsDouble;
        final administrationFee = updatedPrice * (presentageCommission / 100);
        final vatAmount = administrationFee * (presentageVat / 100);
        final grandTotal = updatedPrice + administrationFee + vatAmount;

        _hasPricingUpdated = true;

        print('🎉 Pricing update completed:');
        print('   - Updated Price: $updatedPrice');
        print('   - Commission: $presentageCommission%');
        print('   - Administration Fee: $administrationFee');
        print('   - Grand Total: $grandTotal');

        emit(
          state.copyWith(
            isLoading: false,
            currentFlightOffer: updatedFlightOffer,
            pricingResponse: pricingResponse,
            errorMessage: null,
            updatedPrice: updatedPrice,
            administrationFee: administrationFee,
            grandTotal: grandTotal,
          ),
        );
      } else {
        print('❌ Pricing API returned success: false');
        final errorMessage =
            pricingResponse.message ?? 'Failed to update pricing';
        emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
      }
    } catch (e) {
      print('🔥 Error in updateFlightPricing: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to update flight pricing: $e',
        ),
      );
    }
  }

  Map<String, dynamic> _preparePricingRequestData(FlightOffer flightOffer) {
    final Map<String, dynamic> requestData = {
      "mapping": flightOffer.mapping,
      "type": flightOffer.type,
      "id": flightOffer.id,
      "agent": flightOffer.agent,
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
            // "quantity": pricing.allowedBags.quantity,
            // "weight": pricing.allowedBags.weight,
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
    FlightPricingResponse pricingResponse,
  ) {
    print('🔍 Starting _mergeFlightOfferWithPricing');

    if (pricingResponse.data.flightOffers.isEmpty) {
      print('❌ No flight offers in response');
      return original;
    }

    final pricingOffer = pricingResponse.data.flightOffers.first;
    final presentageCommission = pricingResponse.presentageCommission;

    print('💰 Commission from response: $presentageCommission');
    print('💰 Grand Total: ${pricingOffer.price.grandTotal}');

    final updatedPrice = pricingOffer.price.grandTotalAsDouble;
    final administrationFee = updatedPrice * (presentageCommission / 100);
    final grandTotal = updatedPrice + administrationFee;

    print('🎯 Calculated prices:');
    print('   - Updated Price: $updatedPrice');
    print('   - Commission %: $presentageCommission%');
    print('   - Administration Fee: $administrationFee');
    print('   - Grand Total: $grandTotal');

    // Return the original flight offer unchanged
    return original;
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

  void updatePassengerGender(int index, String gender) {
    final updatedPassengers = List<Passenger>.from(state.passengers);
    updatedPassengers[index] = updatedPassengers[index].copyWith(
      gender: gender,
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
    if (_hasSubmitted || state.isLoading) return;
    if (!state.isFormValid) return;

    _hasSubmitted = true;
    emit(state.copyWith(isLoading: true));

    Future.delayed(Duration(milliseconds: 300), () {
      emit(state.copyWith(isLoading: false, isSubmitted: true));
    });
  }

  void resetSubmission() {
    _hasSubmitted = false;
    emit(state.copyWith(isSubmitted: false));
  }

  @override
  Future<void> close() {
    _hasSubmitted = false;
    return super.close();
  }
}
