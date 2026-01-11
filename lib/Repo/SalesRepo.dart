import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../Models/Product.dart';
import '../Models/Sales.dart'; // Import Product model
// import ProductRepo if needed, but we'll include the update logic here for simplicity

class SalesRepo {
  final _supabase = Supabase.instance.client;
  final String _salesTableName = 'sales_table';
  final String _productsTableName = 'product_table'; // Use the product table name

  // --- Sale Recording Operation ---

  /// Records a new sale in the sales table.
  Future<Sale> addSale(Sale newSale) async {
    try {
      final saleMap = newSale.toJson();

      // Insert data and retrieve the created row
      final data = await _supabase
          .from(_salesTableName)
          .insert(saleMap)
          .select()
          .single();

      return Sale.fromJson(data);

    } on PostgrestException catch (e) {
      print('Error recording sale: ${e.message}');
      rethrow;
    }
  }

  // --- Inventory Update Operation ---

  /// Updates the quantity of a product in the product table.
  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    try {
      await _supabase
          .from(_productsTableName)
          .update({'quantity': newQuantity})
          .eq('id', productId);

      // No data is returned on success

    } on PostgrestException catch (e) {
      print('Error updating product quantity: ${e.message}');
      rethrow;
    }
  }

  // --- Read Operations ---

  Future<List<Sale>> getSalesByBusinessId(int businessId) async {
    // ... (This function remains the same as before)
    try {
      final data = await _supabase
          .from(_salesTableName)
          .select('*')
          .eq('businessId', businessId)
          .order('soldAt', ascending: false);

      if (data is List) {
        return data.map((e) => Sale.fromJson(e)).toList();
      }
      return [];

    } on PostgrestException catch (e) {
      print('Error fetching sales history: ${e.message}');
      rethrow;
    }
  }
  // --- Read Operations ---

  Future<List<Sale>> getAllSales(String userId) async {
    // ... (This function remains the same as before)
    try {
      final data = await _supabase
          .from(_salesTableName)
          .select('*')
          .eq('user_id', userId)
          .order('soldAt', ascending: false);

      if (data is List) {
        return data.map((e) => Sale.fromJson(e)).toList();
      }
      return [];

    } on PostgrestException catch (e) {
      print('Error fetching sales history: ${e.message}');
      rethrow;
    }
  }
}