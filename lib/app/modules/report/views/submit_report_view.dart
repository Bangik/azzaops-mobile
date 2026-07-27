import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../controllers/report_controller.dart';

class SubmitReportView extends GetView<ReportController> {
  const SubmitReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final int woId = Get.arguments as int;

    // Reset fields on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.put(ReportController());
      controller.findingsController.clear();
      controller.workDoneController.clear();
      controller.recommendationsController.clear();
      controller.materialsUsedController.clear();
      controller.pickedPhotos.clear();
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Submit Laporan Pekerjaan'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Mengirim laporan & mengupload foto...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Laporan Detail',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.findingsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Temuan / Kondisi Unit (Wajib)',
                  hintText: 'Tuliskan kondisi unit AC saat diperiksa...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.workDoneController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Pekerjaan yang Dilakukan (Wajib)',
                  hintText: 'Tuliskan perbaikan/servis yang Anda lakukan...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.recommendationsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Rekomendasi untuk Customer (Opsional)',
                  hintText: 'Tuliskan saran perawatan lanjutan...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.materialsUsedController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Material / Sparepart Digunakan (Opsional)',
                  hintText: 'Tuliskan sparepart yang diganti...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Dokumentasi Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              
              // Photo Picker Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAddPhotoButton(context, 'Sebelum (Before)', 'before'),
                  _buildAddPhotoButton(context, 'Proses (Progress)', 'progress'),
                  _buildAddPhotoButton(context, 'Sesudah (After)', 'after'),
                ],
              ),
              const SizedBox(height: 16),
              
              // Preview List
              Obx(() {
                if (controller.pickedPhotos.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada foto dipilih',
                        style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.pickedPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = controller.pickedPhotos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                photo.file,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getPhotoTypeColor(photo.type).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      photo.type.toUpperCase(),
                                      style: TextStyle(
                                        color: _getPhotoTypeColor(photo.type),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() {
                                    return Text(
                                      photo.caption.value.isNotEmpty
                                          ? photo.caption.value
                                          : 'Tanpa keterangan',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: photo.caption.value.isNotEmpty
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontStyle: photo.caption.value.isNotEmpty
                                            ? FontStyle.normal
                                            : FontStyle.italic,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.error),
                              onPressed: () => controller.removePhoto(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => controller.submitReport(woId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'KIRIM LAPORAN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context, String label, String type) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => controller.addPhoto(context, type),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
            child: Column(
              children: [
                Icon(Icons.add_a_photo, color: _getPhotoTypeColor(type)),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPhotoTypeColor(String type) {
    switch (type) {
      case 'before':
        return Colors.orange;
      case 'progress':
        return Colors.blue;
      case 'after':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
