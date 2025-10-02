// // lib/presentation/payment_status/payment_status_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/data/models/payment_status_response.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';
import 'package:tayyran_app/presentation/payment_status/cubit/payment_status_cubit.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String invoiceId;
  final PaymentArguments args;

  const PaymentStatusScreen({
    super.key,
    required this.invoiceId,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PaymentStatusCubit(getIt<PaymentRepository>(), invoiceId, args),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: 'Payment Status',
          height: 120,
          showBackButton: false,
        ),
        body: BlocBuilder<PaymentStatusCubit, PaymentStatusState>(
          builder: (context, state) {
            return _buildStatusContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context, PaymentStatusState state) {
    if (state is PaymentStatusChecking || state is PaymentStatusInitial) {
      return _buildCheckingStatus(context);
    } else if (state is PaymentStatusPending) {
      return _buildPendingStatus(context, state);
    } else if (state is PaymentStatusConfirmed) {
      return _buildConfirmedStatus(context, state);
    } else if (state is PaymentStatusFailed) {
      return _buildFailedStatus(context, state);
    } else if (state is PaymentStatusError) {
      return _buildErrorStatus(context, state);
    } else {
      return _buildCheckingStatus(context);
    }
  }

  Widget _buildCheckingStatus(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Checking payment status...'),
          SizedBox(height: 10),
          Text('Please wait while we verify your payment.'),
        ],
      ),
    );
  }

  Widget _buildPendingStatus(BuildContext context, PaymentStatusPending state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 80, color: Colors.orange),
          SizedBox(height: 20),
          Text(
            'Payment Pending',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Checking again in 8 seconds...',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedStatus(
    BuildContext context,
    PaymentStatusConfirmed state,
  ) {
    final orderData = state.orderData;
    final firstTraveler = orderData.travelers.isNotEmpty
        ? orderData.travelers.first
        : null;
    final ticketNumber = firstTraveler != null
        ? orderData.getTicketNumberForTraveler(firstTraveler.id)
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Success Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.green[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 40, color: Colors.green),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Confirmed!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your flight has been successfully booked',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Ticket Information
          if (ticketNumber != null)
            _buildTicketCard(context, orderData, ticketNumber),

          // Flight Details
          _buildFlightDetailsCard(context, orderData),

          // Passenger Details
          _buildPassengerDetailsCard(context, orderData),

          SizedBox(height: 30),
          GradientButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.home,
                (route) => false,
              );
            },
            text: 'Back to Home',
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    OrderData orderData,
    String ticketNumber,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'E-Ticket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Ticket Number:', style: TextStyle(color: Colors.grey[600])),
            Text(
              ticketNumber,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please keep this number for your records',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetailsCard(BuildContext context, OrderData orderData) {
    if (orderData.flightOffers.isEmpty) return SizedBox();

    final flightOffer = orderData.flightOffers.first;
    final firstItinerary = flightOffer.itineraries.isNotEmpty
        ? flightOffer.itineraries.first
        : null;

    final validatingAirline = flightOffer.validatingAirlineCodes.isNotEmpty
        ? flightOffer.validatingAirlineCodes.first
        : '';
    if (firstItinerary == null) return SizedBox();

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstItinerary.fromAirport.code,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      firstItinerary.fromAirport.city,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Icon(Icons.airplanemode_active, color: Colors.blue),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      firstItinerary.toAirport.code,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      firstItinerary.toAirport.city,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Text('Duration: ${firstItinerary.duration}'),
            Text(
              'Airline: ${validatingAirline.isNotEmpty ? validatingAirline : 'N/A'}',
            ), // UPDATED THIS LINE
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetailsCard(BuildContext context, OrderData orderData) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Passenger Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...orderData.travelers.map(
              (traveler) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      traveler.name.fullName,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${traveler.gender} • ${traveler.dateOfBirth}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedStatus(BuildContext context, PaymentStatusFailed state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text(
            'Payment Failed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            state.reason,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 30),
          GradientButton(
            onPressed: () {
              // Navigate back to search with same data
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.home, // Or your search screen route
                (route) => false,
              );
            },
            text: 'Try Again',
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(BuildContext context, PaymentStatusError state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 80, color: Colors.orange),
          SizedBox(height: 20),
          Text(
            'Error Occurred',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 30),
          GradientButton(
            onPressed: () {
              context.read<PaymentStatusCubit>().checkStatusManually();
            },
            text: 'Retry',
            height: 50,
          ),
        ],
      ),
    );
  }
}

// lib/presentation/payment_status/payment_status_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tayyran_app/core/dependency_injection.dart';
// import 'package:tayyran_app/core/routes/route_names.dart';
// import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
// import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
// import 'package:tayyran_app/data/models/payment_status_response.dart';
// import 'package:tayyran_app/data/repositories/payment_repository.dart';
// import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';
// import 'package:tayyran_app/presentation/payment_status/cubit/payment_status_cubit.dart';

// class PaymentStatusScreen extends StatefulWidget {
//   final String invoiceId;
//   final PaymentArguments args;

//   const PaymentStatusScreen({
//     super.key,
//     required this.invoiceId,
//     required this.args,
//   });

//   @override
//   State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
// }

// class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PaymentStatusCubit(
//         getIt<PaymentRepository>(),
//         widget.invoiceId,
//         widget.args,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: GradientAppBar(
//           title: 'Payment Status',
//           height: 120,
//           showBackButton: false,
//         ),
//         body: BlocConsumer<PaymentStatusCubit, PaymentStatusState>(
//           listener: (context, state) {
//             // Handle any side effects like navigation here if needed
//           },
//           builder: (context, state) {
//             return _buildStatusContent(context, state);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusContent(BuildContext context, PaymentStatusState state) {
//     if (state is PaymentStatusChecking || state is PaymentStatusInitial) {
//       return _buildLoadingStatus(context);
//     } else if (state is PaymentStatusPending) {
//       return _buildPendingStatus(context, state);
//     } else if (state is PaymentStatusConfirmed) {
//       return _buildConfirmedStatus(context, state);
//     } else if (state is PaymentStatusFailed) {
//       return _buildFailedStatus(context, state);
//     } else if (state is PaymentStatusError) {
//       return _buildErrorStatus(context, state);
//     } else {
//       return _buildLoadingStatus(context);
//     }
//   }

//   Widget _buildLoadingStatus(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               strokeWidth: 4,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'Processing Payment...',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             'Please wait while we confirm your payment',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'This may take a few moments',
//             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPendingStatus(BuildContext context, PaymentStatusPending state) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.access_time, size: 80, color: Colors.orange),
//           SizedBox(height: 24),
//           Text(
//             'Payment Pending',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.orange[800],
//             ),
//           ),
//           SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32.0),
//             child: Text(
//               state.message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//             ),
//           ),
//           SizedBox(height: 24),
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Auto-checking in 5 seconds...',
//             style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildConfirmedStatus(
//     BuildContext context,
//     PaymentStatusConfirmed state,
//   ) {
//     final orderData = state.orderData;
//     final firstTraveler = orderData.travelers.isNotEmpty
//         ? orderData.travelers.first
//         : null;
//     final ticketNumber = firstTraveler != null
//         ? orderData.getTicketNumberForTraveler(firstTraveler.id)
//         : null;

//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Success Header
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green[50]!, Colors.green[100]!],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle, size: 40, color: Colors.green),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Booking Confirmed!',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green[800],
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'Your flight has been successfully booked',
//                         style: TextStyle(color: Colors.green[700]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),

//           // Ticket Information
//           if (ticketNumber != null)
//             _buildTicketCard(context, orderData, ticketNumber),

//           // Flight Details
//           _buildFlightDetailsCard(context, orderData),

//           // Passenger Details
//           _buildPassengerDetailsCard(context, orderData),

//           SizedBox(height: 30),
//           GradientButton(
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 RouteNames.home,
//                 (route) => false,
//               );
//             },
//             text: 'Back to Home',
//             height: 50,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTicketCard(
//     BuildContext context,
//     OrderData orderData,
//     String ticketNumber,
//   ) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.confirmation_number, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text(
//                   'E-Ticket',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text('Ticket Number:', style: TextStyle(color: Colors.grey[600])),
//             Text(
//               ticketNumber,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[700],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Please keep this number for your records',
//               style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFlightDetailsCard(BuildContext context, OrderData orderData) {
//     if (orderData.flightOffers.isEmpty) return SizedBox();

//     final flightOffer = orderData.flightOffers.first;
//     final firstItinerary = flightOffer.itineraries.isNotEmpty
//         ? flightOffer.itineraries.first
//         : null;

//     final validatingAirline = flightOffer.validatingAirlineCodes.isNotEmpty
//         ? flightOffer.validatingAirlineCodes.first
//         : '';
//     if (firstItinerary == null) return SizedBox();

//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Flight Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       firstItinerary.fromAirport.code,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       firstItinerary.fromAirport.city,
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 Icon(Icons.airplanemode_active, color: Colors.blue),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       firstItinerary.toAirport.code,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       firstItinerary.toAirport.city,
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Divider(),
//             SizedBox(height: 8),
//             Text('Duration: ${firstItinerary.duration}'),
//             Text(
//               'Airline: ${validatingAirline.isNotEmpty ? validatingAirline : 'N/A'}',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPassengerDetailsCard(BuildContext context, OrderData orderData) {
//     return Card(
//       elevation: 2,
//       margin: EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Passenger Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12),
//             ...orderData.travelers.map(
//               (traveler) => Padding(
//                 padding: EdgeInsets.only(bottom: 8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       traveler.name.fullName,
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     Text(
//                       '${traveler.gender} • ${traveler.dateOfBirth}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFailedStatus(BuildContext context, PaymentStatusFailed state) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 80, color: Colors.red),
//           SizedBox(height: 20),
//           Text(
//             'Payment Failed',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 16),
//           Text(
//             state.reason,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//           ),
//           SizedBox(height: 30),
//           GradientButton(
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 RouteNames.home,
//                 (route) => false,
//               );
//             },
//             text: 'Try Again',
//             height: 50,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorStatus(BuildContext context, PaymentStatusError state) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.warning, size: 80, color: Colors.orange),
//           SizedBox(height: 20),
//           Text(
//             'Error Occurred',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 16),
//           Text(
//             state.errorMessage,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//           ),
//           SizedBox(height: 30),
//           GradientButton(
//             onPressed: () {
//               context.read<PaymentStatusCubit>().checkStatusManually();
//             },
//             text: 'Retry',
//             height: 50,
//           ),
//         ],
//       ),
//     );
//   }
// }
