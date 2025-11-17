// lib/core/routes/app_routes.dart (updated)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/data/api/hotel_api_service.dart';
import 'package:tayyran_app/data/repositories/flight_pricing_repository.dart';
import 'package:tayyran_app/data/repositories/payment_repository.dart';
import 'package:tayyran_app/presentation/airport_search/airport_bottom_sheet.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/booking/booking_screen.dart';
import 'package:tayyran_app/presentation/discount/discount_screen.dart';
import 'package:tayyran_app/presentation/flight/models/flight_segment.dart';
import 'package:tayyran_app/presentation/flight_detail/cubit/flight_detail_cubit.dart';
import 'package:tayyran_app/presentation/flight_detail/flight_detail_screen.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/flight_search_screen.dart';
import 'package:tayyran_app/presentation/hotel_details/hotel_details_screen.dart';
import 'package:tayyran_app/presentation/hotels_search/cubit/hotel_search_cubit.dart';
import 'package:tayyran_app/presentation/hotels_search/hotel_search_screen.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_cubit.dart';
import 'package:tayyran_app/presentation/main_screen/main_app_screen.dart';
import 'package:tayyran_app/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:tayyran_app/presentation/onboarding/onboarding_screen.dart';
import 'package:tayyran_app/presentation/passenger_info/cubit/passenger_info_cubit.dart';
import 'package:tayyran_app/presentation/passenger_info/passenger_info_screen.dart';
import 'package:tayyran_app/presentation/payment/cubit/payment_cubit.dart';
import 'package:tayyran_app/presentation/payment/model/payment_arguments.dart';
import 'package:tayyran_app/presentation/payment/payment_screen.dart';
import 'package:tayyran_app/presentation/payment_status/cubit/payment_status_cubit.dart';
import 'package:tayyran_app/presentation/payment_status/payment_status_screen.dart';
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
        final arg = settings.arguments as TicketArguments;
        final flightOffer = arg.flightOffer;
        final filterCarrier = arg.filters;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => FlightDetailCubit(
              flightOffer: flightOffer,
              filterCarrier: filterCarrier,
              pricingRepository: getIt<FlightPricingRepository>(),
            ),
            child: const FlightDetailScreen(),
          ),
          settings: const RouteSettings(name: RouteNames.flightDetail),
        );

      case RouteNames.passengerInfo:
        final args = settings.arguments as TicketArguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => PassengerInfoCubit(
              flightOffer: args.flightOffer,
              filters: args.filters, // Pass filters to cubit
              pricingRepository: getIt<FlightPricingRepository>(),
            ),
            child: const PassengerInfoScreen(),
          ),
          settings: const RouteSettings(name: RouteNames.passengerInfo),
        );
      case RouteNames.payment:
        final args = settings.arguments as PaymentArguments;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => PaymentCubit(
              getIt<PaymentRepository>(), // Inject repository here
              args,
            ),
            child: PaymentScreen(args: args),
          ),
          settings: const RouteSettings(name: RouteNames.payment),
        );

      case RouteNames.paymentStatus:
        final arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => PaymentStatusCubit(
              getIt<PaymentRepository>(),
              arguments['invoiceId'],
            ),
            child: PaymentStatusScreen(invoiceId: arguments['invoiceId']),
          ),
          settings: const RouteSettings(name: RouteNames.paymentStatus),
        );
      case RouteNames.hotelSearch:
        final searchParams = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => HotelSearchCubit(getIt<HotelApiService>()),
            child: HotelSearchScreen(searchParams: searchParams),
          ),
          settings: const RouteSettings(name: RouteNames.hotelSearch),
        );
      case RouteNames.hotelDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HotelDetailsScreen(
            hotel: args['hotel'],
            searchParams: args['searchParams'],
          ),
          settings: const RouteSettings(name: RouteNames.hotelDetails),
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
