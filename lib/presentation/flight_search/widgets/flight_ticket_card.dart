import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

class FlightTicketCard extends StatelessWidget {
  final FlightTicket ticket;

  const FlightTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteNames.flightDetail,
          arguments: TicketArguments(
            flightOffer: ticket.flightOffer,
            filters: ticket.filterCarrier,
          ),
        );
      },
      child: Card(
        color: Color(0xFFF9fafb),
        elevation: 3,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (ticket.flightType == "multi") _buildPriceHeader(),
              SizedBox(height: 12),
              if (ticket.flightType == "multi")
                _buildMultiCitySimpleLayout(context, isArabic)
              else
                _buildFlightDirectionWithArrow(context, isArabic),

              SizedBox(height: 16),
              _buildSeatsAndTaxInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHeader() {
    return Row(
      children: [
        Spacer(),
        SizedBox(width: 50),
        // Multi-city badge
        if (ticket.flightType == "multi")
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.splashBackgroundColorEnd.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Multi-City Journey',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
          ),

        Spacer(),

        // Price with Currency Icon
        Row(
          children: [
            Image.asset(AppAssets.currencyIcon, height: 25, width: 25),
            SizedBox(width: 4),
            Text(
              ticket.basePrice.toStringAsFixed(0),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Simple Multi-City Layout
  Widget _buildMultiCitySimpleLayout(BuildContext context, bool isArabic) {
    final flightOffer = ticket.flightOffer;
    final itineraries = flightOffer.itineraries;

    if (itineraries.isEmpty) return SizedBox();

    return Column(
      children: [
        // All flight segments
        Column(
          children: List.generate(itineraries.length, (index) {
            final itinerary = itineraries[index];
            final departure = itinerary.departure;
            final isLast = index == itineraries.length - 1;
            final firstSegment = itinerary.segments.isNotEmpty
                ? itinerary.segments[0]
                : null;
            final airlineLogo = firstSegment?.image ?? '';
            return Column(
              children: [
                // Flight segment
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      // Airline and route
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Airline logo
                          if (airlineLogo.isNotEmpty)
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(airlineLogo),
                              radius: 16,
                            ),
                          SizedBox(width: 8),

                          // Route and times
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // From airport and time
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itinerary.fromName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (departure != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            departure.departureTime,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            departure.departureDate,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),

                                SizedBox(height: 8),

                                // Duration and stops
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flight_takeoff,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      itinerary.duration,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: departure?.stops == 0
                                            ? Colors.green[50]
                                            : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getStopText(
                                          departure?.stops ?? 0,
                                          isArabic,
                                        ),
                                        style: TextStyle(
                                          color: departure?.stops == 0
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8),

                                // To airport and time
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        itinerary.toName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (departure != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            departure.arrivalTime,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            departure.arrivalDate,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast) ...[SizedBox(height: 16)],
              ],
            );
          }),
        ),
      ],
    );
  }

  // Original one-way and round trip layout (unchanged)
  Widget _buildFlightDirectionWithArrow(BuildContext context, bool isArabic) {
    final fromParts = ticket.from.split(' - ');
    final toParts = ticket.to.split(' - ');
    final fromCode = fromParts.isNotEmpty ? fromParts[0] : '';
    final toCode = toParts.isNotEmpty ? toParts[0] : '';
    final fromCity = fromParts.length > 1 ? fromParts[1] : ticket.from;
    final toCity = toParts.length > 1 ? toParts[1] : ticket.to;

    return Column(
      children: [
        // Airline info for one-way/round trips
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(ticket.airlineLogo),
              radius: 16,
            ),
            SizedBox(width: 8),
            Text(
              ticket.airline,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Spacer(),
            // Price with Currency Icon
            Row(
              children: [
                Image.asset(AppAssets.currencyIcon, height: 25, width: 25),
                SizedBox(width: 4),
                Text(
                  ticket.basePrice.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),

        // Route
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                fromCity,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.splashBackgroundColorEnd,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ticket.flightType == "round"
                  ? Icon(
                      Icons.sync,
                      size: 16,
                      color: AppColors.splashBackgroundColorEnd,
                    )
                  : Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.splashBackgroundColorEnd,
                    ),
            ),
            Flexible(
              child: Text(
                toCity,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.splashBackgroundColorEnd,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),

        // Airport codes with airplane
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                fromCode,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                AppAssets.airplaneIcon,
                height: 50,
                width: 165,
              ),
            ),
            Expanded(
              child: Text(
                toCode,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildFlightTimesAndDates(isArabic),
      ],
    );
  }

  Widget _buildFlightTimesAndDates(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              ticket.departureTime,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              ticket.departureDateFormatted,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              ticket.duration,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ticket.isDirect ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStopText(ticket.stops, isArabic),
                style: TextStyle(
                  color: ticket.isDirect ? Colors.green : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              ticket.arrivalTime,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              ticket.arrivalDateFormatted,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  String _getStopText(int stops, bool isArabic) {
    if (stops == 0) {
      return isArabic ? 'مباشر' : 'Direct';
    } else if (stops == 1) {
      return isArabic ? 'توقف واحد' : '1 Stop';
    } else {
      return isArabic ? '$stops توقفات' : '$stops Stops';
    }
  }

  Widget _buildSeatsAndTaxInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.event_seat, size: 16, color: Colors.black),
            SizedBox(width: 6),
            Text(
              'Seats remaining: ${ticket.seatsRemaining}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Text(
              '* The price excludes tax',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
