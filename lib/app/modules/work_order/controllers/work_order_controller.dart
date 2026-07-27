import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/work_order_model.dart';
import '../../../data/providers/work_order_provider.dart';
import '../../../data/providers/api_provider.dart';
import '../../../core/utils/storage_helper.dart';

class WorkOrderController extends GetxController {
  final WorkOrderProvider _woProvider = Get.put(WorkOrderProvider());
  final ApiProvider _apiProvider = Get.put(ApiProvider());

  final isLoading = false.obs;
  final isDetailLoading = false.obs;
  final isLoadingMore = false.obs;

  // Work Orders List
  final workOrders = <WorkOrderModel>[].obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedDateFilter = RxnString();
  
  // Pagination State
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final scrollController = ScrollController();

  // Detail Work Order
  final detailWorkOrder = Rxn<WorkOrderModel>();

  // Available Technicians (for assign)
  final availableTechnicians = <UserModel>[].obs;
  final selectedTechnicianIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchWorkOrders();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isLoadingMore.value && currentPage.value < lastPage.value) {
        fetchWorkOrders(isRefresh: false);
      }
    }
  }

  void changeStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
    selectedDateFilter.value = null;
    fetchWorkOrders(isRefresh: true);
  }

  void setFilters({String? status, String? date}) {
    selectedStatusFilter.value = status ?? 'all';
    selectedDateFilter.value = date;
    fetchWorkOrders(isRefresh: true);
  }

  Future<void> fetchWorkOrders({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      lastPage.value = 1;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final filter = selectedStatusFilter.value == 'all'
          ? null
          : selectedStatusFilter.value;
      final nextPage = isRefresh ? 1 : currentPage.value + 1;

      final response = await _woProvider.getWorkOrders(
        status: filter,
        date: selectedDateFilter.value,
        page: nextPage,
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          final list = body['data'] as List;
          final newItems = list
              .map((e) => WorkOrderModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (isRefresh) {
            workOrders.assignAll(newItems);
          } else {
            workOrders.addAll(newItems);
          }

          // Parse pagination metadata
          if (body['meta'] != null) {
            currentPage.value = body['meta']['current_page'] ?? nextPage;
            lastPage.value = body['meta']['last_page'] ?? nextPage;
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar work order: $e');
      debugPrint('Error fetching work orders: $e');
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> fetchOrderDetail(int id) async {
    try {
      isDetailLoading.value = true;
      final response = await _woProvider.getWorkOrderDetail(id);

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          detailWorkOrder.value = WorkOrderModel.fromJson(
            body['data'] as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail work order: $e');
      debugPrint('Error fetching work order detail here: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String status, {String? notes}) async {
    try {
      isLoading.value = true;
      final response = await _woProvider.updateWorkOrderStatus(
        id,
        status,
        notes: notes,
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Status work order berhasil diperbarui');
          // Reload details and list
          fetchOrderDetail(id);
          fetchWorkOrders();
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal memperbarui status');
        }
      } else {
        Get.snackbar('Error', 'Terjadi kesalahan pada server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load available technicians for Kepala Teknisi
  Future<void> fetchAvailableTechnicians() async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.get('/technicians/available');
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          final list = body['data'] as List;
          availableTechnicians.assignAll(
            list
                .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar teknisi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Submit assignment from Kepala Teknisi
  Future<void> assignTechnicians(int workOrderId) async {
    if (selectedTechnicianIds.isEmpty) {
      Get.snackbar('Peringatan', 'Silakan pilih minimal satu teknisi');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiProvider.post(
        '/work-orders/$workOrderId/assign',
        {'technician_ids': selectedTechnicianIds.toList()},
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Teknisi berhasil ditugaskan');
          Get.back(); // Go back to Detail WO screen
          fetchOrderDetail(workOrderId);
          fetchWorkOrders();
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal menugaskan teknisi');
        }
      } else {
        Get.snackbar('Error', 'Terjadi kesalahan pada server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menugaskan teknisi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Request Takeover
  Future<void> requestTakeover(int workOrderId, {String? notes}) async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.post(
        '/work-orders/$workOrderId/takeover',
        {if (notes != null) 'notes': notes},
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Permintaan pengambilalihan berhasil diajukan');
          fetchOrderDetail(workOrderId);
          fetchWorkOrders();
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal mengajukan pengambilalihan');
        }
      } else {
        final message = response.body != null && response.body['message'] != null
            ? response.body['message']
            : 'Gagal mengajukan pengambilalihan';
        Get.snackbar('Error', message.toString());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengajukan pengambilalihan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Approve Takeover
  Future<void> approveTakeover(int takeoverId, int workOrderId) async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.post('/takeovers/$takeoverId/approve', {});

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Pengambilalihan pekerjaan disetujui');
          fetchOrderDetail(workOrderId);
          fetchWorkOrders();
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal memproses persetujuan');
        }
      } else {
        final message = response.body != null && response.body['message'] != null
            ? response.body['message']
            : 'Terjadi kesalahan pada server';
        Get.snackbar('Error', message.toString());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses persetujuan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Reject Takeover
  Future<void> rejectTakeover(int takeoverId, int workOrderId) async {
    try {
      isLoading.value = true;
      final response = await _apiProvider.post('/takeovers/$takeoverId/reject', {});

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Pengambilalihan pekerjaan ditolak');
          fetchOrderDetail(workOrderId);
          fetchWorkOrders();
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal menolak pengambilalihan');
        }
      } else {
        final message = response.body != null && response.body['message'] != null
            ? response.body['message']
            : 'Terjadi kesalahan pada server';
        Get.snackbar('Error', message.toString());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menolak pengambilalihan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTechnicianSelection(int techId) {
    if (selectedTechnicianIds.contains(techId)) {
      selectedTechnicianIds.remove(techId);
    } else {
      selectedTechnicianIds.add(techId);
    }
  }
}
