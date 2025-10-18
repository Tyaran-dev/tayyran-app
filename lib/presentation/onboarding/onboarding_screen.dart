import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/constants/color_constants.dart';
import 'package:tayyran_app/core/routes/route_names.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';
import 'package:tayyran_app/core/utils/widgets/index.dart';
import 'package:tayyran_app/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:tayyran_app/presentation/onboarding/model/onboarding_model.dart';
import 'package:tayyran_app/presentation/onboarding/widgets/onboarding_item.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const OnboardingScreenContent(),
    );
  }
}

class OnboardingScreenContent extends StatefulWidget {
  const OnboardingScreenContent({super.key});

  @override
  State<OnboardingScreenContent> createState() =>
      _OnboardingScreenContentState();
}

class _OnboardingScreenContentState extends State<OnboardingScreenContent> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
  }

  void _pageListener() {
    final page = _pageController.page?.round();
    if (page != null) {
      context.read<OnboardingCubit>().setActiveIndex(page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  if (state.activeIndex !=
                      OnBoardingModel.onBoardingList.length - 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GradientButton(
                          text: 'skip_all'.tr(),
                          width: 110,
                          borderRadius: 50,
                          onPressed: state.isLoading
                              ? null
                              : () => _navigateToHomeScreen(context),
                        ),
                      ],
                    ),
                  SizedBox(height: 65),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().setActiveIndex(index);
                      },
                      itemCount: OnBoardingModel.onBoardingList.length,
                      itemBuilder: (context, index) {
                        return OnboardingItem(
                          onboardingModel:
                              OnBoardingModel.onBoardingList[index],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  AnimatedSmoothIndicator(
                    activeIndex: state.activeIndex,
                    count: OnBoardingModel.onBoardingList.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      dotColor: Colors.grey,
                      activeDotColor: AppColors.splashBackgroundColorEnd,
                    ),
                  ),

                  const SizedBox(height: 20),
                  if (state.isLoading)
                    const CircularProgressIndicator()
                  else
                    GradientButton(
                      text:
                          state.activeIndex ==
                              OnBoardingModel.onBoardingList.length - 1
                          ? 'get_started'.tr()
                          : 'next'.tr(),
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.85,
                      onPressed: () {
                        if (state.activeIndex ==
                            OnBoardingModel.onBoardingList.length - 1) {
                          _completeOnboarding(context);
                        } else {
                          _pageController.animateToPage(
                            state.activeIndex + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _completeOnboarding(BuildContext context) async {
    try {
      await SharedPreferencesService.setFirstTimeCompleted();
      _navigateToHomeScreen(context);
    } catch (e) {
      context.read<OnboardingCubit>().emitError('Failed to save preferences');
    }
  }

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, RouteNames.home);
  }
}
