import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../attendance/controllers/attendance_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => AttendanceController());
  }
}
