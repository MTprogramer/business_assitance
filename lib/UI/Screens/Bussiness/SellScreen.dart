// ... existing imports ...
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../Controller/Product_Controller.dart';
import '../../../Controller/Sales_Controller.dart';
import '../../../Models/BusinessModel.dart';
import '../../../Models/Product.dart';
import '../../Dialogues/SellDialogue.dart';
import '../../Widgets/ProductItem.dart';

class SellScreen extends StatefulWidget {
  final Business? business;

  const SellScreen({super.key , this.business}) ;

  @override
  _SellScreenState createState() {
    return _SellScreenState();
  }
}

class _SellScreenState extends State<SellScreen> {

  // Find or put the controller instance
  late final ProductController productController;
  late final SalesController salesController; // New SalesController

  var searchQuery = "".obs;

  @override
  void initState() {
    super.initState();

    // Initialize/Find controllers
    productController = Get.find<ProductController>();
    salesController = Get.put(SalesController()); // Initialize SalesController

    // 2. Load products immediately if a business is provided
    if (widget.business != null) {
      // Assuming BusinessModel has an integer ID
      productController.loadProducts(widget.business!);
    }
    // Removed productController.loadAllProducts() as context is usually per-business
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = productController.isLoading.value;
      final isSelling = salesController.isSelling.value; // Track selling state
      final products = productController.productsList;

      // Apply filtering to the reactive list based on reactive search query
      List<Product> filteredProducts = products
          .where(
            (p) =>
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            p.businessName.toLowerCase().contains(searchQuery.value.toLowerCase()),
      )
          .toList();

      if (isLoading || isSelling) {
        // Show loading state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(isLoading ? "Fetching products..." : "Processing sale..."),
            ],
          ),
        );
      } else {
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
                    searchQuery.value = value;
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
                          // Update local selected quantity
                          product.selectedQuantity = newQty;
                          print("Selected Quantity: ${product.selectedQuantity}");
                          productController.productsList.refresh(); // Force list refresh
                        },
                        onSell: () {
                          // Check if a quantity is selected
                          if (product.selectedQuantity > 0) {
                            ShowConfirmSaleDialog(context, product, () {

                              // 2. Call the simplified sales controller to record the transaction
                              salesController.recordSale(
                                product: product,
                                quantitySold: product.selectedQuantity,
                              );
                            });
                          } else {
                            Get.snackbar(
                              "Warning",
                              "Please select a quantity greater than zero.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                            );
                          }
                        }
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}