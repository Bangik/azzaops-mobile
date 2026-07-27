import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/home_controller.dart';

class NotificationController extends GetxController {
  final NotificationProvider _notificationProvider = Get.put(NotificationProvider());

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final notifications = <NotificationModel>[].obs;

  // Pagination State
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchNotifications();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isLoadingMore.value && currentPage.value < lastPage.value) {
        fetchNotifications(isRefresh: false);
      }
    }
  }

  Future<void> fetchNotifications({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      lastPage.value = 1;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final nextPage = isRefresh ? 1 : currentPage.value + 1;
      final response = await _notificationProvider.getNotifications(page: nextPage);
      
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          final list = body['data'] as List;
          final newItems = list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();

          if (isRefresh) {
            notifications.assignAll(newItems);
          } else {
            notifications.addAll(newItems);
          }

          // Parse pagination metadata
          if (body['meta'] != null) {
            currentPage.value = body['meta']['current_page'] ?? nextPage;
            lastPage.value = body['meta']['last_page'] ?? nextPage;
          }
          
          // Update unread count in HomeController if available
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().fetchUnreadNotificationsCount();
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat notifikasi: $e');
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) {
      _navigateToTarget(notification);
      return;
    }

    try {
      final response = await _notificationProvider.markAsRead(notification.id);
      if (response.statusCode == 200) {
        // Update local list state
        final idx = notifications.indexWhere((n) => n.id == notification.id);
        if (idx != -1) {
          notifications[idx] = NotificationModel(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
            createdAt: notification.createdAt,
          );
        }

        // Update count in HomeController
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchUnreadNotificationsCount();
        }

        _navigateToTarget(notification);
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;
      final response = await _notificationProvider.markAllAsRead();
      if (response.statusCode == 200) {
        Get.snackbar('Sukses', 'Semua notifikasi ditandai telah dibaca');
        fetchNotifications();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses permintaan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateToTarget(NotificationModel notification) {
    if (notification.data != null && notification.data!['work_order_id'] != null) {
      final woId = int.tryParse(notification.data!['work_order_id'].toString());
      if (woId != null) {
        Get.toNamed(AppRoutes.WORK_ORDER_DETAIL, arguments: woId);
      }
    }
  }
}
