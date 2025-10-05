// main.dart - Fixed version
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/localization/localization.dart';
import 'package:tayyran_app/core/routes/app_routes.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/theme/app_theme.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/splash/cubit/splash_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashCubit()),
        BlocProvider(create: (_) => FlightCubit()),
        BlocProvider(create: (_) => getIt<FlightSearchCubit>()),
        BlocProvider(create: (_) => getIt<AirportSearchCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        title: 'Tayyran',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en', ''), const Locale('ar', '')],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: RouteNames.splash,
        // home: PaymentStatusScreen(),
      ),
    );
  }
}
