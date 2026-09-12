import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../app/core/theme/app_theme.dart';
import '../../../../app/core/widgets/custom_appbar.dart';
import '../../../../app/core/widgets/loading_widget.dart';
import '../controllers/attendance_controller.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Presensi'),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchToday();
          await controller.refreshLocation();
          await controller.fetchLogs(refresh: true);
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LoadingWidget());
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTodayCard(context),
                const SizedBox(height: 16),
                _buildMapCard(),
                const SizedBox(height: 24),
                const Text(
                  'Riwayat Presensi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLogList(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMapCard() {
    return Obx(() {
      final currentPos = controller.currentLocation.value;
      final data = controller.todayData.value;
      final officeLatStr = data?.schedule['attendance_latitude'] ?? '';
      final officeLngStr = data?.schedule['attendance_longitude'] ?? '';
      final radiusStr = data?.schedule['attendance_radius_meters'] ?? '100';

      final officeLat = double.tryParse(officeLatStr);
      final officeLng = double.tryParse(officeLngStr);
      final radius = double.tryParse(radiusStr) ?? 100.0;

      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Lokasi Anda',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: controller.isFetchingLocation.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 20),
                    onPressed: controller.refreshLocation,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  if (currentPos != null && officeLat != null && officeLng != null)
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(currentPos.latitude, currentPos.longitude),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.azzaops.mobile',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: LatLng(officeLat, officeLng),
                              color: AppColors.primary.withOpacity(0.2),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 1,
                              useRadiusInMeter: true,
                              radius: radius,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(currentPos.latitude, currentPos.longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                            ),
                            Marker(
                              point: LatLng(officeLat, officeLng),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.business, color: Colors.red, size: 30),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text(
                          'Memuat peta...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  if (controller.locationError.value != null)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            controller.locationError.value!,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (controller.distanceToOffice.value != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: controller.isWithinRadius.value 
                    ? AppColors.success.withOpacity(0.1) 
                    : AppColors.error.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.isWithinRadius.value ? Icons.check_circle : Icons.warning,
                      color: controller.isWithinRadius.value ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jarak: ${controller.distanceToOffice.value!.toStringAsFixed(0)} meter dari kantor',
                      style: TextStyle(
                        color: controller.isWithinRadius.value ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTodayCard(BuildContext context) {
    return Obx(() {
      final data = controller.todayData.value;
      final hasCheckedIn = data?.hasCheckedIn ?? false;
      final hasCheckedOut = data?.hasCheckedOut ?? false;
      final attendance = data?.attendance;
      final schedule = data?.schedule ?? {'work_start_time': '08:00', 'work_end_time': '17:00'};

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _formatTodayDate(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jadwal: ${schedule['work_start_time']} - ${schedule['work_end_time']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Check-in / Check-out times
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeBlock(
                          label: 'Masuk',
                          time: attendance?.checkIn,
                          icon: Icons.login,
                          color: AppColors.success,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(
                        child: _buildTimeBlock(
                          label: 'Pulang',
                          time: attendance?.checkOut,
                          icon: Icons.logout,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),

                  // Status badge
                  if (attendance != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(attendance.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            attendance.statusLabel,
                            style: TextStyle(
                              color: _getStatusColor(attendance.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (attendance.workDuration != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            attendance.workDuration!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action button
                  if (!hasCheckedIn)
                    _buildActionButton(
                      label: 'Presensi Masuk',
                      icon: Icons.login,
                      color: AppColors.success,
                      onPressed: () => _showCheckDialog(context, isCheckIn: true),
                    )
                  else if (!hasCheckedOut)
                    _buildActionButton(
                      label: 'Presensi Pulang',
                      icon: Icons.logout,
                      color: AppColors.error,
                      onPressed: () => _showCheckDialog(context, isCheckIn: false),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Presensi hari ini sudah lengkap',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimeBlock({
    required String label,
    String? time,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          time ?? '--:--',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: time != null ? AppColors.textPrimary : Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.isSubmitting.value ? null : onPressed,
            icon: controller.isSubmitting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ));
  }

  void _showCheckDialog(BuildContext context, {required bool isCheckIn}) {
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(isCheckIn ? 'Presensi Masuk' : 'Presensi Pulang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCheckIn
                  ? 'Konfirmasi presensi masuk sekarang?'
                  : 'Konfirmasi presensi pulang sekarang?',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (isCheckIn) {
                controller.checkIn(notes: notesController.text);
              } else {
                controller.checkOut(notes: notesController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCheckIn ? AppColors.success : AppColors.error,
            ),
            child: Text(isCheckIn ? 'Masuk' : 'Pulang'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return Obx(() {
      if (controller.isLoadingLogs.value && controller.logs.isEmpty) {
        return const Center(child: LoadingWidget());
      }

      if (controller.logs.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Belum ada riwayat presensi',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.logs.length,
            itemBuilder: (context, index) {
              final log = controller.logs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(log.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(log.status),
                      color: _getStatusColor(log.status),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _formatDate(log.date),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${log.checkIn ?? "--:--"} - ${log.checkOut ?? "--:--"}${log.workDuration != null ? '  (${log.workDuration})' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(log.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      log.statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(log.status),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (controller.hasMoreLogs.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                onPressed: () => controller.fetchLogs(),
                child: controller.isLoadingLogs.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Muat lebih banyak'),
              ),
            ),
        ],
      );
    });
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'present' => AppColors.success,
      'late' => AppColors.warning,
      'absent' => AppColors.error,
      _ => AppColors.textSecondary,
    };
  }

  IconData _getStatusIcon(String status) {
    return switch (status) {
      'present' => Icons.check_circle_outline,
      'late' => Icons.schedule,
      'absent' => Icons.cancel_outlined,
      _ => Icons.help_outline,
    };
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
