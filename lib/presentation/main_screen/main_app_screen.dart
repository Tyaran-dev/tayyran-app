// main_app_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/presentation/booking/booking_screen.dart';
import 'package:tayyran_app/presentation/discount/discount_screen.dart';
import 'package:tayyran_app/presentation/home/home_screen.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_cubit.dart';
import 'package:tayyran_app/presentation/main_screen/cubit/main_app_state.dart';
import 'package:tayyran_app/presentation/profile/profile_screen.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainAppCubit, MainAppState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true, // Allow gradient behind AppBar
          extendBody: true, // Allow gradient behind bottom nav
          appBar: _buildAppBar(state.currentTabIndex),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.splashBackgroundColorStart,
                  AppColors.splashBackgroundColorEnd,
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: SafeArea(child: _buildCurrentTab(state.currentTabIndex)),
          ),
          bottomNavigationBar: _buildBottomNavBar(context, state),
        );
      },
    );
  }

  /// Custom app bar that changes based on the current tab
  PreferredSizeWidget? _buildAppBar(int tabIndex) {
    if (tabIndex != 0) return null; // only on Home

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false, // no back arrow
      centerTitle: true,
      toolbarHeight: 88, // make room for the two-line header
      titleSpacing: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Current location",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w100,
              fontFamily: 'Almarai',
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.location_on, color: Colors.white, size: 20),
              SizedBox(width: 4),
              Text(
                "Dubai, UAE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.notifications, color: Colors.white, size: 26),
        ),
      ],
    );
  }

  /// Switch between tab screens
  Widget _buildCurrentTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const BookingScreen();
      case 2:
        return const DiscountScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  /// Bottom nav bar design
  Widget _buildBottomNavBar(BuildContext context, MainAppState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Discounts",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
