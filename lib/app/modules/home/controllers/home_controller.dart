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

  // Selected date filter (default: today)
  final selectedDate = RxString(
    DateTime.now().toIso8601String().split('T').first,
  );

  // 4 Main Dashboard Metrics
  final myTotalWorkOrders = 0.obs;
  final allTotalWorkOrders = 0.obs;
  final myCompletedWorkOrders = 0.obs;
  final allCompletedWorkOrders = 0.obs;

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

  void changeDateFilter(String dateStr) {
    selectedDate.value = dateStr;
    fetchDashboardData();
  }

  void resetToToday() {
    selectedDate.value = DateTime.now().toIso8601String().split('T').first;
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final query = <String, String>{
        'date': selectedDate.value,
      };

      final response = await _apiProvider.get('/dashboard', query: query);
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true && body['data'] is Map) {
          final data = body['data'] as Map;
          
          // Metrics from backend
          myTotalWorkOrders.value = data['my_total_work_orders'] ?? data['today_assignments'] ?? 0;
          allTotalWorkOrders.value = data['all_total_work_orders'] ?? 0;
          myCompletedWorkOrders.value = data['my_completed_work_orders'] ?? data['completed_today'] ?? 0;
          allCompletedWorkOrders.value = data['all_completed_work_orders'] ?? data['total_completed'] ?? 0;

          if (data['recent_work_orders'] is List) {
            final list = data['recent_work_orders'] as List;
            recentWorkOrders.assignAll(
              list
                  .whereType<Map>()
                  .map((e) => WorkOrderModel.fromJson(Map<String, dynamic>.from(e)))
                  .toList(),
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
