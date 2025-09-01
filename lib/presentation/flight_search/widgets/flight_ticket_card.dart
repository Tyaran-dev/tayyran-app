// flight_ticket_card.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

class FlightTicketCard extends StatelessWidget {
  final FlightTicket ticket;

  const FlightTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            SizedBox(height: 16),

            // Flight Details
            _buildFlightDetails(),
            SizedBox(height: 16),

            // Seats Remaining and Tax Disclaimer
            _buildSeatsAndTaxInfo(),
            SizedBox(height: 16),

            // Book Now Button
            // _buildBookButton(),
          ],
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
            // Currency Icon (static SAR image placeholder)
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

  Widget _buildFlightDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Departure
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket.departureTime,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              _buildAirportText(ticket.from, true),
            ],
          ),
        ),

        // Flight Duration and Stops
        Column(
          children: [
            Text(
              ticket.duration,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 8),
            Image.asset(AppAssets.airplaneIcon, height: 35),
            SizedBox(height: 8),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ticket.isDirect ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ticket.isDirect
                    ? 'Direct'
                    : '${ticket.stops} stop${ticket.stops != 1 ? 's' : ''}',
                style: TextStyle(
                  color: ticket.isDirect ? Colors.green : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Arrival
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ticket.arrivalTime,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              _buildAirportText(ticket.to, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAirportText(String airportInfo, bool isFrom) {
    final parts = airportInfo.split(' - ');
    final code = parts.isNotEmpty ? parts[0] : '';
    final name = parts.length > 1 ? parts[1] : airportInfo;

    return Container(
      constraints: BoxConstraints(maxWidth: 100),
      child: Column(
        crossAxisAlignment: isFrom
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            code,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: isFrom ? TextAlign.left : TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsAndTaxInfo() {
    return Column(
      children: [
        // Seats Remaining
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.event_seat, size: 16, color: Colors.red),
            SizedBox(width: 6),
            Text(
              'Seats remaining: ${ticket.seatsRemaining ?? 9}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
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

  // Widget _buildBookButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: () {
  //         _showBookingOptions();
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: AppColors.splashBackgroundColorEnd,
  //         foregroundColor: Colors.white,
  //         padding: EdgeInsets.symmetric(vertical: 12),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //       child: Text(
  //         'Book Now',
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //       ),
  //     ),
  //   );
  // }

  // void _showBookingOptions() {
  //   // Booking options logic here
  // }
}
