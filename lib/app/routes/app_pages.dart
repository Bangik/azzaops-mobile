import 'package:get/get.dart';
import 'app_routes.dart';

// Bindings
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/work_order/bindings/work_order_binding.dart';
import '../modules/report/bindings/report_binding.dart';

// Views
import '../modules/auth/views/login_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/work_order/views/work_order_detail_view.dart';
import '../modules/work_order/views/assign_technician_view.dart';
import '../modules/report/views/submit_report_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.WORK_ORDER_DETAIL,
      page: () => const WorkOrderDetailView(),
      binding: WorkOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.ASSIGN_TECHNICIAN,
      page: () => const AssignTechnicianView(),
      binding: WorkOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.SUBMIT_REPORT,
      page: () => const SubmitReportView(),
      binding: ReportBinding(),
    ),
  ];
}
