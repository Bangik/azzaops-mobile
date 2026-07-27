# AGENTS.md — AzzaOps Mobile (Flutter)

> Panduan untuk AI coding assistant agar memahami konteks project dan cara develop yang benar.

---

## 1. Project Overview

- **Nama**: AzzaOps Mobile
- **Deskripsi**: Companion mobile app untuk sistem AzzaOps (Field Service Management)
- **Backend**: AzzaOps Web — Laravel, diakses via REST API
- **Auth**: Laravel Sanctum (Bearer token)
- **Push Notification**: Firebase Cloud Messaging (FCM)
- **Distribusi**: Build APK langsung, **TIDAK** upload ke Play Store
- **Package name**: `com.azzaops.mobile`
- **App name**: `AzzaOps`
- **Min Android SDK**: 21 (Android 5.0)

### User Roles di Mobile

| Role | Bisa apa |
|---|---|
| **Kepala Teknisi** | Lihat semua Work Order, assign teknisi ke WO, monitor progress pengerjaan |
| **Teknisi** | Lihat WO yang di-assign ke dia, terima job, update status, submit laporan + foto |

> **Admin TIDAK pakai mobile app.** Admin hanya pakai web.

---

## 2. Tech Stack

| Kategori | Teknologi |
|---|---|
| Framework | Flutter 3.x (latest stable) |
| Language | Dart |
| State Management | **GetX** (state, routing, dependency injection — semua pakai GetX) |
| HTTP Client | `http` atau `dio` |
| Push Notification | `firebase_messaging` |
| Local Notification | `flutter_local_notifications` |
| Foto | `image_picker` (ambil dari kamera/gallery) |
| Image Cache | `cached_network_image` |
| Local Storage | `get_storage` |
| PDF Viewer | Opsional — jika perlu lihat invoice |

### Aturan Dependency

- **JANGAN** mix GetX dengan Provider, Bloc, Riverpod, atau state management lain.
- **JANGAN** pakai code generation (`build_runner`, `freezed`, `json_serializable`). Model class ditulis manual.
- Tambah dependency baru hanya jika benar-benar dibutuhkan. Stdlib/Flutter native dulu.

---

## 3. Project Structure

```
azzaops_mobile/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── app/
│   │   ├── routes/
│   │   │   ├── app_pages.dart          # GetPage list
│   │   │   └── app_routes.dart         # Route name constants
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   ├── work_order_model.dart
│   │   │   │   ├── assignment_model.dart
│   │   │   │   ├── report_model.dart
│   │   │   │   └── notification_model.dart
│   │   │   └── providers/
│   │   │       ├── api_provider.dart          # Base HTTP client + interceptor
│   │   │       ├── auth_provider.dart
│   │   │       ├── work_order_provider.dart
│   │   │       ├── report_provider.dart
│   │   │       └── notification_provider.dart
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   │   ├── bindings/auth_binding.dart
│   │   │   │   ├── controllers/auth_controller.dart
│   │   │   │   └── views/login_view.dart
│   │   │   ├── home/
│   │   │   │   ├── bindings/home_binding.dart
│   │   │   │   ├── controllers/home_controller.dart
│   │   │   │   └── views/home_view.dart
│   │   │   ├── work_order/
│   │   │   │   ├── bindings/work_order_binding.dart
│   │   │   │   ├── controllers/work_order_controller.dart
│   │   │   │   └── views/
│   │   │   │       ├── work_order_list_view.dart
│   │   │   │       ├── work_order_detail_view.dart
│   │   │   │       └── assign_technician_view.dart
│   │   │   ├── report/
│   │   │   │   ├── bindings/report_binding.dart
│   │   │   │   ├── controllers/report_controller.dart
│   │   │   │   └── views/
│   │   │   │       ├── report_view.dart
│   │   │   │       └── submit_report_view.dart
│   │   │   ├── notification/
│   │   │   │   ├── bindings/notification_binding.dart
│   │   │   │   ├── controllers/notification_controller.dart
│   │   │   │   └── views/notification_view.dart
│   │   │   └── profile/
│   │   │       ├── bindings/profile_binding.dart
│   │   │       ├── controllers/profile_controller.dart
│   │   │       └── views/profile_view.dart
│   │   └── core/
│   │       ├── theme/
│   │       │   └── app_theme.dart            # Warna, typography, component theme
│   │       ├── utils/
│   │       │   ├── constants.dart            # API base URL, keys, config
│   │       │   ├── storage_helper.dart       # GetStorage wrapper
│   │       │   └── helpers.dart              # Format tanggal, currency, dll
│   │       └── widgets/
│   │           ├── custom_appbar.dart
│   │           ├── loading_widget.dart
│   │           ├── empty_state.dart
│   │           └── photo_picker.dart
├── android/
├── pubspec.yaml
└── README.md
```

### Aturan Struktur

- **JANGAN** bikin folder/layer baru yang tidak ada di atas kecuali benar-benar perlu.
- Setiap module punya: `bindings/`, `controllers/`, `views/`. Tidak lebih.
- Provider = class yang handle HTTP call, return `Future`. Bukan GetX service.
- Model = plain Dart class dengan `fromJson()` factory + `toJson()` method. Manual, tanpa codegen.
- Shared widget taruh di `core/widgets/`.
- Jangan bikin folder `repositories/`, `services/`, `use_cases/` — overkill untuk project ini.

---

## 4. API Integration

### Base Configuration

```dart
// lib/app/core/utils/constants.dart
class Constants {
  static const String baseUrl = 'https://azzaops.com/api'; // ganti sesuai env
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds
}
```

### Authentication Flow

1. User login → `POST /api/login` dengan email + password
2. Backend return token → simpan di `GetStorage`
3. Semua request selanjutnya pakai header: `Authorization: Bearer {token}`
4. Token expired / 401 response → hapus token, redirect ke login screen
5. Logout → `POST /api/logout` + hapus token lokal

### API Response Format

Semua response dari backend mengikuti format ini:

**Success:**
```json
{
  "success": true,
  "message": "Data berhasil diambil",
  "data": { }
}
```

**Error:**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "email": ["Email wajib diisi"]
  }
}
```

### Base API Provider Pattern

```dart
// lib/app/data/providers/api_provider.dart
class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseUrl;
    httpClient.timeout = Duration(seconds: Constants.connectTimeout);

    // Tambah token ke setiap request
    httpClient.addRequestModifier<dynamic>((request) async {
      final token = StorageHelper.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      return request;
    });

    // Handle 401 → redirect ke login
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        StorageHelper.clearToken();
        Get.offAllNamed(AppRoutes.LOGIN);
      }
      return response;
    });
  }
}
```

### Endpoint List

| Method | Endpoint | Deskripsi | Akses |
|---|---|---|---|
| `POST` | `/api/login` | Login, dapat token | Public |
| `POST` | `/api/logout` | Logout, revoke token | Auth |
| `GET` | `/api/profile` | Get profil user | Auth |
| `PUT` | `/api/profile` | Update profil | Auth |
| `GET` | `/api/work-orders` | List WO (filtered by role) | Auth |
| `GET` | `/api/work-orders/{id}` | Detail WO | Auth |
| `PUT` | `/api/work-orders/{id}/status` | Update status WO | Auth |
| `GET` | `/api/assignments` | List teknisi available untuk assign | Kepala Teknisi |
| `POST` | `/api/assignments` | Assign teknisi ke WO | Kepala Teknisi |
| `POST` | `/api/reports` | Submit laporan + foto (multipart) | Teknisi |
| `GET` | `/api/reports/{workOrderId}` | Lihat laporan WO | Auth |
| `GET` | `/api/notifications` | List notifikasi | Auth |
| `PUT` | `/api/notifications/{id}/read` | Mark satu notifikasi as read | Auth |
| `PUT` | `/api/notifications/read-all` | Mark semua notifikasi as read | Auth |

### Foto Upload

```dart
// Upload laporan dengan foto — multipart/form-data
final form = FormData({
  'work_order_id': workOrderId,
  'description': description,
  'photos[]': photos.map((f) => MultipartFile(f, filename: f.name)).toList(),
});
await post('/api/reports', form);
```

- Foto di-compress sebelum upload: quality 70-80%, max 5MB per file
- Maksimal 10 foto per laporan
- Pakai `image_picker` untuk ambil dari kamera atau gallery

---

## 5. Screens & Features

### 5.1 Auth

**Login Screen:**
- Form: email + password
- Tombol login
- Show/hide password toggle
- Loading state saat proses login
- Error handling: tampilkan pesan error dari API via `Get.snackbar()`

**Auto Login:**
- Cek token di `GetStorage` saat app start
- Token ada → validate dengan `GET /api/profile`
- Valid → langsung ke Home
- Invalid/expired → redirect ke Login

### 5.2 Home / Dashboard

**Kepala Teknisi melihat:**
- Jumlah WO pending assign (belum ada teknisi)
- Jumlah WO in progress
- Jumlah WO hari ini
- Quick action: tap card → ke list WO dengan filter

**Teknisi melihat:**
- Jumlah WO assigned ke dia hari ini
- Jumlah WO in progress
- Quick action: tap card → ke list WO

**Shared:**
- Custom AppBar dengan nama user + role
- Bottom navigation atau drawer (pilih yang lebih simple)
- Badge notifikasi unread count

### 5.3 Work Order List

- List WO dengan card layout
- Tab atau filter chip by status: Pending, Assigned, In Progress, Completed
- Pull to refresh
- Pagination jika data banyak (infinite scroll)
- Search/filter by customer name atau WO number
- **Kepala Teknisi**: tap WO → bisa assign teknisi
- **Teknisi**: tap WO → lihat detail & submit laporan

**Card WO menampilkan:**
- Nomor WO
- Nama customer
- Kategori jasa
- Status (dengan warna badge)
- Tanggal

### 5.4 Work Order Detail

- Info lengkap: customer, lokasi/alamat, kategori jasa, deskripsi masalah
- Status timeline / progress indicator
- List teknisi yang di-assign (nama + status masing-masing)
- **Tombol aksi (conditional by role + status):**
  - Kepala Teknisi: "Assign Teknisi" (jika belum di-assign)
  - Teknisi: "Mulai Pengerjaan" (update status ke In Progress)
  - Teknisi: "Submit Laporan" (buka form submit laporan)
- Lihat laporan yang sudah di-submit (jika ada)

### 5.5 Assign Teknisi (Kepala Teknisi Only)

- Tampil saat kepala teknisi ingin assign teknisi ke WO
- List teknisi available (dari `GET /api/assignments`)
- Bisa pilih satu atau lebih teknisi
- Confirm → `POST /api/assignments`
- Success → kembali ke WO detail, tampilkan snackbar sukses

### 5.6 Submit Laporan (Teknisi Only)

- Form:
  - Text area: deskripsi pengerjaan (wajib)
  - Upload foto: dari kamera atau gallery
  - Preview foto yang sudah dipilih (grid/horizontal scroll)
  - Bisa hapus foto sebelum submit
  - Max 10 foto, max 5MB per foto
- Tombol submit
- Loading state + progress indicator saat upload
- Success → kembali ke WO detail

### 5.7 Notifications

- List notifikasi (card layout)
- Unread → background berbeda / bold
- Tap → mark as read + navigate ke WO terkait
- Tombol "Mark All as Read"
- Pull to refresh
- Badge count di bottom nav / app bar

**FCM Behavior:**
- Foreground: tampilkan local notification
- Background/terminated: tap notification → buka app, navigate ke WO terkait
- Simpan FCM token → kirim ke backend saat login (jika backend support)

### 5.8 Profile

- Tampilkan info: nama, email, role, nomor HP
- Edit profil (nama, nomor HP)
- Ganti password (password lama + password baru + konfirmasi)
- Tombol logout → confirm dialog → clear token → ke login screen

---

## 6. Coding Conventions

### GetX Pattern (WAJIB)

Setiap module terdiri dari 3 bagian:

```
module/
├── bindings/xxx_binding.dart    → Register controller & provider ke DI
├── controllers/xxx_controller.dart → Business logic, state, call provider
└── views/xxx_view.dart          → UI, pakai Obx() untuk reactive
```

**Binding:**
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}
```

**Controller:**
```dart
class HomeController extends GetxController {
  final isLoading = false.obs;
  final workOrders = <WorkOrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final result = await WorkOrderProvider().getWorkOrders();
      workOrders.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
```

**View:**
```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Dashboard'),
      body: Obx(() {
        if (controller.isLoading.value) return LoadingWidget();
        return ListView.builder(...);
      }),
    );
  }
}
```

### Model Class

```dart
class WorkOrderModel {
  final int id;
  final String code;
  final String customerName;
  final String status;
  // ...

  WorkOrderModel({
    required this.id,
    required this.code,
    required this.customerName,
    required this.status,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['id'],
      code: json['code'],
      customerName: json['customer_name'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'customer_name': customerName,
    'status': status,
  };
}
```

- Tidak pakai `freezed`, `json_serializable`, atau codegen apapun.
- Factory `fromJson` + method `toJson`, ditulis manual.

### Naming Convention

| Jenis | Convention | Contoh |
|---|---|---|
| File | `snake_case` | `work_order_model.dart` |
| Class | `PascalCase` | `WorkOrderController` |
| Variable/Method | `camelCase` | `fetchWorkOrders()` |
| Constant | `camelCase` atau `SCREAMING_SNAKE` | `baseUrl` atau `BASE_URL` |
| Route name | `SCREAMING_SNAKE` | `AppRoutes.WORK_ORDER_DETAIL` |

### Error Handling

```dart
try {
  // API call
} catch (e) {
  Get.snackbar(
    'Error',
    e.toString(),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red.shade100,
  );
}
```

- Semua API call di-wrap `try-catch` di level controller.
- Tampilkan error ke user via `Get.snackbar()`.
- 401 → ditangani di `ApiProvider` secara global, redirect ke login.
- No internet → tampilkan pesan "Tidak ada koneksi internet".

### Loading State

Setiap controller yang fetch data HARUS punya:

```dart
final isLoading = false.obs;
```

View HARUS handle loading state:

```dart
Obx(() {
  if (controller.isLoading.value) return LoadingWidget();
  if (controller.items.isEmpty) return EmptyState(message: 'Tidak ada data');
  return ListView.builder(...);
})
```

---

## 7. Key Business Rules (Mobile Side)

### Role-Based Access

| Fitur | Kepala Teknisi | Teknisi |
|---|---|---|
| Lihat semua WO | Ya | Tidak (hanya WO yang di-assign) |
| Assign teknisi ke WO | Ya | Tidak |
| Monitor progress semua WO | Ya | Tidak |
| Update status WO (mulai/selesai) | Tidak | Ya |
| Submit laporan + foto | Tidak | Ya |
| Lihat laporan | Ya | Ya (milik sendiri) |
| Notifikasi | Ya | Ya |
| Edit profil | Ya | Ya |

### Foto

- Compress sebelum upload: quality 70-80%
- Max 10 foto per laporan
- Max 5MB per file setelah compress
- Upload via `multipart/form-data`
- Preview sebelum submit

### Token & Auth

- Token disimpan di `GetStorage` (key: `token`)
- User role disimpan di `GetStorage` (key: `user_role`)
- User data disimpan di `GetStorage` (key: `user_data`)
- Token expired → 401 dari API → clear storage → redirect login
- Tidak perlu refresh token mechanism — login ulang saja

### FCM Notification

- Request permission saat pertama kali buka app
- Simpan FCM token, kirim ke backend jika backend support endpoint
- Tap notifikasi → navigate ke WO terkait (parsing payload `work_order_id`)
- Foreground: tampilkan via `flutter_local_notifications`
- Background: handled by FCM default behavior

### Offline

- **Tidak perlu offline-first untuk MVP**
- Jika tidak ada internet, tampilkan error message
- Tidak perlu local database / SQLite
- `GetStorage` hanya untuk token + user data, bukan cache data

---

## 8. Theme & Branding

```dart
// Warna utama — sesuaikan dengan branding AzzaOps
class AppColors {
  static const Color primary = Color(0xFF1565C0);       // Biru professional
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color accent = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

- Gunakan Material Design 3
- Font: default (Roboto) — jangan tambah custom font kecuali diminta
- Status badge warna: Pending (orange), Assigned (blue), In Progress (indigo), Completed (green), Cancelled (red)

---

## 9. Build & Run

```bash
# Run debug
flutter run

# Build APK release
flutter build apk --release

# Build APK split per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi --release
```

- APK output di `build/app/outputs/flutter-apk/`
- Distribusi: kirim APK langsung ke user (bukan via Play Store)
- Signing: pakai debug key untuk development, buat keystore untuk release

---

## 10. Important Notes for AI Assistants

### DO

- Pakai GetX untuk **SEMUA** (state, routing, DI) — konsisten
- Struktur project **SEDERHANA** — ikuti struktur di section 3
- Model class **MANUAL** — `fromJson`/`toJson` ditulis tangan
- Handle loading & empty state di setiap view
- Handle error di setiap controller dengan `try-catch` + `Get.snackbar()`
- Compress foto sebelum upload
- Cek role user sebelum tampilkan fitur (Kepala Teknisi vs Teknisi)
- Ikuti naming convention yang sudah ditetapkan
- Global 401 handling di `ApiProvider`

### DON'T

- **JANGAN** mix state management (no Provider, Bloc, Riverpod)
- **JANGAN** pakai code generation (`build_runner`, `freezed`, `json_serializable`)
- **JANGAN** pakai GetX service pattern yang over-complex — cukup controller + provider
- **JANGAN** bikin layer abstraction yang tidak perlu (repository, use case, interface)
- **JANGAN** bikin folder baru di luar struktur yang sudah ditentukan
- **JANGAN** tambah dependency baru tanpa alasan yang jelas
- **JANGAN** bikin offline-first / local database — belum perlu untuk MVP
- **JANGAN** pakai custom font kecuali diminta
- **JANGAN** over-engineer — ini app internal, bukan app consumer scale

### Prioritas Development (Urutan Build)

1. Setup project + theme + constants + base API provider
2. Auth (login + auto-login + logout)
3. Home dashboard
4. Work Order list + detail
5. Assign teknisi (Kepala Teknisi)
6. Submit laporan + foto (Teknisi)
7. Notifications
8. Profile
9. FCM integration
10. Polish & testing
