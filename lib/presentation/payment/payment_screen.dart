// lib/presentation/payment/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
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
          title: 'payment.title'.tr(),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.splashBackgroundColorEnd,
                ),
                SizedBox(height: 16),
                Text('payment.initializing'.tr()),
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
                    'payment.error.title'.tr(),
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
                    text: 'payment.retry'.tr(),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.splashBackgroundColorEnd,
                ),
                SizedBox(height: 16),
                Text('payment.processing'.tr()),
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
                    'payment.failed.title'.tr(),
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
                    text: 'payment.tryAgain'.tr(),
                    height: 50,
                  ),
                ],
              ),
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.splashBackgroundColorEnd,
              ),
              SizedBox(height: 16),
              Text('payment.loading'.tr()),
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

          // Card payment section title
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
                text: 'payment.payButton'.tr(
                  namedArgs: {'amount': state.args.amount.toStringAsFixed(2)},
                ),
                height: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Info text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'payment.infoText'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  fontFamily: "Almarai",
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), // Extra padding for keyboard
        ],
      ),
    );
  }

  // Card payment section title
  Widget _buildCardPaymentTitle() {
    return Text(
      'payment.cardDetails'.tr(),
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
                  'payment.summary'.tr(),
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
              'payment.flight'.tr(),
              '${args.flightOffer.airlineName} ${args.flightOffer.flightNumber}',
            ),
            _buildSummaryRow(
              'payment.route'.tr(),
              '${args.flightOffer.fromLocation} → ${args.flightOffer.toLocation}',
            ),
            _buildSummaryRow(
              'payment.passengers'.tr(),
              '${args.passengers.length}',
            ),
            _buildSummaryRow(
              'payment.class'.tr(),
              args.flightOffer.cabinClass.toLowerCase().tr(),
            ),
            _buildSummaryRow('payment.email'.tr(), args.email),
            _buildSummaryRow(
              'payment.phone'.tr(),
              '${args.countryCode}${args.phoneNumber}',
            ),
            const Divider(),
            _buildSummaryRow(
              'payment.totalAmount'.tr(),
              'payment.totalAmountWithCurrency'.tr(
                namedArgs: {'amount': args.amount.toStringAsFixed(2)},
              ),
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
    Navigator.pushNamed(
      context,
      RouteNames.paymentStatus,
      arguments: {'invoiceId': state.invoiceId, 'args': state.args},
    );
  }

  void _handlePaymentError(BuildContext context, PaymentError state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('payment.snackbar.error'.tr(args: [state.errorMessage])),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'payment.retry'.tr(),
          onPressed: () => context.read<PaymentCubit>().retryPayment(),
        ),
      ),
    );
  }

  void _handlePaymentFailed(BuildContext context, PaymentFailed state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('payment.snackbar.failed'.tr(args: [state.reason])),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'payment.retry'.tr(),
          onPressed: () => context.read<PaymentCubit>().retryPayment(),
        ),
      ),
    );
  }
}
