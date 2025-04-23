import 'package:get/get.dart';
import 'package:incident_report_app/core/middleware/auth_middleware.dart';
import 'package:incident_report_app/features/auth/presentation/pages/login_page.dart';
import 'package:incident_report_app/features/auth/presentation/pages/register_page.dart';
import 'package:incident_report_app/features/incidents/presentation/pages/home_page.dart';
import 'package:incident_report_app/features/incidents/presentation/pages/incident_detail_page.dart';
import 'package:incident_report_app/features/incidents/presentation/pages/report_incident_page.dart';
import 'package:incident_report_app/core/bindings/initial_bindings.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
      binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.REPORT_INCIDENT,
      page: () => const ReportIncidentPage(),
      middlewares: [AuthMiddleware()],
      binding: InitialBindings(),
    ),
    GetPage(
      name: Routes.INCIDENT_DETAIL,
      page: () {
        final incident = Get.arguments['incident'];
        return IncidentDetailPage(incident: incident);
      },
      middlewares: [AuthMiddleware()],
      binding: InitialBindings(),
    ),
  ];
} 