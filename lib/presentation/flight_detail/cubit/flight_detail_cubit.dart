// lib/presentation/flight_detail/cubit/flight_detail_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

      final pricingResponse = await _pricingRepository.getFlightPricing(
        pricingData,
      );

      print('✅ Received pricing response');
      print('📋 Response success: ${pricingResponse['success']}');
      print('📋 Response message: ${pricingResponse['message']}');

      if (pricingResponse['success'] == true) {
        // Debug the full response structure
        _debugResponseStructure;
        print('🔍 Full response structure:');
        _printNestedMap(pricingResponse, '');

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

  void _debugResponseStructure(Map<String, dynamic> response) {
    print('🔍 Debugging API response structure:');

    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        print('📊 Data keys: ${data.keys.toList()}');

        if (data.containsKey('flightOffers')) {
          final flightOffers = data['flightOffers'];
          if (flightOffers is List && flightOffers.isNotEmpty) {
            final firstOffer = flightOffers[0];
            if (firstOffer is Map<String, dynamic>) {
              print('📦 Flight offer keys: ${firstOffer.keys.toList()}');

              if (firstOffer.containsKey('presentageCommission')) {
                print(
                  '✅ Found presentageCommission: ${firstOffer['presentageCommission']}',
                );
              } else {
                print('❌ presentageCommission not found in flight offer');
              }

              if (firstOffer.containsKey('price')) {
                final price = firstOffer['price'];
                if (price is Map<String, dynamic>) {
                  print('💰 Price keys: ${price.keys.toList()}');
                  print('💰 grandTotal: ${price['grandTotal']}');
                }
              }
            }
          }
        }
      }
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
    _printNestedMap(pricingData as Map<String, dynamic>, '');

    final priceData = pricingData['price'];
    if (priceData == null) {
      print('❌ No price data in flight offer');
      return original;
    }

    // SAFELY extract grandTotal
    final grandTotal =
        _safeParseDouble(priceData['grandTotal']) ?? original.price;
    print('💰 grandTotal: $grandTotal');

    // SAFELY extract presentageCommission - check multiple possible locations
    double presentageCommission = original.presentageCommission;

    // Check multiple possible locations for the commission
    if (pricingData.containsKey('presentageCommission')) {
      presentageCommission =
          _safeParseDouble(pricingData['presentageCommission']) ??
          original.presentageCommission;
      print(
        '✅ Found presentageCommission in flight offer: $presentageCommission',
      );
    } else if (data.containsKey('presentageCommission')) {
      presentageCommission =
          _safeParseDouble(data['presentageCommission']) ??
          original.presentageCommission;

      print('✅ Found presentageCommission in data: $presentageCommission');
    } else if (pricingResponse.containsKey('presentageCommission')) {
      presentageCommission =
          _safeParseDouble(pricingResponse['presentageCommission']) ??
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

  // Helper method to print nested map structure
  void _printNestedMap(Map<String, dynamic> map, String indent) {
    for (var entry in map.entries) {
      if (entry.value is Map<String, dynamic>) {
        print('$indent${entry.key}: {');
        _printNestedMap(entry.value as Map<String, dynamic>, '$indent  ');
        print('$indent}');
      } else if (entry.value is List) {
        print('$indent${entry.key}: [');
        final list = entry.value as List;
        if (list.isNotEmpty && list.first is Map<String, dynamic>) {
          _printNestedMap(list.first as Map<String, dynamic>, '$indent  ');
        } else if (list.isNotEmpty) {
          print('$indent  ${list.first}');
        }
        print('$indent]');
      } else {
        print('$indent${entry.key}: ${entry.value}');
      }
    }
  }

  // Helper method to safely parse double values
  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  List<TravellerPricing> _extractUpdatedTravelerPricing(
    List<dynamic> travelerPricings,
  ) {
    return travelerPricings.map((pricing) {
      final priceData = pricing['price'];

      // SAFELY extract values - handle both string and numeric values
      final total =
          _safeParseDouble(priceData?['total'])?.toString() ??
          (priceData?['total']?.toString() ?? '0');
      final base =
          _safeParseDouble(priceData?['base'])?.toString() ??
          (priceData?['base']?.toString() ?? '0');
      final tax = _safeParseDouble(priceData?['tax']) ?? 0.0;

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
