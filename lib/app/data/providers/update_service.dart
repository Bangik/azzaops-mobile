import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/api_provider.dart';

class UpdateService extends GetxService {
  final ApiProvider _apiProvider = Get.put(ApiProvider());
  
  final isDownloading = false.obs;
  final downloadProgress = 0.obs;
  final downloadStatus = ''.obs;

  Future<void> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      
      final response = await _apiProvider.get('/app-version/latest');
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        final latestVersionCode = data['version_code'] as int;
        final latestVersionName = data['version_name'] as String;
        final releaseNotes = data['release_notes'] as String? ?? '';
        final downloadUrl = data['download_url'] as String;
        
        if (latestVersionCode > currentBuildNumber) {
          _showUpdateDialog(latestVersionName, releaseNotes, downloadUrl);
        }
      }
    } catch (e) {
      debugPrint('Check update failed: $e');
    }
  }

  void _showUpdateDialog(String versionName, String releaseNotes, String downloadUrl) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Obx(() {
          return AlertDialog(
            title: Text('Update Aplikasi Tersedia (v$versionName)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (releaseNotes.isNotEmpty) ...[
                  const Text('Catatan Rilis:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(releaseNotes),
                  const SizedBox(height: 16),
                ],
                if (isDownloading.value) ...[
                  Text('Mengunduh: ${downloadProgress.value}%'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: downloadProgress.value / 100),
                  const SizedBox(height: 4),
                  Text(
                    downloadStatus.value,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ] else
                  const Text('Versi terbaru dari AzzaOps telah tersedia. Silakan perbarui untuk melanjutkan.'),
              ],
            ),
            actions: isDownloading.value
                ? []
                : [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Nanti'),
                    ),
                    ElevatedButton(
                      onPressed: () => _startUpdate(downloadUrl),
                      child: const Text('Update Sekarang'),
                    ),
                  ],
          );
        }),
      ),
      barrierDismissible: false,
    );
  }

  void _startUpdate(String downloadUrl) {
    isDownloading.value = true;
    downloadProgress.value = 0;
    downloadStatus.value = 'Mulai mengunduh...';

    try {
      OtaUpdate().execute(
        downloadUrl,
        destinationFilename: 'azzaops.apk',
      ).listen(
        (OtaEvent event) {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              downloadProgress.value = int.tryParse(event.value ?? '0') ?? 0;
              downloadStatus.value = 'Mengunduh file...';
              break;
            case OtaStatus.INSTALLING:
              downloadStatus.value = 'Mempersiapkan instalasi...';
              isDownloading.value = false;
              Get.back(); // Close dialog
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              isDownloading.value = false;
              downloadStatus.value = '';
              Get.snackbar('Update Gagal', 'Izin instalasi tidak diberikan.');
              break;
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.INTERNAL_ERROR:
              isDownloading.value = false;
              downloadStatus.value = '';
              Get.snackbar('Update Gagal', 'Terjadi kesalahan saat mengunduh pembaruan.');
              break;
            default:
              break;
          }
        },
        onError: (err) {
          isDownloading.value = false;
          Get.snackbar('Update Gagal', 'Gagal mengunduh file: $err');
        },
      );
    } catch (e) {
      isDownloading.value = false;
      Get.snackbar('Update Gagal', 'Terjadi kesalahan sistem: $e');
    }
  }
}
