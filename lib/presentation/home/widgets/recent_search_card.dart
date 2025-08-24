// import 'package:flutter/material.dart';
// import 'package:tayyran_app/core/constants/color_constants.dart';
// import 'package:tayyran_app/presentation/home/model/recentsearch_model.dart';

// class RecentSearchCard extends StatelessWidget {
//   final RecentSearchModel ticket;
//   final VoidCallback? onTap;
//   final VoidCallback? onDelete;

//   const RecentSearchCard({
//     super.key,
//     required this.ticket,
//     this.onTap,
//     this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Airport icons
//               Column(
//                 children: [
//                   Icon(
//                     Icons.flight_takeoff,
//                     color: AppColors.splashBackgroundColorEnd,
//                     size: 20,
//                   ),
//                   const SizedBox(height: 8),
//                   Container(width: 2, height: 20, color: Colors.grey[300]),
//                   const SizedBox(height: 8),
//                   Icon(
//                     Icons.flight_land,
//                     color: AppColors.splashBackgroundColorStart,
//                     size: 20,
//                   ),
//                 ],
//               ),

//               const SizedBox(width: 16),

//               // Route details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // From -> To
//                     Row(
//                       children: [
//                         Text(
//                           _getAirportCode(ticket.from),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Icon(
//                           Icons.arrow_forward,
//                           color: Colors.grey[600],
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           _getAirportCode(ticket.to),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 4),

//                     // Airport names
//                     Text(
//                       '${_getAirportName(ticket.from)} → ${_getAirportName(ticket.to)}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),

//                     const SizedBox(height: 8),

//                     // Date and passengers
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today,
//                           color: Colors.grey[500],
//                           size: 14,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           ticket.date,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),

//                         const Spacer(),

//                         Icon(Icons.people, color: Colors.grey[500], size: 14),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${ticket.passengers} passenger${ticket.passengers > 1 ? 's' : ''}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),

//                     // Cabin class if available
//                     const SizedBox(height: 4),
//                     Text(
//                       'Class: ${ticket.flightClass}',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey[500],
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Delete button
//               if (onDelete != null) ...[
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
//                   onPressed: onDelete,
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _getAirportCode(String airportString) {
//     return airportString.split(' - ')[0];
//   }

//   String _getAirportName(String airportString) {
//     return airportString.split(' - ')[1];
//   }
// }
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/home/model/recentsearch_model.dart';

class RecentSearchCard extends StatelessWidget {
  final RecentSearchModel ticket;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RecentSearchCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon based on type
              Icon(
                ticket.type == 'flight' ? Icons.flight : Icons.hotel,
                color: ticket.type == 'flight'
                    ? AppColors.splashBackgroundColorEnd
                    : AppColors.splashBackgroundColorStart,
                size: 24,
              ),

              const SizedBox(width: 16),

              // Content based on type
              Expanded(
                child: ticket.type == 'flight'
                    ? _buildFlightContent(ticket)
                    : _buildStayContent(ticket),
              ),

              // Delete button
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightContent(RecentSearchModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // From -> To
        Row(
          children: [
            Text(
              _getAirportCode(ticket.from),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.grey[600], size: 16),
            const SizedBox(width: 8),
            Text(
              _getAirportCode(ticket.to),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Airport names
        Text(
          '${_getAirportName(ticket.from)} → ${_getAirportName(ticket.to)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Date and passengers
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[500], size: 14),
            const SizedBox(width: 4),
            Text(
              ticket.date.isNotEmpty ? ticket.date : 'No date',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            const Spacer(),

            Icon(Icons.people, color: Colors.grey[500], size: 14),
            const SizedBox(width: 4),
            Text(
              '${ticket.passengers} passenger${ticket.passengers > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),

        // Trip type and cabin class
        const SizedBox(height: 4),
        Row(
          children: [
            if (ticket.tripType != null && ticket.tripType!.isNotEmpty)
              Text(
                '${ticket.tripType!.capitalize()} • ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            Text(
              'Class: ${ticket.flightClass.isNotEmpty ? ticket.flightClass : 'Economy'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStayContent(RecentSearchModel ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destination
        Text(
          ticket.to,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        // Dates
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[500], size: 14),
            const SizedBox(width: 4),
            Text(
              '${ticket.date} - ${ticket.returnDate}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Guests and Rooms
        Row(
          children: [
            Icon(Icons.people, color: Colors.grey[500], size: 14),
            const SizedBox(width: 4),
            Text(
              '${ticket.passengers} guest${ticket.passengers > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Icon(Icons.hotel, color: Colors.grey[500], size: 14),
            const SizedBox(width: 4),
            Text(
              '${ticket.rooms ?? 1} room${(ticket.rooms ?? 1) > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  String _getAirportCode(String airportString) {
    if (airportString.isEmpty) return 'N/A';

    final parts = airportString.split(' - ');
    if (parts.isEmpty) return 'N/A';

    return parts[0]; // Return the code part (DXB, AUH, etc.)
  }

  String _getAirportName(String airportString) {
    if (airportString.isEmpty) return 'Not specified';

    final parts = airportString.split(' - ');
    if (parts.length < 2)
      return airportString; // Return the whole string if no separator

    return parts[1]; // Return the name part (Dubai International, etc.)
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
