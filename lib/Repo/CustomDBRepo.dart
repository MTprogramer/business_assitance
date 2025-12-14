import 'package:supabase_flutter/supabase_flutter.dart';

class CustomDBRepo {

  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> runCustomQuery(String query) async {
    final rawData = await _supabase
        .rpc('run_custom_query', params: {'query': query});

    if (rawData == null) {
      return [];
    }

    // 🔴 THIS LINE IS THE FIX
    return List<Map<String, dynamic>>.from(rawData as List);
  }
}
