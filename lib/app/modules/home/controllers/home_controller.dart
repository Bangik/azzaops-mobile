import 'package:get/get.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/work_order_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final ApiProvider _apiProvider = Get.put(ApiProvider());
  final AuthController _authController = Get.find<AuthController>();

  final user = Rxn<UserModel>();

  final isLoading = false.obs;
  final todayAssignments = 0.obs;
  final pendingAssignments = 0.obs;
  final completedToday = 0.obs;
  final totalCompleted = 0.obs;
  final recentWorkOrders = <WorkOrderModel>[].obs;
  
  // Navigation State
  final currentIndex = 0.obs;

  // Unread Notification Count
  final unreadNotificationsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = StorageHelper.getUserData();
    fetchDashboardData();
    fetchUnreadNotificationsCount();
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
    if (index == 0) {
      fetchDashboardData();
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.get('/dashboard');
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          final data = body['data'] as Map<String, dynamic>;
          todayAssignments.value = data['today_assignments'] ?? 0;
          pendingAssignments.value = data['pending_assignments'] ?? 0;
          completedToday.value = data['completed_today'] ?? 0;
          totalCompleted.value = data['total_completed'] ?? 0;

          if (data['recent_work_orders'] != null) {
            final list = data['recent_work_orders'] as List;
            recentWorkOrders.assignAll(
              list.map((e) => WorkOrderModel.fromJson(e as Map<String, dynamic>)).toList(),
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadNotificationsCount() async {
    try {
      final response = await _apiProvider.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          unreadNotificationsCount.value = body['data']['count'] ?? 0;
        }
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await _authController.logout();
  }
}
