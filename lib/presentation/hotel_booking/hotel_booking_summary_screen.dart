// lib/presentation/hotel_booking/screens/hotel_booking_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/utils/widgets/booking_summary_helper.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/presentation/hotel_booking/cubit/hotel_booking_cubit.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_booking_arguments.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/amenities_section.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/booking_summary_bottom_bar.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/contact_info_section.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/guests_section.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/hotel_info_card.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/hotel_policies_section.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/important_information_section.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/price_details_widget.dart';
import 'package:tayyran_app/presentation/hotel_booking/widgets/stay_details_card.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class HotelBookingSummaryScreen extends StatelessWidget {
  final HotelBookingArguments args;

  const HotelBookingSummaryScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        height: 120,
        showBackButton: true,
        title: 'booking.booking_summary'.tr(),
      ),
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<HotelBookingCubit, HotelBookingState>(
        listener: _blocListener,
        builder: (context, state) {
          if (state is HotelBookingInitial) {
            return _buildContent(context, state);
          }
          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildSkeletonAppBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonAppBar() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.splashBackgroundColorStart,
            AppColors.splashBackgroundColorEnd,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 56, left: 16, right: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _blocListener(BuildContext context, HotelBookingState state) {
    if (state is HotelBookingInitial && state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context, HotelBookingInitial state) {
    final nights = BookingSummaryHelper.calculateNights(
      state.hotel.checkInTime,
      state.hotel.checkOutTime,
    );

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: _buildHeaderSection(context, state, nights),
              ),

              // Main Content Sections
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionSpacer(),

                  // Stay Details
                  StayDetailsCard(
                    checkIn: state.searchParams['CheckIn'],
                    checkOut: state.searchParams['CheckOut'],
                    checkInTime: state.priceDetails?.checkInTime ?? '14:00',
                    checkOutTime: state.priceDetails?.checkOutTime ?? '12:00',
                    nights: nights,
                    totalAdults: state.totalAdults,
                    totalChildren: state.totalChildren,
                    numberOfRooms: state.numberOfRooms,
                  ),
                  _buildSectionSpacer(),

                  // Guests Information
                  GuestsSection(
                    numberOfRooms: state.numberOfRooms,
                    totalAdults: state.totalAdults,
                    guests: state.guests,
                  ),
                  _buildSectionSpacer(),

                  // Contact Information
                  ContactInfoSection(
                    contactEmail: state.contactEmail,
                    contactPhone: state.contactPhone,
                    countryCode: state.countryCode,
                  ),
                  _buildSectionSpacer(),

                  // Price Details
                  if (state.priceDetails != null) ...[
                    PriceDetailsWidget(
                      priceBreakdown: state.priceBreakdown,
                      currency: state.hotel.currency,
                      nights: nights,
                      rooms: state.numberOfRooms,
                      percentageCommission: state.hotel.percentageCommission,
                    ),
                    _buildSectionSpacer(),
                  ],

                  // Amenities
                  if (state.priceDetails != null) ...[
                    AmenitiesSection(amenities: state.priceDetails!.amenities),
                    _buildSectionSpacer(),
                  ],

                  // Important Information
                  if (state.priceDetails != null) ...[
                    ImportantInformationSection(
                      rateConditions: state.priceDetails!.rateConditions,
                    ),
                    _buildSectionSpacer(),
                  ],

                  // Hotel Policies
                  if (state.priceDetails != null) ...[
                    HotelPoliciesSection(priceDetails: state.priceDetails!),
                    _buildSectionSpacer(),
                  ],

                  // Bottom padding
                  const SizedBox(height: 80),
                ]),
              ),
            ],
          ),
        ),

        // Bottom Bar
        BookingSummaryBottomBar(
          nights: nights,
          numberOfRooms: state.numberOfRooms,
          priceBreakdown: state.priceBreakdown,
          isLoading: state.isLoading,
          isFormValid: context.read<HotelBookingCubit>().isFormValid,
        ),
      ],
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    HotelBookingInitial state,
    int nights,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.splashBackgroundColorEnd.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.splashBackgroundColorEnd.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.splashBackgroundColorEnd,
                ),
                const SizedBox(width: 8),
                Text(
                  '$nights ${nights > 1 ? 'booking.nights'.tr() : 'booking.night'.tr()} • '
                  '${state.numberOfRooms} ${state.numberOfRooms > 1 ? 'booking.rooms'.tr() : 'booking.room'.tr()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.splashBackgroundColorEnd,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HotelInfoCard(hotel: state.hotel, selectedRoom: state.selectedRoom),
        ],
      ),
    );
  }

  Widget _buildSectionSpacer() {
    return const SizedBox(height: 16);
  }
}
