import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/routes/app_pages.dart';
import 'package:incident_report_app/core/services/api_service.dart';
import 'package:incident_report_app/features/auth/data/services/auth_service.dart';
import 'package:incident_report_app/core/services/biometric_service.dart';
import 'package:incident_report_app/core/services/settings_service.dart';
import 'package:incident_report_app/core/services/storage_service.dart';
import 'package:incident_report_app/core/services/theme_service.dart';
import 'package:incident_report_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:incident_report_app/core/bindings/initial_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => SettingsService().init());
  await Get.putAsync(() => ThemeService().init());
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => BiometricService().init());

  // Initialize bindings
  InitialBindings().dependencies();

  // Initialize AuthController
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return GetMaterialApp(
      title: 'Incident Report App',
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode.value,
      locale: const Locale('fr'),
      fallbackLocale: const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,
    );
  }
}
