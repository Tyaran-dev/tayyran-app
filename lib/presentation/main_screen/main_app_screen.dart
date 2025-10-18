// main_app_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
// import 'package:tayyran_app/presentation/booking/booking_screen.dart';
// import 'package:tayyran_app/presentation/discount/discount_screen.dart';
import 'package:tayyran_app/presentation/home/home_screen.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_cubit.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_state.dart';
import 'package:tayyran_app/presentation/settings/cubit/language_cubit.dart';
// import 'package:tayyran_app/presentation/profile/profile_screen.dart';
import 'package:tayyran_app/presentation/settings/settings_screen.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainAppCubit, MainAppState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: _buildAppBar(state.currentTabIndex),
          body: SafeArea(child: _buildCurrentTab(state.currentTabIndex)),
          bottomNavigationBar: _buildBottomNavBar(context, state),
        );
      },
    );
  }

  /// Custom app bar that changes based on the current tab
  PreferredSizeWidget? _buildAppBar(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home
        return GradientAppBar(title: ''.tr(), isHomePage: true, height: 130);
      // case 1: // Bookings
      //   return GradientAppBar(title: 'My Bookings', showBackButton: false);
      // case 2: // Discounts
      //   return GradientAppBar(title: 'Discounts', showBackButton: false);
      // case 3: // Profile
      //   return GradientAppBar(title: 'Profile', showBackButton: false);
      case 1:
        return GradientAppBar(title: ''.tr(), showBackButton: false);
      default:
        return null;
    }
  }

  /// Switch between tab screens
  Widget _buildCurrentTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const HomeScreen();
      // case 1:
      //   return const BookingScreen();
      // case 2:
      //   return const DiscountScreen();
      // case 3:
      //   return const ProfileScreen();
      case 1:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNavBar(BuildContext context, MainAppState state) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: state.currentTabIndex,
            onTap: (index) => context.read<MainAppCubit>().changeTab(index),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            backgroundColor: Colors.white,
            iconSize: 24,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "home".tr(),
              ),
              // BottomNavigationBarItem(
              //   icon: ImageIcon(AssetImage(AppAssets.bookingIcon)),
              //   label: "Bookings",
              // ),
              // BottomNavigationBarItem(
              //   icon: ImageIcon(AssetImage(AppAssets.discountIcon)),
              //   label: "Discounts",
              // ),
              // BottomNavigationBarItem(
              //   icon: ImageIcon(AssetImage(AppAssets.profileIcon)),
              //   label: "Profile",
              // ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(AppAssets.settingsIcon)),
                label: "settings".tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}
