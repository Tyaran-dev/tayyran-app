import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/routes/app_routes.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/core/theme/app_theme.dart';
import 'package:tayyran_app/presentation/airport_search/cubit/airport_search_cubit.dart';
import 'package:tayyran_app/presentation/flight/cubit/flight_cubit.dart';
import 'package:tayyran_app/presentation/flight_search/cubit/flight_search_cubit.dart';
import 'package:tayyran_app/presentation/settings/cubit/language_cubit.dart';
import 'package:tayyran_app/presentation/splash/cubit/splash_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  setupDependencies();

  // Get saved language before running app
  final savedLanguage = await SharedPreferencesService.getLanguage();
  print('🚀 App starting with language: $savedLanguage');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: Locale(savedLanguage), // Use saved language
      child: MyApp(),
    ),
  );
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
        BlocProvider(create: (_) => LanguageCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: RouteNames.splash,
            // home: PaymentStatusScreen(invoiceId: "58288833"),
            builder: (context, child) {
              // Initialize language when app starts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final languageCubit = context.read<LanguageCubit>();
                if (languageCubit.state is LanguageInitial) {
                  languageCubit.initializeLanguage(context);
                }
              });

              return BlocBuilder<LanguageCubit, LanguageState>(
                builder: (context, state) {
                  print('🌍 Current language state: $state');
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}
