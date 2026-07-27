import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/providers/report_provider.dart';
import '../../../core/widgets/photo_picker.dart';
import '../../../routes/app_routes.dart';
import '../../work_order/controllers/work_order_controller.dart';

class PickedPhoto {
  final File file;
  final String type; // 'before' | 'progress' | 'after'
  final RxString caption;

  PickedPhoto({
    required this.file,
    required this.type,
    String caption = '',
  }) : caption = caption.obs;
}

class ReportController extends GetxController {
  final ReportProvider _reportProvider = Get.put(ReportProvider());

  final findingsController = TextEditingController();
  final workDoneController = TextEditingController();
  final recommendationsController = TextEditingController();
  final materialsUsedController = TextEditingController();

  final isLoading = false.obs;
  final pickedPhotos = <PickedPhoto>[].obs;

  @override
  void onClose() {
    findingsController.dispose();
    workDoneController.dispose();
    recommendationsController.dispose();
    materialsUsedController.dispose();
    super.onClose();
  }

  Future<void> addPhoto(BuildContext context, String type) async {
    if (pickedPhotos.length >= 10) {
      Get.snackbar('Batas Terpenuhi', 'Maksimal 10 foto per laporan');
      return;
    }

    final File? file = await PhotoPicker.showSourceDialog(context);
    if (file != null) {
      // Check file size (must be <= 5MB)
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);
      if (sizeInMB > 5.0) {
        Get.snackbar('Gagal', 'Ukuran foto melebihi batas 5MB');
        return;
      }

      // Prompt for caption optionally
      final captionText = await _promptForCaption(context);
      pickedPhotos.add(
        PickedPhoto(
          file: file,
          type: type,
          caption: captionText ?? '',
        ),
      );
    }
  }

  void removePhoto(int index) {
    pickedPhotos.removeAt(index);
  }

  Future<String?> _promptForCaption(BuildContext context) async {
    final textController = TextEditingController();
    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('Tambah Keterangan (Opsional)'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Masukkan keterangan foto...',
          ),
          maxLength: 255,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: ''),
            child: const Text('Lewati'),
          ),
          TextButton(
            onPressed: () => Get.back(result: textController.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> submitReport(int workOrderId) async {
    final findings = findingsController.text.trim();
    final workDone = workDoneController.text.trim();

    if (findings.isEmpty || workDone.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Temuan dan Pekerjaan yang dilakukan wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    if (pickedPhotos.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Minimal harus mengupload satu foto dokumentasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    try {
      isLoading.value = true;

      final uri = Uri.parse('${Constants.baseUrl}/work-orders/$workOrderId/reports');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final token = StorageHelper.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['findings'] = findings;
      request.fields['work_done'] = workDone;
      if (recommendationsController.text.isNotEmpty) {
        request.fields['recommendations'] = recommendationsController.text.trim();
      }
      if (materialsUsedController.text.isNotEmpty) {
        request.fields['materials_used'] = materialsUsedController.text.trim();
      }

      // Add photos
      for (int i = 0; i < pickedPhotos.length; i++) {
        final photo = pickedPhotos[i];
        final filename = photo.file.path.split('/').last;

        // Automatically detects mimetype and streams the file
        final multipartFile = await http.MultipartFile.fromPath(
          'photos[$i][file]',
          photo.file.path,
          filename: filename,
        );
        request.files.add(multipartFile);

        request.fields['photos[$i][type]'] = photo.type;
        if (photo.caption.value.isNotEmpty) {
          request.fields['photos[$i][caption]'] = photo.caption.value;
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: Constants.connectTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          // Go back first to avoid popping the snackbar overlay
          Get.back();

          Get.snackbar(
            'Sukses',
            'Laporan pekerjaan berhasil dikirim',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
          );
          
          // Refresh Work Order detail
          if (Get.isRegistered<WorkOrderController>()) {
            final woController = Get.find<WorkOrderController>();
            woController.fetchOrderDetail(workOrderId);
            woController.fetchWorkOrders();
          }
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal mengirim laporan');
        }
      } else {
        String errorMessage = 'Terjadi kesalahan pada server';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['message'] != null) {
            errorMessage = body['message'].toString();
          }
        } catch (_) {}
        Get.snackbar('Error', errorMessage);
      }
    } catch (e, stack) {
      debugPrint('ERROR SUBMIT REPORT: $e');
      debugPrint('STACKTRACE: $stack');
      Get.snackbar('Error', 'Gagal mengirim laporan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
