import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color error = Color(0xFFB00020);
}

class AppConstants {
  static const String TOKEN_KEY = 'auth_token';
  static const String REFRESH_TOKEN_KEY = 'refresh_token';
  static const String USER_KEY = 'user_data';
  static const String SETTINGS_KEY = 'app_settings';
  // L'URL de base de l'API - à changer selon votre configuration
  static const String API_BASE_URL = 'http://192.168.188.205:8000/api';
}

class Routes {
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String HOME = '/home';
  static const String INCIDENT_DETAIL = '/incident-detail';
  static const String REPORT_INCIDENT = '/report-incident';
  static const String SETTINGS = '/settings';
} 



class Constants {
  // API Base URL
  static const String apiBaseUrl = AppConstants.API_BASE_URL;
  
  // API Endpoints
  static const String loginEndpoint = '/api/auth/login/';
  static const String registerEndpoint = '/api/auth/register/';
  static const String incidentsEndpoint = '/api/incidents/';
  static const String incidentDetailEndpoint = '/api/incidents/{id}/';
  static const String uploadPhotoEndpoint = '/api/incidents/{id}/photos/';
  static const String uploadVoiceEndpoint = '/api/incidents/{id}/voice/';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Validation Messages
  static const String requiredField = 'Ce champ est obligatoire';
  static const String invalidEmail = 'Email invalide';
  static const String passwordTooShort = 'Le mot de passe doit contenir au moins 8 caractères';
  static const String passwordsDontMatch = 'Les mots de passe ne correspondent pas';

  // Error Messages
  static const String networkError = 'Erreur de connexion. Veuillez vérifier votre connexion internet';
  static const String serverError = 'Erreur serveur. Veuillez réessayer plus tard';
  static const String unauthorizedError = 'Session expirée. Veuillez vous reconnecter';
  static const String unknownError = 'Une erreur inattendue s\'est produite';

  // Success Messages
  static const String loginSuccess = 'Connexion réussie';
  static const String registerSuccess = 'Inscription réussie';
  static const String incidentReported = 'Incident signalé avec succès';
  static const String photoUploaded = 'Photo téléchargée avec succès';
  static const String voiceUploaded = 'Enregistrement vocal téléchargé avec succès';

  // Identifiants des canaux de notification
  static const String notificationChannelId = 'incident_report_channel';
  static const String notificationChannelName = 'Incident Report Notifications';
  static const String notificationChannelDescription =
      'Notifications for incident updates and alerts';

  // Routes de l'application
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String resetPasswordRoute = '/reset-password';
  static const String incidentDetailsRoute = '/incident-details';
  static const String createIncidentRoute = '/create-incident';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  // Messages d'erreur
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorNetwork = 'Vérifiez votre connexion internet';
  static const String errorInvalidCredentials = 'Identifiants invalides';
  static const String errorEmailAlreadyExists = 'Cet email est déjà utilisé';
  static const String errorWeakPassword = 'Le mot de passe est trop faible';
  static const String errorInvalidEmail = 'Email invalide';
  static const String errorUserNotFound = 'Utilisateur non trouvé';
  static const String errorWrongPassword = 'Mot de passe incorrect';
  static const String errorTooManyRequests =
      'Trop de tentatives. Veuillez réessayer plus tard';

  // Messages de succès
  static const String successLogin = 'Connexion réussie';
  static const String successRegister = 'Inscription réussie';
  static const String successPasswordReset =
      'Un email de réinitialisation a été envoyé';
  static const String successPasswordChanged = 'Mot de passe modifié avec succès';
  static const String successIncidentCreated = 'Incident créé avec succès';
  static const String successIncidentUpdated = 'Incident mis à jour avec succès';
  static const String successIncidentDeleted = 'Incident supprimé avec succès';
  static const String successProfileUpdated = 'Profil mis à jour avec succès';
  static const String successSettingsUpdated = 'Paramètres mis à jour avec succès';

  // Thèmes
  static const Map<String, Color> themeColors = {
    'blue': Color(0xFF2196F3),
    'green': Color(0xFF4CAF50),
    'red': Color(0xFFF44336),
    'purple': Color(0xFF9C27B0),
  };
}
