import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            appBar: AppBar(
              backgroundColor: Colors.transparent, // transparent app bar
              elevation: 0,
              title: const Text(
                'My Discounts',
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
