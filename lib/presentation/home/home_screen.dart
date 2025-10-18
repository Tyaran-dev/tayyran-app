// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tayyran_app/core/constants/app_assets.dart';
// import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_background.dart';
import 'package:tayyran_app/presentation/flight/flight_screen.dart';
import 'package:tayyran_app/presentation/home/cubit/home_cubit.dart';
import 'package:tayyran_app/presentation/home/cubit/home_state.dart';
import 'package:tayyran_app/presentation/stay/stay_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return GradientBackground(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildTabs(context, state),
                  Expanded(
                    child: state.selectedTab == "flight"
                        ? const FlightScreen()
                        : const StayScreen(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabs(BuildContext context, HomeState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      // padding: const EdgeInsets.all(6),
      height: 0,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(30),
      //   border: Border.all(color: Colors.black),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.05),
      //       blurRadius: 6,
      //       offset: const Offset(0, 3),
      //     ),
      //   ],
      // ),
      child: SizedBox(height: 0),
      // Row(
      //   children: [
      //     Expanded(
      //       child: GestureDetector(
      //         onTap: () => context.read<HomeCubit>().changeTab("stay"),
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(
      //             vertical: 12,
      //             horizontal: 10,
      //           ),
      //           decoration: BoxDecoration(
      //             color: state.selectedTab == "stay"
      //                 ? AppColors.splashBackgroundColorEnd
      //                 : Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //           ),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               ImageIcon(
      //                 AssetImage(AppAssets.stayIcon),
      //                 color: state.selectedTab == "stay"
      //                     ? Colors.white
      //                     : AppColors.splashBackgroundColorEnd,
      //                 size: 20,
      //               ),
      //               const SizedBox(width: 6),
      //               Text(
      //                 "Stay",
      //                 style: TextStyle(
      //                   color: state.selectedTab == "stay"
      //                       ? Colors.white
      //                       : AppColors.splashBackgroundColorEnd,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       child: GestureDetector(
      //         onTap: () => context.read<HomeCubit>().changeTab("flight"),
      //         child: Container(
      //           padding: const EdgeInsets.symmetric(
      //             vertical: 12,
      //             horizontal: 10,
      //           ),
      //           decoration: BoxDecoration(
      //             color: state.selectedTab == "flight"
      //                 ? AppColors.splashBackgroundColorEnd
      //                 : Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //           ),
      //           child: Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               ImageIcon(
      //                 AssetImage(AppAssets.flightIcon),
      //                 color: state.selectedTab == "flight"
      //                     ? Colors.white
      //                     : AppColors.splashBackgroundColorEnd,
      //                 size: 20,
      //               ),
      //               const SizedBox(width: 6),
      //               Text(
      //                 "Flight",
      //                 style: TextStyle(
      //                   color: state.selectedTab == "flight"
      //                       ? Colors.white
      //                       : AppColors.splashBackgroundColorEnd,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
