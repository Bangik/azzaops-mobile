class WorkOrderItemModel {
  final int id;
  final int workOrderId;
  final String description;
  final int quantity;
  final String? unit;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  WorkOrderItemModel({
    required this.id,
    required this.workOrderId,
    required this.description,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory WorkOrderItemModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderItemModel(
      id: json['id'] is int ? json['id'] as int : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      workOrderId: json['work_order_id'] is int ? json['work_order_id'] as int : (int.tryParse(json['work_order_id']?.toString() ?? '0') ?? 0),
      description: (json['description'] ?? '-').toString(),
      quantity: json['quantity'] is int ? json['quantity'] as int : (int.tryParse(json['quantity']?.toString() ?? '1') ?? 1),
      unit: json['unit']?.toString(),
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'work_order_id': workOrderId,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'notes': notes,
      };
}
