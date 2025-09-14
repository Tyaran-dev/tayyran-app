// lib/presentation/flight_detail/cubit/flight_detail_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';

part 'flight_detail_state.dart';

class FlightDetailCubit extends Cubit<FlightDetailState> {
  FlightDetailCubit(FlightOffer flightOffer)
    : super(FlightDetailState.initial(flightOffer));

  void selectItinerary(int itineraryIndex) {
    emit(state.copyWith(selectedItineraryIndex: itineraryIndex));
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
}

enum SectionType { fareRules, baggage, pricing, segments }
