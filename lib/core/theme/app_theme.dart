import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey[600]),
      floatingLabelStyle: const TextStyle(
        color: AppColors.splashBackgroundColorEnd,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: AppColors.splashBackgroundColorEnd,
          width: 2.0,
        ),
      ),
    ),
    // 🔹 Date Picker Theme
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: AppColors.splashBackgroundColorEnd,
      headerForegroundColor: Colors.white,
      dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.splashBackgroundColorEnd;
        }
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade200;
        }
        return null;
      }),

      todayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.splashBackgroundColorEnd;
        }
        return Colors.white;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return AppColors.splashBackgroundColorEnd;
      }),
      todayBorder: BorderSide(
        color: AppColors.splashBackgroundColorEnd,
        width: 1,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.black;
      }),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.splashBackgroundColorEnd,
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
  );
}
