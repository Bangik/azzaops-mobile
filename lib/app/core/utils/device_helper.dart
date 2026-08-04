import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import 'storage_helper.dart';

class DeviceHelper {
  static Future<void> sendDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      String deviceId = '';
      String platform = '';
      String osVersion = '';
      String deviceBrand = '';
      String deviceModel = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique hardware ID
        platform = 'android';
        osVersion = androidInfo.version.release;
        deviceBrand = androidInfo.brand;
        deviceModel = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        platform = 'ios';
        osVersion = iosInfo.systemVersion;
        deviceBrand = 'Apple';
        deviceModel = iosInfo.model;
      }
      
      final userToken = StorageHelper.getToken();
      if (userToken == null) return; // Only send device info if authenticated
      
      final apiProvider = Get.put(ApiProvider());
      await apiProvider.post('/devices', {
        'device_id': deviceId,
        'platform': platform,
        'app_version': packageInfo.version,
        'build_number': int.tryParse(packageInfo.buildNumber) ?? 0,
        'os_version': osVersion,
        'device_brand': deviceBrand,
        'device_model': deviceModel,
      });
      debugPrint('Device info sent successfully');
    } catch (e) {
      debugPrint('Failed to send device info: $e');
    }
  }
}
