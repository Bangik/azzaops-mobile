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
      id: json['id'] as int,
      // Handle if key is photo_path instead of photo_url from backend
      photoUrl: (json['photo_url'] ?? json['photo_path'] ?? '') as String,
      photoType: (json['photo_type'] ?? 'after') as String,
      caption: json['caption'] as String?,
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
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    var photosList = <ReportPhotoModel>[];
    if (json['photos'] != null) {
      photosList = (json['photos'] as List)
          .map((i) => ReportPhotoModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    return ReportModel(
      id: json['id'] as int,
      workOrderId: json['work_order_id'] as int,
      technicianId: json['technician_id'] as int,
      technician: json['technician'] != null && json['technician'] is Map
          ? UserModel.fromJson(json['technician'] as Map<String, dynamic>)
          : null,
      findings: json['findings'] as String,
      workDone: json['work_done'] as String,
      recommendations: json['recommendations'] as String?,
      materialsUsed: json['materials_used'] as String?,
      photos: photosList,
      submittedAt: (json['submitted_at'] ?? json['created_at'] ?? '') as String,
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
      };
}
