
// Reusable Product Item Widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Models/Product.dart';
import '../Screens/Bussiness/SellScreen.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onSell;

  const ProductItem({
    super.key,
    required this.product,
    required this.onQuantityChanged,
    required this.onSell,
  });

  Color getStockColor() {
    double percentage = (product.stock - product.quantity) / product.stock;
    if (percentage > 0.5) return Colors.green;
    if (percentage > 0.2) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(product.businessName,
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: getStockColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Remaining: ${product.stock - product.quantity}",
                      style: TextStyle(
                          color: getStockColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Quantity, Total & Sell button
            Row(
              children: [
                // Minus button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: () {
                      if (product.quantity > 0) {
                        onQuantityChanged(product.quantity - 1);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                // Quantity text field
                SizedBox(
                  width: 40,
                  height: 36,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: TextEditingController(
                        text: product.quantity.toString())
                      ..selection = TextSelection.fromPosition(TextPosition(
                          offset: product.quantity.toString().length)),
                    onChanged: (value) {
                      int entered = int.tryParse(value) ?? 0;
                      if (entered > product.stock) entered = product.stock;
                      onQuantityChanged(entered);
                    },
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Plus button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      if (product.quantity < product.stock) {
                        onQuantityChanged(product.quantity + 1);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Total price
                Text(
                  "\$${(product.price * product.quantity).toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 8),
                // Sell button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: product.quantity > 0 ? onSell : null,
                  child: const Text(
                    "Sell",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}