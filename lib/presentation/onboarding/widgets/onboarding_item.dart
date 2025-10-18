import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tayyran_app/presentation/onboarding/model/onboarding_model.dart';

class OnboardingItem extends StatelessWidget {
  final OnBoardingModel onboardingModel;

  const OnboardingItem({super.key, required this.onboardingModel});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image with proper scaling
          SizedBox(
            height: size.height * 0.40,
            width: size.width * 0.8,
            child: Image.asset(
              onboardingModel.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported,
                size: 100,
                color: Colors.grey[300],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              onboardingModel.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.bold,
                fontSize: 32,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              onboardingModel.descKey.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.normal,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
