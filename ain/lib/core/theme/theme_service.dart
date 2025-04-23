import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/services/settings_service.dart';
import 'package:incident_report_app/core/constants/constants.dart';

class ThemeService extends GetxService {
  final SettingsService _settingsService = Get.find<SettingsService>();
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final Rx<Color> primaryColor = Constants.themeColors['blue']!.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    themeMode.value = _settingsService.settings.value.isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
    primaryColor.value =
        Constants.themeColors[_settingsService.settings.value.themeColor] ??
            Constants.themeColors['blue']!;
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor.value,
        secondary: primaryColor.value.withOpacity(0.8),
        background: Colors.grey[100]!,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.black,
        onSurface: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor.value,
            width: 2,
          ),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor.value,
        secondary: primaryColor.value.withOpacity(0.8),
        background: Colors.grey[900]!,
        surface: Colors.grey[800]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: primaryColor.value,
            width: 2,
          ),
        ),
      ),
    );
  }

  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  void changePrimaryColor(Color color) {
    primaryColor.value = color;
    Get.changeTheme(Get.isDarkMode ? darkTheme : lightTheme);
  }
} 