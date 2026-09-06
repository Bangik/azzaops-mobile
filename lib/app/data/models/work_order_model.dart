import 'customer_model.dart';
import 'service_category_model.dart';
import 'work_order_item_model.dart';
import 'assignment_model.dart';
import 'report_model.dart';
import 'work_order_takeover_model.dart';
import 'work_order_type_model.dart';

class WorkOrderModel {
  final int id;
  final String woNumber;
  final WorkOrderTypeModel? type;
  final CustomerModel customer;
  final ServiceCategoryModel serviceCategory;
  final String title;
  final String? description;
  final String location;
  final String? scheduledDate;
  final String? scheduledTime;
  final int? jobOrder;
  final String? startedAt;
  final String? completedAt;
  final String? duration;
  final int? durationMinutes;
  final String status;
  final double? estimatedCost;
  final double? totalCost;
  final String? notes;
  final int? parentWoId;
  final String? gmapsLink;
  final List<WorkOrderItemModel> items;
  final List<AssignmentModel> assignments;
  final List<ReportModel> reports;
  final List<WorkOrderTakeoverModel> takeovers;
  final String createdAt;

  WorkOrderModel({
    required this.id,
    required this.woNumber,
    this.type,
    required this.customer,
    required this.serviceCategory,
    required this.title,
    this.description,
    required this.location,
    this.scheduledDate,
    this.scheduledTime,
    this.jobOrder,
    this.startedAt,
    this.completedAt,
    this.duration,
    this.durationMinutes,
    required this.status,
    this.estimatedCost,
    this.totalCost,
    this.notes,
    this.parentWoId,
    this.gmapsLink,
    required this.items,
    required this.assignments,
    required this.reports,
    required this.takeovers,
    required this.createdAt,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <WorkOrderItemModel>[];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .whereType<Map>()
          .map((i) => WorkOrderItemModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    var assignmentsList = <AssignmentModel>[];
    if (json['assignments'] is List) {
      assignmentsList = (json['assignments'] as List)
          .whereType<Map>()
          .map((i) => AssignmentModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    var reportsList = <ReportModel>[];
    if (json['reports'] is List) {
      reportsList = (json['reports'] as List)
          .whereType<Map>()
          .map((i) => ReportModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    var takeoversList = <WorkOrderTakeoverModel>[];
    if (json['takeovers'] is List) {
      takeoversList = (json['takeovers'] as List)
          .whereType<Map>()
          .map((i) => WorkOrderTakeoverModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    // ponytail: type can be either Map (from Eloquent relation) or String (legacy/fallback)
    WorkOrderTypeModel? parsedType;
    if (json['type'] is Map) {
      parsedType = WorkOrderTypeModel.fromJson(Map<String, dynamic>.from(json['type'] as Map));
    } else if (json['type'] is String) {
      parsedType = WorkOrderTypeModel(
        id: 0,
        name: json['type'] as String,
        code: json['type'] as String,
        isActive: true,
      );
    }

    CustomerModel parsedCustomer;
    if (json['customer'] is Map) {
      parsedCustomer = CustomerModel.fromJson(Map<String, dynamic>.from(json['customer'] as Map));
    } else {
      parsedCustomer = CustomerModel.empty();
    }

    ServiceCategoryModel parsedCategory;
    if (json['service_category'] is Map) {
      parsedCategory = ServiceCategoryModel.fromJson(Map<String, dynamic>.from(json['service_category'] as Map));
    } else {
      parsedCategory = ServiceCategoryModel.empty();
    }

    return WorkOrderModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      woNumber: (json['wo_number'] ?? json['code'] ?? '')?.toString() ?? '',
      type: parsedType,
      customer: parsedCustomer,
      serviceCategory: parsedCategory,
      title: (json['title'] ?? '')?.toString() ?? '',
      description: json['description']?.toString(),
      location: (json['location'] ?? '')?.toString() ?? '',
      scheduledDate: json['scheduled_date']?.toString(),
      scheduledTime: json['scheduled_time']?.toString(),
      jobOrder: json['job_order'] is int ? json['job_order'] as int : int.tryParse(json['job_order']?.toString() ?? ''),
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      duration: json['duration']?.toString(),
      durationMinutes: json['duration_minutes'] is int
          ? json['duration_minutes'] as int
          : int.tryParse(json['duration_minutes']?.toString() ?? ''),
      status: (json['status'] ?? 'pending')?.toString() ?? 'pending',
      estimatedCost: json['estimated_cost'] != null ? double.tryParse(json['estimated_cost'].toString()) : null,
      totalCost: json['total_cost'] != null ? double.tryParse(json['total_cost'].toString()) : null,
      notes: json['notes']?.toString(),
      parentWoId: json['parent_wo_id'] is int ? json['parent_wo_id'] as int : int.tryParse(json['parent_wo_id']?.toString() ?? ''),
      gmapsLink: json['gmaps_link']?.toString(),
      items: itemsList,
      assignments: assignmentsList,
      reports: reportsList,
      takeovers: takeoversList,
      createdAt: (json['created_at'] ?? '')?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wo_number': woNumber,
        'type': type?.toJson(),
        'customer': customer.toJson(),
        'service_category': serviceCategory.toJson(),
        'title': title,
        'description': description,
        'location': location,
        'scheduled_date': scheduledDate,
        'scheduled_time': scheduledTime,
        'job_order': jobOrder,
        'started_at': startedAt,
        'completed_at': completedAt,
        'duration': duration,
        'duration_minutes': durationMinutes,
        'status': status,
        'estimated_cost': estimatedCost,
        'total_cost': totalCost,
        'notes': notes,
        'parent_wo_id': parentWoId,
        'gmaps_link': gmapsLink,
        'items': items.map((e) => e.toJson()).toList(),
        'assignments': assignments.map((e) => e.toJson()).toList(),
        'reports': reports.map((e) => e.toJson()).toList(),
        'takeovers': takeovers.map((e) => e.toJson()).toList(),
        'created_at': createdAt,
      };
}
