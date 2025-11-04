// lib/presentation/settings/cubit/language_cubit.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/services/app_locale.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  Future<void> initializeLanguage(BuildContext context) async {
    try {
      // Initialize AppLocale first
      await AppLocale().initialize();

      // Get saved language from AppLocale (which uses SharedPreferences)
      final savedLanguage = AppLocale().languageCode;
      print('🔍 Initializing with saved language: $savedLanguage');

      // Update Dio client
      updateDioClientLanguage(savedLanguage);

      // Sync with EasyLocalization context
      AppLocale().syncWithEasyLocalization(context);

      // Update EasyLocalization if different from current
      if (context.locale.languageCode != savedLanguage) {
        print('🔄 Updating EasyLocalization to: $savedLanguage');
        await context.setLocale(Locale(savedLanguage));
      }

      emit(LanguageChanged(savedLanguage));
      print('✅ Language initialized: $savedLanguage');
    } catch (e) {
      print('❌ Error initializing language: $e');
      updateDioClientLanguage('ar');
      emit(LanguageChanged('ar'));
    }
  }

  Future<void> changeLanguage(
    String languageCode, {
    required BuildContext context,
  }) async {
    try {
      emit(LanguageChanging());
      print('🔄 Changing language to: $languageCode');

      // Update AppLocale
      await AppLocale().setLocale(Locale(languageCode), context: context);

      // Update Dio client
      updateDioClientLanguage(languageCode);

      // Emit state after UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emit(LanguageChanged(languageCode));
        print('✅ Language changed successfully: $languageCode');
      });
    } catch (e) {
      print('❌ Error changing language: $e');
      emit(LanguageError(e.toString()));
    }
  }

  // Get current language without context
  String getCurrentLanguage() {
    return AppLocale().languageCode;
  }

  bool isArabic() {
    return AppLocale().isArabic;
  }

  bool isEnglish() {
    return AppLocale().isEnglish;
  }
}
