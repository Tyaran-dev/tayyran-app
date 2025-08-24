import 'package:tayyran_app/core/constants/app_assets.dart';

class OnBoardingModel {
  final String imagePath;
  final String title;
  final String desc;

  const OnBoardingModel({
    required this.imagePath,
    required this.title,
    required this.desc,
  });

  static List<OnBoardingModel> onBoardingList = [
    OnBoardingModel(
      imagePath: AppAssets.onBoarding1,
      title: "Ready to Fly?",
      desc:
          "Find and book your perfect flight. Search by destination, date, and price. Let's get you there!",
    ),
    OnBoardingModel(
      imagePath: AppAssets.onBoarding2,
      title: "Customize Your Stay",
      desc:
          "Personalize your booking and enjoy a more comfortable and convenient hotel stay.",
    ),
    OnBoardingModel(
      imagePath: AppAssets.onBoarding3,
      title: "Connecting with You",
      desc:
          "We've become a trusted name in travel, dedicated to providing exceptional service and support.",
    ),
  ];
}
