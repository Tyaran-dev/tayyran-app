// lib/presentation/payment/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_button.dart';
import 'package:tayyran_app/presentation/payment/cubit/payment_cubit.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';

class PaymentScreen extends StatelessWidget {
  final PaymentArguments args;

  const PaymentScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentAuthorized) {
          _navigateToPaymentStatus(context, state);
        } else if (state is PaymentError) {
          _handlePaymentError(context, state);
        } else if (state is PaymentFailed) {
          _handlePaymentFailed(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: 'Payment',
          height: 120,
          showBackButton: true,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading || state is PaymentInitial) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.splashBackgroundColorEnd,
                ),
                SizedBox(height: 16),
                Text('Initializing payment...'),
              ],
            ),
          );
        }

        if (state is PaymentError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    onPressed: () =>
                        context.read<PaymentCubit>().retryPayment(),
                    text: 'Retry Payment',
                    height: 50,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PaymentReady) {
          return _buildPaymentInterface(context, state);
        }

        if (state is PaymentProcessing) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.splashBackgroundColorEnd,
                ),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          );
        }

        if (state is PaymentFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.reason,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    onPressed: () =>
                        context.read<PaymentCubit>().retryPayment(),
                    text: 'Try Again',
                    height: 50,
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.splashBackgroundColorEnd,
              ),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentInterface(BuildContext context, PaymentReady state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment summary
          _buildPaymentSummary(state.args),
          const SizedBox(height: 24),

          // Apple Pay Button (Commented for future use)
          // _buildApplePayButton(),
          // const SizedBox(height: 24),

          // Divider with "OR" text
          // _buildDividerWithText(),
          // const SizedBox(height: 24),

          // Card payment section titlex`
          _buildCardPaymentTitle(),
          const SizedBox(height: 16),

          // Card payment view
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFf9fafb),
            ),
            child: state.cardView,
          ),
          const SizedBox(height: 32),

          // Pay button
          Center(
            child: SizedBox(
              width: context.widthPct(0.65),
              child: GradientButton(
                onPressed: () => context.read<PaymentCubit>().processPayment(),
                text: 'Pay ${state.args.amount.toStringAsFixed(2)} SAR',
                height: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Info text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Your payment will be authorized first and then captured to confirm your booking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 40), // Extra padding for keyboard
        ],
      ),
    );
  }

  // Apple Pay Button (Commented for future implementation)
  // ignore: unused_element
  Widget _buildApplePayButton() {
    return const SizedBox.shrink(); // Completely hidden for now

    // Uncomment this when you want to implement Apple Pay:

    // return Container(
    //   width: double.infinity,
    //   height: 50,
    //   decoration: BoxDecoration(
    //     color: Colors.black,
    //     borderRadius: BorderRadius.circular(8),
    //     border: Border.all(color: Colors.grey[300]!),
    //   ),
    //   child: Material(
    //     color: Colors.transparent,
    //     child: InkWell(
    //       onTap: () {
    //         // TODO: Implement Apple Pay functionality
    //         debugPrint('Apple Pay tapped');
    //       },
    //       borderRadius: BorderRadius.circular(8),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(Icons.apple, color: Colors.white, size: 24),
    //           const SizedBox(width: 12),
    //           Text(
    //             'Pay with Apple Pay',
    //             style: TextStyle(
    //               color: Colors.white,
    //               fontSize: 16,
    //               fontWeight: FontWeight.w600,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  // Divider with "OR" text
  // ignore: unused_element
  Widget _buildDividerWithText() {
    return const SizedBox.shrink(); // Hidden when Apple Pay is hidden

    // Uncomment this when you implement Apple Pay:

    // return Row(
    //   children: [
    //     Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 16),
    //       child: Text(
    //         'OR',
    //         style: TextStyle(
    //           color: Colors.grey[500],
    //           fontSize: 14,
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //     ),
    //     Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
    //   ],
    // );
  }

  // Card payment section title
  Widget _buildCardPaymentTitle() {
    // return const SizedBox.shrink(); // Hidden when Apple Pay is hidden

    // Uncomment this when you implement Apple Pay:

    return Text(
      'Enter Card Details',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.splashBackgroundColorEnd,
      ),
    );
  }

  Widget _buildPaymentSummary(PaymentArguments args) {
    return Card(
      color: const Color(0xFFF9fafb),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: AppColors.splashBackgroundColorEnd),
                const SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Flight',
              '${args.flightOffer.airlineName} ${args.flightOffer.flightNumber}',
            ),
            _buildSummaryRow(
              'Route',
              '${args.flightOffer.fromLocation} → ${args.flightOffer.toLocation}',
            ),
            _buildSummaryRow('Passengers', '${args.passengers.length}'),
            _buildSummaryRow(
              'Class',
              args.flightOffer.cabinClass.toUpperCase(),
            ),
            _buildSummaryRow('Email', args.email),
            _buildSummaryRow('Phone', '${args.countryCode}${args.phoneNumber}'),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              '${args.amount.toStringAsFixed(2)} SAR',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? AppColors.splashBackgroundColorEnd
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPaymentStatus(BuildContext context, PaymentAuthorized state) {
    // Navigator.pushReplacementNamed(
    //   context,
    //   RouteNames.paymentStatus,
    //   arguments: {'invoiceId': state.invoiceId, 'args': state.args},
    // );
    Navigator.pushNamed(
      context,
      RouteNames.paymentStatus,
      arguments: {
        'invoiceId': state.invoiceId,
        'args': state.args, // Your PaymentArguments object
      },
    );
  }

  void _handlePaymentError(BuildContext context, PaymentError state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment error: ${state.errorMessage}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => context.read<PaymentCubit>().retryPayment(),
        ),
      ),
    );
  }

  void _handlePaymentFailed(BuildContext context, PaymentFailed state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${state.reason}'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => context.read<PaymentCubit>().retryPayment(),
        ),
      ),
    );
  }
}
