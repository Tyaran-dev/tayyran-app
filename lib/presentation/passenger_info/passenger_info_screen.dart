// lib/presentation/passenger_info/passenger_info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/flight_detail/cubit/flight_detail_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/cubit/passenger_info_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/country_code_selection_bottom_sheet.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/passenger_card.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/passenger_form_bottom_sheet.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';

class PassengerInfoScreen extends StatelessWidget {
  const PassengerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PassengerInfoCubit, PassengerInfoState>(
      listener: (context, state) {
        // Handle error states
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'passengerInfo.retry'.tr(),
                textColor: Colors.white,
                onPressed: () {
                  context.read<PassengerInfoCubit>().retryPricingUpdate();
                },
              ),
            ),
          );
        }
        if (state.isSubmitted && !state.isLoading) {
          _navigateToPaymentScreen(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: 'passengerInfo.title'.tr(),
          height: 120,
          showBackButton: true,
        ),
        body: BlocBuilder<PassengerInfoCubit, PassengerInfoState>(
          builder: (context, state) {
            return buildContent(context, state);
          },
        ),
        bottomNavigationBar: _buildBottomBookingBar(context),
      ),
    );
  }

  Widget buildContent(BuildContext context, PassengerInfoState state) {
    final cubit = context.read<PassengerInfoCubit>();

    // Initialize pricing when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.updateFlightPricing();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner if there's an error
          if (state.errorMessage != null) _buildErrorBanner(context),

          // Trip type indicator
          Center(child: _buildTripTypeHeader(state)),
          const SizedBox(height: 16),

          // Flight summary
          buildFlightSummary(context, state),
          const SizedBox(height: 24),

          // Passenger list title
          Text(
            '${'passengerInfo.passengers'.tr()} (${state.passengers.length})',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackgroundColorEnd,
            ),
          ),
          const SizedBox(height: 16),

          // Passenger cards list
          buildPassengerCards(context, state),
          const SizedBox(height: 20),

          // Contact information
          buildContactInformation(context, state),
          const SizedBox(height: 30),
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
              'passengerInfo.priceUpdateFailed'.tr(),
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeHeader(PassengerInfoState state) {
    final tripType = _determineTripType(state.currentFlightOffer);

    Color getColor() {
      switch (tripType) {
        case FlightTripType.roundTrip:
          return Colors.blue;
        case FlightTripType.multiCity:
          return Colors.purple;
        case FlightTripType.oneWay:
          return Colors.green;
      }
    }

    String getText() {
      switch (tripType) {
        case FlightTripType.roundTrip:
          return 'passengerInfo.tripTypes.roundTrip'.tr();
        case FlightTripType.multiCity:
          return 'passengerInfo.tripTypes.multiCity'.tr(
            args: [state.currentFlightOffer.itineraries.length.toString()],
          );
        case FlightTripType.oneWay:
          return 'passengerInfo.tripTypes.oneWay'.tr();
      }
    }

    IconData getIcon() {
      switch (tripType) {
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
        color: getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getColor().withValues(alpha: 0.3)),
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

  FlightTripType _determineTripType(FlightOffer flightOffer) {
    // Method 1: Check mapping for multi-city pattern
    final mapping = flightOffer.mapping;
    final hasMultipleCities = mapping.split('||').length > 2;

    // Method 2: Check if it's truly multi-city by analyzing the itineraries
    final isTrueMultiCity = _isTrueMultiCity(flightOffer);

    // Method 3: Check if we have multiple unique origins/destinations
    final hasMultipleOriginsDestinations = _hasMultipleOriginsDestinations(
      flightOffer,
    );

    // Method 4: Check if this is a complex route (not simple round trip)
    final isComplexRoute = _isComplexRoute(flightOffer);

    print('🔍 PassengerInfo - Trip Type Detection:');
    print('   - Mapping: $mapping');
    print('   - Has multiple cities in mapping: $hasMultipleCities');
    print('   - Is true multi-city: $isTrueMultiCity');
    print(
      '   - Has multiple origins/destinations: $hasMultipleOriginsDestinations',
    );
    print('   - Is complex route: $isComplexRoute');
    print('   - Backend flightType: ${flightOffer.flightType}');
    print('   - Number of itineraries: ${flightOffer.itineraries.length}');

    if (hasMultipleCities ||
        isTrueMultiCity ||
        hasMultipleOriginsDestinations ||
        isComplexRoute) {
      print('🎯 Detected as: Multi-City');
      return FlightTripType.multiCity;
    } else if (flightOffer.itineraries.length > 1) {
      print('🎯 Detected as: Round Trip');
      return FlightTripType.roundTrip;
    } else {
      print('🎯 Detected as: One Way');
      return FlightTripType.oneWay;
    }
  }

  bool _isTrueMultiCity(FlightOffer flightOffer) {
    if (flightOffer.itineraries.length <= 2) return false;
    return flightOffer.itineraries.length > 2;
  }

  bool _hasMultipleOriginsDestinations(FlightOffer flightOffer) {
    final Set<String> origins = {};
    final Set<String> destinations = {};

    for (final itinerary in flightOffer.itineraries) {
      origins.add(itinerary.fromLocation);
      destinations.add(itinerary.toLocation);
    }

    print('   - Unique origins: $origins');
    print('   - Unique destinations: $destinations');

    return origins.length > 2 || destinations.length > 2;
  }

  bool _isComplexRoute(FlightOffer flightOffer) {
    if (flightOffer.itineraries.length < 2) return false;

    final firstItinerary = flightOffer.itineraries.first;
    final lastItinerary = flightOffer.itineraries.last;

    final isSimpleRoundTrip =
        firstItinerary.fromLocation == lastItinerary.toLocation &&
        firstItinerary.toLocation == lastItinerary.fromLocation;

    print('   - Is simple round trip: $isSimpleRoundTrip');

    return !isSimpleRoundTrip;
  }

  String _getRouteSummary(FlightOffer flightOffer) {
    final tripType = _determineTripType(flightOffer);

    switch (tripType) {
      case FlightTripType.oneWay:
        return '${flightOffer.fromLocation} → ${flightOffer.toLocation}';
      case FlightTripType.roundTrip:
        return '${flightOffer.fromLocation} → ${flightOffer.toLocation} → ${flightOffer.fromLocation}';
      case FlightTripType.multiCity:
        final cities = <String>[];
        for (final itinerary in flightOffer.itineraries) {
          if (cities.isEmpty || cities.last != itinerary.fromLocation) {
            cities.add(itinerary.fromLocation);
          }
          cities.add(itinerary.toLocation);
        }
        return cities.join(' → ');
    }
  }

  Widget buildFlightSummary(BuildContext context, PassengerInfoState state) {
    final flightOffer = state.currentFlightOffer;
    final tripType = _determineTripType(flightOffer);

    if (tripType == FlightTripType.multiCity) {
      return _buildMultiCityFlightSummary(context, state);
    } else if (tripType == FlightTripType.roundTrip) {
      return _buildRoundTripFlightSummary(context, state);
    } else {
      return _buildOneWayFlightSummary(context, state);
    }
  }

  Widget _buildRoundTripFlightSummary(
    BuildContext context,
    PassengerInfoState state,
  ) {
    final flightOffer = state.currentFlightOffer;
    final cubit = context.read<PassengerInfoCubit>();

    final outboundItinerary = flightOffer.itineraries[0];
    final returnItinerary = flightOffer.itineraries[1];

    final outboundSegment = outboundItinerary.segments.isNotEmpty
        ? outboundItinerary.segments.first
        : null;
    final returnSegment = returnItinerary.segments.isNotEmpty
        ? returnItinerary.segments.first
        : null;
    final currentLang = getCurrentLang(context);

    // Get airline info for each segment
    final outboundAirlineName = outboundSegment != null
        ? cubit.getAirlineNameForSegment(outboundSegment, currentLang)
        : flightOffer.airlineName;
    final outboundAirlineLogo = outboundSegment != null
        ? cubit.getAirlineLogoForSegment(outboundSegment)
        : flightOffer.airlineLogo;

    final returnAirlineName = returnSegment != null
        ? cubit.getAirlineNameForSegment(returnSegment, currentLang)
        : flightOffer.airlineName;
    final returnAirlineLogo = returnSegment != null
        ? cubit.getAirlineLogoForSegment(returnSegment)
        : flightOffer.airlineLogo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: outboundAirlineLogo.isNotEmpty
                        ? NetworkImage(outboundAirlineLogo)
                        : null,
                    radius: 20,
                    child: outboundAirlineLogo.isEmpty
                        ? Icon(
                            Icons.airplanemode_active,
                            color: AppColors.splashBackgroundColorEnd,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cubit.displayAirlineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'passengerInfo.tripTypes.roundTrip'.tr(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                AppAssets.ticketLogo,
                width: 65,
                height: 65,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Outbound Flight
          _buildFlightSegment(
            itinerary: outboundItinerary,
            segment: outboundSegment,
            title: 'passengerInfo.flightSegments.outbound'.tr(),
            icon: Icons.flight_takeoff,
            airlineName: outboundAirlineName,
            airlineLogo: outboundAirlineLogo,
          ),

          const SizedBox(height: 16),

          // Return Flight
          _buildFlightSegment(
            itinerary: returnItinerary,
            segment: returnSegment,
            title: 'passengerInfo.flightSegments.return'.tr(),
            icon: Icons.flight_land,
            airlineName: returnAirlineName,
            airlineLogo: returnAirlineLogo,
          ),

          const SizedBox(height: 16),

          // Flight details summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.totalDuration'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    _calculateTotalDuration(flightOffer),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.class'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    flightOffer.cabinClass.toLowerCase().tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.passengers'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${getTotalPassengers(flightOffer)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiCityFlightSummary(
    BuildContext context,
    PassengerInfoState state,
  ) {
    final flightOffer = state.currentFlightOffer;
    final cubit = context.read<PassengerInfoCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3CC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'passengerInfo.flightSummary.multiCityJourney'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRouteSummary(flightOffer),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                AppAssets.ticketLogo,
                width: 65,
                height: 65,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flight segments
          ...flightOffer.itineraries.asMap().entries.map((entry) {
            final index = entry.key;
            final itinerary = entry.value;
            final firstSegment = itinerary.segments.isNotEmpty
                ? itinerary.segments.first
                : null;
            final currentLang = getCurrentLang(context);
            final airlineName = firstSegment != null
                ? cubit.getAirlineNameForSegment(firstSegment, currentLang)
                : flightOffer.airlineName;
            final airlineLogo = firstSegment != null
                ? cubit.getAirlineLogoForSegment(firstSegment)
                : flightOffer.airlineLogo;

            return Column(
              children: [
                if (index > 0) const SizedBox(height: 12),
                _buildMultiCitySegment(
                  itinerary,
                  firstSegment,
                  index + 1,
                  airlineName,
                  airlineLogo,
                ),
                if (index < flightOffer.itineraries.length - 1)
                  const Divider(height: 20),
              ],
            );
          }),

          const SizedBox(height: 16),

          // Flight details summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.totalFlights'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${flightOffer.itineraries.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.class'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    flightOffer.cabinClass.toLowerCase().tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.passengers'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${getTotalPassengers(flightOffer)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOneWayFlightSummary(
    BuildContext context,
    PassengerInfoState state,
  ) {
    final flightOffer = state.currentFlightOffer;
    final cubit = context.read<PassengerInfoCubit>();

    final firstItinerary = flightOffer.itineraries.isNotEmpty
        ? flightOffer.itineraries.first
        : Itinerary.empty();
    final firstSegment = firstItinerary.segments.isNotEmpty
        ? firstItinerary.segments.first
        : null;

    // Get airline info
    final currentLang = getCurrentLang(context);
    final airlineName = firstSegment != null
        ? cubit.getAirlineNameForSegment(firstSegment, currentLang)
        : flightOffer.airlineName;
    final airlineLogo = firstSegment != null
        ? cubit.getAirlineLogoForSegment(firstSegment)
        : flightOffer.airlineLogo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3CC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Airline header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: airlineLogo.isNotEmpty
                        ? NetworkImage(airlineLogo)
                        : null,
                    radius: 20,
                    child: airlineLogo.isEmpty
                        ? Icon(
                            Icons.airplanemode_active,
                            color: AppColors.splashBackgroundColorEnd,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airlineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'passengerInfo.tripTypes.oneWay'.tr(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                AppAssets.ticketLogo,
                width: 65,
                height: 65,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flight route
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstItinerary.fromAirport.code,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    firstItinerary.fromAirport.city.split(' - ').first,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      AppAssets.airplaneIcon,
                      height: 50,
                      width: context.widthPct(0.60),
                    ),
                  ),
                  Text(
                    firstItinerary.duration,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    firstItinerary.toAirport.code,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    firstItinerary.toAirport.city.split(' - ').first,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flight details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.date'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    formatDate(firstSegment?.departure.at ?? DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.class'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    flightOffer.cabinClass.toLowerCase().tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'passengerInfo.flightSummary.passengers'.tr(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${getTotalPassengers(flightOffer)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSegment({
    required Itinerary itinerary,
    required Segment? segment,
    required String title,
    required IconData icon,
    required String airlineName,
    required String airlineLogo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3CC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Segment header
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.splashBackgroundColorEnd),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                formatDate(segment?.departure.at ?? DateTime.now()),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Airline info
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: airlineLogo.isNotEmpty
                    ? NetworkImage(airlineLogo)
                    : null,
                radius: 12,
                child: airlineLogo.isEmpty
                    ? Icon(
                        Icons.airplanemode_active,
                        color: AppColors.splashBackgroundColorEnd,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                airlineName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Flight route
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary.fromAirport.code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    _formatTime(segment?.departure.at ?? DateTime.now()),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.flight,
                    size: 16,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                  Text(
                    itinerary.duration,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    itinerary.toAirport.code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    _formatTime(segment?.arrival.at ?? DateTime.now()),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${segment?.carrierCode ?? ''}${segment?.number ?? ''} • ${itinerary.segments.length} ${itinerary.segments.length > 1 ? 'segments' : 'segment'}',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiCitySegment(
    Itinerary itinerary,
    Segment? firstSegment,
    int flightNumber,
    String airlineName,
    String airlineLogo,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flight number
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.splashBackgroundColorEnd,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$flightNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline and flight number
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: airlineLogo.isNotEmpty
                        ? NetworkImage(airlineLogo)
                        : firstSegment?.image != null
                        ? NetworkImage(firstSegment!.image!)
                        : null,
                    radius: 12,
                    child: airlineLogo.isEmpty && firstSegment?.image == null
                        ? Icon(
                            Icons.airplanemode_active,
                            color: AppColors.splashBackgroundColorEnd,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    airlineName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${firstSegment?.carrierCode ?? ''}${firstSegment?.number ?? ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Route and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itinerary.fromAirport.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        _formatTime(
                          firstSegment?.departure.at ?? DateTime.now(),
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.flight,
                        size: 16,
                        color: AppColors.splashBackgroundColorEnd,
                      ),
                      Text(
                        itinerary.duration,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        itinerary.toAirport.code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        _formatTime(firstSegment?.arrival.at ?? DateTime.now()),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${formatDate(firstSegment?.departure.at ?? DateTime.now())} • ${itinerary.segments.length} ${itinerary.segments.length > 1 ? 'segments' : 'segment'}',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  String _calculateTotalDuration(FlightOffer flightOffer) {
    Duration totalDuration = Duration.zero;
    for (final itinerary in flightOffer.itineraries) {
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

  Widget buildPassengerCards(BuildContext context, PassengerInfoState state) {
    final cubit = context.read<PassengerInfoCubit>();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.passengers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final passenger = state.passengers[index];
        return PassengerCard(
          passenger: passenger,
          index: index,
          onEdit: () => showPassengerFormBottomSheet(context, index, cubit),
        );
      },
    );
  }

  void showPassengerFormBottomSheet(
    BuildContext context,
    int passengerIndex,
    PassengerInfoCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PassengerFormBottomSheet(
            passengerIndex: passengerIndex,
            cubit: cubit,
          ),
        );
      },
    );
  }

  Widget buildContactInformation(
    BuildContext context,
    PassengerInfoState state,
  ) {
    final cubit = context.read<PassengerInfoCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'passengerInfo.contactInfo.title'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackgroundColorEnd,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            initialValue: state.contactEmail,
            decoration: InputDecoration(
              labelText: 'passengerInfo.contactInfo.email'.tr(),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(
                Icons.email,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => cubit.updateContactEmail(value),
          ),
          const SizedBox(height: 16),

          // Phone Number with Country Code
          Row(
            children: [
              // Country Code
              SizedBox(
                width: 140,
                child: InkWell(
                  onTap: () => _showCountryCodeSelection(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'passengerInfo.contactInfo.countryCode'.tr(),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.countryCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Phone Number
              Expanded(
                child: TextFormField(
                  initialValue: state.contactPhone,
                  decoration: InputDecoration(
                    labelText: 'passengerInfo.contactInfo.phone'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.updateContactPhone(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCountryCodeSelection(BuildContext context) {
    // Store the cubit reference before the async gap
    final cubit = context.read<PassengerInfoCubit>();
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => const CountryCodeSelectionBottomSheet(),
    ).then((selectedCountry) {
      // This callback runs after the async operation, but we use the stored cubit reference
      if (selectedCountry != null && context.mounted) {
        cubit.updateCountryCode(selectedCountry['dial_code']!);
      }
    });
  }

  void _navigateToPaymentScreen(BuildContext context) {
    final cubit = context.read<PassengerInfoCubit>();
    final state = cubit.state;

    cubit.resetSubmission();

    final flightOffer = state.currentFlightOffer;
    final grandTotal = state.grandTotal ?? state.currentFlightOffer.price;
    final paymentArgs = PaymentArguments(
      amount: grandTotal,
      email: state.contactEmail,
      phoneNumber: state.contactPhone,
      countryCode: state.countryCode,
      flightOffer: flightOffer,
      passengers: state.passengers,
      pricingResponse: state.pricingResponse!,
    );

    Navigator.pushReplacementNamed(
      context,
      RouteNames.payment,
      arguments: paymentArgs,
    );
  }

  void _handleContinueToPayment(BuildContext context) {
    final cubit = context.read<PassengerInfoCubit>();

    // Validate all passenger data before proceeding
    if (validateAllPassengers(cubit.state.passengers)) {
      cubit.submitPassengerInfo();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passengerInfo.validation.fillAllInfo'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildBottomBookingBar(BuildContext context) {
    return BlocBuilder<PassengerInfoCubit, PassengerInfoState>(
      builder: (context, state) {
        final grandTotal = state.grandTotal ?? state.currentFlightOffer.price;

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
              // Price details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'passengerInfo.totalPrice'.tr(),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (state.isLoading)
                          const SizedBox(
                            width: 60,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.splashBackgroundColorEnd,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          // Wrap price text in Flexible + FittedBox to prevent overflow
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                grandTotal.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.splashBackgroundColorEnd,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        Image.asset(
                          AppAssets.currencyIcon,
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Continue button
              SizedBox(
                width: context.widthPct(0.55),
                child: GradientButton(
                  onPressed: state.isFormValid && !state.isLoading
                      ? () => _handleContinueToPayment(context)
                      : null,
                  text: state.isLoading
                      ? 'passengerInfo.updating'.tr()
                      : 'passengerInfo.continueToPayment'.tr(),
                  height: 50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
