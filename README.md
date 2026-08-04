# AzzaOps Mobile

## Cara Build Production (.apk)

Untuk membuat build APK production yang siap didistribusikan langsung ke pengguna (tanpa melalui Play Store), jalankan perintah berikut:

### 1. Build APK Standar
Menghasilkan satu file APK universal yang mendukung semua arsitektur:
```bash
flutter build apk --release
```
Output file: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build APK Split per ABI (Direkomendasikan)
Membagi APK berdasarkan arsitektur CPU target (armeabi-v7a, arm64-v8a, x86_64) untuk menghemat ukuran file unduhan:
```bash
flutter build apk --split-per-abi --release
```
Output file: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (dll)

---

## Cara Menjalankan Aplikasi di Development
Untuk menjalankan aplikasi dalam mode debug/development:
```bash
flutter run
```
