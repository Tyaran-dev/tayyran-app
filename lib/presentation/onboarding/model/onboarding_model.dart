import 'package:tayyran_app/core/constants/app_assets.dart';
import 'package:easy_localization/easy_localization.dart';

class OnBoardingModel {
  final String imagePath;
  final String titleKey;
  final String descKey;

  const OnBoardingModel({
    required this.imagePath,
    required this.titleKey,
    required this.descKey,
  });

  String get title => titleKey.tr();
  String get description => descKey.tr();

  static List<OnBoardingModel> onBoardingList = [
    OnBoardingModel(
      imagePath: AppAssets.onBoarding1,
      titleKey: "onboarding_title_1",
      descKey: "onboarding_desc_1",
    ),
    OnBoardingModel(
      imagePath: AppAssets.onBoarding2,
      titleKey: "onboarding_title_2",
      descKey: "onboarding_desc_2",
    ),
    OnBoardingModel(
      imagePath: AppAssets.onBoarding3,
      titleKey: "onboarding_title_3",
      descKey: "onboarding_desc_3",
    ),
  ];
}
