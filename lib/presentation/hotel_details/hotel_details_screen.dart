// lib/presentation/hotel_details/screens/hotel_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/presentation/hotel_booking/models/hotel_booking_arguments.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/loading_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';
import 'package:tayyran_app/presentation/hotel_details/cubit/hotel_details_cubit.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/hotel_details_header.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/room_type_group.dart';
import 'package:tayyran_app/presentation/hotel_details/widgets/hotel_facilities_section.dart';

class HotelDetailsScreen extends StatelessWidget {
  final HotelData hotel;
  final Map<String, dynamic> searchParams;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.searchParams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HotelDetailsCubit(hotel: hotel, searchParams: searchParams),
      child: Scaffold(
        appBar: GradientAppBar(
          height: 120,
          showBackButton: true,
          title: 'hotels.hotel_details'.tr(),
        ),
        backgroundColor: Colors.white,
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<HotelDetailsCubit, HotelDetailsState>(
      builder: (context, state) {
        if (state is HotelDetailsLoading) {
          return _buildShimmerLoading();
        } else if (state is HotelDetailsLoaded) {
          return _buildLoadedState(state, context);
        } else {
          return _buildErrorState();
        }
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      children: [
        // Image Slider Shimmer
        Container(
          height: 250,
          color: Colors.grey[200],
          child: const ShimmerEffect(),
        ),

        // Hotel Info Shimmer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: LoadingShimmer.text(width: 200, height: 24)),
                  LoadingShimmer.text(width: 60, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              LoadingShimmer.text(width: 150, height: 16),
              const SizedBox(height: 8),
              LoadingShimmer.text(width: double.infinity, height: 16),
              const SizedBox(height: 16),

              // Description Shimmer
              LoadingShimmer.text(
                width: double.infinity,
                height: 80,
                borderRadius: 8,
              ),
              const SizedBox(height: 24),

              // Rooms Shimmer
              LoadingShimmer.text(width: 150, height: 20),
              const SizedBox(height: 16),
              ...List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: LoadingShimmer.roomCard(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState(HotelDetailsLoaded state, BuildContext context) {
    final cubit = context.read<HotelDetailsCubit>();

    return ListView(
      children: [
        // Enhanced Header with Image Limit
        HotelDetailsHeader(
          hotel: state.hotel,
          onViewAllImages: () => cubit.showAllImages(context),
        ),

        // Hotel Description with Read More
        if (state.hotel.description.isNotEmpty)
          _buildDescriptionSection(state.hotel, context, cubit),

        // Enhanced Room Selection with Room Type Groups
        _buildRoomSelectionSection(state, context),

        // Enhanced Facilities with View All
        HotelFacilitiesSection(
          facilities: state.hotel.hotelFacilities,
          onViewAll: () => cubit.showAllFacilities(context),
        ),

        // // Location & Contact
        // _buildLocationContactSection(state.hotel),

        // Attractions
        if (state.hotel.attractions.isNotEmpty)
          _buildAttractionsSection(state.hotel),

        // Policies
        _buildPoliciesSection(state.hotel),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'hotels.loading_error'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
    HotelData hotel,
    BuildContext context,
    HotelDetailsCubit cubit,
  ) {
    // Clean HTML from description
    final cleanDescription = hotel.description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Check if description is too long (more than 200 characters)
    final isLongDescription = cleanDescription.length > 200;
    final displayText = isLongDescription
        ? '${cleanDescription.substring(0, 200)}...'
        : cleanDescription;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'hotels.about_hotel'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (isLongDescription) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => cubit.showHotelDescription(context),
                child: Text(
                  'hotels.read_more'.tr(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomSelectionSection(
    HotelDetailsLoaded state,
    BuildContext context,
  ) {
    final cubit = context.read<HotelDetailsCubit>();
    final roomGroups = _groupRoomsByType(state.hotel.rooms);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'hotels.available_rooms'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.hotel.rooms.length} ${'hotels.room_options'.tr()}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          if (state.hotel.rooms.isEmpty)
            _buildNoRoomsAvailable()
          else
            Column(
              children: roomGroups.entries.map((entry) {
                return RoomTypeGroup(
                  roomType: entry.key,
                  rooms: entry.value,
                  currency: state.hotel.currency,
                  selectedRoom: state.selectedRoom,
                  onSelectRoom: (room) => cubit.selectRoom(room),
                  onViewCancellationPolicy: (room) =>
                      cubit.showCancellationPolicies(context, room),
                  percentageCommission: state.hotel.percentageCommission,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Map<String, List<HotelRoom>> _groupRoomsByType(List<HotelRoom> rooms) {
    final groups = <String, List<HotelRoom>>{};

    for (final room in rooms) {
      final roomType = room.displayName;
      if (!groups.containsKey(roomType)) {
        groups[roomType] = [];
      }
      groups[roomType]!.add(room);
    }

    return groups;
  }

  Widget _buildNoRoomsAvailable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.hotel_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'hotels.no_rooms_available'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'hotels.try_different_dates'.tr(),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ... (Keep all your existing methods for location, contact, attractions, policies, etc.)

  // ignore: unused_element
  Widget _buildLocationContactSection(HotelData hotel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'hotels.location_contact'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address with pin code
          _buildInfoItem(
            Icons.location_on,
            '${hotel.cityName}, ${hotel.countryName}',
            '${hotel.address} ${hotel.pinCode.isNotEmpty ? '(${hotel.pinCode})' : ''}',
          ),

          // Phone
          if (hotel.phoneNumber.isNotEmpty)
            _buildInfoItem(
              Icons.phone,
              'hotels.phone'.tr(),
              hotel.phoneNumber,
              onTap: () => _callPhone(hotel.phoneNumber),
            ),

          // Email
          if (hotel.email.isNotEmpty)
            _buildInfoItem(
              Icons.email,
              'hotels.email'.tr(),
              hotel.email,
              onTap: () => _sendEmail(hotel.email),
            ),

          // Website
          if (hotel.hotelWebsiteUrl.isNotEmpty)
            _buildInfoItem(
              Icons.language,
              'hotels.website'.tr(),
              hotel.hotelWebsiteUrl,
              onTap: () => _openWebsite(hotel.hotelWebsiteUrl),
            ),

          // Map coordinates
          if (hotel.latitude != null && hotel.longitude != null)
            _buildMapSection(hotel),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: onTap != null ? Colors.blue : Colors.grey[700],
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
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

  Widget _buildMapSection(HotelData hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'hotels.location_on_map'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _openMaps(hotel),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 32, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text(
                        '${hotel.latitude!.toStringAsFixed(4)}, ${hotel.longitude!.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'hotels.tap_to_open_map'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttractionsSection(HotelData hotel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attractions, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'hotels.nearby_attractions'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: hotel.attractions.entries
                .map((entry) => _buildAttractionItem(entry.key, entry.value))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionItem(String number, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.replaceAll(RegExp(r'[^\d]'), ''),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliciesSection(HotelData hotel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.policy, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'hotels.hotel_policies'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPolicyItem(
            Icons.login,
            'hotels.check_in'.tr(),
            hotel.checkInTime,
          ),
          _buildPolicyItem(
            Icons.logout,
            'hotels.check_out'.tr(),
            hotel.checkOutTime,
          ),
          if (hotel.hotelFees.mandatory.isNotEmpty)
            _buildPolicyItem(
              Icons.attach_money,
              'hotels.mandatory_fees'.tr(),
              'hotels.applicable'.tr(),
            ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<HotelDetailsCubit, HotelDetailsState>(
      builder: (context, state) {
        if (state is HotelDetailsLoaded && state.selectedRoom != null) {
          final selectedRoom = state.selectedRoom!;
          final cubit = context.read<HotelDetailsCubit>();

          // Calculate the final price with admin fee and VAT
          final breakdown = selectedRoom.getPriceBreakdown(
            state.hotel.percentageCommission,
          );

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
                // Price Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'hotels.total_price'.tr(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Text(
                            breakdown.total.toStringAsFixed(
                              2,
                            ), // Use calculated total
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
                      TextButton(
                        onPressed: () =>
                            cubit.showPriceDetails(context, selectedRoom),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(bottom: 15),
                          minimumSize: const Size(0, 0),
                        ),
                        child: Text(
                          'hotels.price_details'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.splashBackgroundColorEnd,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Book Button
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: GradientButton(
                    onPressed: () {
                      _proceedToBooking(state, context);
                    },
                    text: 'hotels.book_now'.tr(),
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _proceedToBooking(HotelDetailsLoaded state, BuildContext context) {
    final selectedRoom = state.selectedRoom!;

    // Calculate room counts from search params
    final rooms = state.searchParams['PaxRooms'] as List<dynamic>;
    final numberOfRooms = rooms.length;

    // Calculate total adults and children correctly
    int totalAdults = 0;
    int totalChildren = 0;

    for (final room in rooms) {
      totalAdults += (room['Adults'] as int);
      totalChildren += (room['Children'] as int);
    }

    print('📊 Booking Summary Data:');
    print('   Rooms: $numberOfRooms');
    print('   Total Adults: $totalAdults');
    print('   Total Children: $totalChildren');

    // Show room distribution
    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      print(
        '   Room ${i + 1}: ${room['Adults']} adults, ${room['Children']} children',
      );
    }

    Navigator.pushNamed(
      context,
      RouteNames.hotelBookingSummary,
      arguments: HotelBookingArguments(
        hotel: state.hotel,
        selectedRoom: selectedRoom,
        searchParams: state.searchParams,
        numberOfRooms: numberOfRooms,
        totalAdults: totalAdults,
        totalChildren: totalChildren,
      ),
    );
  }

  // URL Launcher methods
  Future<void> _callPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _sendEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _openWebsite(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _openMaps(HotelData hotel) async {
    if (hotel.latitude != null && hotel.longitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${hotel.latitude},${hotel.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }
}
