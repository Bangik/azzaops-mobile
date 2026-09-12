import 'user_model.dart';

class WorkOrderSessionModel {
  final int id;
  final int workOrderId;
  final int? technicianId;
  final UserModel? technician;
  final String startedAt;
  final String? endedAt;
  final String? notes;
  final String? duration;
  final int? durationMinutes;

  WorkOrderSessionModel({
    required this.id,
    required this.workOrderId,
    this.technicianId,
    this.technician,
    required this.startedAt,
    this.endedAt,
    this.notes,
    this.duration,
    this.durationMinutes,
  });

  /// A session with no `ended_at` is still ongoing (work is currently active).
  bool get isActive => endedAt == null;

  factory WorkOrderSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderSessionModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      workOrderId: json['work_order_id'] is int
          ? json['work_order_id'] as int
          : (int.tryParse(json['work_order_id']?.toString() ?? '0') ?? 0),
      technicianId: json['technician_id'] is int
          ? json['technician_id'] as int
          : int.tryParse(json['technician_id']?.toString() ?? ''),
      technician: json['technician'] != null && json['technician'] is Map
          ? UserModel.fromJson(
              Map<String, dynamic>.from(json['technician'] as Map),
            )
          : null,
      startedAt: (json['started_at'] ?? '').toString(),
      endedAt: json['ended_at']?.toString(),
      notes: json['notes']?.toString(),
      duration: json['duration']?.toString(),
      durationMinutes: json['duration_minutes'] is int
          ? json['duration_minutes'] as int
          : int.tryParse(json['duration_minutes']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'technician_id': technicianId,
    'technician': technician?.toJson(),
    'started_at': startedAt,
    'ended_at': endedAt,
    'notes': notes,
    'duration': duration,
    'duration_minutes': durationMinutes,
  };
}
