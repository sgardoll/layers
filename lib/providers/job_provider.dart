import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/result.dart';
import '../models/layer.dart';
import '../models/project.dart';
import '../services/layer_service.dart';

enum JobPhase { idle, uploading, processing, completed, failed }

class JobState {
  final JobPhase phase;
  final String? jobId;
  final String? error;
  final double? progress;
  final List<Layer>? layers;

  const JobState({
    this.phase = JobPhase.idle,
    this.jobId,
    this.error,
    this.progress,
    this.layers,
  });

  JobState copyWith({
    JobPhase? phase,
    String? jobId,
    String? error,
    double? progress,
    List<Layer>? layers,
  }) {
    return JobState(
      phase: phase ?? this.phase,
      jobId: jobId ?? this.jobId,
      error: error,
      progress: progress ?? this.progress,
      layers: layers ?? this.layers,
    );
  }

  bool get isIdle => phase == JobPhase.idle;
  bool get isUploading => phase == JobPhase.uploading;
  bool get isProcessing => phase == JobPhase.processing;
  bool get isCompleted => phase == JobPhase.completed;
  bool get isFailed => phase == JobPhase.failed;
  bool get isWorking => isUploading || isProcessing;
}

class JobNotifier extends StateNotifier<JobState> {
  final LayerService _service;

  JobNotifier(this._service) : super(const JobState());

  Future<void> processImage(XFile image) async {
    state = state.copyWith(phase: JobPhase.uploading, error: null);

    final submitResult = await _service.submitImage(image);

    switch (submitResult) {
      case Success(data: final job):
        state = state.copyWith(phase: JobPhase.processing, jobId: job.id);
        await _pollForCompletion(job.id);

      case Failure(message: final msg):
        state = state.copyWith(phase: JobPhase.failed, error: msg);
    }
  }

  Future<void> processImageBytes(
    Uint8List bytes, {
    String mimeType = 'image/png',
  }) async {
    state = state.copyWith(phase: JobPhase.uploading, error: null);

    final submitResult = await _service.submitImageBytes(
      bytes,
      mimeType: mimeType,
    );

    switch (submitResult) {
      case Success(data: final job):
        state = state.copyWith(phase: JobPhase.processing, jobId: job.id);
        await _pollForCompletion(job.id);

      case Failure(message: final msg):
        state = state.copyWith(phase: JobPhase.failed, error: msg);
    }
  }

  Future<void> _pollForCompletion(String jobId) async {
    final result = await _service.pollUntilComplete(
      jobId,
      onProgress: (job) {
        if (job.isProcessing) {
          state = state.copyWith(phase: JobPhase.processing);
        }
      },
    );

    switch (result) {
      case Success(data: final job):
        if (job.isCompleted && job.layers != null) {
          final layers = job.layers!.map((layerData) {
            return Layer(
              id: 'layer_${layerData.index}',
              name: 'Layer ${layerData.index + 1}',
              pngUrl: layerData.imageUrl,
              zIndex: layerData.index,
              width: layerData.width,
              height: layerData.height,
            );
          }).toList();

          state = state.copyWith(phase: JobPhase.completed, layers: layers);
        } else if (job.isFailed) {
          state = state.copyWith(
            phase: JobPhase.failed,
            error: job.error ?? 'Processing failed',
          );
        }

      case Failure(message: final msg):
        state = state.copyWith(phase: JobPhase.failed, error: msg);
    }
  }

  Future<void> cancel() async {
    if (state.jobId != null) {
      await _service.cancelJob(state.jobId!);
    }
    reset();
  }

  void reset() {
    state = const JobState();
  }
}

final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  final service = ref.watch(layerServiceProvider);
  return JobNotifier(service);
});

final currentProjectProvider = StateProvider<Project?>((ref) => null);
