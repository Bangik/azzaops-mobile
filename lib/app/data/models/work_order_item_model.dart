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
      id: json['id'] as int,
      workOrderId: json['work_order_id'] as int,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String?,
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      notes: json['notes'] as String?,
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
