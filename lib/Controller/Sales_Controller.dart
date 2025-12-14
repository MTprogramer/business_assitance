import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../Models/Product.dart';
import '../../../Controller/Product_Controller.dart';
import '../Models/Sales.dart';
import '../Repo/SalesRepo.dart';

class SalesController extends GetxController {
  final SalesRepo _repo = SalesRepo();
  final ProductController productController = Get.find<ProductController>();

  RxBool isSelling = false.obs;
  // RxList<Sale> salesHistory = <Sale>[].obs; // Optional: for history tracking

  /// Records a new sale and attempts to update inventory sequentially.
  Future<void> recordSale({
    required Product product,
    required int quantitySold,
  }) async {
    isSelling.value = true;

    // Safety check for ID
    if (product.id == null || product.id == 0) {
      Get.snackbar("Error", "Product ID is missing.", backgroundColor: Colors.red);
      isSelling.value = false;
      return;
    }

    // Safety check for inventory
    if (quantitySold <= 0 || product.quantity < quantitySold) {
      Get.snackbar(
        "Warning",
        "Insufficient stock or invalid quantity.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      isSelling.value = false;
      return;
    }

    final newQuantity = product.quantity - quantitySold;

    try {
      // 1. **Record the Sale** (FIRST DB CALL)
      final saleToRecord = Sale(
        productId: product.id!,
        businessId: product.businessId,
        quantity: quantitySold,
        unitPrice: product.price,
        totalPrice: quantitySold * product.price, // Calculate total price
        soldAt: DateTime.now(),
      );

      final newSale = await _repo.addSale(saleToRecord);

      // 2. **Update the Inventory** (SECOND DB CALL - RISKY POINT)
      await _repo.updateProductQuantity(product.id!, newQuantity);

      // 3. Update the local product list immediately after successful DB update
      final productIndex = productController.productsList.indexWhere((p) => p.id == product.id);

      if (productIndex != -1) {
        // Update the quantity property of the Product object in the list
        productController.productsList[productIndex].quantity = newQuantity;

        // Reset selected quantity
        productController.productsList[productIndex].selectedQuantity = 0;

        // Force GetX to update the list to trigger UI refresh
        productController.productsList.refresh();
      }

      Get.snackbar(
        "Sale Recorded!",
        "Sold $quantitySold units of ${product.name} for \$${newSale.totalPrice.toStringAsFixed(2)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      print("Sale failed: $e");

      // IMPORTANT: In a simple sequential model, if the updateProductQuantity fails,
      // the sale is already recorded. We should log this error aggressively.
      String message = "Transaction failed. Inventory might be inconsistent! Error: ${e.toString()}";

      Get.snackbar(
        "CRITICAL ERROR",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 8),
      );
    } finally {
      isSelling.value = false;
    }
  }
}