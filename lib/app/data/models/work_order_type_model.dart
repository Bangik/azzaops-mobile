class WorkOrderTypeModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  WorkOrderTypeModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
  });

  factory WorkOrderTypeModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderTypeModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? '-').toString(),
      code: (json['code'] ?? '').toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'description': description,
        'is_active': isActive,
      };
}
