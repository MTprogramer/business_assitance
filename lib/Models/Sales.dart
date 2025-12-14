class Sale {
  final int? id;
  final int productId;
  final int businessId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime soldAt;

  Sale({
    this.id,
    required this.productId,
    required this.businessId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.soldAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'businessId': businessId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'soldAt': soldAt.toIso8601String(),
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      productId: json['productId'],
      businessId: json['businessId'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      soldAt: DateTime.parse(json['soldAt']),
    );
  }
}
