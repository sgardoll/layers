import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// In CI / unit tests we don't want missing .env to crash analysis/tests.
// The app still requires real keys at runtime.
const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

Future<void> initSupabase() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    if (_isFlutterTest) return;
    rethrow;
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    if (_isFlutterTest) return;
    throw Exception('SUPABASE_URL not found in .env file');
  }
  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    if (_isFlutterTest) return;
    throw Exception('SUPABASE_ANON_KEY not found in .env file');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseStorageProvider = Provider<SupabaseStorageClient>((ref) {
  return ref.watch(supabaseClientProvider).storage;
});
