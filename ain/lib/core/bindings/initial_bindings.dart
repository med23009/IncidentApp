import 'package:get/get.dart';
import 'package:incident_report_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/incident_controller.dart';
import 'package:incident_report_app/features/incidents/presentation/controllers/location_controller.dart';
import 'package:incident_report_app/core/services/api_service.dart';
import 'package:incident_report_app/core/services/storage_service.dart';
import 'package:incident_report_app/core/services/theme_service.dart';
import 'package:incident_report_app/core/services/settings_service.dart';
import 'package:incident_report_app/core/services/biometric_service.dart';
import 'package:incident_report_app/features/auth/data/services/auth_service.dart';
import 'package:incident_report_app/features/incidents/data/services/incident_service.dart';
import 'package:incident_report_app/features/incidents/data/services/incident_storage_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services (initialisés en premier)
    Get.put(ApiService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(ThemeService(), permanent: true);
    Get.put(SettingsService(), permanent: true);
    Get.put(BiometricService(), permanent: true);

    // Auth Services
    Get.put(AuthService(), permanent: true);
    Get.put(AuthController(), permanent: true);

    // Incident Services (initialisés avant le contrôleur)
    Get.put(IncidentService(), permanent: true);
    Get.put(IncidentStorageService(), permanent: true);
    Get.put(IncidentController(), permanent: true);
    
    // Location
    Get.put(LocationController(), permanent: true);
  }
} 