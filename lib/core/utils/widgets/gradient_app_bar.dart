// gradient_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool isHomePage;
  final bool isFlightResults;
  final double? height;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? customTitle;
  final VoidCallback? onDestinationTap;

  static const LinearGradient gradient = LinearGradient(
    colors: [
      AppColors.splashBackgroundColorStart,
      AppColors.splashBackgroundColorEnd,
    ],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

  const GradientAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.isHomePage = false,
    this.isFlightResults = false,
    this.height,
    this.onBackPressed,
    this.actions,
    this.customTitle,
    this.onDestinationTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? kToolbarHeight,
      decoration: const BoxDecoration(gradient: gradient),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        title: isFlightResults
            ? _buildFlightSearchTitleWithCubit(context)
            : customTitle ??
                  (isHomePage
                      ? _buildHomeAppBarContent()
                      : Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
        centerTitle: true,
        actions: isFlightResults
            ? [
                // Empty actions for flight results
                const SizedBox(width: 16),
              ]
            : actions ??
                  (isHomePage
                      ? const [
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ]
                      : null),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  Widget _buildFlightSearchTitleWithCubit(BuildContext context) {
    return BlocBuilder<FlightSearchCubit, FlightSearchState>(
      buildWhen: (previous, current) {
        // Only rebuild if searchData changes
        return previous.searchData != current.searchData ||
            previous.isLoading != current.isLoading;
      },
      builder: (context, state) {
        print('GradientAppBar rebuilding with searchData: ${state.searchData}');

        if (state.isLoading) {
          return _buildLoadingState();
        } else {
          return _buildFlightSearchDetails(state.searchData);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Searching flights...',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFlightSearchDetails(Map<String, dynamic> searchData) {
    // Use the safeSearchData method from your state to ensure all keys exist
    final safeData = {
      'from': searchData['from'] ?? '',
      'to': searchData['to'] ?? '',
      'departureDate': searchData['departureDate'] ?? '',
      'returnDate': searchData['returnDate'] ?? '',
      'adults': searchData['adults'] is int ? searchData['adults'] : 1,
      'children': searchData['children'] is int ? searchData['children'] : 0,
      'infants': searchData['infants'] is int ? searchData['infants'] : 0,
      'cabinClass': searchData['cabinClass'] is String
          ? searchData['cabinClass']
          : 'Economy',
      'type': searchData['type'] is String ? searchData['type'] : 'oneway',
    };

    final from = safeData['from']?.toString() ?? '';
    final to = safeData['to']?.toString() ?? '';
    final adults = safeData['adults'] as int;
    final children = safeData['children'] as int;
    final infants = safeData['infants'] as int;
    final totalPassengers = adults + children + infants;
    final cabinClass = safeData['cabinClass']?.toString() ?? 'Economy';
    final departureDate = safeData['departureDate']?.toString() ?? '';
    final isRoundTrip = safeData['type'] == 'round';
    final returnDate = safeData['returnDate']?.toString() ?? '';

    // Extract airport codes if available (format: "DXB - Dubai")
    final fromCode = from.contains(' - ') ? from.split(' - ').first : from;
    final toCode = to.contains(' - ') ? to.split(' - ').first : to;

    // Format date from "31-Aug-2025" to "31 Aug"
    String formatDate(String dateString) {
      if (dateString.contains('-')) {
        try {
          final parts = dateString.split('-');
          if (parts.length == 3) {
            final day = parts[0];
            final monthAbbr = parts[1];
            return '$day $monthAbbr';
          }
          return dateString;
        } catch (e) {
          return dateString;
        }
      }
      return dateString;
    }

    final formattedDepartureDate = formatDate(departureDate);
    final formattedReturnDate = isRoundTrip && returnDate.isNotEmpty
        ? formatDate(returnDate)
        : '';

    return GestureDetector(
      onTap: onDestinationTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main route line
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flight_takeoff, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                fromCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),

              // Round trip or one-way indicator
              isRoundTrip
                  ? Icon(Icons.sync, size: 16, color: Colors.white)
                  : Icon(Icons.arrow_forward, size: 16, color: Colors.white),

              const SizedBox(width: 8),
              Icon(Icons.flight_land, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                toCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Details row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Passenger icon
              Icon(Icons.person, size: 12, color: Colors.white),
              const SizedBox(width: 2),
              Text(
                '$totalPassengers ${totalPassengers > 1 ? 'Passengers' : 'Passenger'}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 2, backgroundColor: Colors.white),
              const SizedBox(width: 8),

              // Class
              Text(
                cabinClass,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 2, backgroundColor: Colors.white),
              const SizedBox(width: 8),

              // Calendar icon
              Icon(Icons.calendar_today, size: 12, color: Colors.white),
              const SizedBox(width: 2),

              // Dates
              if (isRoundTrip && formattedReturnDate.isNotEmpty)
                Text(
                  '$formattedDepartureDate → $formattedReturnDate',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )
              else
                Text(
                  formattedDepartureDate,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeAppBarContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Current location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w100,
            fontFamily: 'Almarai',
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SizedBox(width: 4),
            Text(
              "Dubai, UAE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                fontFamily: 'Almarai',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
