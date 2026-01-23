import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');

const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

Future<void> initSupabase() async {
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseStorageProvider = Provider<SupabaseStorageClient>((ref) {
  return ref.watch(supabaseClientProvider).storage;
});
