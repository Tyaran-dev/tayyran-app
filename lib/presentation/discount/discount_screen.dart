import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_background.dart';
import 'package:tayyran_app/presentation/discount/cubit/discount_cubit.dart';
import 'package:tayyran_app/presentation/discount/cubit/discount_state.dart';

class DiscountScreen extends StatelessWidget {
  const DiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DiscountCubit(),
      child: BlocBuilder<DiscountCubit, DiscountState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent, // allow gradient behind
            appBar: GradientAppBar(title: 'Discount', showBackButton: false),
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
                    'Discount Content Goes Here',
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
