part of 'onboarding_cubit.dart';

@immutable
class OnboardingState {
  final int activeIndex;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.activeIndex = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    int? activeIndex,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      activeIndex: activeIndex ?? this.activeIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OnboardingState &&
        other.activeIndex == activeIndex &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return activeIndex.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;
  }

  static OnboardingState initial() {
    return const OnboardingState();
  }
}
