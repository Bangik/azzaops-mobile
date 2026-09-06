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
  final String? gmapsLink;
 
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
    this.gmapsLink,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      type: (json['type'] ?? 'individual').toString(),
      name: (json['name'] ?? '-').toString(),
      companyName: json['company_name']?.toString(),
      picName: json['pic_name']?.toString(),
      phone: (json['phone'] ?? '').toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      market: json['market']?.toString(),
      gmapsLink: json['gmaps_link']?.toString(),
    );
  }

  factory CustomerModel.empty() {
    return CustomerModel(
      id: 0,
      type: 'individual',
      name: '-',
      phone: '',
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
        'gmaps_link': gmapsLink,
      };

  String get displayName => type == 'business' && companyName != null
      ? '$companyName (PIC: $name)'
      : name;
}
