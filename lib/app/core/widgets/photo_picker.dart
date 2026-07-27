import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class PhotoPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> showSourceDialog(BuildContext context) async {
    File? pickedFile;
    await Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () async {
                    pickedFile = await _pickImage(ImageSource.camera);
                    Get.back();
                  },
                ),
                _buildOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () async {
                    pickedFile = await _pickImage(ImageSource.gallery);
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return pickedFile;
  }

  static Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static Future<File?> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Automatically compress to 70% quality as requested
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
    return null;
  }
}
