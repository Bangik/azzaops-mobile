import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../../../core/utils/storage_helper.dart';
import '../controllers/work_order_controller.dart';

class AssignTechnicianView extends GetView<WorkOrderController> {
  const AssignTechnicianView({super.key});

  @override
  Widget build(BuildContext context) {
    final int woId = Get.arguments as int;
    final currentUser = StorageHelper.getUserData();

    // Reset selected technicians and load available technicians
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedTechnicianIds.clear();
      // Pre-select already assigned technicians if any
      final currentDetail = controller.detailWorkOrder.value;
      if (currentDetail != null && currentDetail.id == woId) {
        for (final a in currentDetail.assignments) {
          if (a.status != 'transferred' && a.status != 'rejected') {
            controller.selectedTechnicianIds.add(a.technicianId);
          }
        }
      }
      controller.fetchAvailableTechnicians();
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Tugaskan Teknisi'),
      body: Obx(() {
        if (controller.isLoading.value && controller.availableTechnicians.isEmpty) {
          return const LoadingWidget();
        }

        if (controller.availableTechnicians.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada teknisi aktif tersedia',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return Column(
          children: [
            // Quick action to assign to self
            if (currentUser != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tugaskan ke saya sendiri:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary),
                    ),
                    Obx(() {
                      final isMeSelected = controller.selectedTechnicianIds.contains(currentUser.id);
                      return TextButton.icon(
                        onPressed: () => controller.toggleTechnicianSelection(currentUser.id),
                        icon: Icon(
                          isMeSelected ? Icons.check_circle : Icons.add_circle_outline,
                          size: 18,
                          color: isMeSelected ? AppColors.success : AppColors.primary,
                        ),
                        label: Text(
                          isMeSelected ? 'Sudah Dipilih' : 'Pilih Saya',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMeSelected ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.availableTechnicians.length,
                itemBuilder: (context, index) {
                  final tech = controller.availableTechnicians[index];
                  final isMe = currentUser != null && tech.id == currentUser.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: isMe
                        ? RoundedRectangleBorder(
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    child: Obx(() {
                      final isSelected = controller.selectedTechnicianIds.contains(tech.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => controller.toggleTechnicianSelection(tech.id),
                        title: Row(
                          children: [
                            Text(
                              tech.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SAYA',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('${tech.email} • ${tech.role == "kepala_teknisi" ? "Kepala Teknisi" : "Teknisi"}'),
                        secondary: CircleAvatar(
                          backgroundColor: isMe ? AppColors.primary : Colors.blueGrey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        activeColor: AppColors.primary,
                      );
                    }),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () => controller.assignTechnicians(woId),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('SIMPAN PENUGASAN'),
              ),
            ),
          ],
        );
      }),
    );
  }
}
