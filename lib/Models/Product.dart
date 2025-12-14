
import 'package:flutter/cupertino.dart';

class Product {
  final int? id ;
  final String name;
  final String businessName;
  final int businessId;
  final double price;
  final String imageUrl;
  int quantity;
  int selectedQuantity;
  Product({
    this.id,
    required this.name,
    this.businessName = "",
    this.businessId = 0,
    required this.price,
    required this.imageUrl,
    this.quantity = 0,
    this.selectedQuantity = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'businessName': businessName,
      'businessId': businessId,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }


  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      businessName: json['businessName'] ?? "",
      businessId: json['businessId'] ?? 0,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? "",
      quantity: json['quantity'] ?? 0,
    );
  }


}
