import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../core/utils/storage_helper.dart';
import '../../home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  final ProfileProvider _profileProvider = Get.put(ProfileProvider());

  final user = Rxn<UserModel>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalProfile();
    fetchProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void loadLocalProfile() {
    final localUser = StorageHelper.getUserData();
    if (localUser != null) {
      user.value = localUser;
      nameController.text = localUser.name;
      phoneController.text = localUser.phone ?? '';
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _profileProvider.getProfile();
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          final userJson = body['data'] as Map<String, dynamic>;
          final updatedUser = UserModel.fromJson(userJson);
          await StorageHelper.saveUserData(updatedUser);
          user.value = updatedUser;
          
          // Update in HomeController if active
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().user.value = updatedUser;
          }
        }
      }
    } catch (_) {
      // Quietly fail as we have local backup
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Validasi Gagal', 'Nama tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _profileProvider.updateProfile(name, phone);
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Profil berhasil diperbarui');
          final userJson = body['data'] as Map<String, dynamic>;
          final updatedUser = UserModel.fromJson(userJson);
          await StorageHelper.saveUserData(updatedUser);
          user.value = updatedUser;
          
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().user.value = updatedUser;
          }
        } else {
          Get.snackbar('Gagal', body['message'] ?? 'Gagal memperbarui profil');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword() async {
    final currentPass = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar('Validasi Gagal', 'Semua kolom password wajib diisi');
      return;
    }

    if (newPass.length < 8) {
      Get.snackbar('Validasi Gagal', 'Password baru minimal 8 karakter');
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar('Validasi Gagal', 'Konfirmasi password baru tidak cocok');
      return;
    }

    try {
      isLoading.value = true;
      final response = await _profileProvider.updatePassword(currentPass, newPass, confirmPass);
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true) {
          Get.snackbar('Sukses', 'Password berhasil diperbarui');
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        } else {
          Get.snackbar('Gagal', body['message'] ?? 'Gagal memperbarui password');
        }
      } else {
        final message = response.body != null && response.body['message'] != null
            ? response.body['message']
            : 'Password saat ini salah';
        Get.snackbar('Gagal', message.toString());
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui password: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
