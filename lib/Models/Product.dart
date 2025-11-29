
import 'package:flutter/cupertino.dart';

class Product {
  final String id ;
  final String name;
  final String businessName;
  final double price;
  final String imageUrl;
  int quantity;
  int selectedQuantity;
  Product({
    this.id = "" ,
    required this.name,
    this.businessName = "",
    required this.price,
    required this.imageUrl,
    this.quantity = 0,
    this.selectedQuantity = 0,
  });

  // A simple method to simulate saving the product
  Map<String, dynamic> toMap() {
    return {
      'id': id.isEmpty ? UniqueKey().toString() : id,
      'name': name,
      'businessName': businessName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

}
