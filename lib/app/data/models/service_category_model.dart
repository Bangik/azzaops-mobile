class ServiceCategoryModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'is_active': isActive,
      };
}
