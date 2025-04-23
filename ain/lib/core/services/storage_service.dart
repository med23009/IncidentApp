import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  final _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> write(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      return await _prefs.setString(key, jsonEncode(value));
    }
  }

  Future<T?> read<T>(String key) async {
    final value = _prefs.get(key);
    if (value == null) return null;

    if (T == String) {
      return value as T;
    } else if (T == int) {
      return value as T;
    } else if (T == bool) {
      return value as T;
    } else if (T == double) {
      return value as T;
    } else if (T == List<String>) {
      return value as T;
    } else {
      return jsonDecode(value as String) as T;
    }
  }

  Future<bool> delete(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Méthodes sécurisées pour les données sensibles
  Future<bool> writeSecure(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  Future<String?> readSecure(String key) async {
    return _prefs.getString(key);
  }

  Future<bool> removeSecure(String key) async {
    return await _prefs.remove(key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<String?> getToken() async {
    return await readSecure(AppConstants.TOKEN_KEY);
  }
} 