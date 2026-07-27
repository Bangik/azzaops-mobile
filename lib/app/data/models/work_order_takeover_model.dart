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
      id: json['id'] as int,
      workOrderId: json['work_order_id'] as int,
      requestedById: json['requested_by'] as int,
      requester: json['requester'] != null
          ? UserModel.fromJson(json['requester'] as Map<String, dynamic>)
          : null,
      originalTechnicianId: json['original_technician_id'] as int,
      originalTechnician: json['original_technician'] != null
          ? UserModel.fromJson(json['original_technician'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      approvedBy: json['approved_by'] as int?,
      rejectedBy: json['rejected_by'] as int?,
      notes: json['notes'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
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
