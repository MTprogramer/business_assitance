import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationRepo {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(
      String email,
      String password,
      String name,
      ) async {
    try {
      print('AUTH_REPO: Attempting Sign Up for $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      return response;
    } on AuthApiException catch (e) {
      print('AUTH_REPO_ERROR: Sign Up Failed -> ${e.message}');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(
      String email,
      String password,
      ) async {
    try {
      print('AUTH_REPO: Attempting Sign In for $email');

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } on AuthApiException catch (e) {
      print('AUTH_REPO_ERROR: Sign In Failed -> ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Session? get currentSession => _supabase.auth.currentSession;
}
