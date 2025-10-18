part of 'language_cubit.dart';

abstract class LanguageState {
  const LanguageState();
}

class LanguageInitial extends LanguageState {}

class LanguageChanging extends LanguageState {}

class LanguageChanged extends LanguageState {
  final String languageCode;

  const LanguageChanged(this.languageCode);
}

class LanguageRefreshed extends LanguageState {
  final String languageCode;

  const LanguageRefreshed(this.languageCode);
}

class LanguageError extends LanguageState {
  final String message;

  const LanguageError(this.message);
}
