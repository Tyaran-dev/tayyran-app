// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:tayyran_app/core/constants/app_assets.dart';
// import 'package:tayyran_app/core/constants/color_constants.dart';
// import 'package:tayyran_app/core/routes/route_names.dart';
// import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
// import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

// class FlightTicketCard extends StatelessWidget {
//   final FlightTicket ticket;

//   const FlightTicketCard({super.key, required this.ticket});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           RouteNames.flightDetail,
//           arguments: TicketArguments(
//             flightOffer: ticket.flightOffer,
//             filters: ticket.filterCarrier,
//           ),
//         );
//       },
//       child: Card(
//         color: Color(0xFFF9fafb),
//         elevation: 3,
//         margin: EdgeInsets.only(bottom: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             children: [
//               if (ticket.flightType == "multi") _buildPriceHeader(context),
//               SizedBox(height: 12),
//               if (ticket.flightType == "multi")
//                 _buildMultiCitySimpleLayout(context)
//               else
//                 _buildFlightDirectionWithArrow(context),

//               SizedBox(height: 16),
//               _buildSeatsAndTaxInfo(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceHeader(BuildContext context) {
//     return Row(
//       children: [
//         Spacer(),
//         SizedBox(width: 50),
//         // Multi-city badge
//         if (ticket.flightType == "multi")
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               color: AppColors.splashBackgroundColorEnd.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Text(
//               'multi_city_journey'.tr(),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.splashBackgroundColorEnd,
//               ),
//             ),
//           ),

//         Spacer(),

//         // Price with Currency Icon
//         Row(
//           children: [
//             Image.asset(AppAssets.currencyIcon, height: 25, width: 25),
//             SizedBox(width: 4),
//             Text(
//               _formatPriceForLocale(ticket.basePrice, context),
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 color: AppColors.splashBackgroundColorEnd,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // Simple Multi-City Layout
//   Widget _buildMultiCitySimpleLayout(BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';
//     final flightOffer = ticket.flightOffer;
//     final itineraries = flightOffer.itineraries;

//     if (itineraries.isEmpty) return SizedBox();

//     return Column(
//       children: [
//         // All flight segments
//         Column(
//           children: List.generate(itineraries.length, (index) {
//             final itinerary = itineraries[index];
//             final departure = itinerary.departure;
//             final isLast = index == itineraries.length - 1;
//             final firstSegment = itinerary.segments.isNotEmpty
//                 ? itinerary.segments[0]
//                 : null;
//             final airlineLogo = firstSegment?.image ?? '';

//             return Column(
//               children: [
//                 // Flight segment
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[300]!),
//                   ),
//                   child: Column(
//                     children: [
//                       // Airline and route
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Airline logo
//                           if (airlineLogo.isNotEmpty)
//                             CircleAvatar(
//                               backgroundColor: Colors.transparent,
//                               backgroundImage: NetworkImage(airlineLogo),
//                               radius: 16,
//                             ),
//                           SizedBox(width: 8),

//                           // Route and times
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: isArabic
//                                   ? CrossAxisAlignment.end
//                                   : CrossAxisAlignment.start,
//                               children: [
//                                 // From airport and time
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         itinerary.fromName,
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                         textAlign: isArabic
//                                             ? TextAlign.right
//                                             : TextAlign.left,
//                                       ),
//                                     ),
//                                     SizedBox(width: 8),
//                                     if (departure != null)
//                                       Column(
//                                         crossAxisAlignment: isArabic
//                                             ? CrossAxisAlignment.start
//                                             : CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             _formatTimeForLocale(
//                                               departure.departureTime,
//                                               context,
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             _formatDateForLocale(
//                                               departure.departureDate,
//                                               context,
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                   ],
//                                 ),

//                                 SizedBox(height: 8),

//                                 // Duration and stops
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Icon(
//                                       Icons.flight_takeoff,
//                                       size: 14,
//                                       color: Colors.grey,
//                                     ),
//                                     SizedBox(width: 4),
//                                     Text(
//                                       _formatDurationForLocale(
//                                         itinerary.duration,
//                                         context,
//                                       ),
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     SizedBox(width: 8),
//                                     Container(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: 6,
//                                         vertical: 2,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: departure?.stops == 0
//                                             ? Colors.green[50]
//                                             : Colors.orange[50],
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         _getStopText(
//                                           departure?.stops ?? 0,
//                                           context,
//                                         ),
//                                         style: TextStyle(
//                                           color: departure?.stops == 0
//                                               ? Colors.green
//                                               : Colors.orange,
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 SizedBox(height: 8),

//                                 // To airport and time
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         itinerary.toName,
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                         textAlign: isArabic
//                                             ? TextAlign.right
//                                             : TextAlign.left,
//                                       ),
//                                     ),
//                                     SizedBox(width: 8),
//                                     if (departure != null)
//                                       Column(
//                                         crossAxisAlignment: isArabic
//                                             ? CrossAxisAlignment.start
//                                             : CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             _formatTimeForLocale(
//                                               departure.arrivalTime,
//                                               context,
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             _formatDateForLocale(
//                                               departure.arrivalDate,
//                                               context,
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!isLast) ...[
//                   SizedBox(height: 16),
//                   // Connection time for multi-city
//                   if (index < itineraries.length - 1)
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.schedule, size: 14, color: Colors.blue),
//                           SizedBox(width: 4),
//                           Text(
//                             'connection_time'.tr(),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.blue[700],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   SizedBox(height: 16),
//                 ],
//               ],
//             );
//           }),
//         ),
//       ],
//     );
//   }

//   // Original one-way and round trip layout
//   Widget _buildFlightDirectionWithArrow(BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';
//     final fromParts = ticket.from.split(' - ');
//     final toParts = ticket.to.split(' - ');
//     final fromCode = fromParts.isNotEmpty ? fromParts[0] : '';
//     final toCode = toParts.isNotEmpty ? toParts[0] : '';
//     final fromCity = fromParts.length > 1 ? fromParts[1] : ticket.from;
//     final toCity = toParts.length > 1 ? toParts[1] : ticket.to;

//     return Column(
//       children: [
//         // Airline info for one-way/round trips
//         Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.transparent,
//               backgroundImage: NetworkImage(ticket.airlineLogo),
//               radius: 16,
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 ticket.airline,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             Spacer(),
//             // Price with Currency Icon
//             Row(
//               children: [
//                 Image.asset(AppAssets.currencyIcon, height: 25, width: 25),
//                 SizedBox(width: 4),
//                 Text(
//                   _formatPriceForLocale(ticket.basePrice, context),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: AppColors.splashBackgroundColorEnd,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         SizedBox(height: 12),

//         // Route
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 fromCity,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.normal,
//                   color: AppColors.splashBackgroundColorEnd,
//                 ),
//                 textAlign: isArabic ? TextAlign.right : TextAlign.left,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 5.0),
//               child: ticket.flightType == "round"
//                   ? Icon(
//                       Icons.sync,
//                       size: 16,
//                       color: AppColors.splashBackgroundColorEnd,
//                     )
//                   : Icon(
//                       isArabic ? Icons.arrow_back : Icons.arrow_forward,
//                       size: 16,
//                       color: AppColors.splashBackgroundColorEnd,
//                     ),
//             ),
//             Flexible(
//               child: Text(
//                 toCity,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.normal,
//                   color: AppColors.splashBackgroundColorEnd,
//                 ),
//                 textAlign: isArabic ? TextAlign.left : TextAlign.right,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 8),

//         // Airport codes with airplane
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Text(
//                 fromCode,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: isArabic ? TextAlign.right : TextAlign.left,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8),
//               child: Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.rotationY(isArabic ? 3.14159 : 0),
//                 child: Image.asset(
//                   AppAssets.airplaneIcon,
//                   height: 50,
//                   width: 165,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Text(
//                 toCode,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: isArabic ? TextAlign.left : TextAlign.right,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         _buildFlightTimesAndDates(context),
//       ],
//     );
//   }

//   Widget _buildFlightTimesAndDates(BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Column(
//           crossAxisAlignment: isArabic
//               ? CrossAxisAlignment.end
//               : CrossAxisAlignment.start,
//           children: [
//             Text(
//               _formatTimeForLocale(ticket.departureTime, context),
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 4),
//             Text(
//               _formatDateForLocale(ticket.departureDateFormatted, context),
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         Column(
//           children: [
//             Text(
//               _formatDurationForLocale(ticket.duration, context),
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//             SizedBox(height: 4),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: ticket.isDirect ? Colors.green[50] : Colors.orange[50],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 _getStopText(ticket.stops, context),
//                 style: TextStyle(
//                   color: ticket.isDirect ? Colors.green : Colors.orange,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Column(
//           crossAxisAlignment: isArabic
//               ? CrossAxisAlignment.start
//               : CrossAxisAlignment.end,
//           children: [
//             Text(
//               _formatTimeForLocale(ticket.arrivalTime, context),
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 4),
//             Text(
//               _formatDateForLocale(ticket.arrivalDateFormatted, context),
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   String _getStopText(int stops, BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';
//     final countText = isArabic
//         ? _convertToArabicNumerals(stops.toString())
//         : stops.toString();

//     if (stops == 0) {
//       return 'direct'.tr();
//     } else if (stops == 1) {
//       return 'one_stop'.tr();
//     } else {
//       return 'multiple_stops'.tr(namedArgs: {'count': countText});
//     }
//   }

//   Widget _buildSeatsAndTaxInfo(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Icon(Icons.event_seat, size: 16, color: Colors.black),
//             SizedBox(width: 6),
//             Text(
//               'seats_remaining'.tr(
//                 namedArgs: {
//                   'count': _formatNumberForLocale(
//                     ticket.seatsRemaining,
//                     context,
//                   ),
//                 },
//               ),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.black,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Spacer(),
//             Text(
//               'price_excludes_tax'.tr(),
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.splashBackgroundColorEnd,
//               ),
//             ),
//           ],
//         ),
//         // Additional info for multi-city flights
//         if (ticket.flightType == "multi" &&
//             ticket.flightSegments.length > 1) ...[
//           SizedBox(height: 8),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.blue[50],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.airline_seat_recline_extra,
//                   size: 14,
//                   color: Colors.blue,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   '${_formatNumberForLocale(ticket.flightSegments.length, context)} ${'flight_segments'.tr()}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // Format price with Arabic numerals if needed
//   String _formatPriceForLocale(double price, BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';

//     if (isArabic) {
//       return _convertToArabicNumerals(price.toStringAsFixed(0));
//     } else {
//       return price.toStringAsFixed(0);
//     }
//   }

//   // Format time with Arabic numerals if needed
//   String _formatTimeForLocale(String time, BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';

//     if (isArabic) {
//       return _convertTimeToArabicNumerals(time);
//     } else {
//       return time;
//     }
//   }

//   // Format date with Arabic numerals if needed
//   String _formatDateForLocale(String date, BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';

//     if (isArabic) {
//       return _convertDateToArabicNumerals(date);
//     } else {
//       return date;
//     }
//   }

//   // Format duration with Arabic numerals and Arabic units if needed
//   String _formatDurationForLocale(String duration, BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';

//     if (isArabic) {
//       return _convertDurationToArabicNumerals(duration);
//     } else {
//       return duration;
//     }
//   }

//   // Convert English numerals to Arabic numerals
//   String _convertToArabicNumerals(String input) {
//     const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
//     const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

//     String result = input;
//     for (int i = 0; i < english.length; i++) {
//       result = result.replaceAll(english[i], arabic[i]);
//     }
//     return result;
//   }

//   // Convert time string to Arabic numerals (e.g., "2:30 PM" → "٢:٣٠ م")
//   String _convertTimeToArabicNumerals(String time) {
//     // First convert numbers
//     String result = _convertToArabicNumerals(time);

//     // Then convert AM/PM to Arabic
//     result = result.replaceAll('AM', 'ص');
//     result = result.replaceAll('PM', 'م');
//     result = result.replaceAll('am', 'ص');
//     result = result.replaceAll('pm', 'م');

//     return result;
//   }

//   // Convert date string to Arabic numerals (e.g., "25 Dec 2024" → "٢٥ ديسمبر ٢٠٢٤")
//   String _convertDateToArabicNumerals(String date) {
//     // Convert numbers first
//     String result = _convertToArabicNumerals(date);

//     // Convert English month names to Arabic
//     result = result.replaceAll('Jan', 'يناير');
//     result = result.replaceAll('Feb', 'فبراير');
//     result = result.replaceAll('Mar', 'مارس');
//     result = result.replaceAll('Apr', 'أبريل');
//     result = result.replaceAll('May', 'مايو');
//     result = result.replaceAll('Jun', 'يونيو');
//     result = result.replaceAll('Jul', 'يوليو');
//     result = result.replaceAll('Aug', 'أغسطس');
//     result = result.replaceAll('Sep', 'سبتمبر');
//     result = result.replaceAll('Oct', 'أكتوبر');
//     result = result.replaceAll('Nov', 'نوفمبر');
//     result = result.replaceAll('Dec', 'ديسمبر');

//     // Full month names
//     result = result.replaceAll('January', 'يناير');
//     result = result.replaceAll('February', 'فبراير');
//     result = result.replaceAll('March', 'مارس');
//     result = result.replaceAll('April', 'أبريل');
//     result = result.replaceAll('May', 'مايو');
//     result = result.replaceAll('June', 'يونيو');
//     result = result.replaceAll('July', 'يوليو');
//     result = result.replaceAll('August', 'أغسطس');
//     result = result.replaceAll('September', 'سبتمبر');
//     result = result.replaceAll('October', 'أكتوبر');
//     result = result.replaceAll('November', 'نوفمبر');
//     result = result.replaceAll('December', 'ديسمبر');

//     return result;
//   }

//   // Convert duration string to Arabic numerals and Arabic units (e.g., "2h 30m" → "٢س ٣٠د")
//   String _convertDurationToArabicNumerals(String duration) {
//     // First convert numbers
//     String result = _convertToArabicNumerals(duration);

//     // Convert time units to Arabic
//     result = result.replaceAll('h', 'س'); // hour → ساعة
//     result = result.replaceAll('H', 'س'); // hour → ساعة
//     result = result.replaceAll('hr', 'س'); // hour → ساعة
//     result = result.replaceAll('hrs', 'س'); // hours → ساعة
//     result = result.replaceAll('hour', 'س'); // hour → ساعة
//     result = result.replaceAll('hours', 'س'); // hours → ساعة

//     result = result.replaceAll('m', 'د'); // minute → دقيقة
//     result = result.replaceAll('min', 'د'); // minute → دقيقة
//     result = result.replaceAll('mins', 'د'); // minutes → دقيقة
//     result = result.replaceAll('minute', 'د'); // minute → دقيقة
//     result = result.replaceAll('minutes', 'د'); // minutes → دقيقة

//     // Handle common duration formats
//     result = result.replaceAll('ساعة', 'س'); // Use abbreviated form
//     result = result.replaceAll('دقيقة', 'د'); // Use abbreviated form

//     // Handle space formatting for better appearance
//     result = result.replaceAll(' س ', 'س ');
//     result = result.replaceAll(' د ', 'د ');

//     return result;
//   }

//   String _formatNumberForLocale(int number, BuildContext context) {
//     final isArabic = context.locale.languageCode == 'ar';
//     return isArabic
//         ? _convertToArabicNumerals(number.toString())
//         : number.toString();
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/localization_helper.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight_search/models/flight_ticket_model.dart';

class FlightTicketCard extends StatelessWidget {
  final FlightTicket ticket;

  const FlightTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
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
              if (ticket.flightType == "multi") _buildPriceHeader(context),
              SizedBox(height: 12),
              if (ticket.flightType == "multi")
                _buildMultiCitySimpleLayout(context)
              else
                _buildFlightDirectionWithArrow(context),

              SizedBox(height: 16),
              _buildSeatsAndTaxInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceHeader(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        SizedBox(width: 50),
        // Multi-city badge
        if (ticket.flightType == "multi")
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.splashBackgroundColorEnd.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'multi_city_journey'.tr(),
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
              _formatPriceForLocale(ticket.basePrice, context),
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
  Widget _buildMultiCitySimpleLayout(BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);
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
                              crossAxisAlignment: isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // From airport and time
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        textAlign: isArabic
                                            ? TextAlign.right
                                            : TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (departure != null)
                                      Column(
                                        crossAxisAlignment: isArabic
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            LocalizationHelper.formatTimeStringLocalized(
                                              departure.departureTime,
                                              context,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            LocalizationHelper.formatDateStringLocalized(
                                              departure.departureDate,
                                              context,
                                            ),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.flight_takeoff,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      _formatDurationForLocale(
                                        itinerary.duration,
                                        context,
                                      ),
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
                                          context,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        textAlign: isArabic
                                            ? TextAlign.right
                                            : TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (departure != null)
                                      Column(
                                        crossAxisAlignment: isArabic
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            LocalizationHelper.formatTimeStringLocalized(
                                              departure.arrivalTime,
                                              context,
                                            ),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            LocalizationHelper.formatDateStringLocalized(
                                              departure.arrivalDate,
                                              context,
                                            ),
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
                if (!isLast) ...[
                  SizedBox(height: 16),
                  // Connection time for multi-city
                  if (index < itineraries.length - 1)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.blue),
                          SizedBox(width: 4),
                          Text(
                            'connection_time'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 16),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }

  // Original one-way and round trip layout
  Widget _buildFlightDirectionWithArrow(BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);
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
            Expanded(
              child: Text(
                ticket.airline,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Spacer(),
            // Price with Currency Icon
            Row(
              children: [
                Image.asset(AppAssets.currencyIcon, height: 25, width: 25),
                SizedBox(width: 4),
                Text(
                  _formatPriceForLocale(ticket.basePrice, context),
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
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
                      isArabic ? Icons.arrow_back : Icons.arrow_forward,
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
                textAlign: isArabic ? TextAlign.left : TextAlign.right,
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
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(isArabic ? 3.14159 : 0),
                child: Image.asset(
                  AppAssets.airplaneIcon,
                  height: 50,
                  width: 165,
                ),
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
                textAlign: isArabic ? TextAlign.left : TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildFlightTimesAndDates(context),
      ],
    );
  }

  Widget _buildFlightTimesAndDates(BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.formatTimeLocalized(
                ticket.departureDate,
                context,
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              LocalizationHelper.formatDateLocalized(
                ticket.departureDate,
                context,
              ),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Column(
          children: [
            Text(
              _formatDurationForLocale(ticket.duration, context),
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
                _getStopText(ticket.stops, context),
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
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              LocalizationHelper.formatTimeLocalized(
                ticket.arrivalDate,
                context,
              ),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              LocalizationHelper.formatDateLocalized(
                ticket.arrivalDate,
                context,
              ),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  String _getStopText(int stops, BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);
    final countText = isArabic
        ? LocalizationHelper.convertToArabicNumerals(stops.toString())
        : stops.toString();

    if (stops == 0) {
      return 'direct'.tr();
    } else if (stops == 1) {
      return 'one_stop'.tr();
    } else {
      return 'multiple_stops'.tr(namedArgs: {'count': countText});
    }
  }

  Widget _buildSeatsAndTaxInfo(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.event_seat, size: 16, color: Colors.black),
            SizedBox(width: 6),
            Text(
              'seats_remaining'.tr(
                namedArgs: {
                  'count': _formatNumberForLocale(
                    ticket.seatsRemaining,
                    context,
                  ),
                },
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Text(
              'price_excludes_tax'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
          ],
        ),
        // Additional info for multi-city flights
        if (ticket.flightType == "multi" &&
            ticket.flightSegments.length > 1) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.airline_seat_recline_extra,
                  size: 14,
                  color: Colors.blue,
                ),
                SizedBox(width: 4),
                Text(
                  '${_formatNumberForLocale(ticket.flightSegments.length, context)} ${'flight_segments'.tr()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Format price with Arabic numerals if needed
  String _formatPriceForLocale(double price, BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);

    if (isArabic) {
      return LocalizationHelper.convertToArabicNumerals(
        price.toStringAsFixed(0),
      );
    } else {
      return price.toStringAsFixed(0);
    }
  }

  // Format duration with Arabic numerals and Arabic units if needed
  String _formatDurationForLocale(String duration, BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);

    if (isArabic) {
      return _convertDurationToArabicNumerals(duration);
    } else {
      return duration;
    }
  }

  // Convert duration string to Arabic numerals and Arabic units
  String _convertDurationToArabicNumerals(String duration) {
    // First convert numbers
    String result = LocalizationHelper.convertToArabicNumerals(duration);

    // Convert time units to Arabic
    result = result.replaceAll('h', 'س'); // hour → ساعة
    result = result.replaceAll('H', 'س'); // hour → ساعة
    result = result.replaceAll('hr', 'س'); // hour → ساعة
    result = result.replaceAll('hrs', 'س'); // hours → ساعة
    result = result.replaceAll('hour', 'س'); // hour → ساعة
    result = result.replaceAll('hours', 'س'); // hours → ساعة

    result = result.replaceAll('m', 'د'); // minute → دقيقة
    result = result.replaceAll('min', 'د'); // minute → دقيقة
    result = result.replaceAll('mins', 'د'); // minutes → دقيقة
    result = result.replaceAll('minute', 'د'); // minute → دقيقة
    result = result.replaceAll('minutes', 'د'); // minutes → دقيقة

    // Handle space formatting for better appearance
    result = result.replaceAll(' س ', 'س ');
    result = result.replaceAll(' د ', 'د ');

    return result;
  }

  String _formatNumberForLocale(int number, BuildContext context) {
    final isArabic = LocalizationHelper.isArabic(context);
    return isArabic
        ? LocalizationHelper.convertToArabicNumerals(number.toString())
        : number.toString();
  }
}
