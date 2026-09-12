class AttendanceModel {
  final int id;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String statusLabel;
  final String? notes;
  final String? workDuration;

  AttendanceModel({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.statusLabel,
    this.notes,
    this.workDuration,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      status: json['status'] ?? 'present',
      statusLabel: json['status_label'] ?? 'Hadir',
      notes: json['notes'],
      workDuration: json['work_duration'],
    );
  }
}

class AttendanceTodayResponse {
  final AttendanceModel? attendance;
  final Map<String, String> schedule;
  final bool hasCheckedIn;
  final bool hasCheckedOut;

  AttendanceTodayResponse({
    this.attendance,
    required this.schedule,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
  });

  factory AttendanceTodayResponse.fromJson(Map<String, dynamic> json) {
    final scheduleRaw = json['schedule'] as Map<String, dynamic>? ?? {};
    return AttendanceTodayResponse(
      attendance: json['attendance'] != null
          ? AttendanceModel.fromJson(json['attendance'])
          : null,
      schedule: {
        'work_start_time': scheduleRaw['work_start_time']?.toString() ?? '08:00',
        'work_end_time': scheduleRaw['work_end_time']?.toString() ?? '17:00',
        'attendance_radius_meters': scheduleRaw['attendance_radius_meters']?.toString() ?? '100',
        'attendance_latitude': scheduleRaw['attendance_latitude']?.toString() ?? '',
        'attendance_longitude': scheduleRaw['attendance_longitude']?.toString() ?? '',
      },
      hasCheckedIn: json['has_checked_in'] ?? false,
      hasCheckedOut: json['has_checked_out'] ?? false,
    );
  }
}
