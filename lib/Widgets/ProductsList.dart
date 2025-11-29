
// --- DataTable Widget Implementation (Updated) ---
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/Product.dart';

Widget BuildProductDataTable(List<Product> products , BuildContext context , Function onRemove , Function onEdit) {
  return Container(
    width: double.infinity,
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.blue.shade50),
        dataRowMinHeight: 70,
        dataRowMaxHeight: 80,
        columnSpacing: 12,
        horizontalMargin: 12,
        columns: const [
          DataColumn(label: Text('🖼️ Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          DataColumn(label: Text('📝 Product Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          DataColumn(label: Text('🏢 Business Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          DataColumn(label: Text('🔢 Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          DataColumn(label: Text('💲 Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          DataColumn(label: Text('⚙️ Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ],
        rows: products.map((product) => _buildDataRow(product , context , onRemove , onEdit)).toList(),
      ),
    ),
  );
}

// --- DataRow Builder for each product (Updated) ---
DataRow _buildDataRow(Product product , BuildContext context , Function onRemove , Function onEdit) {
  return DataRow(
    cells: [
      // 1. Image
      DataCell(
        SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
        ),
      ),

      // 2. Product Name
      DataCell(
        Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // 3. Business Name (NEW CELL ADDED HERE)
      DataCell(
        Text(
          product.businessName,
          style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade700),
        ),
      ),
      // ---------------------------------------------

      // 4. Product Quantity
      DataCell(
        Text(
          product.quantity.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.deepPurple),
        ),
      ),

      // 5. Product Price
      DataCell(
        Text(
          '₹ ${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
        ),
      ),

      // 6. Action UI
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit Button
            ElevatedButton.icon(
              onPressed: () {
                onEdit(product);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade400,
                foregroundColor: Colors.black87,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
            // Remove Button
            OutlinedButton.icon(
              onPressed: () {
               onRemove(product);
              },
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}