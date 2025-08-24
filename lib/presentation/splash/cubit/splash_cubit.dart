import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayyran_app/core/routes/route_names.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkFirstTime() async {
    emit(SplashLoading());

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Minimum splash time

      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        // User is first time - go to onboarding
        emit(SplashNavigationState(RouteNames.onboarding));
      } else {
        // User has completed onboarding - go to home
        emit(SplashNavigationState(RouteNames.home));
      }
    } catch (e) {
      emit(
        SplashErrorState(
          'Failed to load app. Please check your connection and try again.',
        ),
      );
    }
  }

  Future<void> setFirstTimeCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
    } catch (e) {
      // Handle error silently or log it
      print('Error setting first time: $e');
    }
  }
}
