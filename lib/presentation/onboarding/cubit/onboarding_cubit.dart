import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  void setActiveIndex(int index) {
    emit(state.copyWith(activeIndex: index));
  }

  void emitError(String errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage, isLoading: false));
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // This is now handled in the UI layer
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Failed to complete onboarding",
        ),
      );
    }
  }
}
