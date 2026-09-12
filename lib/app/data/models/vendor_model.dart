class VendorModel {
  final int id;
  final String name;

  VendorModel({required this.id, required this.name});

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] is int
          ? json['id'] as int
          : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? '-').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
