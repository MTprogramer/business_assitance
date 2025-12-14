import 'package:supabase_flutter/supabase_flutter.dart';

import '../Models/Product.dart';

class ProductRepo {
  final _supabase = Supabase.instance.client;
  final String _tableName = 'product_table';

  // --- CREATE Operation ---

  /// 1. Add a New Product
  Future<Product> addProduct(Product newProduct) async {
    try {
      final productMap = newProduct.toJson();

      // Insert data and retrieve the created row
      final data = await _supabase
          .from(_tableName)
          .insert(productMap)
          .select()
          .single();

      return Product.fromJson(data);

    } on PostgrestException catch (e) {
      print('Error adding new product: ${e.message}');
      rethrow;
    }
  }

  // --- READ Operations ---

  /// 2. Get All Products for a Specific Business
  Future<List<Product>> getProductsByBusinessId(int businessId) async {
    try {
      // Filter products by the business_id column
      final data = await _supabase
          .from(_tableName)
          .select('*')
          .eq('businessId', businessId);

      print("Data: $data");
      return data.map((e) => Product.fromJson(e)).toList();
          return [];

    } on PostgrestException catch (e) {
      print('Error getting products for business $businessId: ${e.message}');
      rethrow;
    }
  }

  // --- READ Operations ---

  /// 2. Get All Products for a Specific Business
  Future<List<Product>> getAllProducts() async {
    try {
      // Filter products by the business_id column
      final data = await _supabase
          .from(_tableName)
          .select('*');

      print("Data: $data");
      return data.map((e) => Product.fromJson(e)).toList();
          return [];

    } on PostgrestException catch (e) {
      print('Error getting products');
      rethrow;
    }
  }

  /// 3. Get Single Product by ID
  Future<Product?> getProductById(int productId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('*')
          .eq('id', productId)
          .single();

      if (data != null) {
        return Product.fromJson(data);
      }
      return null;

    } on PostgrestException catch (e) {
      // Handle "no rows found" specifically
      if (e.code == 'PGRST116') return null;
      print('Error getting product by ID: ${e.message}');
      rethrow;
    }
  }

  // --- UPDATE Operation ---

  /// 4. Update an Existing Product
  Future<Product> updateProduct(Product updatedProduct) async {
    if (updatedProduct.id == null) {
      throw Exception("Cannot update product without a valid ID.");
    }

    try {
      final productMap = updatedProduct.toJson();

      // Update the row matching the ID and return the updated row
      final data = await _supabase
          .from(_tableName)
          .update(productMap)
          .eq('id', updatedProduct.id??0)
          .select()
          .single();

      return Product.fromJson(data);

    } on PostgrestException catch (e) {
      print('Error updating product: ${e.message}');
      rethrow;
    }
  }

  /// 5. Update Product Quantity Only (Optimized Update)
  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'quantity': newQuantity})
          .eq('id', productId);

      // Note: We don't use .select() here as we don't need the returned data, saving bandwidth.

    } on PostgrestException catch (e) {
      print('Error updating product quantity: ${e.message}');
      rethrow;
    }
  }


  // --- DELETE Operation ---

  /// 6. Delete Product by ID
  Future<void> deleteProductById(int productId) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', productId);

    } on PostgrestException catch (e) {
      print('Error deleting product: ${e.message}');
      rethrow;
    }
  }

  // --- Other Useful Functions ---

  /// 7. Search Products within a Business
  Future<List<Product>> searchProducts(int businessId, String query) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('*')
          .eq('businessId', businessId) // First, filter by business
          .ilike('name', '%$query%');   // Then, search by name (case-insensitive partial match)

      if (data is List) {
        return data.map((e) => Product.fromJson(e)).toList();
      }
      return [];

    } on PostgrestException catch (e) {
      print('Error searching products: ${e.message}');
      rethrow;
    }
  }
}