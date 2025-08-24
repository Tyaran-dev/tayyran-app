import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            appBar: AppBar(
              backgroundColor: Colors.transparent, // transparent app bar
              elevation: 0,
              title: const Text(
                'My Profile',
                style: TextStyle(color: Colors.white),
              ),
              automaticallyImplyLeading: false, // no back arrow
            ),
            body: Container(
              color: Colors.white, // allow gradient behind
            ),
          );
        },
      ),
    );
  }
}
