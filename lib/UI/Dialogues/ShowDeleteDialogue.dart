
import 'package:business_assistance/Models/Product.dart';
import 'package:business_assistance/UI/Screens/Products/ProductsScreen.dart';
import 'package:flutter/material.dart';

import '../../Models/BusinessModel.dart';

void ShowDeleteDialog(
    BuildContext context, {
      Business? business,
      Product? product,
      required bool isFromProduct,   // true → deleting a product | false → deleting a business
      required onDelete, // callback executed on confirm
    }) {

  final String title = isFromProduct
      ? "Delete Product"
      : "Delete Business";

  final String itemName = isFromProduct
      ? product?.name ?? "this product"
      : business?.name ?? "this business";

  final String message = isFromProduct
      ? "Are you sure you want to permanently delete the product **$itemName**? This action cannot be undone."
      : "Are you sure you want to permanently delete the business **$itemName**? This action cannot be undone.";

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 10,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded,
                color: Colors.redAccent, size: 50),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Message (supports markdown style **bold**)
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      side: const BorderSide(color: Colors.blueGrey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete(); // execute callback

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$itemName deleted successfully")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Delete"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
