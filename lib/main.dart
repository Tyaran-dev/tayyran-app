import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tayyran_app/core/localization/localization.dart';
import 'package:tayyran_app/core/routes/app_routes.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_cubit.dart';
import 'package:tayyran_app/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:tayyran_app/presentation/splash/cubit/splash_cubit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashCubit()),
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(create: (_) => MainAppCubit()), // Add this provider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
      ),
    );
  }
}
