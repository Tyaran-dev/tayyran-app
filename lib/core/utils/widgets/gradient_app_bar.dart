// gradient_app_bar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/helpers/app_extensions.dart';
import 'package:tayyran_app/core/utils/helpers/helpers.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_state.dart';
import 'package:tayyran_app/presentation/settings/cubit/language_cubit.dart';

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
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return AppBar(
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
                              title.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Almarai',
                              ),
                            )),
            centerTitle: true,
            actions: isFlightResults
                ? [
                    // Empty actions for flight results
                    const SizedBox(width: 16),
                  ]
                : [const SizedBox(width: 16)],
            systemOverlayStyle: SystemUiOverlayStyle.light,
          );
        },
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
          return _buildFlightSearchDetails(context, state.searchData);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Row(
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
          'search_flights_loading'.tr(),
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFlightSearchDetails(
    BuildContext context,
    Map<String, dynamic> searchData,
  ) {
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
      'flightType': searchData['flightType'] is String
          ? searchData['flightType']
          : 'oneway',
      'multiCityRoutes': searchData['multiCityRoutes'] is List
          ? searchData['multiCityRoutes']
          : [],
    };

    final from = safeData['from']?.toString() ?? '';
    final to = safeData['to']?.toString() ?? '';
    final adults = safeData['adults'] as int;
    final children = safeData['children'] as int;
    final infants = safeData['infants'] as int;
    final totalPassengers = adults + children + infants;
    final cabinClass = safeData['cabinClass']?.toString() ?? 'Economy';
    final departureDate = safeData['departureDate']?.toString() ?? '';
    final isRoundTrip = safeData['flightType'] == 'round';
    final isMultiCity = safeData['flightType'] == 'multi';
    final returnDate = safeData['returnDate']?.toString() ?? '';
    final multiCityRoutes = safeData['multiCityRoutes'] as List;

    // For multi-city, show simplified route
    if (isMultiCity && multiCityRoutes.isNotEmpty) {
      return _buildMultiCityAppBar(
        multiCityRoutes,
        totalPassengers,
        cabinClass,
      );
    }

    // Extract airport codes if available (format: "DXB - Dubai")
    final fromCode = from.contains(' - ') ? from.split(' - ').first : from;
    final toCode = to.contains(' - ') ? to.split(' - ').first : to;

    // Format date for display in app bar (day and month only)
    String formatDateForAppBar(String dateString, BuildContext context) {
      if (dateString.isEmpty) return "";

      print('🔧 formatDateForAppBar input: "$dateString"');

      try {
        // Parse the date using helper function
        final dateTime = parseDate(dateString);
        print('🔧 Parsed dateTime: $dateTime');

        // Use helper function to format the date according to locale
        final fullFormattedDate = formatDateForDisplay(dateTime, context);
        print('🔧 Full formatted date: "$fullFormattedDate"');

        // Extract just the day and month part for display (remove year)
        final parts = fullFormattedDate.split('-');
        if (parts.length == 3) {
          final day = parts[0];
          final month = parts[1];
          final result = '$day $month';
          print('✅ App bar date result: "$result"');
          return result;
        }
        return fullFormattedDate;
      } catch (e) {
        print('❌ Error formatting date for app bar: $e');
        // Fallback: try to extract day and month directly
        if (dateString.contains('-')) {
          try {
            final parts = dateString.split('-');
            if (parts.length == 3) {
              final day = parts[0];
              final month = parts[1];
              return '$day $month';
            }
          } catch (e2) {
            print('❌ Manual date formatting also failed: $e2');
          }
        }
        return dateString;
      }
    }

    final formattedDepartureDate = formatDateForAppBar(departureDate, context);
    final formattedReturnDate = isRoundTrip && returnDate.isNotEmpty
        ? formatDateForAppBar(returnDate, context)
        : '';

    return _buildStandardFlightAppBar(
      fromCode: fromCode,
      toCode: toCode,
      isRoundTrip: isRoundTrip,
      totalPassengers: totalPassengers,
      cabinClass: cabinClass,
      formattedDepartureDate: formattedDepartureDate,
      formattedReturnDate: formattedReturnDate,
    );
  }

  Widget _buildMultiCityAppBar(
    List<dynamic> routes,
    int totalPassengers,
    String cabinClass,
  ) {
    // Get first and last destinations for simplified display
    String firstFrom = '';
    String lastTo = '';

    if (routes.isNotEmpty) {
      final firstRoute = routes.first;
      final lastRoute = routes.last;

      if (firstRoute is Map) {
        firstFrom = _extractAirportCode(firstRoute['from']?.toString() ?? '');
      }
      if (lastRoute is Map) {
        lastTo = _extractAirportCode(lastRoute['to']?.toString() ?? '');
      }
    }

    final routeCount = routes.length;

    return GestureDetector(
      onTap: null, // Disable tap for multi-city
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main multi-city route
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flight_takeoff, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                firstFrom.isNotEmpty ? firstFrom : '...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),

              // Multi-city indicator
              Row(
                children: [
                  Icon(Icons.more_horiz, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$routeCount ${routeCount > 1 ? 'flights' : 'flight'}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.more_horiz, size: 16, color: Colors.white),
                ],
              ),

              const SizedBox(width: 8),
              Icon(Icons.flight_land, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                lastTo.isNotEmpty ? lastTo : '...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Details row - simplified for multi-city
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Passenger icon
              Icon(Icons.people, size: 12, color: Colors.white),
              const SizedBox(width: 2),
              Text(
                '$totalPassengers',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 2, backgroundColor: Colors.white),
              const SizedBox(width: 8),

              // Class
              Text(
                cabinClass.toCabinClassDisplayName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 2, backgroundColor: Colors.white),
              const SizedBox(width: 8),

              // Multi-city indicator
              Icon(Icons.account_tree, size: 12, color: Colors.white),
              const SizedBox(width: 2),
              Text(
                'Multi-City',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandardFlightAppBar({
    required String fromCode,
    required String toCode,
    required bool isRoundTrip,
    required int totalPassengers,
    required String cabinClass,
    required String formattedDepartureDate,
    required String formattedReturnDate,
  }) {
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
                '$totalPassengers ${totalPassengers > 1 ? 'Passengers'.tr() : 'Passenger'.tr()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 2, backgroundColor: Colors.white),
              const SizedBox(width: 8),

              // Class
              Text(
                cabinClass.toCabinClassDisplayName.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 2, backgroundColor: Colors.white),
              const SizedBox(width: 8),

              // Calendar icon
              Icon(Icons.calendar_today, size: 12, color: Colors.white),
              const SizedBox(width: 2),

              // Dates - responsive text
              if (isRoundTrip && formattedReturnDate.isNotEmpty)
                _buildResponsiveText(
                  '$formattedDepartureDate → $formattedReturnDate',
                  maxChars: 25,
                )
              else
                _buildResponsiveText(formattedDepartureDate, maxChars: 15),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveText(String text, {int maxChars = 20}) {
    // For very small screens, truncate long text
    if (text.length > maxChars) {
      return Flexible(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      return Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }
  }

  String _extractAirportCode(String location) {
    return location.contains(' - ') ? location.split(' - ').first : location;
  }

  Widget _buildHomeAppBarContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "home".tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Almarai',
          ),
        ),
      ],
    );
  }
}
