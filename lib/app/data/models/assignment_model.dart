import 'user_model.dart';

class AssignmentModel {
  final int id;
  final int workOrderId;
  final int technicianId;
  final UserModel? technician;
  final int assignedById;
  final UserModel? assignedBy;
  final String status;
  final String assignedAt;
  final String? acceptedAt;
  final String? completedAt;
  final String? notes;

  AssignmentModel({
    required this.id,
    required this.workOrderId,
    required this.technicianId,
    this.technician,
    required this.assignedById,
    this.assignedBy,
    required this.status,
    required this.assignedAt,
    this.acceptedAt,
    this.completedAt,
    this.notes,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as int,
      workOrderId: json['work_order_id'] as int,
      technicianId: json['technician_id'] as int,
      technician: json['technician'] != null && json['technician'] is Map
          ? UserModel.fromJson(json['technician'] as Map<String, dynamic>)
          : null,
      assignedById: json['assigned_by'] is int
          ? json['assigned_by'] as int
          : (json['assigned_by'] is Map ? json['assigned_by']['id'] as int : 0),
      assignedBy: json['assigner'] != null && json['assigner'] is Map
          ? UserModel.fromJson(json['assigner'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      assignedAt: json['assigned_at'] as String,
      acceptedAt: json['accepted_at'] as String?,
      completedAt: json['completed_at'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'work_order_id': workOrderId,
        'technician_id': technicianId,
        'technician': technician?.toJson(),
        'assigned_by': assignedById,
        'status': status,
        'assigned_at': assignedAt,
        'accepted_at': acceptedAt,
        'completed_at': completedAt,
        'notes': notes,
      };

  String get technicianName => technician?.name ?? 'Teknisi #$assignedById';
}
