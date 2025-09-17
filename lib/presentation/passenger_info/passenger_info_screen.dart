// lib/presentation/passenger_info/screens/passenger_info_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/presentation/passenger_info/cubit/passenger_info_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/country_code_selection_bottom_sheet.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/passenger_card.dart';
import 'package:tayyran_app/presentation/passenger_info/widgets/passenger_form_bottom_sheet.dart';

class PassengerInfoScreen extends StatefulWidget {
  final FlightOffer flightOffer;

  const PassengerInfoScreen({super.key, required this.flightOffer});

  @override
  State<PassengerInfoScreen> createState() => _PassengerInfoScreenState();
}

class _PassengerInfoScreenState extends State<PassengerInfoScreen> {
  String _selectedCountryCode = '+966';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PassengerInfoCubit(widget.flightOffer),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          title: 'Passenger Information',
          height: 120,
          showBackButton: true,
        ),
        body: _PassengerInfoContent(selectedCountryCode: _selectedCountryCode),
        bottomNavigationBar: const _BottomNavigationBar(),
      ),
    );
  }

  void _updateCountryCode(String code) {
    if (mounted) {
      setState(() {
        _selectedCountryCode = code;
      });
    }
  }
}

class _PassengerInfoContent extends StatelessWidget {
  final String selectedCountryCode;

  const _PassengerInfoContent({required this.selectedCountryCode});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PassengerInfoCubit>();
    final flightOffer = cubit.flightOffer;

    return BlocBuilder<PassengerInfoCubit, PassengerInfoState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight summary
              _buildFlightSummary(context, flightOffer),
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
              _buildPassengerCards(context, state, cubit),
              const SizedBox(height: 20),

              // Contact information
              _buildContactInformation(context, state, selectedCountryCode),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
  // color: Color(0xFFFFE3CC),

  Widget _buildFlightSummary(BuildContext context, FlightOffer flightOffer) {
    final firstItinerary = flightOffer.itineraries.isNotEmpty
        ? flightOffer.itineraries.first
        : Itinerary.empty();
    final firstSegment = firstItinerary.segments.isNotEmpty
        ? firstItinerary.segments.first
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFE3CC),
        // color: Colors.white,
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
          // Airline header (with avatars left + right)
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
                      // width: 165,
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
                    _formatDate(firstSegment?.departure.at ?? DateTime.now()),
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
                    '${_getTotalPassengers(flightOffer)}',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _getTotalPassengers(FlightOffer flightOffer) {
    return flightOffer.adults + flightOffer.children + flightOffer.infants;
  }

  Widget _buildPassengerCards(
    BuildContext context,
    PassengerInfoState state,
    PassengerInfoCubit cubit,
  ) {
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
          onEdit: () => _showPassengerFormBottomSheet(context, index, cubit),
        );
      },
    );
  }

  void _showPassengerFormBottomSheet(
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

  Widget _buildContactInformation(
    BuildContext context,
    PassengerInfoState state,
    String countryCode,
  ) {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              context.read<PassengerInfoCubit>().updateContactEmail(value);
            },
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
                          selectedCountryCode,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    context.read<PassengerInfoCubit>().updateContactPhone(
                      value,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCountryCodeSelection(BuildContext context) async {
    final selectedCountry = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => const CountryCodeSelectionBottomSheet(),
    );

    if (selectedCountry != null) {
      // Update country code through the parent state
      final parentState = context
          .findAncestorStateOfType<_PassengerInfoScreenState>();
      parentState?._updateCountryCode(selectedCountry['dial_code']!);
    }
  }
}

// Bottom Navigation Bar Widget
class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PassengerInfoCubit, PassengerInfoState>(
      builder: (context, state) {
        // final flight = state.flightOffer;

        return SafeArea(
          bottom: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price + currency
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(
                            '${2600}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.splashBackgroundColorEnd,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            AppAssets.currencyIcon,
                            width: 28,
                            height: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: context.widthPct(0.65),
                  child: GradientButton(
                    onPressed: state.isFormValid
                        ? () => context
                              .read<PassengerInfoCubit>()
                              .submitPassengerInfo()
                        : null,
                    text: 'Continue to Payment',
                    height: 50,
                    width: context.widthPct(0.60),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
