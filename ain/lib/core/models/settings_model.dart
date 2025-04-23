import 'package:flutter/material.dart';

class SettingsModel {
  final bool isDarkMode;
  final bool isBiometricEnabled;
  final bool isNotificationsEnabled;
  final String language;
  final String themeColor;
  final Color primaryColor;

  SettingsModel({
    this.isDarkMode = false,
    this.isBiometricEnabled = false,
    this.isNotificationsEnabled = true,
    this.language = 'fr',
    this.themeColor = 'Blue',
    this.primaryColor = const Color(0xFF2196F3),
  });

  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      isDarkMode: false,
      isBiometricEnabled: false,
      isNotificationsEnabled: true,
      language: 'fr',
      themeColor: 'Blue',
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] ?? false,
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      isNotificationsEnabled: json['isNotificationsEnabled'] ?? true,
      language: json['language'] ?? 'fr',
      themeColor: json['themeColor'] ?? 'Blue',
      primaryColor: _getColorFromString(json['primaryColor'] ?? '0xFF2196F3'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'isBiometricEnabled': isBiometricEnabled,
      'isNotificationsEnabled': isNotificationsEnabled,
      'language': language,
      'themeColor': themeColor,
      'primaryColor': primaryColor.value.toRadixString(16),
    };
  }

  SettingsModel copyWith({
    bool? isDarkMode,
    bool? isBiometricEnabled,
    bool? isNotificationsEnabled,
    String? language,
    String? themeColor,
    Color? primaryColor,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      language: language ?? this.language,
      themeColor: themeColor ?? this.themeColor,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }

  static Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
} 