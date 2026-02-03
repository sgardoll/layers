import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';
import '../models/project.dart';
import '../services/supabase_project_service.dart'
    hide supabaseProjectServiceProvider;
import 'supabase_providers.dart';

/// State for the project list
enum ProjectListStatus { initial, loading, loaded, error }

class ProjectListState {
  final List<Project> projects;
  final ProjectListStatus status;
  final String? errorMessage;

  const ProjectListState({
    this.projects = const [],
    this.status = ProjectListStatus.initial,
    this.errorMessage,
  });

  ProjectListState copyWith({
    List<Project>? projects,
    ProjectListStatus? status,
    String? errorMessage,
  }) {
    return ProjectListState(
      projects: projects ?? this.projects,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class ProjectListNotifier extends StateNotifier<ProjectListState> {
  final SupabaseProjectService _service;
  final Map<String, StreamSubscription<Project>> _subscriptions = {};

  ProjectListNotifier(this._service) : super(const ProjectListState());

  Future<void> loadProjects() async {
    state = state.copyWith(status: ProjectListStatus.loading);

    final result = await _service.listProjects();

    result.when(
      success: (projects) {
        state = state.copyWith(
          projects: projects,
          status: ProjectListStatus.loaded,
        );
        // Subscribe to realtime updates for processing projects
        for (final project in projects) {
          if (project.status == 'queued' || project.status == 'processing') {
            _subscribeToProject(project.id);
          }
        }
      },
      failure: (message, _) {
        state = state.copyWith(
          status: ProjectListStatus.error,
          errorMessage: message,
        );
      },
    );
  }

  Future<Result<Project>> createProject(
    Uint8List imageBytes,
    String fileName,
  ) async {
    final result = await _service.createProject(
      imageBytes: imageBytes,
      fileName: fileName,
    );

    result.when(
      success: (project) {
        state = state.copyWith(projects: [project, ...state.projects]);
        // Subscribe to updates for the new project
        _subscribeToProject(project.id);
      },
      failure: (_, __) {},
    );

    return result;
  }

  Future<Result<void>> deleteProject(String projectId) async {
    final result = await _service.deleteProject(projectId);

    result.when(
      success: (_) {
        _cancelSubscription(projectId);
        state = state.copyWith(
          projects: state.projects.where((p) => p.id != projectId).toList(),
        );
      },
      failure: (_, __) {},
    );

    return result;
  }

  void _subscribeToProject(String projectId) {
    // Cancel existing subscription if any
    _cancelSubscription(projectId);

    _subscriptions[projectId] = _service
        .subscribeToProject(projectId)
        .listen(
          (updatedProject) {
            final index = state.projects.indexWhere((p) => p.id == projectId);
            if (index != -1) {
              final updatedList = [...state.projects];
              updatedList[index] = updatedProject;
              state = state.copyWith(projects: updatedList);

              // Stop subscribing once project is ready or failed
              if (updatedProject.status == 'ready' ||
                  updatedProject.status == 'failed') {
                _cancelSubscription(projectId);
              }
            }
          },
          onError: (e) {
            _cancelSubscription(projectId);
          },
        );
  }

  void _cancelSubscription(String projectId) {
    _subscriptions[projectId]?.cancel();
    _subscriptions.remove(projectId);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  /// Reset all state (called on logout)
  void reset() {
    // Cancel all subscriptions
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    // Reset to initial state
    state = const ProjectListState();
  }
}

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, ProjectListState>((ref) {
      final service = ref.watch(supabaseProjectServiceProvider);
      return ProjectListNotifier(service);
    });

/// Currently selected project for viewing/editing
final currentProjectProvider = StateProvider<Project?>((ref) => null);
