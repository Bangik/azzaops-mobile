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
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      workOrderId: json['work_order_id'] is int ? json['work_order_id'] as int : (int.tryParse(json['work_order_id']?.toString() ?? '0') ?? 0),
      technicianId: json['technician_id'] is int ? json['technician_id'] as int : (int.tryParse(json['technician_id']?.toString() ?? '0') ?? 0),
      technician: json['technician'] != null && json['technician'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['technician'] as Map))
          : null,
      assignedById: json['assigned_by'] is int
          ? json['assigned_by'] as int
          : (json['assigned_by'] is Map ? (int.tryParse(json['assigned_by']['id']?.toString() ?? '0') ?? 0) : 0),
      assignedBy: json['assigner'] != null && json['assigner'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['assigner'] as Map))
          : null,
      status: (json['status'] ?? 'pending').toString(),
      assignedAt: (json['assigned_at'] ?? json['created_at'] ?? '').toString(),
      acceptedAt: json['accepted_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      notes: json['notes']?.toString(),
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
