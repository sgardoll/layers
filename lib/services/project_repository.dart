import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/result.dart';
import '../models/layer.dart';
import '../models/project.dart';

class ProjectRepository {
  static const _projectsDir = 'projects';

  Future<Directory> _getProjectsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final projectsDir = Directory('${appDir.path}/$_projectsDir');
    if (!await projectsDir.exists()) {
      await projectsDir.create(recursive: true);
    }
    return projectsDir;
  }

  Future<Directory> _getProjectDirectory(String projectId) async {
    final projectsDir = await _getProjectsDirectory();
    final projectDir = Directory('${projectsDir.path}/$projectId');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }
    return projectDir;
  }

  Future<Result<Project>> saveProject(
    Project project,
    List<Layer> layers,
  ) async {
    try {
      final projectDir = await _getProjectDirectory(project.id);

      final projectFile = File('${projectDir.path}/project.json');
      await projectFile.writeAsString(jsonEncode(project.toJson()));

      final layersFile = File('${projectDir.path}/layers.json');
      await layersFile.writeAsString(
        jsonEncode(layers.map((l) => l.toJson()).toList()),
      );

      return Success(project);
    } catch (e) {
      return Failure('Failed to save project: $e');
    }
  }

  Future<Result<(Project, List<Layer>)>> loadProject(String projectId) async {
    try {
      final projectDir = await _getProjectDirectory(projectId);

      final projectFile = File('${projectDir.path}/project.json');
      if (!await projectFile.exists()) {
        return const Failure('Project not found');
      }

      final projectJson = jsonDecode(await projectFile.readAsString());
      final project = Project.fromJson(projectJson as Map<String, dynamic>);

      final layersFile = File('${projectDir.path}/layers.json');
      List<Layer> layers = [];
      if (await layersFile.exists()) {
        final layersJson = jsonDecode(await layersFile.readAsString()) as List;
        layers = layersJson
            .map((l) => Layer.fromJson(l as Map<String, dynamic>))
            .toList();
      }

      return Success((project, layers));
    } catch (e) {
      return Failure('Failed to load project: $e');
    }
  }

  Future<Result<List<Project>>> listProjects() async {
    try {
      final projectsDir = await _getProjectsDirectory();
      final projects = <Project>[];

      await for (final entity in projectsDir.list()) {
        if (entity is Directory) {
          final projectFile = File('${entity.path}/project.json');
          if (await projectFile.exists()) {
            final json = jsonDecode(await projectFile.readAsString());
            projects.add(Project.fromJson(json as Map<String, dynamic>));
          }
        }
      }

      projects.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt;
        final bDate = b.updatedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });
      return Success(projects);
    } catch (e) {
      return Failure('Failed to list projects: $e');
    }
  }

  Future<Result<void>> deleteProject(String projectId) async {
    try {
      final projectDir = await _getProjectDirectory(projectId);
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete project: $e');
    }
  }

  Future<Result<(Project, List<Layer>)>> importLayersPack(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        return const Failure('Invalid .layers file: missing manifest');
      }

      final manifest = jsonDecode(
        String.fromCharCodes(manifestFile.content as List<int>),
      );

      final projectId =
          manifest['projectId'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final projectName =
          manifest['projectName'] as String? ?? 'Imported Project';
      final sourceImage = manifest['sourceImagePath'] as String? ?? '';
      final layersData = manifest['layers'] as List? ?? [];

      final projectDir = await _getProjectDirectory(projectId);
      final layersDir = Directory('${projectDir.path}/layers');
      await layersDir.create(recursive: true);

      final layers = <Layer>[];
      for (final layerInfo in layersData) {
        final layerFile = archive.findFile(layerInfo['file'] as String);
        if (layerFile == null) continue;

        final localFileName = 'layer_${layerInfo['zIndex']}.png';
        final localFile = File('${layersDir.path}/$localFileName');
        await localFile.writeAsBytes(layerFile.content as List<int>);

        layers.add(
          Layer(
            id:
                layerInfo['id'] as String? ??
                DateTime.now().microsecondsSinceEpoch.toString(),
            name: 'Layer ${layerInfo['zIndex']}',
            pngUrl: localFile.path,
            width: 0,
            height: 0,
            zIndex: layerInfo['zIndex'] as int? ?? 0,
            visible: layerInfo['visible'] as bool? ?? true,
            transform: LayerTransform(
              opacity: (layerInfo['opacity'] as num?)?.toDouble() ?? 1.0,
            ),
          ),
        );
      }

      final project = Project(
        id: projectId,
        name: projectName,
        sourceImagePath: sourceImage,
        layers: layers,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveProject(project, layers);
      return Success((project, layers));
    } catch (e) {
      return Failure('Failed to import .layers file: $e');
    }
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});
