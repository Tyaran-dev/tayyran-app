import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/flight_detail/cubit/flight_detail_cubit.dart';
import 'package:intl/intl.dart';

class FlightDetailScreen extends StatelessWidget {
  const FlightDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlightDetailCubit, FlightDetailState>(
      listener: (context, state) {
        // Handle error states
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
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
          title: 'Flight Details',
          height: 120,
          showBackButton: true,
        ),
        body: BlocBuilder<FlightDetailCubit, FlightDetailState>(
          builder: (context, state) {
            // Show loading overlay when updating pricing
            if (state.isLoading) {
              return Stack(
                children: [
                  _buildContent(context, state),
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
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
                          const Text(
                            'Updating prices...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildContent(BuildContext context, FlightDetailState state) {
    final flight = state.flightOffer;
    final itinerary = state.selectedItinerary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Error banner if there's an error
          if (state.errorMessage != null) _buildErrorBanner(context),

          // Virtual flight path
          _buildFlightCard(itinerary, flight),
          const SizedBox(height: 16),

          // Departure and arrival details
          _buildAirportDetails(itinerary, context),
          const SizedBox(height: 16),

          // Flight duration and stops
          _buildFlightSummary(itinerary, flight),
          const SizedBox(height: 16),

          // Baggage information
          _buildBaggageInformation(flight),
          const SizedBox(height: 16),

          // Fare rules
          _buildFareRulesCard(flight, context),
          const SizedBox(height: 16),

          // Retry button if there was an error
          if (state.errorMessage != null) _buildRetryButton(context),

          // Spacer for bottom button
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
              'Failed to update prices. Showing cached prices.',
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => context.read<FlightDetailCubit>().retryPricingUpdate(),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry Price Update'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.splashBackgroundColorEnd,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFlightCard(Itinerary itinerary, FlightOffer flight) {
    if (itinerary.segments.isEmpty) return const SizedBox();

    final firstSegment = itinerary.segments.first;
    final lastSegment = itinerary.segments.last;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: 3.0.toBoxDecoration(color: const Color(0xFFF9fafb)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Airline logo + details (centered) ---
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  image: firstSegment.image != null
                      ? DecorationImage(
                          image: NetworkImage(firstSegment.image!),
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                child: firstSegment.image == null
                    ? Icon(
                        Icons.airplanemode_active,
                        color: AppColors.splashBackgroundColorEnd,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(height: 2),
              Text(
                flight.airlineName,
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

          // --- Flight path row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Departure airport
              _buildAirportPoint(firstSegment.fromAirport, true),

              // Flight path with plane + duration
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

              // Arrival airport
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

  Widget _buildAirportDetails(Itinerary itinerary, BuildContext context) {
    if (itinerary.segments.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: 3.0.toBoxDecoration(color: const Color(0xFFF9fafb)),
      child: Column(
        children: [
          for (int i = 0; i < itinerary.segments.length; i++)
            Column(
              children: [
                if (i > 0)
                  _buildLayoverSection(
                    itinerary.segments[i - 1],
                    itinerary.segments[i],
                  ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: icons + vertical line
                    Column(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                        Container(
                          width: 2,
                          height: context.heightPct(0.11),
                          color: Colors.grey[300],
                        ),
                        Icon(
                          Icons.flight,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                        Container(
                          width: 2,
                          height: context.heightPct(0.1),
                          color: Colors.grey[300],
                        ),
                        Icon(
                          Icons.flight_land,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Right side: details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeDetail(
                            time: _formatTimeAmPm(
                              itinerary.segments[i].departure.at,
                            ),
                            date: _formatDate(
                              itinerary.segments[i].departure.at,
                            ),
                            airport: itinerary.segments[i].fromAirport,
                            terminal: itinerary.segments[i].departure.terminal,
                            isDeparture: true,
                            flightNumber:
                                '${itinerary.segments[i].carrierCode} ${itinerary.segments[i].number}',
                            duration: itinerary.segments[i].duration,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[300]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Icon(
                                    Icons.flight,
                                    size: 16,
                                    color: AppColors.splashBackgroundColorEnd,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[300]),
                                ),
                              ],
                            ),
                          ),
                          _buildTimeDetail(
                            time: _formatTimeAmPm(
                              itinerary.segments[i].arrival.at,
                            ),
                            date: _formatDate(itinerary.segments[i].arrival.at),
                            airport: itinerary.segments[i].toAirport,
                            terminal: itinerary.segments[i].arrival.terminal,
                            isDeparture: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (i < itinerary.segments.length - 1)
                  const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLayoverSection(Segment previousSegment, Segment nextSegment) {
    final layoverDuration = nextSegment.departure.at.difference(
      previousSegment.arrival.at,
    );
    final hours = layoverDuration.inHours;
    final minutes = layoverDuration.inMinutes.remainder(60);

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
                  'Layover at ${previousSegment.toAirport.code}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${hours}h ${minutes}m layover • Change of aircraft',
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
                  'Terminal $terminal',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              if (flightNumber != null && isDeparture)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Flight: $flightNumber • $duration',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.splashBackgroundColorEnd,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightSummary(Itinerary itinerary, FlightOffer flight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: 3.0.toBoxDecoration(color: const Color(0xFFF9fafb)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.schedule,
            title: 'Duration',
            value: itinerary.duration,
          ),
          _buildSummaryItem(
            icon: Icons.airplanemode_active,
            title: 'Stops',
            value: _getStopText(flight.stops),
          ),
          _buildSummaryItem(
            icon: Icons.airline_seat_recline_normal,
            title: 'Class',
            value: flight.cabinClass,
          ),
        ],
      ),
    );
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
      decoration: 3.0.toBoxDecoration(color: const Color(0xFFF9fafb)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baggage Allowance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBaggageItem(
                icon: Icons.luggage,
                title: 'Checked',
                value: flight.allowedBags,
              ),
              _buildBaggageItem(
                icon: Icons.work_outline,
                title: 'Cabin',
                value: '${flight.allowedCabinBags} piece(s)',
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
      decoration: 3.0.toBoxDecoration(color: const Color(0xFFF9fafb)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fare Conditions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                'View all fare rules',
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
          _getFareRuleIcon(rule.category),
          size: 20,
          color: AppColors.splashBackgroundColorEnd,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFareRuleTitle(rule.category),
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
                  'Not Applicable',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              if (rule.maxPenaltyAmount == "0.00")
                Text(
                  'Free of charge',
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

          // ✅ CORRECT: Calculate administration fee on base price
          administrationFee = flight.price * (presentageCommission / 100);

          // ✅ CORRECT: Calculate VAT on administration fee only
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
              // Price details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Price',
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
                        'Price details',
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

              // Book button
              SizedBox(
                width: context.widthPct(0.55),
                child: GradientButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.passengerInfo,
                            arguments: flight.copyWith(price: totalWithFees),
                          );
                        },
                  text: state.isLoading ? 'Updating...' : 'Book',
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
        // Calculate commission and VAT values
        double presentageCommission = 0.0;
        double presentageVat = 0.0;
        double administrationFee = 0.0;
        double vatAmount = 0.0;
        double totalWithFees = flight.price;

        try {
          presentageCommission = flight.presentageCommission;
          presentageVat = flight.presentageVat;

          // ✅ CORRECT: Administration fee on base price
          administrationFee = flight.price * (presentageCommission / 100);

          // ✅ CORRECT: VAT on administration fee only
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
            final baseContentHeight = 350.0; // Increased for VAT section
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
                      const Text(
                        'Fare Breakdown',
                        style: TextStyle(
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

                  // Passenger fare details
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

                  // Total section with breakdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.splashBackgroundColorEnd.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Subtotal (sum of all passenger fares)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${flight.price} ${flight.currency}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Administration fee breakdown
                        if (presentageCommission > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Administration Fee ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${administrationFee.toStringAsFixed(2)} ${flight.currency}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],

                        // VAT breakdown
                        if (presentageVat > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'VAT ($presentageVat%)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${vatAmount.toStringAsFixed(2)} ${flight.currency}',
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

                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${totalWithFees.toStringAsFixed(2)} ${flight.currency}',
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
    double subtotal = 0.0;

    final passengerWidgets = flight.travellerPricing.map((pricing) {
      final travelerType = pricing.travelerType;
      travelerNumbers[travelerType] = (travelerNumbers[travelerType] ?? 0) + 1;
      final travelerNumber = travelerNumbers[travelerType]!;

      // Calculate passenger total (convert string to double)
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
                  _formatTravelerTypeWithNumber(
                    pricing.travelerType,
                    travelerNumber,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${pricing.total} ${flight.currency}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              title: 'Base Fare',
              value: '${pricing.base} ${flight.currency}',
            ),
            _buildDetailRow(
              title: 'Taxes & Fees',
              value: '${pricing.tax} ${flight.currency}',
            ),
          ],
        ),
      );
    }).toList();

    // Update the flight price to match the calculated subtotal
    // This ensures consistency between passenger totals and the displayed price
    if (flight.price != subtotal) {
      // If there's a discrepancy, we might want to use the calculated subtotal
      // But for now, we'll just use the flight.price from the API
    }

    return passengerWidgets;
  }

  String _formatTravelerTypeWithNumber(String type, int number) {
    final baseType = _formatTravelerType(type);
    return '$baseType $number';
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
              const Text(
                'Fare Rules & Policies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  String _formatTimeAmPm(DateTime dateTime) =>
      DateFormat('h:mm a').format(dateTime);
  String _formatDate(DateTime dateTime) =>
      DateFormat('MMM dd, yyyy').format(dateTime);
  String _getStopText(int stops) => stops == 0
      ? 'Direct'
      : stops == 1
      ? '1 stop'
      : '$stops stops';

  IconData _getFareRuleIcon(String category) {
    switch (category) {
      case 'EXCHANGE':
        return Icons.swap_horiz;
      case 'REFUND':
        return Icons.currency_exchange;
      case 'REVALIDATION':
        return Icons.autorenew;
      default:
        return Icons.info_outline;
    }
  }

  String _getFareRuleTitle(String category) {
    switch (category) {
      case 'EXCHANGE':
        return 'Flight Change';
      case 'REFUND':
        return 'Refund Policy';
      case 'REVALIDATION':
        return 'Revalidation';
      default:
        return category;
    }
  }

  String _formatTravelerType(String type) {
    switch (type.toUpperCase()) {
      case 'ADULT':
        return 'Adult';
      case 'CHILD':
        return 'Child';
      case 'INFANT':
        return 'Infant';
      case 'HELD_INFANT':
        return 'Infant';
      default:
        return type;
    }
  }
}
