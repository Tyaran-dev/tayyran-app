// lib/cubits/language_cubit.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayyran_app/core/dependency_injection.dart';
import 'package:tayyran_app/core/services/shared_preferences_service.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  Future<void> initializeLanguage(BuildContext context) async {
    try {
      // 🎯 FIRST: Get saved language from SharedPreferences
      final savedLanguage = await SharedPreferencesService.getLanguage();
      print('🔍 Initializing with saved language: $savedLanguage');
      // 🧠 Update helper cache
      // 🎯 SECOND: Update Dio client with saved language
      updateDioClientLanguage(savedLanguage);

      // 🎯 THIRD: Update EasyLocalization if different from current
      if (context.locale.languageCode != savedLanguage) {
        print('🔄 Updating EasyLocalization to: $savedLanguage');
        await context.setLocale(Locale(savedLanguage));
      }

      // 🎯 FINALLY: Emit the state
      emit(LanguageChanged(savedLanguage));
      print('✅ Language initialized: $savedLanguage');
    } catch (e) {
      print('❌ Error initializing language: $e');
      // Fallback to Arabic
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

      // 🎯 FIRST: Save to SharedPreferences
      await SharedPreferencesService.saveLanguage(languageCode);

      // 🧠 SECOND: Update helper cache immediately

      // 🎯 SECOND: Update Dio client
      updateDioClientLanguage(languageCode);

      // 🎯 THIRD: Update EasyLocalization
      final newLocale = Locale(languageCode);
      await context.setLocale(newLocale);

      // 🎯 FINALLY: Emit state after UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emit(LanguageChanged(languageCode));
        print('✅ Language changed successfully: $languageCode');
      });
    } catch (e) {
      print('❌ Error changing language: $e');
      emit(LanguageError(e.toString()));
    }
  }

  // Your existing methods remain the same...
  void refreshLanguage() {
    if (state is LanguageChanged) {
      final currentLang = (state as LanguageChanged).languageCode;
      emit(LanguageRefreshed(currentLang));
    }
  }

  String getCurrentLanguage() {
    return state is LanguageChanged
        ? (state as LanguageChanged).languageCode
        : 'ar';
  }

  bool isArabic() {
    return getCurrentLanguage() == 'ar';
  }

  bool isEnglish() {
    return getCurrentLanguage() == 'en';
  }
}
