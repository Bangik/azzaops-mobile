import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../../app/core/widgets/empty_state.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/work_order_controller.dart';

class WorkOrderListView extends GetView<WorkOrderController> {
  const WorkOrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already registered (in case it is displayed inside home bottom nav stack)
    final WorkOrderController controller = Get.put(WorkOrderController());

    final statusFilters = [
      {'label': 'Semua', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Assigned', 'value': 'assigned'},
      {'label': 'Dikerjakan', 'value': 'in_progress'},
      {'label': 'Pengecekan', 'value': 'checking'},
      {'label': 'Dilaporkan', 'value': 'reported'},
      {'label': 'Selesai', 'value': 'completed'},
      {'label': 'Batal', 'value': 'cancelled'},
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Work Orders',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filter Tanggal',
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal scrolling Filter Chips
          Container(
            height: 60,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: statusFilters.map((filter) {
                  return Obx(() {
                    final isSelected = controller.selectedStatusFilter.value == filter['value'] && controller.selectedDateFilter.value == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          filter['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade100,
                        checkmarkColor: Colors.white,
                        onSelected: (_) {
                          controller.changeStatusFilter(filter['value']!);
                        },
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ),
          
          // Date Filter Indicator
          Obx(() {
            if (controller.selectedDateFilter.value != null) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Menampilkan tanggal: ${controller.selectedDateFilter.value} (${controller.selectedStatusFilter.value.toUpperCase()})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.setFilters(status: 'all', date: null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Work Order List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.workOrders.isEmpty) {
                return const LoadingWidget();
              }

              if (controller.workOrders.isEmpty) {
                return EmptyState(
                  message: 'Tidak ada work order dalam kategori ini',
                  onRefresh: controller.fetchWorkOrders,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchWorkOrders,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.workOrders.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.workOrders.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      );
                    }
                    final wo = controller.workOrders[index];
                    return _buildWorkOrderCard(wo);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderCard(dynamic wo) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Get.toNamed(AppRoutes.WORK_ORDER_DETAIL, arguments: wo.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    wo.woNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildStatusBadge(wo.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      wo.customer.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.construction_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${wo.serviceCategory.name} (${wo.type.toUpperCase()})',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.engineering_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      wo.assignments.where((a) => a.status != 'transferred').isEmpty
                          ? 'Belum Ditugaskan'
                          : 'Teknisi: ${wo.assignments.where((a) => a.status != 'transferred').map((a) => a.technicianName).join(", ")}',
                      style: TextStyle(
                        color: wo.assignments.where((a) => a.status != 'transferred').isEmpty ? AppColors.warning : AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: wo.assignments.where((a) => a.status != 'transferred').isEmpty ? FontWeight.bold : FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    wo.scheduledDate ?? '-',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(wo.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getPriorityLabel(wo.priority),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(wo.priority),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'Pending';
        break;
      case 'assigned':
        color = AppColors.accent;
        label = 'Assigned';
        break;
      case 'in_progress':
        color = Colors.indigo;
        label = 'Dikerjakan';
        break;
      case 'checking':
        color = Colors.blueGrey;
        label = 'Pengecekan';
        break;
      case 'reported':
        color = Colors.purple;
        label = 'Dilaporkan';
        break;
      case 'completed':
        color = AppColors.success;
        label = 'Selesai';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Batal';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '1':
      case 'urgent':
        return Colors.red.shade900;
      case '2':
      case 'high':
        return AppColors.error;
      case '3':
      case 'normal':
        return AppColors.primary;
      case '4':
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case '1':
        return 'URGENT';
      case '2':
        return 'TINGGI';
      case '3':
        return 'NORMAL';
      case '4':
        return 'RENDAH';
      default:
        return priority.toUpperCase();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'PILIH TANGGAL WORK ORDER',
    );
    if (picked != null) {
      final dateStr = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.setFilters(status: controller.selectedStatusFilter.value, date: dateStr);
    }
  }
}
