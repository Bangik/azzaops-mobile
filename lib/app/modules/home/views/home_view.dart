import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/utils/helpers.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../../work_order/controllers/work_order_controller.dart';

// Placeholder views that we will implement next
import '../../work_order/views/work_order_list_view.dart';
import '../../notification/views/notification_view.dart';
import '../../profile/views/profile_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Work Order',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (controller.unreadNotificationsCount.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${controller.unreadNotificationsCount.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _buildDashboard(context),
            WorkOrderListView(),
            const NotificationView(),
            const ProfileView(),
          ],
        ),
      );
    });
  }

  Widget _buildDashboard(BuildContext context) {
    final user = controller.user.value!;
    final isKepala = user.isKepalaTeknisi;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AzzaOps Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filter Tanggal',
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                      child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchDashboardData();
          await controller.fetchUnreadNotificationsCount();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date Filter Bar
              Obx(() {
                final todayStr = DateTime.now().toIso8601String().split('T').first;
                final isToday = controller.selectedDate.value == todayStr;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blue.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isToday ? AppColors.primary : Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isToday
                              ? 'Filter: Hari Ini (${DateHelper.formatDate(controller.selectedDate.value)})'
                              : 'Filter: ${DateHelper.formatDate(controller.selectedDate.value)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isToday ? AppColors.primary : Colors.orange.shade900,
                          ),
                        ),
                      ),
                      if (!isToday)
                        InkWell(
                          onTap: controller.resetToToday,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.refresh, size: 14, color: Colors.orange.shade900),
                                const SizedBox(width: 2),
                                Text(
                                  'Hari Ini',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                ),
                              ],
                            ),
                          ),
                        ),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                          child: Icon(Icons.edit_calendar, size: 16, color: isToday ? AppColors.primary : Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              const Text(
                'Ringkasan Tugas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Statistics Grid (4 Cards)
              Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 100,
                    child: LoadingWidget(),
                  );
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      title: 'Pekerjaan Anda',
                      value: '${controller.myTotalWorkOrders.value}',
                      color: AppColors.primary,
                      icon: Icons.assignment_ind_outlined,
                      onTap: () => _onCardTap(0),
                    ),
                    _buildStatCard(
                      title: 'Semua Pekerjaan',
                      value: '${controller.allTotalWorkOrders.value}',
                      color: AppColors.accent,
                      icon: Icons.assignment_outlined,
                      onTap: () => _onCardTap(1),
                    ),
                    _buildStatCard(
                      title: 'Selesai Anda',
                      value: '${controller.myCompletedWorkOrders.value}',
                      color: AppColors.success,
                      icon: Icons.task_alt_outlined,
                      onTap: () => _onCardTap(2),
                    ),
                    _buildStatCard(
                      title: 'Semua Selesai',
                      value: '${controller.allCompletedWorkOrders.value}',
                      color: Colors.indigo,
                      icon: Icons.done_all_outlined,
                      onTap: () => _onCardTap(3),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              const Text(
                'Pekerjaan Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Recent Work Orders List
              Obx(() {
                if (controller.isLoading.value) {
                  return const SizedBox(
                    height: 100,
                    child: LoadingWidget(),
                  );
                }

                if (controller.recentWorkOrders.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Tidak ada pekerjaan terbaru',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.recentWorkOrders.length,
                  itemBuilder: (context, index) {
                    final wo = controller.recentWorkOrders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.build_circle, color: AppColors.primary),
                        ),
                        title: Text(
                          wo.woNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(wo.title),
                            const SizedBox(height: 4),
                            Text(
                              wo.assignments.where((a) => a.status != 'transferred').isEmpty
                                   ? 'Belum Ditugaskan'
                                  : 'Teknisi: ${wo.assignments.where((a) => a.status != 'transferred').map((a) => a.technicianName).join(", ")}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                        onTap: () {
                          Get.toNamed(AppRoutes.WORK_ORDER_DETAIL, arguments: wo.id);
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap(int cardIndex) {
    final date = controller.selectedDate.value;
    String? status;

    switch (cardIndex) {
      case 0: // Pekerjaan Anda
        status = 'all';
        break;
      case 1: // Semua Pekerjaan
        status = 'all';
        break;
      case 2: // Selesai Anda
        status = 'completed';
        break;
      case 3: // Semua Selesai
        status = 'completed';
        break;
    }

    // Switch to Work Order tab
    controller.changeTabIndex(1);

    // Update filters in WorkOrderController
    final woController = Get.isRegistered<WorkOrderController>()
        ? Get.find<WorkOrderController>()
        : Get.put(WorkOrderController());
    woController.setFilters(status: status, date: date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime.tryParse(controller.selectedDate.value) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH TANGGAL DASHBOARD',
    );
    if (picked != null) {
      final dateStr = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.changeDateFilter(dateStr);
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
