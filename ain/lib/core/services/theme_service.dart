import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/services/settings_service.dart';
import 'package:incident_report_app/core/constants/constants.dart';

class ThemeService extends GetxService {
  final _settingsService = Get.find<SettingsService>();
  final themeMode = ThemeMode.system.obs;
  final primaryColor = AppColors.primary.obs;

  Future<ThemeService> init() async {
    await loadTheme();
    return this;
  }

  Future<void> loadTheme() async {
    final settings = _settingsService.settings.value;
    themeMode.value = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    primaryColor.value = settings.primaryColor;
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primaryColor.value,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor.value,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: primaryColor.value,
          secondary: AppColors.secondary,
          background: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor.value,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _settingsService.updateSettings(
      _settingsService.settings.value.copyWith(
        isDarkMode: mode == ThemeMode.dark,
      ),
    );
  }

  void changePrimaryColor(Color color) {
    primaryColor.value = color;
    _settingsService.updateSettings(
      _settingsService.settings.value.copyWith(
        primaryColor: color,
      ),
    );
  }
} 