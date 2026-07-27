class CustomerModel {
  final int id;
  final String type;
  final String name;
  final String? companyName;
  final String? picName;
  final String phone;
  final String? address;
  final String? city;
  final String? market;

  CustomerModel({
    required this.id,
    required this.type,
    required this.name,
    this.companyName,
    this.picName,
    required this.phone,
    this.address,
    this.city,
    this.market,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      companyName: json['company_name'] as String?,
      picName: json['pic_name'] as String?,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      market: json['market'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'company_name': companyName,
        'pic_name': picName,
        'phone': phone,
        'address': address,
        'city': city,
        'market': market,
      };

  String get displayName => type == 'business' && companyName != null
      ? '$companyName (PIC: $name)'
      : name;
}
