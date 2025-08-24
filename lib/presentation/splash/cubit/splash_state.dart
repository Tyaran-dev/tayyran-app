part of 'splash_cubit.dart';

@immutable
abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashNavigationState extends SplashState {
  final String routeName;
  final Object? args;

  SplashNavigationState(this.routeName, [this.args]);
}

class SplashErrorState extends SplashState {
  final String errorMessage;

  SplashErrorState(this.errorMessage);
}
