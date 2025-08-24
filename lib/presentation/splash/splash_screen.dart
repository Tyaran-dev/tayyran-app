import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashFlow();
  }

  void _startSplashFlow() async {
    // Wait for both splash duration and SharedPreferences initialization
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      SharedPreferencesService.isFirstTime(),
    ]).then((results) {
      final isFirstTime = results[1] as bool;

      if (!mounted) return;

      if (isFirstTime) {
        Navigator.pushReplacementNamed(context, RouteNames.onboarding);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.splashBackgroundColorStart,
              AppColors.splashBackgroundColorEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ClipOval(
            child: Image.asset(
              AppAssets.splashLogo,
              width: 311,
              height: 311,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
