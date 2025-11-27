
class Product {
  final String name;
  final String businessName;
  final double price;
  final String imageUrl;
  final int stock;
  int quantity;

  Product({
    required this.name,
    this.businessName = "",
    required this.price,
    required this.imageUrl,
    this.stock = 0,
    this.quantity = 0,
  });
}