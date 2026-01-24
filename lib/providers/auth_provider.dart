import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../services/auth_service.dart';

/// Provides the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

/// Stream of auth state changes (for listening)
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current authenticated user, or null
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.valueOrNull?.session?.user;
});

/// Whether user is currently authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Auth state notifier for sign-in/sign-up/sign-out actions
class AuthStateNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() {
    // Watch the stream and sync state
    final streamState = ref.watch(authStateStreamProvider);
    return streamState.whenData((authState) => authState.session?.user);
  }

  AuthService get _authService => ref.read(authServiceProvider);

  /// Sign in with email and password. Returns error message or null on success.
  Future<String?> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
      return null;
    } catch (e) {
      final message = _parseAuthError(e);
      state = AsyncValue.error(message, StackTrace.current);
      return message;
    }
  }

  /// Sign up with email and password. Returns error message or null on success.
  Future<String?> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
      return null;
    } catch (e) {
      final message = _parseAuthError(e);
      state = AsyncValue.error(message, StackTrace.current);
      return message;
    }
  }

  String _parseAuthError(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}

/// Provider for auth actions (sign in, sign up, sign out)
final authStateProvider =
    NotifierProvider<AuthStateNotifier, AsyncValue<User?>>(
      AuthStateNotifier.new,
    );
