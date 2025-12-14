import 'package:business_assistance/Controller/BusinessController.dart';
import 'package:business_assistance/Controller/BusinessController.dart';
import 'package:business_assistance/Controller/Sales_Controller.dart';
import 'package:business_assistance/Controller/Sales_Controller.dart';
import 'package:business_assistance/Models/BusinessModel.dart';
import 'package:business_assistance/Repo/BusinessRepository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../Models/Product.dart';
import '../Repo/ProductRepo.dart'; // Ensure correct path

class ProductController extends GetxController {
  final ProductRepo _repo = ProductRepo();
  final BusinessRepository _businessRepo = BusinessRepository();

  // Reactive State
  RxBool isLoading = true.obs;
  RxList<Product> productsList = <Product>[].obs;
  RxString errorMessage = ''.obs;

  // State specific to the business whose products we are viewing
  Business? currentBusinessId;

  /// Initializes the controller and fetches products for the given business ID.
  void loadProducts(Business business) async {
    // Only reload if the business ID has changed or the list is empty
    if (business.id == currentBusinessId?.id && productsList.isNotEmpty && !isLoading.value) {
      return;
    }

    currentBusinessId = business;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<Product> fetchedProducts = await _repo.getProductsByBusinessId(business.id);

      // Update the reactive list
      productsList.assignAll(fetchedProducts);

      print("Successfully loaded ${fetchedProducts.length} products for business ID ${business.id}.");

    } catch (e) {
      print("Error loading products: $e");
      errorMessage.value = 'Failed to load products: ${e.toString()}';
      Get.snackbar(
        "Error",
        "Could not load products: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Initializes the controller and fetches products for the given business ID.
  void loadAllProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<Product> fetchedProducts = await _repo.getAllProducts();

      // Update the reactive list
      productsList.assignAll(fetchedProducts);

      print("Successfully loaded ${fetchedProducts.length} products ");

    } catch (e) {
      print("Error loading products: $e");
      errorMessage.value = 'Failed to load products: ${e.toString()}';
      Get.snackbar(
        "Error",
        "Could not load products: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds a new product to the database and updates the local list.
  void addProduct(Map<String, dynamic> productData) async {
    if (currentBusinessId == null) return;

    try {
      // 1. Create Product model from dialog data
      final newProduct = Product(
        name: productData['name'],
        price: productData['price'],
        imageUrl: productData['imageUrl'],
        businessName: currentBusinessId?.name ?? '',
        businessId: currentBusinessId?.id ?? 0, // Use the ID of the current screen's business
        quantity: productData['quantity'],
      );

      // 2. Add to Supabase via repository
      final createdProduct = await _repo.addProduct(newProduct);

      // 3. Update reactive list
      productsList.add(createdProduct);
      _businessRepo.incrementTotalProducts(currentBusinessId!.id);

      Get.snackbar(
        "Success",
        "${createdProduct.name} added successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );


    } catch (e) {
      print("Error adding product: $e");
      Get.snackbar(
        "Error",
        "Could not add product: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Updates an existing product in the database and local list.
  void updateProduct(Map<String, dynamic> productData, Product oldProduct) async {
    try {
      // 1. Create the updated Product object using the old ID
      final updatedProduct = Product(
        id: oldProduct.id,
        name: productData['name'],
        price: productData['price'],
        imageUrl: productData['imageUrl'],
        businessName: oldProduct.businessName,
        businessId: oldProduct.businessId,
        quantity: productData['quantity'],
      );

      // 2. Update via repository
      final resultProduct = await _repo.updateProduct(updatedProduct);

      // 3. Update the item in the reactive list
      final index = productsList.indexWhere((p) => p.id == resultProduct.id);
      if (index != -1) {
        productsList[index] = resultProduct;

        Get.snackbar(
          "Success",
          "${resultProduct.name} updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("Error updating product: $e");
      Get.snackbar(
        "Error",
        "Could not update product: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Deletes a product from the database and local list.
  void deleteProduct(int productId) async {
    try {
      // 1. Delete from Supabase
      await _repo.deleteProductById(productId);

      // 2. Remove from reactive list
      productsList.removeWhere((p) => p.id == productId);

      Get.snackbar(
        "Deleted",
        "Product deleted successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting product: $e");
      Get.snackbar(
        "Error",
        "Could not delete product: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}