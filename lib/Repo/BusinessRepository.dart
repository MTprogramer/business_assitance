import 'package:supabase_flutter/supabase_flutter.dart';

import '../Models/BusinessModel.dart';
// Assuming you have defined your Business model class

class BusinessRepository {
  // Get the Supabase client instance
  final _supabase = Supabase.instance.client;
  final String _tableName = 'business';

  // --- READ Operations ---

  /// 1. Get All Business (Current function, slightly modified for clarity)
  Future<List<Business>> getAllBusiness() async {
    try {
      final data = await _supabase.from(_tableName).select('*');

      // Use Dart's type system for safety
      if (data is List) {
        return data.map((e) => Business.fromJson(e)).toList();
      }
      return [];

    } on PostgrestException catch (e) {
      // Handle Supabase-specific errors
      print('Error getting all business: ${e.message}');
      rethrow;
    } catch (e) {
      // Handle general errors
      print('An unexpected error occurred: $e');
      rethrow;
    }
  }

  /// 2. Get Business by ID
  Future<Business?> getBusinessById(String businessId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('*')
          .eq('id', businessId) // Assuming 'id' is the primary key column
          .single(); // Use .single() to expect exactly one row

      if (data != null) {
        return Business.fromJson(data);
      }
      return null;

    } on PostgrestException catch (e) {
      // If no row is found, .single() throws a PostgrestException.
      // We often check for the specific status code (e.g., 406 for no row).
      if (e.code == 'PGRST116') { // Specific code for PostgREST "no rows found"
        return null;
      }
      print('Error getting business by ID: ${e.message}');
      rethrow;
    }
  }

  // --- CREATE Operation ---

  /// 3. Add a New Business
  Future<Business> addBusiness(Business newBusiness) async {
    try {
      // Convert the Business model back to a JSON map
      final businessMap = newBusiness.toJson();

      // Insert the data. The '.select()' at the end ensures the inserted row
      // (including generated values like 'id', 'created_at') is returned.
      final data = await _supabase
          .from(_tableName)
          .insert(businessMap)
          .select() // Return the created row
          .single(); // Expect one created row

      return Business.fromJson(data);

    } on PostgrestException catch (e) {
      print('Error adding new business: ${e.message}');
      rethrow;
    }
  }

  // --- UPDATE Operation ---

  /// 4. Update an Existing Business
  Future<Business> updateBusiness(Business updatedBusiness) async {
    try {
      // Ensure the Business model has its ID for the .eq() clause
      final businessMap = updatedBusiness.toJson();

      // Update the row matching the ID and return the updated row
      final data = await _supabase
          .from(_tableName)
          .update(businessMap)
          .eq('id', updatedBusiness.id) // Assuming 'id' is a required field
          .select()
          .single();

      return Business.fromJson(data);

    } on PostgrestException catch (e) {
      print('Error updating business: ${e.message}');
      rethrow;
    }
  }

  // --- DELETE Operation ---

  /// 5. Delete Business by ID
  Future<void> deleteBusinessById(String businessId) async {
    try {
      // Delete the row matching the ID
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', businessId);

      // No data is returned on success

    } on PostgrestException catch (e) {
      print('Error deleting business: ${e.message}');
      rethrow;
    }
  }

  // --- Other Useful Functions ---

  /// 6. Filter Business by a specific field (e.g., category)
  Future<List<Business>> getBusinessByCategory(String category) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('*')
          .eq('category', category); // Assuming you have a 'category' column

      if (data is List) {
        return data.map((e) => Business.fromJson(e)).toList();
      }
      return [];

    } on PostgrestException catch (e) {
      print('Error filtering business: ${e.message}');
      rethrow;
    }
  }

  Future<void> incrementTotalProducts(int businessId, {int count = 1}) async {
    try {
      // Get current totalProducts
      final data = await _supabase
          .from('business')
          .select('totalProducts')
          .eq('id', businessId)
          .single();

      if (data == null) return;

      final currentCount = data['totalProducts'] as int? ?? 0;

      // Update totalProducts
      await _supabase
          .from('business')
          .update({'totalProducts': currentCount + count})
          .eq('id', businessId);

    } on PostgrestException catch (e) {
      print('Error incrementing totalProducts: ${e.message}');
      rethrow;
    }
  }


  /// 7. Search Business by text in a column (e.g., business name)
  Future<List<Business>> searchBusinessByName(String query) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('*')
          .ilike('name', '%$query%'); // Case-insensitive partial match

      if (data is List) {
        return data.map((e) => Business.fromJson(e)).toList();
      }
      return [];

    } on PostgrestException catch (e) {
      print('Error searching business: ${e.message}');
      rethrow;
    }
  }
}