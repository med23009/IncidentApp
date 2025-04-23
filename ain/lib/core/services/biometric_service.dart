import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService extends GetxService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final isBiometricEnabled = false.obs;
  final isBiometricAvailable = false.obs;

  Future<BiometricService> init() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    
    isBiometricAvailable.value = canCheckBiometrics && isDeviceSupported;
    
    final prefs = await SharedPreferences.getInstance();
    isBiometricEnabled.value = prefs.getBool(Constants.biometricEnabledKey) ?? false;
    
    return this;
  }

  Future<bool> authenticate() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à l\'application',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.biometricEnabledKey, true);
    isBiometricEnabled.value = true;
  }

  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.biometricEnabledKey, false);
    isBiometricEnabled.value = false;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting available biometrics: ${e.message}');
      return [];
    }
  }

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      print('Error checking device support: ${e.message}');
      return false;
    }
  }
} 