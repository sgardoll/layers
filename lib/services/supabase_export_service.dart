import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../core/result.dart';

enum ExportType { pngs, zip, layersPack }

class ExportJob {
  final String id;
  final String projectId;
  final ExportType type;
  final String status;
  final String? assetUrl;
  final String? errorMessage;
  final DateTime createdAt;

  ExportJob({
    required this.id,
    required this.projectId,
    required this.type,
    required this.status,
    this.assetUrl,
    this.errorMessage,
    required this.createdAt,
  });

  bool get isComplete => status == 'ready';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'queued';
}

class SupabaseExportService {
  final SupabaseClient _client;

  SupabaseExportService(this._client);

  Future<Result<ExportJob>> createExport({
    required String projectId,
    required ExportType type,
    List<String>? layerIds,
  }) async {
    try {
      final response = await _client
          .from('exports')
          .insert({
            'project_id': projectId,
            'type': type.name,
            'status': 'queued',
            'options': layerIds != null ? {'layerIds': layerIds} : {},
          })
          .select()
          .single();

      return Success(_exportFromRow(response));
    } catch (e) {
      return Failure('Failed to create export: $e');
    }
  }

  Future<Result<ExportJob>> getExport(String exportId) async {
    try {
      final response = await _client
          .from('exports')
          .select()
          .eq('id', exportId)
          .single();

      return Success(_exportFromRow(response));
    } catch (e) {
      return Failure('Failed to get export: $e');
    }
  }

  Future<Result<List<ExportJob>>> listExports(String projectId) async {
    try {
      final response = await _client
          .from('exports')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      final exports = (response as List)
          .map((row) => _exportFromRow(row))
          .toList();

      return Success(exports);
    } catch (e) {
      return Failure('Failed to list exports: $e');
    }
  }

  /// List all exports across all projects (for Export tab)
  Future<Result<List<ExportJob>>> listAllExports() async {
    try {
      final response = await _client
          .from('exports')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      final exports = (response as List)
          .map((row) => _exportFromRow(row))
          .toList();

      return Success(exports);
    } catch (e) {
      return Failure('Failed to list exports: $e');
    }
  }

  Future<Result<void>> deleteExport(String exportId) async {
    try {
      await _client.from('exports').delete().eq('id', exportId);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete export: $e');
    }
  }

  Stream<ExportJob> subscribeToExport(String exportId) {
    return _client
        .from('exports')
        .stream(primaryKey: ['id'])
        .eq('id', exportId)
        .map(
          (rows) => rows.isNotEmpty
              ? _exportFromRow(rows.first)
              : throw Exception('Export not found'),
        );
  }

  ExportJob _exportFromRow(Map<String, dynamic> row) {
    return ExportJob(
      id: row['id'],
      projectId: row['project_id'],
      type: ExportType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => ExportType.zip,
      ),
      status: row['status'],
      assetUrl: row['asset_url'],
      errorMessage: row['error_message'],
      createdAt: DateTime.parse(row['created_at']),
    );
  }
}

final supabaseExportServiceProvider = Provider<SupabaseExportService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExportService(client);
});
