import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_background.dart';
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
            backgroundColor: Colors.transparent,
            appBar: GradientAppBar(title: 'Bookings', showBackButton: false),
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
                    'Booking Content Goes Here',
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
