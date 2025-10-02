import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/passenger_info/cubit/passenger_info_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/country_code_selection_bottom_sheet.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/passenger_card.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/passenger_form_bottom_sheet.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';

class PassengerInfoScreen extends StatelessWidget {
  const PassengerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PassengerInfoCubit, PassengerInfoState>(
      listener: (context, state) {
        // Handle error states
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  context.read<PassengerInfoCubit>().retryPricingUpdate();
                },
              ),
            ),
          );
        }
        if (state.isSubmitted && !state.isLoading) {
          _navigateToPaymentScreen(context);
        }
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: 'Passenger Information',
          height: 120,
          showBackButton: true,
        ),
        body: BlocBuilder<PassengerInfoCubit, PassengerInfoState>(
          builder: (context, state) {
            return buildContent(context, state);
          },
        ),
        bottomNavigationBar: _buildBottomBookingBar(context),
      ),
    );
  }

  Widget buildContent(BuildContext context, PassengerInfoState state) {
    final cubit = context.read<PassengerInfoCubit>();

    // Initialize pricing when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.updateFlightPricing();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner if there's an error
          if (state.errorMessage != null) buildErrorBanner(context),

          // Flight summary
          buildFlightSummary(context, state.currentFlightOffer),
          const SizedBox(height: 24),

          // Passenger list title
          Text(
            'Passengers (${state.passengers.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackgroundColorEnd,
            ),
          ),
          const SizedBox(height: 16),

          // Passenger cards list
          buildPassengerCards(context, state),
          const SizedBox(height: 20),

          // Contact information
          buildContactInformation(context, state),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _navigateToPaymentScreen(BuildContext context) {
    final cubit = context.read<PassengerInfoCubit>();
    final state = cubit.state;

    cubit.resetSubmission();

    final flightOffer = state.currentFlightOffer;
    double presentageCommission = flightOffer.presentageCommission;
    double administrationFee = flightOffer.price * (presentageCommission / 100);
    double totalWithCommission = flightOffer.price + administrationFee;

    // Debug: Print what we're passing to payment
    debugPrint("🚀 Navigating to payment with:");
    debugPrint("  - Passengers count: ${state.passengers.length}");
    debugPrint("  - Email: ${state.contactEmail}");
    debugPrint("  - Phone: ${state.contactPhone}");
    debugPrint("  - Country Code: ${state.countryCode}");
    debugPrint(
      "  - Pricing Response Available: ${state.pricingResponse != null}",
    );

    for (int i = 0; i < state.passengers.length; i++) {
      final passenger = state.passengers[i];
      debugPrint(
        "  Passenger ${i + 1}: ${passenger.firstName} ${passenger.lastName}",
      );
    }

    final paymentArgs = PaymentArguments(
      amount: totalWithCommission,
      email: state.contactEmail,
      phoneNumber: state.contactPhone,
      countryCode: state.countryCode,
      flightOffer: flightOffer,
      passengers: state.passengers,
      pricingResponse: state.pricingResponse!,
    );

    Navigator.pushReplacementNamed(
      context,
      RouteNames.payment,
      arguments: paymentArgs,
    );
  }

  Widget buildErrorBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to update prices. Showing cached prices.',
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlightSummary(BuildContext context, FlightOffer flightOffer) {
    final firstItinerary = flightOffer.itineraries.isNotEmpty
        ? flightOffer.itineraries.first
        : Itinerary.empty();
    final firstSegment = firstItinerary.segments.isNotEmpty
        ? firstItinerary.segments.first
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3CC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Airline header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(flightOffer.airlineLogo),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flightOffer.airlineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Flight ${firstSegment?.carrierCode ?? ''}${firstSegment?.number ?? ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                AppAssets.ticketLogo,
                width: 65,
                height: 65,
                fit: BoxFit.fill,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flight route
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstItinerary.fromAirport.code,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    firstItinerary.fromAirport.city.split(' - ').first,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      AppAssets.airplaneIcon,
                      height: 50,
                      width: context.widthPct(0.60),
                    ),
                  ),
                  Text(
                    firstItinerary.duration,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    firstItinerary.toAirport.code,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    firstItinerary.toAirport.city.split(' - ').first,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flight details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    formatDate(firstSegment?.departure.at ?? DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Class',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    flightOffer.cabinClass.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Passengers',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${getTotalPassengers(flightOffer)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPassengerCards(BuildContext context, PassengerInfoState state) {
    final cubit = context.read<PassengerInfoCubit>();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.passengers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final passenger = state.passengers[index];
        return PassengerCard(
          passenger: passenger,
          index: index,
          onEdit: () => showPassengerFormBottomSheet(context, index, cubit),
        );
      },
    );
  }

  void showPassengerFormBottomSheet(
    BuildContext context,
    int passengerIndex,
    PassengerInfoCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PassengerFormBottomSheet(
            passengerIndex: passengerIndex,
            cubit: cubit,
          ),
        );
      },
    );
  }

  Widget buildContactInformation(
    BuildContext context,
    PassengerInfoState state,
  ) {
    final cubit = context.read<PassengerInfoCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.splashBackgroundColorEnd,
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            initialValue: state.contactEmail,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.email,
                color: AppColors.splashBackgroundColorEnd,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => cubit.updateContactEmail(value),
          ),
          const SizedBox(height: 16),

          // Phone Number with Country Code
          Row(
            children: [
              // Country Code
              SizedBox(
                width: 140,
                child: InkWell(
                  onTap: () => _showCountryCodeSelection(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Country Code',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.countryCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Phone Number
              Expanded(
                child: TextFormField(
                  initialValue: state.contactPhone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.updateContactPhone(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCountryCodeSelection(BuildContext context) {
    // Store the cubit reference before the async gap
    final cubit = context.read<PassengerInfoCubit>();
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => const CountryCodeSelectionBottomSheet(),
    ).then((selectedCountry) {
      // This callback runs after the async operation, but we use the stored cubit reference
      if (selectedCountry != null && context.mounted) {
        cubit.updateCountryCode(selectedCountry['dial_code']!);
      }
    });
  }

  void _handleContinueToPayment(BuildContext context) {
    final cubit = context.read<PassengerInfoCubit>();

    // Validate all passenger data before proceeding
    if (validateAllPassengers(cubit.state.passengers)) {
      cubit.submitPassengerInfo();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all passenger information correctly'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildBottomBookingBar(BuildContext context) {
    return BlocBuilder<PassengerInfoCubit, PassengerInfoState>(
      builder: (context, state) {
        final grandTotal = state.grandTotal ?? state.currentFlightOffer.price;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Price',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        if (state.isLoading)
                          const SizedBox(
                            width: 60,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.splashBackgroundColorEnd,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Text(
                            grandTotal.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.splashBackgroundColorEnd,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Image.asset(
                          AppAssets.currencyIcon,
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Continue button
              SizedBox(
                width: context.widthPct(0.65),
                child: GradientButton(
                  onPressed: state.isFormValid && !state.isLoading
                      ? () => _handleContinueToPayment(context)
                      : null,
                  text: state.isLoading ? 'Updating...' : 'Continue to Payment',
                  height: 50,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
