import 'package:flutter/material.dart';
void ShowConfirmSaleDialog(BuildContext context, dynamic product, VoidCallback onConfirm) {
  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isTotal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      // Modern Dialog Styling
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 10,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status/Brand Header
            const Center(
              child: Icon(
                Icons.receipt_long,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Center(
              child: Text(
                "Confirm Sale",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content (Sale Details)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                      label: "Product:",
                      value: product.name,
                      isTotal: false),
                  const Divider(height: 12, color: Colors.green),
                  _buildDetailRow(
                      label: "Quantity:",
                      value: product.selectedQuantity.toString(),
                      isTotal: false),
                  const Divider(height: 12, color: Colors.green),
                  _buildDetailRow(
                      label: "Total Price:",
                      value:
                      "\$${(product.price * product.selectedQuantity).toStringAsFixed(2)}",
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons (Enhanced)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button (Secondary)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueGrey,
                      side: BorderSide(color: Colors.blueGrey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),

                // Confirm Button (Primary/Elevated)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text("Confirm"),
                    onPressed: () {
                      // Execute the logic passed from the screen (e.g., updating state)
                      onConfirm();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Sale confirmed successfully!"))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
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
