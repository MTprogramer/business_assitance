import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Models/Product.dart';

/// Shows a dynamic dialog for adding a new product or editing an existing one.
/// [existingProduct]: If provided, the dialog is in 'Edit' mode.
/// [onSave]: Callback executed on successful form submission, returns the updated/new Product map.
void ShowProductFormDialog(BuildContext context, {Product? existingProduct, required Function(Map<String, dynamic> productData) onSave,}) {
  // --- Form State Variables ---
  final _formKey = GlobalKey<FormState>();
  final isEditMode = existingProduct != null;

  final TextEditingController nameController = TextEditingController(text: existingProduct?.name ?? '');
  final TextEditingController priceController = TextEditingController(text: existingProduct?.price.toString() ?? '');
  final TextEditingController imageUrlController = TextEditingController(text: existingProduct?.imageUrl ?? '');
  final TextEditingController stockController = TextEditingController(text: existingProduct?.quantity.toString() ?? '');


  bool isButtonEnabled = isEditMode;

  // Update state for button enablement check
  void _updateButtonState(Function(VoidCallback) dialogSetState) {
    dialogSetState(() {
      isButtonEnabled = nameController.text.isNotEmpty &&
          priceController.text.isNotEmpty ;
    });
  }

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, dialogSetState) {
          // Check state initially if not in edit mode
          if (!isEditMode && !isButtonEnabled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateButtonState(dialogSetState);
            });
          }

          final String titleText = isEditMode ? "Edit Product: ${existingProduct!.name}" : "Add New Product";
          final String buttonText = isEditMode ? "Save Changes" : "Add Product";

          // --- Form Submission Logic ---
          void handleSubmit() {
            if (_formKey.currentState!.validate()) {
              final Map<String, dynamic> productData = {
                'id': existingProduct?.id ?? '', // Use existing ID or let the caller generate one
                'name': nameController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                'imageUrl': imageUrlController.text.trim(),
                'quantity': int.tryParse(stockController.text.trim()) ?? 0,
                'businessName': existingProduct?.businessName ?? "",
              };

              // Execute the callback with the new/updated data
              onSave(productData);

              // Close dialog and show confirmation message
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${productData['name']} ${isEditMode ? 'updated' : 'added'} successfully!'),
                  backgroundColor: isEditMode ? Colors.blue.shade600 : Colors.green.shade600,
                ),
              );
            }
          }

          // --- UI Structure ---
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            elevation: 15,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,  // 👉 50% of screen
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  onChanged: () => _updateButtonState(dialogSetState), // Check validation on every change
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title and Icon
                      Row(
                        children: [
                          Icon(isEditMode ? Icons.edit : Icons.add_shopping_cart,
                              color: isEditMode ? Colors.blue : Colors.green, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              titleText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1),

                      // --- Input Fields ---
                      _buildTextField(
                        controller: nameController,
                        label: "Product Name",
                        icon: Icons.label,
                        required: true,
                      ),
                      _buildTextField(
                        controller: priceController,
                        label: "Price (₹)",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      _buildTextField(
                        controller: imageUrlController,
                        label: "Image URL (Optional)",
                        icon: Icons.image,
                        required: true,
                      ),
                      _buildTextField(
                        controller: stockController,
                        label: "Stock Quantity (Optional)",
                        icon: Icons.inventory,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30),

                      // --- Action Buttons ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Cancel Button
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
                          ),
                          const SizedBox(width: 12),

                          // Add/Save Button (Dynamic)
                          ElevatedButton.icon(
                            onPressed: isButtonEnabled ? handleSubmit : null, // Disabled if not valid
                            icon: Icon(isEditMode ? Icons.save : Icons.add, size: 18),
                            label: Text(buttonText),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditMode ? Colors.blue.shade600 : Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// --- Helper Widget for styled input fields ---
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool required = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueGrey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label is required.';
        }
        if (keyboardType == TextInputType.number && value != null && value.isNotEmpty && double.tryParse(value) == null) {
          return 'Please enter a valid number.';
        }
        return null;
      },
    ),
  );
}