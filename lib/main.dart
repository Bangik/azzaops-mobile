import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/storage_helper.dart';
import 'app/core/utils/fcm_helper.dart';
import 'app/routes/app_pages.dart';
import 'app/data/providers/update_service.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // Untuk rootBundle

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Membaca file sertifikat dari assets
    ByteData data = await rootBundle.load('assets/ca/certificate.pem');

    // Menambahkan sertifikat ke dalam SecurityContext bawaan aplikasi
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      data.buffer.asUint8List(),
    );

    debugPrint("Sertifikat SSL berhasil dimuat");
  } catch (e) {
    debugPrint("Gagal memuat sertifikat SSL: $e");
  }

  // Initialize GetStorage
  await StorageHelper.init();

  // Initialize Firebase and FCM
  await FcmHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check for app updates on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.put(UpdateService()).checkForUpdate();
    });

    return GetMaterialApp(
      title: 'AzzaOps',
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
