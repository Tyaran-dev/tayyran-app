// settings_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_app_bar.dart';
import 'package:tayyran_app/core/utils/widgets/gradient_background.dart';
import 'package:tayyran_app/presentation/settings/cubit/language_cubit.dart';
import 'package:tayyran_app/presentation/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: GradientAppBar(title: 'settings'.tr(), showBackButton: false),
          body: GradientBackground(
            begin: Alignment.topRight,
            end: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This will now properly rebuild
                    _buildChangeLanguageTitle(),
                    const SizedBox(height: 20),
                    _buildLanguageOptions(),
                    const SizedBox(height: 20),
                    _buildCurrentLanguageDisplay(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangeLanguageTitle() {
    // Use BlocBuilder to rebuild when language changes
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Text(
          'change_language'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildLanguageOptions() {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        final currentLocale = context.locale;
        final currentLang = currentLocale.languageCode;

        return Column(
          children: [
            _buildLanguageOption(
              context,
              value: 'ar',
              title: 'arabic'.tr(),
              isSelected: currentLang == 'ar',
            ),
            _buildLanguageOption(
              context,
              value: 'en',
              title: 'english'.tr(),
              isSelected: currentLang == 'en',
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentLanguageDisplay() {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final currentLocale = context.locale;
        final currentLang = currentLocale.languageCode;
        return Text(
          '${'current_language'.tr()}: ${currentLang == 'ar' ? 'arabic'.tr() : 'english'.tr()}',
          style: const TextStyle(fontSize: 16),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String value,
    required String title,
    required bool isSelected,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        onTap: () {
          context.read<LanguageCubit>().changeLanguage(value, context: context);
        },
      ),
    );
  }
}
