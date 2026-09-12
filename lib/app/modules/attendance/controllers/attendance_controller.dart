import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/providers/attendance_provider.dart';

class AttendanceController extends GetxController {
  final AttendanceProvider _provider = Get.put(AttendanceProvider());

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final todayData = Rxn<AttendanceTodayResponse>();
  final logs = <AttendanceModel>[].obs;
  final isLoadingLogs = false.obs;
  final hasMoreLogs = true.obs;
  int _currentPage = 1;

  // Location variables
  final currentLocation = Rxn<Position>();
  final locationError = RxnString();
  final distanceToOffice = RxnDouble();
  final isWithinRadius = false.obs;
  final isFetchingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchToday().then((_) => _initLocation());
    fetchLogs();
  }

  Future<void> _initLocation() async {
    isFetchingLocation.value = true;
    locationError.value = null;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError.value = 'Layanan lokasi dinonaktifkan.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = 'Izin lokasi ditolak.';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (position.isMocked) {
        locationError.value = 'Aplikasi Fake GPS terdeteksi. Harap matikan untuk melakukan presensi.';
        return;
      }

      currentLocation.value = position;
      _calculateDistance(position);
    } catch (e) {
      locationError.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<void> refreshLocation() async {
    await _initLocation();
  }

  void _calculateDistance(Position currentPos) {
    final data = todayData.value;
    if (data == null) return;

    final latStr = data.schedule['attendance_latitude'] ?? '';
    final lngStr = data.schedule['attendance_longitude'] ?? '';
    final radiusStr = data.schedule['attendance_radius_meters'] ?? '100';

    if (latStr.isEmpty || lngStr.isEmpty) {
      locationError.value = 'Lokasi presensi belum diatur oleh Admin.';
      return;
    }

    final officeLat = double.tryParse(latStr);
    final officeLng = double.tryParse(lngStr);
    final radius = double.tryParse(radiusStr) ?? 100.0;

    if (officeLat == null || officeLng == null) return;

    const Distance distance = Distance();
    final distMeter = distance.as(
      LengthUnit.Meter,
      LatLng(currentPos.latitude, currentPos.longitude),
      LatLng(officeLat, officeLng),
    );

    distanceToOffice.value = distMeter;
    isWithinRadius.value = distMeter <= radius;
  }

  Future<void> fetchToday() async {
    try {
      isLoading.value = true;
      final response = await _provider.getToday();
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true && body['data'] is Map) {
          todayData.value = AttendanceTodayResponse.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
          if (currentLocation.value != null) {
            _calculateDistance(currentLocation.value!);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data presensi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIn({String? notes}) async {
    if (locationError.value != null) {
      Get.snackbar('Error Lokasi', locationError.value!);
      return;
    }
    if (currentLocation.value == null) {
      Get.snackbar('Error', 'Tunggu hingga lokasi ditemukan.');
      return;
    }
    if (currentLocation.value!.isMocked) {
      Get.snackbar('Fake GPS', 'Matikan Fake GPS untuk presensi.');
      return;
    }
    if (!isWithinRadius.value) {
      Get.snackbar('Di Luar Radius', 'Anda harus berada di lokasi kantor untuk presensi masuk.');
      return;
    }

    try {
      isSubmitting.value = true;
      final response = await _provider.checkIn(
        notes: notes,
        latitude: currentLocation.value!.latitude,
        longitude: currentLocation.value!.longitude,
      );
      if (response.statusCode == 200 && response.body?['success'] == true) {
        Get.snackbar('Berhasil', response.body['message'] ?? 'Presensi masuk dicatat.');
        await fetchToday();
        await fetchLogs(refresh: true);
      } else {
        Get.snackbar('Gagal', response.body?['message'] ?? 'Gagal presensi masuk.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> checkOut({String? notes}) async {
    if (locationError.value != null) {
      Get.snackbar('Error Lokasi', locationError.value!);
      return;
    }
    if (currentLocation.value == null) {
      Get.snackbar('Error', 'Tunggu hingga lokasi ditemukan.');
      return;
    }
    if (currentLocation.value!.isMocked) {
      Get.snackbar('Fake GPS', 'Matikan Fake GPS untuk presensi.');
      return;
    }
    if (!isWithinRadius.value) {
      Get.snackbar('Di Luar Radius', 'Anda harus berada di lokasi kantor untuk presensi pulang.');
      return;
    }

    try {
      isSubmitting.value = true;
      final response = await _provider.checkOut(
        notes: notes,
        latitude: currentLocation.value!.latitude,
        longitude: currentLocation.value!.longitude,
      );
      if (response.statusCode == 200 && response.body?['success'] == true) {
        Get.snackbar('Berhasil', response.body['message'] ?? 'Presensi pulang dicatat.');
        await fetchToday();
        await fetchLogs(refresh: true);
      } else {
        Get.snackbar('Gagal', response.body?['message'] ?? 'Gagal presensi pulang.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchLogs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      logs.clear();
      hasMoreLogs.value = true;
    }

    if (!hasMoreLogs.value) return;

    try {
      isLoadingLogs.value = true;
      final response = await _provider.getMyLog(page: _currentPage);
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List)
              .whereType<Map>()
              .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          logs.addAll(list);

          final meta = body['meta'];
          if (meta != null) {
            hasMoreLogs.value = meta['current_page'] < meta['last_page'];
            _currentPage = (meta['current_page'] as int) + 1;
          } else {
            hasMoreLogs.value = false;
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat presensi.');
    } finally {
      isLoadingLogs.value = false;
    }
  }
}
