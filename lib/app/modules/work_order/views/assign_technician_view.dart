import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../controllers/work_order_controller.dart';

class AssignTechnicianView extends GetView<WorkOrderController> {
  const AssignTechnicianView({super.key});

  @override
  Widget build(BuildContext context) {
    final int woId = Get.arguments as int;

    // Reset selected technicians and load available technicians
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectedTechnicianIds.clear();
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.availableTechnicians.length,
                itemBuilder: (context, index) {
                  final tech = controller.availableTechnicians[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Obx(() {
                      final isSelected = controller.selectedTechnicianIds.contains(tech.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => controller.toggleTechnicianSelection(tech.id),
                        title: Text(
                          tech.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(tech.email),
                        secondary: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white),
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
