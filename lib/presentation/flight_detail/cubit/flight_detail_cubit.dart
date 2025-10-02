// lib/presentation/flight_detail/cubit/flight_detail_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/data/models/flight_pricing_response.dart';
import 'package:tayyran_app/data/repositories/flight_pricing_repository.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';

part 'flight_detail_state.dart';

class FlightDetailCubit extends Cubit<FlightDetailState> {
  final FlightPricingRepository _pricingRepository;
  final FlightOffer _originalFlightOffer;
  // late bool _hasAutoUpdated = false;

  FlightDetailCubit({
    required FlightOffer flightOffer,
    required FlightPricingRepository pricingRepository,
  }) : _pricingRepository = pricingRepository,
       _originalFlightOffer = flightOffer,
       super(FlightDetailState.initial(flightOffer)) {
    print('🚀 FlightDetailCubit created');
    print('📊 Initial price: ${flightOffer.price}');
    print("presentage Commission price: ${flightOffer.presentageCommission}");
    // Auto-update pricing when cubit is created
    // _autoUpdatePricing();
  }

  // void _autoUpdatePricing() {
  //   if (!_hasAutoUpdated) {
  //     print('⚡ Auto-updating pricing...');
  //     _hasAutoUpdated = true;
  //     updateFlightPricing();
  //   } else {
  //     print('⏩ Pricing already auto-updated, skipping');
  //   }
  // }

  // Future<void> updateFlightPricing() async {
  //   if (state.isLoading) return;

  //   print('🔄 updateFlightPricing() called');
  //   print('📊 Original price: ${_originalFlightOffer.price}');
  //   print(
  //     '📊 Original commission: ${_originalFlightOffer.presentageCommission}%',
  //   );

  //   emit(state.copyWith(isLoading: true, errorMessage: null));

  //   try {
  //     final pricingData = _preparePricingRequestData(_originalFlightOffer);
  //     print('📤 Sending pricing request...');

  //     final pricingResponse = await _pricingRepository.getFlightPricing(
  //       pricingData,
  //     );

  //     print('✅ Received pricing response');
  //     print('📋 Response success: ${pricingResponse['success']}');
  //     print('📋 Response message: ${pricingResponse['message']}');

  //     if (pricingResponse['success'] == true) {
  //       // Debug the full response structure
  //       _debugResponseStructure;
  //       print('🔍 Full response structure:');
  //       printNestedMap(pricingResponse);

  //       final updatedFlightOffer = _mergeFlightOfferWithPricing(
  //         _originalFlightOffer,
  //         pricingResponse,
  //       );

  //       print('🎉 Update completed:');
  //       print('   - New price: ${updatedFlightOffer.price}');
  //       print(
  //         '   - New commission: ${updatedFlightOffer.presentageCommission}%',
  //       );

  //       emit(
  //         state.copyWith(
  //           flightOffer: updatedFlightOffer,
  //           isLoading: false,
  //           errorMessage: null,
  //         ),
  //       );
  //     } else {
  //       print('❌ Pricing API returned success: false');
  //       final errorMessage =
  //           pricingResponse['message'] ?? 'Failed to update pricing';
  //       emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
  //     }
  //   } catch (e, stackTrace) {
  //     print('🔥 Error in updateFlightPricing: $e');
  //     print('📋 Stack trace: $stackTrace');
  //     emit(
  //       state.copyWith(
  //         isLoading: false,
  //         errorMessage: 'Failed to update flight pricing: $e',
  //       ),
  //     );
  //   }
  // }

  Future<void> updateFlightPricing() async {
    if (state.isLoading) return;

    print('🔄 updateFlightPricing() called');
    print('📊 Original price: ${_originalFlightOffer.price}');
    print(
      '📊 Original commission: ${_originalFlightOffer.presentageCommission}%',
    );

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final pricingData = _preparePricingRequestData(_originalFlightOffer);
      print('📤 Sending pricing request...');

      // Use the typed response instead of Map
      final pricingResponse = await _pricingRepository.getFlightPricing(
        pricingData,
      );

      print('✅ Received pricing response');
      print('📋 Response success: ${pricingResponse.success}');
      print('📋 Response message: ${pricingResponse.message}');

      if (pricingResponse.success) {
        // Debug the full response structure
        print('🔍 Full response structure:');
        _debugResponseStructure(pricingResponse);

        final updatedFlightOffer = _mergeFlightOfferWithPricing(
          _originalFlightOffer,
          pricingResponse,
        );

        print('🎉 Update completed:');
        print('   - New price: ${updatedFlightOffer.price}');
        print(
          '   - New commission: ${updatedFlightOffer.presentageCommission}%',
        );

        emit(
          state.copyWith(
            flightOffer: updatedFlightOffer,
            isLoading: false,
            errorMessage: null,
          ),
        );
      } else {
        print('❌ Pricing API returned success: false');
        final errorMessage =
            pricingResponse.message ?? 'Failed to update pricing';
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

  void _debugResponseStructure(FlightPricingResponse response) {
    print('📦 Response Type: FlightPricingResponse');
    print('   - Success: ${response.success}');
    print('   - Commission: ${response.presentageCommission}%');

    if (response.data.flightOffers.isNotEmpty) {
      final offer = response.data.flightOffers.first;
      print('   - Flight Offer ID: ${offer.id}');
      print('   - Grand Total: ${offer.price.grandTotal}');
      print('   - Currency: ${offer.price.currency}');
      print('   - Traveler Count: ${offer.travelerPricings.length}');

      for (final traveler in offer.travelerPricings) {
        print(
          '     - Traveler ${traveler.travelerId}: ${traveler.travelerType} - ${traveler.price.total}',
        );
      }
    } else {
      print('   - No flight offers in response');
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
    FlightPricingResponse pricingResponse,
  ) {
    print('🔍 Starting _mergeFlightOfferWithPricing');

    if (pricingResponse.data.flightOffers.isEmpty) {
      print('❌ No flight offers in pricing response');
      return original;
    }

    final pricingOffer = pricingResponse.data.flightOffers.first;
    final presentageCommission = pricingResponse.presentageCommission;

    print('💰 Commission from response: $presentageCommission');
    print('💰 Grand Total: ${pricingOffer.price.grandTotal}');

    // Extract updated traveler pricing if available
    final updatedTravelerPricing = _extractUpdatedTravelerPricing(
      pricingOffer.travelerPricings,
    );

    final updatedOffer = original.copyWith(
      price: pricingOffer.price.grandTotalAsDouble,
      presentageCommission: presentageCommission,
      travellerPricing: updatedTravelerPricing.isNotEmpty
          ? updatedTravelerPricing
          : original.travellerPricing,
    );

    print('🎯 Final updated offer:');
    print('   - Price: ${updatedOffer.price}');
    print('   - Commission: ${updatedOffer.presentageCommission}%');
    print(
      '   - Traveler Pricing Count: ${updatedOffer.travellerPricing.length}',
    );

    return updatedOffer;
  }

  List<TravellerPricing> _extractUpdatedTravelerPricing(
    List<TravelerPricing> travelerPricings,
  ) {
    return travelerPricings.map((pricing) {
      // Convert from TravelerPricing to TravellerPricing
      return TravellerPricing(
        travelerType: pricing.travelerType,
        total: pricing.price.total,
        base: pricing.price.base,
        tax: calculateTotalTax(pricing.price.taxes),
        travelClass: pricing.fareDetailsBySegment.isNotEmpty
            ? pricing.fareDetailsBySegment.first.cabin
            : '',
        allowedBags: BaggageAllowance(quantity: '', weight: ''),
        cabinBagsAllowed: pricing.fareDetailsBySegment.isNotEmpty
            ? pricing.fareDetailsBySegment.first.includedCheckedBags.quantity
            : 0,
        fareDetails: pricing.fareDetailsBySegment.map((segment) {
          return FareDetail(
            segmentId: segment.segmentId,
            cabin: segment.cabin,
            fareBasis: segment.fareBasis,
            fareClass: segment.segmentClass,
            bagsAllowed: segment.includedCheckedBags.quantity.toString(),
            cabinBagsAllowed: segment.includedCheckedBags.quantity,
          );
        }).toList(),
      );
    }).toList();
  }

  void selectItinerary(int itineraryIndex) {
    if (itineraryIndex >= 0 &&
        itineraryIndex < state.flightOffer.itineraries.length) {
      emit(state.copyWith(selectedItineraryIndex: itineraryIndex));
    }
  }

  void toggleExpandedSection(SectionType section) {
    final newExpandedSections = Set<SectionType>.from(state.expandedSections);

    if (newExpandedSections.contains(section)) {
      newExpandedSections.remove(section);
    } else {
      newExpandedSections.add(section);
    }

    emit(state.copyWith(expandedSections: newExpandedSections));
  }

  void expandSection(SectionType section) {
    final newExpandedSections = Set<SectionType>.from(state.expandedSections);
    newExpandedSections.add(section);
    emit(state.copyWith(expandedSections: newExpandedSections));
  }

  void collapseSection(SectionType section) {
    final newExpandedSections = Set<SectionType>.from(state.expandedSections);
    newExpandedSections.remove(section);
    emit(state.copyWith(expandedSections: newExpandedSections));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void retryPricingUpdate() {
    clearError();
    updateFlightPricing();
  }

  @override
  Future<void> close() {
    // Clean up any resources if needed
    return super.close();
  }
}

enum SectionType { fareRules, baggage, pricing, segments }
