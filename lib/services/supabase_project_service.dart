import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../core/supabase_client.dart';
import '../core/result.dart';
import '../models/layer.dart';
import '../models/project.dart';

class SupabaseProjectService {
  final SupabaseClient _client;

  SupabaseProjectService(this._client);

  String get _userId => _client.auth.currentUser?.id ?? 'anonymous';

  Future<Result<Project>> createProject({
    required File imageFile,
    Map<String, dynamic> params = const {},
  }) async {
    try {
      final projectId =
          _client.auth.currentUser?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final ext = p.extension(imageFile.path);
      final storagePath = '$_userId/$projectId/source$ext';

      final bytes = await imageFile.readAsBytes();
      await _client.storage
          .from('source-images')
          .uploadBinary(storagePath, bytes);

      final response = await _client
          .from('projects')
          .insert({
            'user_id': _client.auth.currentUser?.id,
            'source_image_path': storagePath,
            'params': params,
            'status': 'queued',
          })
          .select()
          .single();

      return Success(_projectFromRow(response));
    } catch (e) {
      return Failure('Failed to create project: $e');
    }
  }

  Future<Result<Project>> getProject(String projectId) async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .eq('id', projectId)
          .single();

      return Success(_projectFromRow(response));
    } catch (e) {
      return Failure('Failed to get project: $e');
    }
  }

  Future<Result<List<Project>>> listProjects() async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      final projects = (response as List)
          .map((row) => _projectFromRow(row))
          .toList();

      return Success(projects);
    } catch (e) {
      return Failure('Failed to list projects: $e');
    }
  }

  Future<Result<List<Layer>>> getProjectLayers(String projectId) async {
    try {
      final response = await _client
          .from('project_layers')
          .select()
          .eq('project_id', projectId)
          .order('z_index', ascending: true);

      final layers = (response as List)
          .map((row) => _layerFromRow(row))
          .toList();

      return Success(layers);
    } catch (e) {
      return Failure('Failed to get layers: $e');
    }
  }

  Future<Result<void>> updateLayerTransform(
    String layerId, {
    double? x,
    double? y,
    double? scale,
    double? rotation,
    double? opacity,
  }) async {
    try {
      final current = await _client
          .from('project_layers')
          .select('transform')
          .eq('id', layerId)
          .single();

      final transform = Map<String, dynamic>.from(current['transform'] ?? {});
      if (x != null) transform['x'] = x;
      if (y != null) transform['y'] = y;
      if (scale != null) transform['scale'] = scale;
      if (rotation != null) transform['rotation'] = rotation;
      if (opacity != null) transform['opacity'] = opacity;

      await _client
          .from('project_layers')
          .update({'transform': transform})
          .eq('id', layerId);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to update layer: $e');
    }
  }

  Future<Result<void>> updateLayerVisibility(
    String layerId,
    bool visible,
  ) async {
    try {
      await _client
          .from('project_layers')
          .update({'visible': visible})
          .eq('id', layerId);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to update visibility: $e');
    }
  }

  Future<Result<void>> updateLayerOrder(String layerId, int zIndex) async {
    try {
      await _client
          .from('project_layers')
          .update({'z_index': zIndex})
          .eq('id', layerId);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to update order: $e');
    }
  }

  Future<Result<void>> deleteProject(String projectId) async {
    try {
      await _client.from('projects').delete().eq('id', projectId);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete project: $e');
    }
  }

  Stream<Project> subscribeToProject(String projectId) {
    return _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('id', projectId)
        .map(
          (rows) => rows.isNotEmpty
              ? _projectFromRow(rows.first)
              : throw Exception('Project not found'),
        );
  }

  Future<String> getSignedUrl(String bucket, String path) async {
    final response = await _client.storage
        .from(bucket)
        .createSignedUrl(path, 3600);
    return response;
  }

  Future<Uint8List> downloadFile(String bucket, String path) async {
    return await _client.storage.from(bucket).download(path);
  }

  Project _projectFromRow(Map<String, dynamic> row) {
    return Project(
      id: row['id'],
      name: row['source_image_path'].split('/').last,
      sourceImagePath: row['source_image_path'],
      createdAt: DateTime.parse(row['created_at']),
      updatedAt: DateTime.parse(row['updated_at']),
    );
  }

  Layer _layerFromRow(Map<String, dynamic> row) {
    final transform = row['transform'] as Map<String, dynamic>? ?? {};
    final bbox = row['bbox'] as Map<String, dynamic>?;

    return Layer(
      id: row['id'],
      name: row['name'],
      pngUrl: row['png_url'] ?? '',
      width: row['width'],
      height: row['height'],
      zIndex: row['z_index'],
      visible: row['visible'] ?? true,
      bbox: bbox != null
          ? LayerBbox(
              left: (bbox['x'] as num?)?.toDouble() ?? 0,
              top: (bbox['y'] as num?)?.toDouble() ?? 0,
              width: (bbox['width'] as num).toDouble(),
              height: (bbox['height'] as num).toDouble(),
            )
          : null,
      transform: LayerTransform(
        x: (transform['x'] as num?)?.toDouble() ?? 0,
        y: (transform['y'] as num?)?.toDouble() ?? 0,
        scale: (transform['scale'] as num?)?.toDouble() ?? 1,
        rotation: (transform['rotation'] as num?)?.toDouble() ?? 0,
        opacity: (transform['opacity'] as num?)?.toDouble() ?? 1,
      ),
    );
  }
}

final supabaseProjectServiceProvider = Provider<SupabaseProjectService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProjectService(client);
});
