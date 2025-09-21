// lib/core/routes/app_routes.dart (updated)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/data/models/flight_search_response.dart';
import 'package:tayyran_app/data/repositories/flight_pricing_repository.dart';
import 'package:tayyran_app/presentation/airport_search/airport_bottom_sheet.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/booking/booking_screen.dart';
import 'package:tayyran_app/presentation/discount/discount_screen.dart';
import 'package:tayyran_app/presentation/flight_detail/cubit/flight_detail_cubit.dart';
import 'package:tayyran_app/presentation/flight_detail/flight_detail_screen.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/flight_search_screen.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_cubit.dart';
import 'package:tayyran_app/presentation/main_screen/main_app_screen.dart';
import 'package:tayyran_app/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:tayyran_app/presentation/onboarding/onboarding_screen.dart';
import 'package:tayyran_app/presentation/passenger_info/passenger_info_screen.dart';
import 'package:tayyran_app/presentation/profile/profile_screen.dart';
import 'package:tayyran_app/presentation/splash/splash_screen.dart';
import 'package:tayyran_app/presentation/stay/stay_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => PopScope(canPop: false, child: SplashScreen()),
          settings: const RouteSettings(name: RouteNames.splash),
        );

      case RouteNames.onboarding:
        return MaterialPageRoute(
          builder: (_) => PopScope(
            canPop: false,
            child: BlocProvider(
              create: (_) => OnboardingCubit(),
              child: const OnboardingScreen(),
            ),
          ),
          settings: const RouteSettings(name: RouteNames.onboarding),
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => PopScope(
            canPop: false,
            child: BlocProvider(
              create: (_) => MainAppCubit(),
              child: const MainAppScreen(),
            ),
          ),
          settings: const RouteSettings(name: RouteNames.home),
        );

      case RouteNames.booking:
        return MaterialPageRoute(
          builder: (_) => PopScope(canPop: false, child: const BookingScreen()),
          settings: const RouteSettings(name: RouteNames.booking),
        );

      case RouteNames.discount:
        return MaterialPageRoute(
          builder: (_) =>
              PopScope(canPop: false, child: const DiscountScreen()),
          settings: const RouteSettings(name: RouteNames.discount),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => PopScope(canPop: false, child: const ProfileScreen()),
          settings: const RouteSettings(name: RouteNames.profile),
        );

      case RouteNames.stay:
        return MaterialPageRoute(
          builder: (_) => PopScope(canPop: false, child: const StayScreen()),
          settings: const RouteSettings(name: RouteNames.stay),
        );

      case RouteNames.airportSelection:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<AirportSearchCubit>(context),
            child: AirportBottomSheet(
              isOrigin: args['isOrigin'],
              currentValue: args['currentValue'],
              segmentId: args['segmentId'],
            ),
          ),
          settings: const RouteSettings(name: RouteNames.airportSelection),
        );

      case RouteNames.flightSearch:
        final searchData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<FlightSearchCubit>(),
            child: FlightSearchScreen(searchData: searchData),
          ),
          settings: const RouteSettings(name: RouteNames.flightSearch),
        );

      case RouteNames.flightDetail:
        final flightOffer = settings.arguments as FlightOffer;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => FlightDetailCubit(
              flightOffer: flightOffer,
              pricingRepository: getIt<FlightPricingRepository>(),
            ),
            child: const FlightDetailScreen(),
          ),
          settings: const RouteSettings(name: RouteNames.flightDetail),
        );

      case RouteNames.passengerInfo:
        final flightOffer = settings.arguments as FlightOffer;
        return MaterialPageRoute(
          builder: (_) => PassengerInfoScreen(flightOffer: flightOffer),
          settings: const RouteSettings(name: RouteNames.passengerInfo),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => PopScope(
            canPop: false,
            child: Scaffold(
              body: Center(
                child: Text('No route defined for ${settings.name}'),
              ),
            ),
          ),
        );
    }
  }
}
