import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_project_service.dart';
import '../services/supabase_export_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseProjectServiceProvider = Provider<SupabaseProjectService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProjectService(client);
});

final supabaseExportServiceProvider = Provider<SupabaseExportService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExportService(client);
});
