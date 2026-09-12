import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/constants.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';
import '../../../core/widgets/photo_picker.dart';
import '../../work_order/controllers/work_order_controller.dart';

class ReportController extends GetxController {
  final ReportProvider _reportProvider = Get.put(ReportProvider());

  final findingsController = TextEditingController();
  final workDoneController = TextEditingController();
  final recommendationsController = TextEditingController();
  final materialsUsedController = TextEditingController();

  final isLoading = false.obs; // submitting final report
  final isLoadingDraft = false.obs; // fetching existing draft on open
  final isUploadingPhoto = false.obs; // uploading a photo to the draft

  // Photos already saved on the server as part of the draft report.
  final draftPhotos = <ReportPhotoModel>[].obs;

  Timer? _debounce;
  int? woId;

  @override
  void onInit() {
    super.onInit();
    woId = Get.arguments as int?;
    if (woId != null) {
      _fetchDraft(woId!);
    }

    findingsController.addListener(_onTextChanged);
    workDoneController.addListener(_onTextChanged);
    recommendationsController.addListener(_onTextChanged);
    materialsUsedController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _saveDraftFields);
  }

  // Draft is stored server-side so a technician can pause mid-report and
  // resume later (even from another device) without losing progress.
  Future<void> _fetchDraft(int id) async {
    try {
      isLoadingDraft.value = true;
      final response = await _reportProvider.getDraft(id);

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true && body['data'] is Map) {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          findingsController.text = (data['findings'] ?? '').toString();
          workDoneController.text = (data['work_done'] ?? '').toString();
          recommendationsController.text = (data['recommendations'] ?? '')
              .toString();
          materialsUsedController.text = (data['materials_used'] ?? '')
              .toString();
          _assignPhotosFrom(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching draft report: $e');
    } finally {
      isLoadingDraft.value = false;
    }
  }

  void _assignPhotosFrom(Map<String, dynamic> data) {
    if (data['photos'] is List) {
      draftPhotos.assignAll(
        (data['photos'] as List)
            .whereType<Map>()
            .map((p) => ReportPhotoModel.fromJson(Map<String, dynamic>.from(p)))
            .toList(),
      );
    }
  }

  Future<void> _saveDraftFields() async {
    if (woId == null) return;
    try {
      await _reportProvider.saveDraftFields(woId!, {
        'findings': findingsController.text.trim(),
        'work_done': workDoneController.text.trim(),
        'recommendations': recommendationsController.text.trim(),
        'materials_used': materialsUsedController.text.trim(),
      });
    } catch (e) {
      debugPrint('Error saving draft fields: $e');
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    findingsController.dispose();
    workDoneController.dispose();
    recommendationsController.dispose();
    materialsUsedController.dispose();
    super.onClose();
  }

  Future<void> addPhoto(BuildContext context, String type) async {
    if (woId == null) return;

    final File? file = await PhotoPicker.showSourceDialog(context);
    if (file == null) return;

    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB > 5.0) {
      Get.snackbar('Gagal', 'Ukuran foto melebihi batas 5MB');
      return;
    }

    final captionText = await _promptForCaption(context);
    await _uploadDraftPhoto(file, type, captionText ?? '');
  }

  // Photo is uploaded immediately (cicilan) so progress is saved as a draft
  // on the server as soon as the technician takes each photo.
  Future<void> _uploadDraftPhoto(File file, String type, String caption) async {
    try {
      isUploadingPhoto.value = true;

      final uri = Uri.parse(
        '${Constants.baseUrl}/work-orders/$woId/reports/draft',
      );
      final request = http.MultipartRequest('POST', uri);

      final token = StorageHelper.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      final filename = file.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos[0][file]',
          file.path,
          filename: filename,
        ),
      );
      request.fields['photos[0][type]'] = type;
      if (caption.isNotEmpty) {
        request.fields['photos[0][caption]'] = caption;
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: Constants.connectTimeout),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is Map) {
          _assignPhotosFrom(Map<String, dynamic>.from(body['data'] as Map));
        } else {
          Get.snackbar('Error', body['message'] ?? 'Gagal mengupload foto');
        }
      } else {
        Get.snackbar('Error', 'Gagal mengupload foto ke server');
      }
    } catch (e) {
      debugPrint('Error uploading draft photo: $e');
      Get.snackbar('Error', 'Gagal mengupload foto: $e');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> removePhoto(int photoId) async {
    final removed = draftPhotos.firstWhereOrNull((p) => p.id == photoId);
    if (removed == null) return;

    // Optimistic removal, restore if the server call fails.
    draftPhotos.removeWhere((p) => p.id == photoId);
    try {
      final response = await _reportProvider.deleteDraftPhoto(photoId);
      if (response.statusCode != 200) {
        draftPhotos.add(removed);
        Get.snackbar('Error', 'Gagal menghapus foto');
      }
    } catch (e) {
      draftPhotos.add(removed);
      Get.snackbar('Error', 'Gagal menghapus foto: $e');
    }
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

    if (draftPhotos.isEmpty) {
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
      _debounce?.cancel();

      // Photos were already uploaded to the draft; finalizing just flips
      // the report from draft to submitted on the backend.
      final response = await _reportProvider.submitFinal(workOrderId, {
        'findings': findings,
        'work_done': workDone,
        if (recommendationsController.text.trim().isNotEmpty)
          'recommendations': recommendationsController.text.trim(),
        if (materialsUsedController.text.trim().isNotEmpty)
          'materials_used': materialsUsedController.text.trim(),
      });

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
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
        final message =
            response.body != null && response.body['message'] != null
            ? response.body['message'].toString()
            : 'Terjadi kesalahan pada server';
        Get.snackbar('Error', message);
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
