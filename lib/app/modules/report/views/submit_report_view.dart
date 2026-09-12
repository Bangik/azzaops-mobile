import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/utils/constants.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../controllers/report_controller.dart';

class SubmitReportView extends GetView<ReportController> {
  const SubmitReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final int woId = Get.arguments as int;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Submit Laporan Pekerjaan'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Mengirim laporan...');
        }

        if (controller.isLoadingDraft.value) {
          return const LoadingWidget(message: 'Memuat draft laporan...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Laporan tersimpan otomatis sebagai draft. Anda bisa mencicil foto & isi laporan lalu lanjutkan kapan saja.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Laporan Detail',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Photo Picker Buttons
              Obx(() {
                final uploading = controller.isUploadingPhoto.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAddPhotoButton(
                      context,
                      'Sebelum (Before)',
                      'before',
                      uploading,
                    ),
                    _buildAddPhotoButton(
                      context,
                      'Proses (Progress)',
                      'progress',
                      uploading,
                    ),
                    _buildAddPhotoButton(
                      context,
                      'Sesudah (After)',
                      'after',
                      uploading,
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                if (!controller.isUploadingPhoto.value)
                  return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(),
                );
              }),
              const SizedBox(height: 8),

              // Preview List
              Obx(() {
                if (controller.draftPhotos.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada foto diupload',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.draftPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = controller.draftPhotos[index];
                    final photoUrl = photo.photoUrl.startsWith('http')
                        ? photo.photoUrl
                        : '${Constants.mediaBaseUrl}/${photo.photoUrl}';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                photoUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) => Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPhotoTypeColor(
                                        photo.photoType,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      photo.photoType.toUpperCase(),
                                      style: TextStyle(
                                        color: _getPhotoTypeColor(
                                          photo.photoType,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (photo.caption ?? '').isNotEmpty
                                        ? photo.caption!
                                        : 'Tanpa keterangan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: (photo.caption ?? '').isNotEmpty
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontStyle:
                                          (photo.caption ?? '').isNotEmpty
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () => controller.removePhoto(photo.id),
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

  Widget _buildAddPhotoButton(
    BuildContext context,
    String label,
    String type,
    bool disabled,
  ) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: disabled ? null : () => controller.addPhoto(context, type),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 4.0,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_a_photo,
                  color: disabled ? Colors.grey : _getPhotoTypeColor(type),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
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
