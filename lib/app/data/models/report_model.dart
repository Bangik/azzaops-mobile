import 'user_model.dart';

class ReportPhotoModel {
  final int id;
  final String photoUrl;
  final String photoType;
  final String? caption;

  ReportPhotoModel({
    required this.id,
    required this.photoUrl,
    required this.photoType,
    this.caption,
  });

  factory ReportPhotoModel.fromJson(Map<String, dynamic> json) {
    return ReportPhotoModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      photoUrl: (json['photo_url'] ?? json['photo_path'] ?? '').toString(),
      photoType: (json['photo_type'] ?? 'after').toString(),
      caption: json['caption']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo_url': photoUrl,
    'photo_type': photoType,
    'caption': caption,
  };
}

class ReportModel {
  final int id;
  final int workOrderId;
  final int technicianId;
  final UserModel? technician;
  final String findings;
  final String workDone;
  final String? recommendations;
  final String? materialsUsed;
  final List<ReportPhotoModel> photos;
  final String submittedAt;
  final bool isDraft;

  ReportModel({
    required this.id,
    required this.workOrderId,
    required this.technicianId,
    this.technician,
    required this.findings,
    required this.workDone,
    this.recommendations,
    this.materialsUsed,
    required this.photos,
    required this.submittedAt,
    this.isDraft = false,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    var photosList = <ReportPhotoModel>[];
    if (json['photos'] is List) {
      photosList = (json['photos'] as List)
          .whereType<Map>()
          .map((i) => ReportPhotoModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }
    return ReportModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      workOrderId: json['work_order_id'] is int
          ? json['work_order_id'] as int
          : (int.tryParse(json['work_order_id']?.toString() ?? '0') ?? 0),
      technicianId: json['technician_id'] is int
          ? json['technician_id'] as int
          : (int.tryParse(json['technician_id']?.toString() ?? '0') ?? 0),
      technician: json['technician'] != null && json['technician'] is Map
          ? UserModel.fromJson(
              Map<String, dynamic>.from(json['technician'] as Map),
            )
          : null,
      findings: (json['findings'] ?? '-').toString(),
      workDone: (json['work_done'] ?? '-').toString(),
      recommendations: json['recommendations']?.toString(),
      materialsUsed: json['materials_used']?.toString(),
      photos: photosList,
      submittedAt: (json['submitted_at'] ?? json['created_at'] ?? '')
          .toString(),
      isDraft: json['is_draft'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'technician_id': technicianId,
    'technician': technician?.toJson(),
    'findings': findings,
    'work_done': workDone,
    'recommendations': recommendations,
    'materials_used': materialsUsed,
    'photos': photos.map((e) => e.toJson()).toList(),
    'submitted_at': submittedAt,
    'is_draft': isDraft,
  };
}
