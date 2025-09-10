// lib/presentation/flight_search/widgets/flight_ticket_card.dart (updated)
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

class FlightTicketCard extends StatelessWidget {
  final FlightTicket ticket;

  const FlightTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      // onTap: () {
      //   if (ticket.flightOffer != null) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) => BlocProvider(
      //           create: (_) => FlightDetailCubit(ticket.flightOffer!),
      //           child: FlightDetailScreen(),
      //         ),
      //       ),
      //     );
      //   }
      // },
      child: Card(
        color: Color(0xFFF9fafb),
        elevation: 3,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Airline Header
              _buildAirlineHeader(),
              SizedBox(height: 8),

              // NEW LAYOUT: Direction centered with arrow image
              _buildFlightDirectionWithArrow(context, isArabic),
              SizedBox(height: 16),

              // Flight Times and Dates
              _buildFlightTimesAndDates(isArabic),
              SizedBox(height: 16),

              // Seats Remaining and Tax Disclaimer
              _buildSeatsAndTaxInfo(),
              SizedBox(height: 16),

              // Book Now Button
              // _buildBookButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirlineHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(ticket.airlineLogo),
          radius: 16,
        ),
        SizedBox(width: 8),
        // Airline Name
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
              ticket.price.toStringAsFixed(0),
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

  Widget _buildFlightDirectionWithArrow(BuildContext context, bool isArabic) {
    // Extract airport codes for the main direction
    final fromParts = ticket.from.split(' - ');
    final toParts = ticket.to.split(' - ');
    final fromCode = fromParts.isNotEmpty ? fromParts[0] : '';
    final toCode = toParts.isNotEmpty ? toParts[0] : '';
    final fromCity = fromParts.length > 1 ? fromParts[1] : ticket.from;
    final toCity = toParts.length > 1 ? toParts[1] : ticket.to;

    return Column(
      children: [
        // Main Direction (Centered)
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
              child: Text(
                "→",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.splashBackgroundColorEnd,
                ),
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

        // Arrow image between departure and arrival
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Departure Airport Code
            Expanded(
              child: Text(
                fromCode,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Arrow icon
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                AppAssets.airplaneIcon,
                height: 50,
                width: 165,
              ),
            ),

            // Arrival Airport Code
            Expanded(
              child: Text(
                toCode,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlightTimesAndDates(bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Departure Time and Date
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

        // Flight Duration
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

        // Arrival Time and Date
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ticket.arrivalTime,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // if (ticket.arrivesNextDay)
                //   Padding(
                //     padding: EdgeInsets.only(left: 4),
                //     child: Text(
                //       isArabic ? '+١' : '+1',
                //       style: TextStyle(
                //         fontSize: 10,
                //         color: Colors.red,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
              ],
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
        // Seats Remaining
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
            // Tax Disclaimer
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
