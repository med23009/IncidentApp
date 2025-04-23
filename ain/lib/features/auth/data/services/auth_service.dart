import 'package:get/get.dart';
import 'package:incident_report_app/core/services/api_service.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final RxString token = ''.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  Future<AuthService> init() async {
    await _loadUser();
    return this;
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.USER_KEY);
    final accessToken = prefs.getString(AppConstants.TOKEN_KEY);
    
    if (userData != null && accessToken != null) {
      currentUser.value = User.fromJson(jsonDecode(userData));
      token.value = accessToken;
      isAuthenticated.value = true;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register/',
        {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        token.value = data['access'];
        currentUser.value = User.fromJson(data['user']);
        await _saveToken(data['access']);
        await _saveRefreshToken(data['refresh']);
        await _saveUser(data['user']);
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiService.post(
        '/auth/login/',
        {
          'email': email,
          'password': password,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          print('Login response data is null');
          throw Exception('Login response data is null');
        }

        print('Response data type: ${data.runtimeType}');
        print('Response data content: $data');

        if (data['status'] == 'error') {
          print('Login error: ${data['message']}');
          throw Exception(data['message'] ?? 'Login failed');
        }

        if (data['status'] == 'success') {
          final userData = data['user'];
          final accessToken = data['access'];
          final refreshToken = data['refresh'];

          print('User data: $userData');
          print('Access token: $accessToken');
          print('Refresh token: $refreshToken');

          if (userData == null || accessToken == null || refreshToken == null) {
            print('Missing data - User: $userData, Access: $accessToken, Refresh: $refreshToken');
            throw Exception('Missing user or token data in response');
          }

          token.value = accessToken;
          currentUser.value = User.fromJson(userData);
          await _saveToken(accessToken);
          await _saveRefreshToken(refreshToken);
          await _saveUser(userData);
          isAuthenticated.value = true;
          return true;
        }
      }
      return false;
    } catch (e, stackTrace) {
      print('Error during login: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken != null) {
        await _apiService.post('/auth/logout/', {'refresh': refreshToken});
      }
      await _clearTokens();
      token.value = '';
      currentUser.value = null;
      isAuthenticated.value = false;
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.post(
        '/auth/token/refresh/',
        {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        token.value = data['access'];
        await _saveToken(data['access']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.USER_KEY, jsonEncode(userData));
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.TOKEN_KEY, token);
  }

  Future<void> _saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.REFRESH_TOKEN_KEY, refreshToken);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.TOKEN_KEY);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.REFRESH_TOKEN_KEY);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.TOKEN_KEY);
    await prefs.remove(AppConstants.REFRESH_TOKEN_KEY);
    await prefs.remove(AppConstants.USER_KEY);
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await _apiService.get('/auth/user/');
      if (response.statusCode == 200) {
        final data = response.data;
        currentUser.value = User.fromJson(data);
        isAuthenticated.value = true;
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
} 