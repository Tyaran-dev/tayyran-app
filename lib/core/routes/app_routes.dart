import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/presentation/booking/booking_screen.dart';
import 'package:tayyran_app/presentation/discount/discount_screen.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/flight_search_screen.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_cubit.dart';
import 'package:tayyran_app/presentation/main_screen/main_app_screen.dart';
import 'package:tayyran_app/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:tayyran_app/presentation/onboarding/onboarding_screen.dart';
import 'package:tayyran_app/presentation/profile/profile_screen.dart';
import 'package:tayyran_app/presentation/splash/splash_screen.dart';
import 'package:tayyran_app/presentation/stay/stay_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => PopScope(
            canPop: false, // ⛔ disables system back
            child: SplashScreen(),
          ),
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

      case RouteNames.flightSearch:
        final searchData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => FlightSearchCubit(),
            child: FlightSearchScreen(searchData: searchData),
          ),
          settings: const RouteSettings(name: RouteNames.flightSearch),
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
