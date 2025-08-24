import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

/// A customizable gradient button widget.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? height;
  final bool isLoading;
  final Widget? icon;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.padding,
    this.height = 40,
    this.borderRadius = 12.0,
    this.isLoading = false,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Material(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            width: width,
            height: height,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                  : LinearGradient(
                      colors: [
                        AppColors.splashBackgroundColorEnd,
                        AppColors.splashBackgroundColorStart,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDisabled ? Colors.grey : Colors.white,
                width: 1,
              ),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[icon!, const SizedBox(width: 8)],
                        Text(
                          text,
                          style:
                              textStyle ??
                              const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
