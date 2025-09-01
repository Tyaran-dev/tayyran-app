// date_text_field.dart
import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class DateTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasError;

  const DateTextField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: hasError ? Colors.red : Colors.grey[600],
            ),
            labelText: label,
            labelStyle: TextStyle(
              color: hasError ? Colors.red : Colors.grey[600],
            ),
            floatingLabelStyle: TextStyle(
              color: hasError ? Colors.red : AppColors.splashBackgroundColorEnd,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade400,
                width: hasError ? 2.0 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.deepPurple,
                width: hasError ? 2.0 : 2.0,
              ),
            ),
            filled: true,
            fillColor: hasError ? Colors.red.withOpacity(0.05) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
