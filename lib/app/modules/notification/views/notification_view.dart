import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../../app/core/widgets/empty_state.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already registered (when displayed in the home navigation stack)
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifikasi',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              if (controller.notifications.any((n) => !n.isRead)) {
                controller.markAllAsRead();
              } else {
                Get.snackbar('Informasi', 'Semua notifikasi sudah dibaca');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const LoadingWidget();
        }

        if (controller.notifications.isEmpty) {
          return EmptyState(
            message: 'Tidak ada notifikasi untuk Anda',
            icon: Icons.notifications_none_outlined,
            onRefresh: controller.fetchNotifications,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: controller.notifications.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              }
              final notif = controller.notifications[index];
              return Card(
                elevation: notif.isRead ? 1 : 3,
                color: notif.isRead ? Colors.white : Colors.blue.shade50,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(notif.type).withOpacity(0.15),
                    child: Icon(_getIcon(notif.type), color: _getIconColor(notif.type)),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notif.body,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif.createdAt.contains('T') 
                            ? notif.createdAt.replaceAll('T', ' ').split('.').first 
                            : notif.createdAt,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  trailing: notif.isRead 
                      ? null 
                      : const Icon(Icons.fiber_new, color: AppColors.primary, size: 28),
                  onTap: () => controller.markAsRead(notif),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'work_order_new':
        return Icons.assignment_turned_in;
      case 'work_order_assigned':
        return Icons.person_add;
      case 'work_order_updated':
        return Icons.update;
      case 'report_submitted':
        return Icons.rate_review;
      case 'invoice_created':
        return Icons.receipt_long;
      case 'payment_received':
        return Icons.payments;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'work_order_new':
        return AppColors.warning;
      case 'work_order_assigned':
        return AppColors.primary;
      case 'work_order_updated':
        return Colors.indigo;
      case 'report_submitted':
        return Colors.purple;
      case 'invoice_created':
        return Colors.teal;
      case 'payment_received':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
