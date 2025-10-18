import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight_detail/cubit/flight_detail_cubit.dart';

class FlightDetailScreen extends StatelessWidget {
  const FlightDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlightDetailCubit, FlightDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'retry'.tr(),
                textColor: Colors.white,
                onPressed: () {
                  context.read<FlightDetailCubit>().retryPricingUpdate();
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: _getAppBarTitle(context),
          height: 120,
          showBackButton: true,
        ),
        body: BlocBuilder<FlightDetailCubit, FlightDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Stack(
                children: [
                  _buildContent(context, state),
                  _buildLoadingOverlay(),
                ],
              );
            }
            return _buildContent(context, state);
          },
        ),
        bottomNavigationBar: _buildBottomBookingBar(context),
      ),
    );
  }

  String _getAppBarTitle(BuildContext context) {
    final state = context.read<FlightDetailCubit>().state;
    switch (state.tripType) {
      case FlightTripType.roundTrip:
        return 'round_trip_details'.tr();
      case FlightTripType.multiCity:
        return 'multi_city_journey'.tr();
      case FlightTripType.oneWay:
        return 'flight_details'.tr();
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.splashBackgroundColorEnd,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'updating_prices'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FlightDetailState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (state.errorMessage != null) _buildErrorBanner(context),
          _buildTripTypeHeader(state),
          const SizedBox(height: 16),
          if (state.tripType == FlightTripType.multiCity)
            _buildMultiCityRouteOverview(state),
          const SizedBox(height: 16),
          ..._buildFlightSections(state),
          const SizedBox(height: 16),
          _buildAirportDetails(state),
          const SizedBox(height: 16),
          _buildFlightSummary(state),
          const SizedBox(height: 16),
          _buildBaggageInformation(state.flightOffer),
          const SizedBox(height: 16),
          _buildFareRulesCard(state.flightOffer, context),
          if (state.errorMessage != null) _buildRetryButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'failed_to_update_prices'.tr(),
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFlightSections(FlightDetailState state) {
    switch (state.tripType) {
      case FlightTripType.oneWay:
        return [
          _buildFlightSection(
            state.selectedOutboundItinerary,
            state,
            'flight'.tr(),
            Icons.flight_takeoff,
          ),
        ];
      case FlightTripType.roundTrip:
        return [
          _buildFlightSection(
            state.selectedOutboundItinerary,
            state,
            'outbound_flight'.tr(),
            Icons.flight_takeoff,
          ),
          const SizedBox(height: 24),
          _buildFlightSection(
            state.selectedReturnItinerary!,
            state,
            'return_flight'.tr(),
            Icons.flight_land,
          ),
        ];
      case FlightTripType.multiCity:
        return state.allItineraries.asMap().entries.map((entry) {
          final index = entry.key;
          final itinerary = entry.value;
          return Column(
            children: [
              if (index > 0) const SizedBox(height: 24),
              _buildFlightSection(
                itinerary,
                state,
                '${'flight'.tr()} ${index + 1}: ${itinerary.fromLocation} → ${itinerary.toLocation}',
                _getMultiCityIcon(index, state.allItineraries.length),
              ),
            ],
          );
        }).toList();
    }
  }

  IconData _getMultiCityIcon(int index, int total) {
    if (index == 0) return Icons.flight_takeoff;
    if (index == total - 1) return Icons.flight_land;
    return Icons.flight;
  }

  Widget _buildMultiCityRouteOverview(FlightDetailState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'journey_route'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.routeSummary,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.allItineraries.length} ${'flights'.tr()} • ${_calculateTotalDuration(state)} ${'total_duration'.tr()}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeHeader(FlightDetailState state) {
    Color getColor() {
      switch (state.tripType) {
        case FlightTripType.roundTrip:
          return Colors.blue;
        case FlightTripType.multiCity:
          return Colors.purple;
        case FlightTripType.oneWay:
          return Colors.green;
      }
    }

    String getText() {
      switch (state.tripType) {
        case FlightTripType.roundTrip:
          return 'round_trip'.tr();
        case FlightTripType.multiCity:
          return 'multi_city_flights'.tr(
            namedArgs: {'count': state.allItineraries.length.toString()},
          );
        case FlightTripType.oneWay:
          return 'one_way'.tr();
      }
    }

    IconData getIcon() {
      switch (state.tripType) {
        case FlightTripType.roundTrip:
          return Icons.swap_horiz;
        case FlightTripType.multiCity:
          return Icons.account_tree;
        case FlightTripType.oneWay:
          return Icons.arrow_forward;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getIcon(), color: getColor(), size: 16),
          const SizedBox(width: 8),
          Text(
            getText(),
            style: TextStyle(
              color: getColor(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSection(
    Itinerary itinerary,
    FlightDetailState state,
    String title,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.splashBackgroundColorEnd),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildFlightCard(itinerary, state),
      ],
    );
  }

  Widget _buildFlightCard(Itinerary itinerary, FlightDetailState state) {
    if (itinerary.segments.isEmpty) return const SizedBox();

    final firstSegment = itinerary.segments.first;
    final lastSegment = itinerary.segments.last;

    final airlineName = state.getAirlineNameForSegment(firstSegment);
    final airlineLogo = state.getAirlineLogoForSegment(firstSegment);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9fafb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  image: airlineLogo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(airlineLogo),
                          fit: BoxFit.contain,
                        )
                      : firstSegment.image != null
                      ? DecorationImage(
                          image: NetworkImage(firstSegment.image!),
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                child: airlineLogo.isEmpty && firstSegment.image == null
                    ? Icon(
                        Icons.airplanemode_active,
                        color: AppColors.splashBackgroundColorEnd,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(height: 2),
              Text(
                airlineName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Airbus A${firstSegment.aircraft?.code ?? "320"}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAirportPoint(firstSegment.fromAirport, true),
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.grey[300],
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: -6,
                          child: Center(
                            child: Icon(
                              Icons.flight,
                              size: 18,
                              color: AppColors.splashBackgroundColorEnd,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itinerary.duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAirportPoint(lastSegment.toAirport, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAirportPoint(Airport airport, bool isDeparture) {
    return Column(
      crossAxisAlignment: isDeparture
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          airport.code,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.splashBackgroundColorEnd,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            airport.city.split(' - ').first,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
            textAlign: isDeparture ? TextAlign.start : TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAirportDetails(FlightDetailState state) {
    return Column(
      children: [
        if (state.tripType == FlightTripType.multiCity) ...[
          ...state.allItineraries.asMap().entries.map((entry) {
            final index = entry.key;
            final itinerary = entry.value;
            return Column(
              children: [
                if (index > 0) const SizedBox(height: 24),
                _buildSingleItineraryDetails(
                  itinerary,
                  state,
                  '${'flight'.tr()} ${index + 1} ${'flight_details_title'.tr()}: ${itinerary.fromLocation} → ${itinerary.toLocation}',
                ),
              ],
            );
          }),
        ] else if (state.tripType == FlightTripType.roundTrip) ...[
          _buildSingleItineraryDetails(
            state.selectedOutboundItinerary,
            state,
            'outbound_journey_details'.tr(),
          ),
          const SizedBox(height: 24),
          _buildSingleItineraryDetails(
            state.selectedReturnItinerary!,
            state,
            'return_journey_details'.tr(),
          ),
        ] else ...[
          _buildSingleItineraryDetails(
            state.selectedOutboundItinerary,
            state,
            'flight_details_title'.tr(),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleItineraryDetails(
    Itinerary itinerary,
    FlightDetailState state,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9fafb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildItineraryDetails(itinerary, state),
        ],
      ),
    );
  }

  Widget _buildItineraryDetails(Itinerary itinerary, FlightDetailState state) {
    if (itinerary.segments.isEmpty) return const SizedBox();

    return Column(
      children: [
        for (int i = 0; i < itinerary.segments.length; i++)
          Column(
            children: [
              if (i > 0)
                _buildLayoverSection(
                  itinerary.segments[i - 1],
                  itinerary.segments[i],
                  state,
                ),
              _buildSegmentDetails(itinerary.segments[i], state),
              if (i < itinerary.segments.length - 1) const SizedBox(height: 20),
            ],
          ),
      ],
    );
  }

  Widget _buildSegmentDetails(Segment segment, FlightDetailState state) {
    final airlineName = state.getAirlineNameForSegment(segment);
    final airlineLogo = state.getAirlineLogoForSegment(segment);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: airlineLogo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(airlineLogo),
                        fit: BoxFit.contain,
                      )
                    : segment.image != null
                    ? DecorationImage(
                        image: NetworkImage(segment.image!),
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              child: airlineLogo.isEmpty && segment.image == null
                  ? Icon(
                      Icons.airplanemode_active,
                      color: AppColors.splashBackgroundColorEnd,
                      size: 20,
                    )
                  : null,
            ),
            Container(width: 2, height: 90, color: Colors.grey[300]),
            Icon(
              Icons.flight,
              color: AppColors.splashBackgroundColorEnd,
              size: 20,
            ),
            Container(width: 2, height: 90, color: Colors.grey[300]),
            Icon(
              Icons.flight_land,
              color: AppColors.splashBackgroundColorEnd,
              size: 20,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeDetail(
                time: formatTimeAmPm(segment.departure.at),
                date: formatDateFull(segment.departure.at),
                airport: segment.fromAirport,
                terminal: segment.departure.terminal,
                isDeparture: true,
                flightNumber: '${segment.carrierCode} ${segment.number}',
                duration: segment.duration,
                airlineName: airlineName,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.flight,
                        size: 16,
                        color: AppColors.splashBackgroundColorEnd,
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
              ),
              _buildTimeDetail(
                time: formatTimeAmPm(segment.arrival.at),
                date: formatDateFull(segment.arrival.at),
                airport: segment.toAirport,
                terminal: segment.arrival.terminal,
                isDeparture: false,
                airlineName: airlineName,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayoverSection(
    Segment previousSegment,
    Segment nextSegment,
    FlightDetailState state,
  ) {
    final layoverDuration = nextSegment.departure.at.difference(
      previousSegment.arrival.at,
    );
    final hours = layoverDuration.inHours;
    final minutes = layoverDuration.inMinutes.remainder(60);

    final nextAirlineName = state.getAirlineNameForSegment(nextSegment);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.splashBackgroundColorEnd.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            size: 20,
            color: AppColors.splashBackgroundColorEnd,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'layover_at'.tr(
                    namedArgs: {'airport': previousSegment.toAirport.code},
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hours}h ${minutes}m layover • ${'change_to'.tr(namedArgs: {'airline': nextAirlineName})}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail({
    required String time,
    required String date,
    required Airport airport,
    required String? terminal,
    required bool isDeparture,
    String? flightNumber,
    String? duration,
    String? airlineName,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                airport.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${airport.code} • ${airport.city.split(' - ').first}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (terminal != null)
                Text(
                  '${'terminal'.tr()} $terminal',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              if (flightNumber != null && isDeparture && airlineName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$airlineName • $flightNumber',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.splashBackgroundColorEnd,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${'duration'.tr()}: $duration',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightSummary(FlightDetailState state) {
    final totalDuration = _calculateTotalDuration(state);
    final totalStops = _calculateTotalStops(state);
    final totalFlights = _calculateTotalFlights(state);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9fafb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.schedule,
            title: 'total_duration_label'.tr(),
            value: totalDuration,
          ),
          _buildSummaryItem(
            icon: Icons.airplanemode_active,
            title: state.tripType == FlightTripType.multiCity
                ? 'total_flights'.tr()
                : 'total_stops'.tr(),
            value: state.tripType == FlightTripType.multiCity
                ? '$totalFlights ${'flights'.tr()}'
                : totalStops == 0
                ? 'direct'.tr()
                : '$totalStops ${'stops'.tr()}',
          ),
          _buildSummaryItem(
            icon: Icons.airline_seat_recline_normal,
            title: 'class'.tr(),
            value: state.flightOffer.cabinClass.toLowerCase().tr(),
          ),
        ],
      ),
    );
  }

  String _calculateTotalDuration(FlightDetailState state) {
    Duration totalDuration = Duration.zero;
    for (final itinerary in state.allItineraries) {
      if (itinerary.segments.isNotEmpty) {
        final firstSegment = itinerary.segments.first;
        final lastSegment = itinerary.segments.last;
        totalDuration += lastSegment.arrival.at.difference(
          firstSegment.departure.at,
        );
      }
    }

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  int _calculateTotalStops(FlightDetailState state) {
    int totalStops = 0;
    for (final itinerary in state.allItineraries) {
      totalStops += itinerary.segments.length - 1;
    }
    return totalStops;
  }

  int _calculateTotalFlights(FlightDetailState state) {
    return state.allItineraries.length;
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.splashBackgroundColorEnd),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBaggageInformation(FlightOffer flight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9fafb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'baggage_allowance'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBaggageItem(
                icon: Icons.luggage,
                title: 'checked'.tr(),
                value: flight.allowedBags,
              ),
              _buildBaggageItem(
                icon: Icons.work_outline,
                title: 'cabin'.tr(),
                value: '${flight.allowedCabinBags} ${'piece_s'.tr()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.splashBackgroundColorEnd),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFareRulesCard(FlightOffer flight, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9fafb),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'fare_conditions'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...flight.fareRules
              .take(flight.fareRules.length > 3 ? 3 : flight.fareRules.length)
              .map(
                (rule) => Column(
                  children: [
                    _buildFareRuleItem(rule),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
          if (flight.fareRules.length > 3)
            TextButton(
              onPressed: () => _showFareRulesBottomSheet(context, flight),
              child: Text(
                'view_all_fare_rules'.tr(),
                style: TextStyle(color: AppColors.splashBackgroundColorEnd),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFareRuleItem(FareRule rule) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          getFareRuleIcon(rule.category),
          size: 20,
          color: AppColors.splashBackgroundColorEnd,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getFareRuleTitle(rule.category),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              if (rule.maxPenaltyAmount != null &&
                  rule.maxPenaltyAmount != "0.00")
                Text(
                  'Fee: ${rule.maxPenaltyAmount} SAR',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              if (rule.notApplicable == true)
                Text(
                  'not_applicable'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              if (rule.maxPenaltyAmount == "0.00")
                Text(
                  'free_of_charge'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => context.read<FlightDetailCubit>().retryPricingUpdate(),
        icon: const Icon(Icons.refresh),
        label: Text('retry_price_update'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.splashBackgroundColorEnd,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBottomBookingBar(BuildContext context) {
    return BlocBuilder<FlightDetailCubit, FlightDetailState>(
      builder: (context, state) {
        final flight = state.flightOffer;

        double presentageCommission = 0.0;
        double presentageVat = 0.0;
        double administrationFee = 0.0;
        double vatAmount = 0.0;
        double totalWithFees = flight.price;

        try {
          presentageCommission = flight.presentageCommission;
          presentageVat = flight.presentageVat;
          administrationFee = flight.price * (presentageCommission / 100);
          vatAmount = administrationFee * (presentageVat / 100);
          totalWithFees = flight.price + administrationFee + vatAmount;
        } catch (e) {
          presentageCommission = 0.0;
          presentageVat = 0.0;
          administrationFee = 0.0;
          vatAmount = 0.0;
          totalWithFees = flight.price;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'total_price'.tr(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        if (state.isLoading)
                          const SizedBox(
                            width: 60,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Text(
                            totalWithFees.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.splashBackgroundColorEnd,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Image.asset(
                          AppAssets.currencyIcon,
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: state.isLoading
                          ? null
                          : () =>
                                _showFareBreakdownBottomSheet(context, flight),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(bottom: 15),
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'price_details'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: state.isLoading
                              ? Colors.grey[400]
                              : AppColors.splashBackgroundColorEnd,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: context.widthPct(0.55),
                child: GradientButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.passengerInfo,
                            arguments: TicketArguments(
                              flightOffer: flight.copyWith(
                                price: totalWithFees,
                              ),
                              filters: state.filters,
                            ),
                          );
                        },
                  text: state.isLoading ? 'updating'.tr() : 'book'.tr(),
                  height: 50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFareBreakdownBottomSheet(BuildContext context, FlightOffer flight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        double presentageCommission = 0.0;
        double presentageVat = 0.0;
        double administrationFee = 0.0;
        double vatAmount = 0.0;
        double totalWithFees = flight.price;

        try {
          presentageCommission = flight.presentageCommission;
          presentageVat = flight.presentageVat;
          administrationFee = flight.price * (presentageCommission / 100);
          vatAmount = administrationFee * (presentageVat / 100);
          totalWithFees = flight.price + administrationFee + vatAmount;
        } catch (e) {
          presentageCommission = 0.0;
          presentageVat = 0.0;
          administrationFee = 0.0;
          vatAmount = 0.0;
          totalWithFees = flight.price;
        }

        final travelerNumbers = <String, int>{};

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = MediaQuery.of(context).size.height * 0.8;
            final baseContentHeight = 350.0;
            final passengerContentHeight =
                flight.travellerPricing.length * 120.0;
            final contentHeight = baseContentHeight + passengerContentHeight;
            final calculatedHeight = contentHeight < maxHeight
                ? contentHeight
                : maxHeight;

            return Container(
              constraints: BoxConstraints(maxHeight: calculatedHeight),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Text(
                        'fare_breakdown'.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  flight.travellerPricing.length > 2
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _buildPassengerItems(
                                flight,
                                travelerNumbers,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildPassengerItems(
                            flight,
                            travelerNumbers,
                          ),
                        ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.splashBackgroundColorEnd.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'subtotal'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${flight.price.toStringAsFixed(2)} ${flight.currency.toLowerCase().tr()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (presentageCommission > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'administration_fee'.tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${administrationFee.toStringAsFixed(2)} ${flight.currency.toLowerCase().tr()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (presentageVat > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'vat'.tr(args: ['$presentageVat']),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${vatAmount.toStringAsFixed(2)} ${flight.currency.toLowerCase().tr()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${totalWithFees.toStringAsFixed(2)} ${flight.currency.toLowerCase().tr()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.splashBackgroundColorEnd,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPassengerItems(
    FlightOffer flight,
    Map<String, int> travelerNumbers,
  ) {
    // ignore: unused_local_variable
    double subtotal = 0.0;

    final passengerWidgets = flight.travellerPricing.map((pricing) {
      final travelerType = pricing.travelerType;
      travelerNumbers[travelerType] = (travelerNumbers[travelerType] ?? 0) + 1;
      final travelerNumber = travelerNumbers[travelerType]!;

      final passengerTotal = double.tryParse(pricing.total) ?? 0.0;
      subtotal += passengerTotal;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTravelerTypeWithNumber(
                    pricing.travelerType,
                    travelerNumber,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${pricing.total} ${flight.currency.toLowerCase().tr()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              title: 'base_fare'.tr(),
              value: '${pricing.base} ${flight.currency.toLowerCase().tr()}',
            ),
            _buildDetailRow(
              title: 'taxes_fees'.tr(),
              value:
                  '${pricing.tax.toStringAsFixed(2)} ${flight.currency.toLowerCase().tr()}',
            ),
          ],
        ),
      );
    }).toList();

    return passengerWidgets;
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    bool isSubItem = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: isSubItem ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isSubItem ? Colors.grey[600] : Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold
                  ? FontWeight.bold
                  : (isSubItem ? FontWeight.normal : FontWeight.w500),
              color: isSubItem ? Colors.grey[600] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showFareRulesBottomSheet(BuildContext context, FlightOffer flight) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'fare_rules_policies'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...flight.fareRules.map(
                (rule) => Column(
                  children: [
                    _buildFareRuleItem(rule),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
