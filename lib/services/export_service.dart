import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/result.dart';
import '../models/layer.dart';

enum ExportFormat { png, zip, layers }

class ExportService {
  final Dio _dio;

  ExportService(this._dio);

  Future<Result<File>> exportLayerAsPng(
    Layer layer, {
    required String projectName,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        layer.pngUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        return const Failure('Failed to download layer');
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = '${projectName}_layer_${layer.zIndex}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.data!);

      return Success(file);
    } catch (e) {
      return Failure('Export failed: $e');
    }
  }

  Future<Result<File>> exportAllLayersAsZip(
    List<Layer> layers, {
    required String projectName,
  }) async {
    try {
      final archive = Archive();

      for (final layer in layers) {
        final response = await _dio.get<List<int>>(
          layer.pngUrl,
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.data == null) continue;

        final fileName = 'layer_${layer.zIndex.toString().padLeft(2, '0')}.png';
        archive.addFile(
          ArchiveFile(fileName, response.data!.length, response.data!),
        );
      }

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        return const Failure('Failed to create ZIP');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$projectName.zip');
      await file.writeAsBytes(zipData);

      return Success(file);
    } catch (e) {
      return Failure('ZIP export failed: $e');
    }
  }

  Future<Result<File>> exportAsLayersPack(
    List<Layer> layers, {
    required String projectName,
    required String projectId,
    Uint8List? thumbnail,
  }) async {
    try {
      final archive = Archive();

      final manifest = StringBuffer();
      manifest.writeln('{');
      manifest.writeln('  "version": 1,');
      manifest.writeln('  "projectId": "$projectId",');
      manifest.writeln('  "projectName": "$projectName",');
      manifest.writeln('  "layerCount": ${layers.length},');
      manifest.writeln('  "layers": [');

      for (var i = 0; i < layers.length; i++) {
        final layer = layers[i];
        final response = await _dio.get<List<int>>(
          layer.pngUrl,
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.data == null) continue;

        final fileName =
            'layers/layer_${layer.zIndex.toString().padLeft(2, '0')}.png';
        archive.addFile(
          ArchiveFile(fileName, response.data!.length, response.data!),
        );

        manifest.writeln('    {');
        manifest.writeln('      "id": "${layer.id}",');
        manifest.writeln('      "zIndex": ${layer.zIndex},');
        manifest.writeln('      "visible": ${layer.visible},');
        manifest.writeln('      "opacity": ${layer.transform.opacity},');
        manifest.writeln('      "file": "$fileName"');
        manifest.write('    }');
        if (i < layers.length - 1)
          manifest.writeln(',');
        else
          manifest.writeln();
      }

      manifest.writeln('  ]');
      manifest.writeln('}');

      archive.addFile(
        ArchiveFile(
          'manifest.json',
          manifest.length,
          manifest.toString().codeUnits,
        ),
      );

      if (thumbnail != null) {
        archive.addFile(
          ArchiveFile('thumbnail.png', thumbnail.length, thumbnail),
        );
      }

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) {
        return const Failure('Failed to create .layers pack');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$projectName.layers');
      await file.writeAsBytes(zipData);

      return Success(file);
    } catch (e) {
      return Failure('.layers export failed: $e');
    }
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: file.uri.pathSegments.last);
  }

  Future<void> shareFiles(List<File> files) async {
    await Share.shareXFiles(files.map((f) => XFile(f.path)).toList());
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(Dio());
});
