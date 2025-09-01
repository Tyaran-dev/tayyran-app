// utils/gradient_background.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Alignment begin;
  final Alignment end;

  const GradientBackground({
    super.key,
    required this.child,
    this.begin = Alignment.bottomRight,
    this.end = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.splashBackgroundColorStart,
            AppColors.splashBackgroundColorEnd,
          ],
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}
