import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service wrapping Supabase Auth
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Current authenticated user, or null if not signed in
  User? get currentUser => _client.auth.currentUser;

  /// Whether a user is currently authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes (sign in, sign out, token refresh)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(email: email, password: password);
    } catch (e) {
      debugPrint('AuthService: Sign up failed: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('AuthService: Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('AuthService: Sign out failed: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('AuthService: Password reset failed: $e');
      rethrow;
    }
  }
}
