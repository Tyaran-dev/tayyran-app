// lib/presentation/flight_detail/screens/flight_detail_screen.dart
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        title: 'Flight Details',
        height: 120,
        showBackButton: true,
      ),
      body: BlocBuilder<FlightDetailCubit, FlightDetailState>(
        builder: (context, state) {
          final flight = state.flightOffer;
          final itinerary = state.selectedItinerary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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

                // Spacer for bottom button
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBookingBar(context),
    );
  }

  Widget _buildFlightCard(Itinerary itinerary, FlightOffer flight) {
    if (itinerary.segments.isEmpty) return const SizedBox();

    final firstSegment = itinerary.segments.first;
    final lastSegment = itinerary.segments.last;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: 3.0.toBoxDecoration(color: Color(0xFFF9fafb)),
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
      decoration: 3.0.toBoxDecoration(color: Color(0xFFF9fafb)),
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
                          height: context.heightPct(
                            0.11,
                          ), // adjust length of line
                          color: Colors.grey[300],
                        ),
                        Icon(
                          Icons.flight,
                          color: AppColors.splashBackgroundColorEnd,
                        ),
                        Container(
                          width: 2,
                          height: context.heightPct(
                            0.1,
                          ), // adjust length of line
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
                            // icon: null, // handled on left side
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
                            // icon: null, // handled on left side
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
        color: AppColors.splashBackgroundColorEnd.withValues(
          alpha: 0.2,
        ), // Changed to light gray background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    // required IconData icon,
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
        // Icon(icon, size: 20, color: AppColors.splashBackgroundColorEnd),
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
      decoration: 3.0.toBoxDecoration(color: Color(0xFFF9fafb)),
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
            value: flight.cabinClass.toCabinClassDisplayName,
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
      decoration: 3.0.toBoxDecoration(color: Color(0xFFF9fafb)),
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

          // Show all if <= 3, otherwise show only 3
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

          // Show "View all" button only if more than 3
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
                  mainAxisSize:
                      MainAxisSize.min, // 👈 important to avoid overflow
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        Text(
                          '${flight.price}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.splashBackgroundColorEnd,
                          ),
                        ),
                        SizedBox(width: 10),
                        Image.asset(
                          AppAssets.currencyIcon,
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          _showFareBreakdownBottomSheet(context, flight),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(
                          bottom: 15,
                        ), // remove extra padding
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'Price details',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.splashBackgroundColorEnd,
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
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.passengerInfo,
                      arguments: flight,
                    );
                  },
                  text: 'Book',
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fare Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...flight.travellerPricing.map(
                (pricing) => Column(
                  children: [
                    _buildFareBreakdownRow(
                      '${pricing.travelerType} Fare',
                      '${pricing.total} ${flight.currency}',
                    ),
                    _buildFareBreakdownRow(
                      '  Base fare',
                      '${pricing.base} ${flight.currency}',
                      isSubItem: true,
                    ),
                    _buildFareBreakdownRow(
                      '  Taxes & fees',
                      '${pricing.tax} ${flight.currency}',
                      isSubItem: true,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const Divider(),
              _buildFareBreakdownRow(
                'Total',
                '${flight.price} ${flight.currency}',
                isTotal: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFareBreakdownRow(
    String title,
    String value, {
    bool isSubItem = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSubItem ? 2 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isSubItem ? Colors.grey[600] : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? AppColors.splashBackgroundColorEnd
                  : Colors.black,
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

  String _formatTimeAmPm(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  String _getStopText(int stops) {
    switch (stops) {
      case 0:
        return 'Direct';
      case 1:
        return '1 stop';
      default:
        return '$stops stops';
    }
  }

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
}
