import 'dart:math';

// Import the Controller
import 'package:business_assistance/UI/Dialogues/ShowDeleteDialogue.dart';
import 'package:business_assistance/Models/Product.dart';
import 'package:business_assistance/UI/Widgets/CustomButton.dart';
import 'package:business_assistance/UI/Widgets/ProductsList.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import '../../../Controller/Product_Controller.dart';
import '../../../Models/BusinessModel.dart';
import '../../Dialogues/ProductAddDialogue.dart';

class ProductsScreen extends StatefulWidget {
  final Business? business;

  const ProductsScreen({super.key, this.business});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Find or put the controller instance
  late final ProductController productController;

  var searchQuery = "".obs; // Make searchQuery reactive to enable filtering within Obx

  @override
  void initState() {
    super.initState();
    // 1. Initialize Controller
    productController = Get.put(ProductController());

    // 2. Load products immediately if a business is provided
    if (widget.business != null) {
      // Assuming BusinessModel has an integer ID for businessId in Product
      productController.loadProducts(widget.business!);
    }else{
      productController.loadAllProducts();
    }
  }

  // NOTE: The hardcoded `products` list is now removed.

  @override
  Widget build(BuildContext context) {
    // Use Obx to wrap the entire body to react to changes in the controller state
    return Obx(() {
      final isLoading = productController.isLoading.value;
      final products = productController.productsList;

      // Apply filtering to the reactive list based on reactive search query
      List<Product> filteredProducts = products
          .where(
            (p) =>
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            p.businessName.toLowerCase().contains(searchQuery.value.toLowerCase()),
      )
          .toList();

      final isNotEmpty = filteredProducts.isNotEmpty;


      return Scaffold(
        appBar: widget.business != null && isNotEmpty
            ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 70,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  searchQuery.value = value; // Update reactive search query
                },
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CustomButton(
                text: "Add Product",
                startIcon: Icons.add,
                onPressed: () => _addNewProduct(context),
                height: 42,
                cornerRadius: 12,
              ),
            ),
          ],
        )
            : null,
        body: isLoading
            ? _buildLoadingState() // Show loading while fetching
            : filteredProducts.isEmpty && products.isEmpty // No products fetched yet (initial empty state)
            ? _buildEmptyState(context)
            : filteredProducts.isEmpty && products.isNotEmpty // No products match search query
            ? _buildNoResultsState(context)
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                BuildProductDataTable(
                  filteredProducts, // Use the filtered list
                  context,
                      (product) => _showDeleteDialog(context, product),
                      (product) => _editProduct(context, product),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      );
    }); // End of Obx
  }

  // New Widget to show the loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text("Fetching products...", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // New Widget for when search returns no results
  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "No products match your search query.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Try adjusting your search term: \"${searchQuery.value}\"",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }


  // Helper function to call the Add Product dialog and controller
  void _addNewProduct(BuildContext context) {
    ShowProductFormDialog(
      context,
      onSave: (productData) {
        // Pass data directly to the controller
        productController.addProduct(productData);
      },
    );
  }

  // Helper function to call the Edit Product dialog and controller
  void _editProduct(BuildContext context, Product productToEdit) {
    ShowProductFormDialog(
      context,
      existingProduct: productToEdit,
      onSave: (updatedData) {
        // Pass updated data and the original product to the controller
        productController.updateProduct(updatedData, productToEdit);
      },
    );
  }

  // Helper function to show the Delete dialog and call the controller
  void _showDeleteDialog(BuildContext context, Product product) {
    ShowDeleteDialog(
      context,
      product: product,
      isFromProduct: true,
      onDelete: () {
        if (product.id != null) {
          productController.deleteProduct(product.id as int);
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Keep the existing image in case of initial no-data state
          Image.asset("assets/images/no_bussines_image.jpeg", height: 180),
          const SizedBox(height: 20),
          const Text(
            "You have no product yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Add your first product to get started",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 25),

          widget.business != null
              ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _addNewProduct(context),
            icon: const Icon(Icons.add),
            label: const Text("Add Product"), // Corrected text here
          )
              : Container(),
        ],
      ),
    );
  }
}