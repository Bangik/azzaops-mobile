import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/utils/fcm_helper.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = Get.put(AuthProvider());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final showPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAutoLogin();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  Future<void> checkAutoLogin() async {
    final token = StorageHelper.getToken();
    if (token != null) {
      isLoading.value = true;
      try {
        final response = await _authProvider.getProfile();
        if (response.statusCode == 200 && response.body != null) {
          final body = response.body;
          if (body['success'] == true) {
            final userJson = body['data'] as Map<String, dynamic>;
            final user = UserModel.fromJson(userJson);
            await StorageHelper.saveUserData(user);
            Get.offAllNamed(AppRoutes.HOME);
            return;
          }
        }
      } catch (e) {
        // Silent catch: if check fails (e.g. no internet), let user stay on login
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Email dan password wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    try {
      isLoading.value = true;
      // We can pass fcm token later if integrated
      final response = await _authProvider.login(email, password);

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          final data = body['data'] as Map<String, dynamic>;
          final token = data['token'] as String;
          final userJson = data['user'] as Map<String, dynamic>;
          final user = UserModel.fromJson(userJson);

          await StorageHelper.saveToken(token);
          await StorageHelper.saveUserData(user);

          // Fetch and upload FCM token upon login
          try {
            final fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken != null) {
              await FcmHelper.uploadFcmToken(fcmToken);
            }
          } catch (_) {}

          Get.offAllNamed(AppRoutes.HOME);
        } else {
          Get.snackbar(
            'Login Gagal',
            body['message'] ?? 'Email atau password salah',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
          );
        }
      } else {
        final message =
            response.body != null && response.body['message'] != null
            ? response.body['message']
            : 'Terjadi kesalahan pada server';
        Get.snackbar(
          'Login Gagal',
          message.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal masuk ke server: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (_) {}
    await StorageHelper.clearAll();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
