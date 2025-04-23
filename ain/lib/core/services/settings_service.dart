import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/core/models/settings_model.dart';
import 'package:incident_report_app/core/services/storage_service.dart';

class SettingsService extends GetxService {
  final _storageService = Get.find<StorageService>();
  final settings = SettingsModel().obs;
  
  final themeMode = ThemeMode.system.obs;
  final primaryColor = Colors.blue.obs;
  final notificationsEnabled = true.obs;
  final language = 'fr'.obs;

  Future<SettingsService> init() async {
    await loadSettings();
    return this;
  }

  Future<void> loadSettings() async {
    final savedSettings = await _storageService.read(AppConstants.SETTINGS_KEY);
    if (savedSettings != null) {
      settings.value = SettingsModel.fromJson(savedSettings);
    }
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    settings.value = newSettings;
    await _storageService.write(AppConstants.SETTINGS_KEY, newSettings.toJson());
    
    // Update theme
    Get.changeThemeMode(
      newSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
    
    // Update locale
    Get.updateLocale(Locale(newSettings.language));
  }

  void resetSettings() {
    final defaultSettings = SettingsModel();
    updateSettings(defaultSettings);
    Get.changeThemeMode(ThemeMode.light);
    Get.updateLocale(const Locale('fr'));
  }

  Future<void> toggleDarkMode() async {
    final newSettings = settings.value.copyWith(
      isDarkMode: !settings.value.isDarkMode,
    );
    await updateSettings(newSettings);
    Get.changeThemeMode(
      newSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> toggleBiometricAuth() async {
    final newSettings = settings.value.copyWith(
      isBiometricEnabled: !settings.value.isBiometricEnabled,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleNotifications() async {
    final newSettings = settings.value.copyWith(
      isNotificationsEnabled: !settings.value.isNotificationsEnabled,
    );
    await updateSettings(newSettings);
  }

  Future<void> changeLanguage(String language) async {
    final newSettings = settings.value.copyWith(language: language);
    await updateSettings(newSettings);
    Get.updateLocale(Locale(language));
  }

  Future<void> changeThemeColor(String color) async {
    final newSettings = settings.value.copyWith(themeColor: color);
    await updateSettings(newSettings);
    // TODO: Implémenter le changement de couleur du thème
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await _storageService.write('notifications_enabled', value);
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await _storageService.write('language', code);
    Get.updateLocale(Locale(code));
  }
} 