import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/features/auth/presentation/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  final authController = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
} 