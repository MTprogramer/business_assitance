import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Models/Product.dart';
import '../../Widgets/ProductItem.dart';


class SellScreen extends StatefulWidget {
  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  List<Product> products = [
    Product(
      name: "Apple",
      businessName: "Fruit Mart",
      price: 2.0,
      imageUrl:
      "data:image/jpeg;base64,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",
      stock: 10,
    ),
    Product(
      name: "Banana",
      businessName: "Fruit Mart",
      price: 1.5,
      imageUrl: "data:image/jpeg;base64,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",
      stock: 5,
    ),
    Product(
      name: "Milk",
      businessName: "Dairy Shop",
      price: 3.0,
      imageUrl:
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwCz1slKYZnzFOt2vvX8U7d5on-x_-u4i8zg&s",
      stock: 8,
    ),
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products
        .where((p) =>
    p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.businessName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      // appBar: AppBar(title: const Text("Sell Products"), backgroundColor: Colors.blue),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Products list
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductItem(
                  product: product,
                  onQuantityChanged: (newQty) {
                    setState(() {
                      product.quantity = newQty;
                    });
                  },
                  onSell: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Sale"),
                          content: Text(
                              "Product: ${product.name}\nQuantity: ${product.quantity}\nTotal Price: \$${(product.price * product.quantity).toStringAsFixed(2)}"),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  product.quantity = 0;
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
