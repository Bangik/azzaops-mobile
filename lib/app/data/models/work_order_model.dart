import 'customer_model.dart';
import 'service_category_model.dart';
import 'work_order_item_model.dart';
import 'assignment_model.dart';
import 'report_model.dart';
import 'work_order_takeover_model.dart';

class WorkOrderModel {
  final int id;
  final String woNumber;
  final String type;
  final CustomerModel customer;
  final ServiceCategoryModel serviceCategory;
  final String title;
  final String? description;
  final String location;
  final String? scheduledDate;
  final String? startedAt;
  final String? completedAt;
  final String status;
  final String priority;
  final double? estimatedCost;
  final double? totalCost;
  final String? notes;
  final int? parentWoId;
  final List<WorkOrderItemModel> items;
  final List<AssignmentModel> assignments;
  final List<ReportModel> reports;
  final List<WorkOrderTakeoverModel> takeovers;
  final String createdAt;

  WorkOrderModel({
    required this.id,
    required this.woNumber,
    required this.type,
    required this.customer,
    required this.serviceCategory,
    required this.title,
    this.description,
    required this.location,
    this.scheduledDate,
    this.startedAt,
    this.completedAt,
    required this.status,
    required this.priority,
    this.estimatedCost,
    this.totalCost,
    this.notes,
    this.parentWoId,
    required this.items,
    required this.assignments,
    required this.reports,
    required this.takeovers,
    required this.createdAt,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <WorkOrderItemModel>[];
    if (json['items'] != null) {
      itemsList = (json['items'] as List)
          .map((i) => WorkOrderItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    var assignmentsList = <AssignmentModel>[];
    if (json['assignments'] != null) {
      assignmentsList = (json['assignments'] as List)
          .map((i) => AssignmentModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    var reportsList = <ReportModel>[];
    if (json['reports'] != null) {
      reportsList = (json['reports'] as List)
          .map((i) => ReportModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    var takeoversList = <WorkOrderTakeoverModel>[];
    if (json['takeovers'] != null) {
      takeoversList = (json['takeovers'] as List)
          .map((i) => WorkOrderTakeoverModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return WorkOrderModel(
      id: json['id'] as int,
      woNumber: (json['wo_number'] ?? json['code'] ?? '') as String,
      type: json['type'] as String,
      customer: CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
      serviceCategory: ServiceCategoryModel.fromJson(json['service_category'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String,
      scheduledDate: json['scheduled_date'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      estimatedCost: json['estimated_cost'] != null ? double.parse(json['estimated_cost'].toString()) : null,
      totalCost: json['total_cost'] != null ? double.parse(json['total_cost'].toString()) : null,
      notes: json['notes'] as String?,
      parentWoId: json['parent_wo_id'] as int?,
      items: itemsList,
      assignments: assignmentsList,
      reports: reportsList,
      takeovers: takeoversList,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wo_number': woNumber,
        'type': type,
        'customer': customer.toJson(),
        'service_category': serviceCategory.toJson(),
        'title': title,
        'description': description,
        'location': location,
        'scheduled_date': scheduledDate,
        'started_at': startedAt,
        'completed_at': completedAt,
        'status': status,
        'priority': priority,
        'estimated_cost': estimatedCost,
        'total_cost': totalCost,
        'notes': notes,
        'parent_wo_id': parentWoId,
        'items': items.map((e) => e.toJson()).toList(),
        'assignments': assignments.map((e) => e.toJson()).toList(),
        'reports': reports.map((e) => e.toJson()).toList(),
        'takeovers': takeovers.map((e) => e.toJson()).toList(),
        'created_at': createdAt,
      };
}
