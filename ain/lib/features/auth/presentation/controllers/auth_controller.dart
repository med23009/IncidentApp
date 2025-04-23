import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:incident_report_app/core/services/api_service.dart';
import 'package:incident_report_app/core/services/biometric_service.dart';
import 'package:incident_report_app/core/services/storage_service.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/core/models/user_model.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final BiometricService _biometricService = Get.find<BiometricService>();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString token = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isBiometricEnabled = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  String name = '';

  @override
  void onInit() {
    super.onInit();
    _checkBiometricStatus();
    _loadUser();
  }

  Future<void> _checkBiometricStatus() async {
    await _biometricService.init();
    isBiometricEnabled.value = _biometricService.isBiometricEnabled.value;
  }

  Future<void> _loadUser() async {
    final userData = await _storageService.read(Constants.userKey);
    final accessToken = await _storageService.readSecure(AppConstants.TOKEN_KEY);
    final refreshToken = await _storageService.readSecure(AppConstants.REFRESH_TOKEN_KEY);

    if (userData != null && accessToken != null) {
      currentUser.value = User.fromJson(userData);
      name = currentUser.value?.firstName ?? '';
      token.value = accessToken;
      isAuthenticated.value = true;

      // Vérifier si le token est expiré et le rafraîchir si nécessaire
      if (refreshToken != null) {
        await _refreshToken(refreshToken);
      }
    }
  }

  Future<void> _refreshToken(String refreshToken) async {
    try {
      final response = await _apiService.post(
        '/auth/token/refresh/',
        {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access'];
        await _storageService.writeSecure(AppConstants.TOKEN_KEY, newToken);
        token.value = newToken;
      } else {
        // Si le rafraîchissement échoue, déconnecter l'utilisateur
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> checkAuthStatus() async {
    final accessToken = await _storageService.readSecure(AppConstants.TOKEN_KEY);
    if (accessToken != null) {
      token.value = accessToken;
      isAuthenticated.value = true;
    }
  }

  Future<bool> loginWithBiometrics() async {
    if (!_biometricService.isBiometricAvailable.value) {
      Get.snackbar(
        'Erreur',
        'L\'authentification biométrique n\'est pas disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final success = await _biometricService.authenticate();
    if (success && currentUser.value != null) {
      // Vérifier si le token est toujours valide
      final accessToken = await _storageService.readSecure(AppConstants.TOKEN_KEY);
      if (accessToken != null) {
        token.value = accessToken;
        isAuthenticated.value = true;
        return true;
      }
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post(
        '/auth/login/',
        {
          'email': email,
          'password': password,
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          print('Login response data is null');
          Get.snackbar(
            'Erreur',
            'Réponse invalide du serveur',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }

        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final userData = data['user'];

        if (accessToken == null || refreshToken == null || userData == null) {
          print('Missing required data in response');
          Get.snackbar(
            'Erreur',
            'Données manquantes dans la réponse',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }

        // Store tokens securely
        await _storageService.writeSecure(AppConstants.TOKEN_KEY, accessToken);
        await _storageService.writeSecure(AppConstants.REFRESH_TOKEN_KEY, refreshToken);
        
        // Store user information
        currentUser.value = User.fromJson(userData);
        name = currentUser.value?.firstName ?? '';
        await _storageService.write(Constants.userKey, userData);
        
        token.value = accessToken;
        isAuthenticated.value = true;
        
        // Navigate to home page
        Get.offAllNamed(Routes.HOME);
        return true;
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Erreur',
          'Email ou mot de passe incorrect',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Une erreur est survenue lors de la connexion',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la connexion',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post(
        '/auth/register/',
        data,
      );

      if (response.statusCode == 201) {
        name = data['first_name'] ?? '';
        Get.snackbar(
          'Succès',
          Constants.successRegister,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else if (response.statusCode == 400) {
        // Afficher les erreurs de validation du backend
        final errors = response.data;
        String errorMessage = '';
        errors.forEach((key, value) {
          errorMessage += '$key: ${value.join(', ')}\n';
        });
        Get.snackbar(
          'Erreur',
          errorMessage.isNotEmpty ? errorMessage : Constants.errorGeneric,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Erreur',
          Constants.errorGeneric,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post(
        '/auth/reset-password/',
        {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Succès',
          Constants.successPasswordReset,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        Constants.errorGeneric,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

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

  Future<void> logout() async {
    try {
      // Récupérer le refresh token pour la déconnexion côté serveur
      final refreshToken = await _storageService.readSecure(AppConstants.REFRESH_TOKEN_KEY);
      if (refreshToken != null) {
        await _apiService.post('/auth/logout/', {'refresh': refreshToken});
      }
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      // Nettoyer les données locales
      await _storageService.remove(Constants.userKey);
      await _storageService.removeSecure(AppConstants.TOKEN_KEY);
      await _storageService.removeSecure(AppConstants.REFRESH_TOKEN_KEY);
      currentUser.value = null;
      token.value = '';
      isAuthenticated.value = false;
      Get.offAllNamed(Constants.loginRoute);
    }
  }
} 