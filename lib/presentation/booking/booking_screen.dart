import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/presentation/booking/cubit/booking_cubit.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(),
      child: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent, // allow gradient behind
            appBar: AppBar(
              backgroundColor: Colors.transparent, // transparent app bar
              elevation: 0,
              title: const Text(
                'My Bookings',
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
