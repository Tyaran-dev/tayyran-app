import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_background.dart';
import 'package:tayyran_app/presentation/profile/cubit/profile_cubit.dart';
import 'package:tayyran_app/presentation/profile/cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent, // allow gradient behind
            appBar: GradientAppBar(title: 'Profile', showBackButton: false),
            body: GradientBackground(
              begin: Alignment.topRight,
              end: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.only(
                  top: 20,
                ), // Space between app bar and content
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                // Your booking content here
                child: Center(
                  child: Text(
                    'Profile Content Goes Here',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
