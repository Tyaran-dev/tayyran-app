import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/data/models/payment_status_response.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';
import 'package:tayyran_app/presentation/payment_status/cubit/payment_status_cubit.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String invoiceId;

  const PaymentStatusScreen({super.key, required this.invoiceId});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PaymentStatusCubit(getIt<PaymentRepository>(), widget.invoiceId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: 'Payment Status',
          height: 120,
          showBackButton: false,
        ),
        body: BlocConsumer<PaymentStatusCubit, PaymentStatusState>(
          listener: (context, state) {
            // Handle any side effects like navigation here if needed
          },
          builder: (context, state) {
            return _buildMainContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, PaymentStatusState state) {
    if (state is PaymentStatusChecking || state is PaymentStatusInitial) {
      return _buildLoadingStatus(context, state);
    } else if (state is PaymentStatusPending) {
      return _buildPendingStatus(context, state);
    } else if (state is PaymentStatusConfirmed) {
      return _buildConfirmedStatus(context, state);
    } else if (state is PaymentStatusFailed) {
      return _buildFailedStatus(context, state);
    } else if (state is PaymentStatusError) {
      return _buildErrorStatus(context, state);
    } else {
      return _buildLoadingStatus(context, state);
    }
  }

  Widget _buildLoadingStatus(BuildContext context, PaymentStatusState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.splashBackgroundColorEnd,
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'We are confirming your payment details',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildPendingStatus(BuildContext context, PaymentStatusPending state) {
    final secondsUntilNextCheck = 8 - (state.timerCount % 8);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.access_time, size: 50, color: Colors.orange),
          ),
          SizedBox(height: 24),
          Text(
            'Payment Pending',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  strokeWidth: 4,
                ),
              ),
              Text(
                '$secondsUntilNextCheck',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Next check in $secondsUntilNextCheck seconds',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildConfirmedStatus(
    BuildContext context,
    PaymentStatusConfirmed state,
  ) {
    final orderData = state.orderData;
    final ticket = orderData.tickets.isNotEmpty
        ? orderData.tickets.first
        : null;
    final traveler = orderData.travelers.isNotEmpty
        ? orderData.travelers.first
        : null;
    final flightOffer = orderData.flightOffers.isNotEmpty
        ? orderData.flightOffers.first
        : null;
    final segment = flightOffer?.itineraries.first.segments.first;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Success Header
          _buildSuccessHeader(),
          SizedBox(height: 20),

          // Ticket Information
          if (ticket != null) _buildTicketCard(ticket, traveler),

          // Flight Details
          if (segment != null && flightOffer != null)
            _buildFlightDetailsCard(segment, flightOffer),

          // Price Breakdown
          if (flightOffer != null) _buildPriceCard(flightOffer),

          // Passenger Details
          _buildPassengerDetailsCard(orderData.travelers),

          // // Contact Information
          // _buildContactCard(orderData.contacts),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: GradientButton(
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
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 30, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your flight has been successfully booked and tickets issued',
                  style: TextStyle(color: Colors.green[700], fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'You will receive a confirmation email shortly',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket, Traveler? traveler) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'E-Ticket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'ISSUED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket Number',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        ticket.documentNumber,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (traveler != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Passenger',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          traveler.name.fullName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Please save this ticket number for your records',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetailsCard(Segment segment, FlightOffer flightOffer) {
    // final airline = flightOffer.validatingAirlineCodes.isNotEmpty
    //     ? flightOffer.validatingAirlineCodes.first
    //     : '';

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        segment.departure.iataCode,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatTime(segment.departure.at),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formatDateString(segment.departure.at),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.flight_takeoff, color: Colors.blue, size: 24),
                    SizedBox(height: 4),
                    Text(
                      segment.duration
                          .replaceAll('PT', '')
                          .replaceAll('M', 'm'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        segment.arrival.iataCode,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatTime(segment.arrival.at),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formatDateString(segment.arrival.at),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFlightDetailItem(
                  'Flight',
                  '${segment.carrierCode} ${segment.number}',
                ),
                _buildFlightDetailItem('Class', 'ECONOMY'),
                // _buildFlightDetailItem('Aircraft', segment.aircraft.code),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(FlightOffer flightOffer) {
    final price = flightOffer.price;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Base Fare', style: TextStyle(color: Colors.grey[600])),
                Text('${price.currency} ${price.base}'),
              ],
            ),
            SizedBox(height: 8),
            ...price.taxes.map(
              (tax) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax (${tax.code})',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text('${price.currency} ${tax.amount}'),
                  ],
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${price.currency} ${price.total}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetailsCard(List<Traveler> travelers) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            ...travelers.map(
              (traveler) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            traveler.name.fullName,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${traveler.gender} • ${formatDateString(traveler.dateOfBirth)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: 2),
                          Text(
                            traveler.contact.emailAddress,
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      ),
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 50, color: Colors.red),
          ),
          SizedBox(height: 24),
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
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.home,
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning, size: 50, color: Colors.orange),
          ),
          SizedBox(height: 24),
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

  // Helper methods
  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 120,
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.splashBackgroundColorEnd,
        ),
      ),
    );
  }

  Widget _buildFlightDetailItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
