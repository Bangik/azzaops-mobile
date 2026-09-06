import 'user_model.dart';

class WorkOrderTakeoverModel {
  final int id;
  final int workOrderId;
  final int requestedById;
  final UserModel? requester;
  final int originalTechnicianId;
  final UserModel? originalTechnician;
  final String status; // pending, approved, rejected
  final int? approvedBy;
  final int? rejectedBy;
  final String? notes;
  final String createdAt;

  WorkOrderTakeoverModel({
    required this.id,
    required this.workOrderId,
    required this.requestedById,
    this.requester,
    required this.originalTechnicianId,
    this.originalTechnician,
    required this.status,
    this.approvedBy,
    this.rejectedBy,
    this.notes,
    required this.createdAt,
  });

  factory WorkOrderTakeoverModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderTakeoverModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      workOrderId: json['work_order_id'] is int ? json['work_order_id'] as int : (int.tryParse(json['work_order_id']?.toString() ?? '0') ?? 0),
      requestedById: json['requested_by'] is int ? json['requested_by'] as int : (int.tryParse(json['requested_by']?.toString() ?? '0') ?? 0),
      requester: json['requester'] != null && json['requester'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['requester'] as Map))
          : null,
      originalTechnicianId: json['original_technician_id'] is int ? json['original_technician_id'] as int : (int.tryParse(json['original_technician_id']?.toString() ?? '0') ?? 0),
      originalTechnician: json['original_technician'] != null && json['original_technician'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['original_technician'] as Map))
          : null,
      status: (json['status'] ?? 'pending').toString(),
      approvedBy: json['approved_by'] is int ? json['approved_by'] as int : int.tryParse(json['approved_by']?.toString() ?? ''),
      rejectedBy: json['rejected_by'] is int ? json['rejected_by'] as int : int.tryParse(json['rejected_by']?.toString() ?? ''),
      notes: json['notes']?.toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'work_order_id': workOrderId,
        'requested_by': requestedById,
        'requester': requester?.toJson(),
        'original_technician_id': originalTechnicianId,
        'original_technician': originalTechnician?.toJson(),
        'status': status,
        'approved_by': approvedBy,
        'rejected_by': rejectedBy,
        'notes': notes,
        'created_at': createdAt,
      };
}
