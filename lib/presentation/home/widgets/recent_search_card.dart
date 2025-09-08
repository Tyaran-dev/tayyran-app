import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/home/model/recentsearch_model.dart';

class RecentSearchCard extends StatelessWidget {
  final RecentSearchModel ticket;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;

  const RecentSearchCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: Colors.blue[40],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? AppColors.splashBackgroundColorStart
              : Colors.grey[300]!,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 40, 10),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ticket.type == 'flight'
                          ? AppColors.splashBackgroundColorEnd.withOpacity(0.1)
                          : AppColors.splashBackgroundColorStart.withOpacity(
                              0.1,
                            ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ticket.type == 'flight' ? Icons.flight : Icons.hotel,
                      color: ticket.type == 'flight'
                          ? AppColors.splashBackgroundColorEnd
                          : AppColors.splashBackgroundColorStart,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // From airport
                        _buildAirportRow(
                          code: _getAirportCode(ticket.from),
                          name: _getAirportName(ticket.from),
                          isFrom: true,
                        ),

                        const SizedBox(height: 6),

                        // To airport
                        _buildAirportRow(
                          code: _getAirportCode(ticket.to),
                          name: _getAirportName(ticket.to),
                          isFrom: false,
                        ),

                        const SizedBox(height: 8),

                        // Dates row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _buildDateText(ticket),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Passenger and class info
                        Wrap(
                          spacing: 40,
                          children: [
                            // Passengers
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: Colors.grey[600],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ticket.passengers} ${ticket.passengers > 1 ? 'Passengers' : 'Passenger'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),

                            // Cabin class
                            if (ticket.flightClass.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.airline_seat_recline_normal,
                                    color: Colors.grey[600],
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ticket.flightClass,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
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
            ),

            // Delete button positioned at center right, below second airport name
            if (onDelete != null)
              Positioned(
                top: 40,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500], size: 18),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportRow({
    required String code,
    required String name,
    required bool isFrom,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Airport code with direction icon next to it
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Airport code
            Container(
              width: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: isFrom ? Colors.blue[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isFrom ? Colors.blue[700] : Colors.green[700],
                ),
              ),
            ),

            const SizedBox(width: 4), // Small space between code and icon
            // Direction icon - now placed next to the airport code
            Icon(
              isFrom ? Icons.flight_takeoff : Icons.flight_land,
              color: isFrom ? Colors.blue : Colors.green,
              size: 16,
            ),
          ],
        ),

        const SizedBox(width: 8),

        // Airport name - takes remaining space
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _buildDateText(RecentSearchModel ticket) {
    if (ticket.date.isEmpty) return 'No date selected';

    final bool isRoundTrip = ticket.tripType?.toLowerCase() == 'round';
    if (isRoundTrip && ticket.returnDate.isNotEmpty) {
      return '${_formatDate(ticket.date)} - ${_formatDate(ticket.returnDate)}';
    }

    return _formatDate(ticket.date);
  }

  String _formatDate(String date) {
    if (date.length > 10) {
      return date.substring(0, 10);
    }
    return date;
  }

  String _getAirportCode(String airportString) {
    if (airportString.isEmpty) return 'N/A';
    final parts = airportString.split(' - ');
    if (parts.isEmpty) return 'N/A';
    return parts[0];
  }

  String _getAirportName(String airportString) {
    if (airportString.isEmpty) return 'Not specified';
    final parts = airportString.split(' - ');
    if (parts.length < 2) return airportString;
    return parts[1];
  }
}
