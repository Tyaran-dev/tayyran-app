import 'package:flutter/material.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';

class AirportTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isOrigin;
  final VoidCallback onTap;

  const AirportTextField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isOrigin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[600]),
            floatingLabelStyle: const TextStyle(
              color: AppColors.splashBackgroundColorEnd,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.deepPurple,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
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
