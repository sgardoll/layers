import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/job.dart';
import '../services/job_store.dart';
import '../services/fal_service.dart';

/// Routes for job management
class JobsRoutes {
  final JobStore jobStore;
  final FalService falService;

  JobsRoutes({required this.jobStore, required this.falService});

  Router get router {
    final router = Router();

    // POST /api/jobs - Submit a new layering job
    router.post('/', _createJob);

    // GET /api/jobs/<id> - Get job status
    router.get('/<id>', _getJob);

    // DELETE /api/jobs/<id> - Cancel/delete job
    router.delete('/<id>', _deleteJob);

    // POST /api/jobs/<id>/poll - Manually trigger status update from fal.ai
    router.post('/<id>/poll', _pollJob);

    return router;
  }

  Future<Response> _createJob(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final imageUrl = json['image_url'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        return Response(
          400,
          body: jsonEncode({'error': 'image_url is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Create job in our database
      final job = jobStore.createJob(imageUrl: imageUrl);

      // Submit to fal.ai
      try {
        final falResponse = await falService.submitJob(imageUrl: imageUrl);

        // Update job with fal request ID
        final updatedJob = job.copyWith(
          status: JobStatus.processing,
          falRequestId: falResponse.requestId,
        );
        jobStore.updateJob(updatedJob);

        return Response.ok(
          jsonEncode({
            'job_id': updatedJob.id,
            'status': updatedJob.status.name,
            'created_at': updatedJob.createdAt.toIso8601String(),
            'expires_at': updatedJob.expiresAt.toIso8601String(),
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        // Failed to submit to fal.ai, mark job as failed
        final failedJob = job.copyWith(
          status: JobStatus.failed,
          error: 'Failed to submit to AI service: $e',
        );
        jobStore.updateJob(failedJob);

        return Response(
          502,
          body: jsonEncode({
            'job_id': job.id,
            'status': 'failed',
            'error': 'Failed to submit to AI service',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      return Response(
        400,
        body: jsonEncode({'error': 'Invalid request: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getJob(Request request, String id) async {
    final job = jobStore.getJob(id);

    if (job == null) {
      return Response.notFound(
        jsonEncode({'error': 'Job not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // If job is still processing, check fal.ai for updates
    if (job.status == JobStatus.processing && job.falRequestId != null) {
      try {
        final status = await falService.checkStatus(job.falRequestId!);

        if (status.isCompleted) {
          // Get the result
          final layers = await falService.getResult(job.falRequestId!);
          final layerResults = layers.asMap().entries.map((e) {
            return LayerResult(
              id: 'layer_${e.key}',
              url: e.value.url,
              width: e.value.width,
              height: e.value.height,
              order: e.key,
            );
          }).toList();

          final completedJob = job.copyWith(
            status: JobStatus.completed,
            progress: 1.0,
            layers: layerResults,
          );
          jobStore.updateJob(completedJob);

          return _jobResponse(completedJob);
        } else if (status.isFailed) {
          final failedJob = job.copyWith(
            status: JobStatus.failed,
            error: status.error ?? 'Unknown error from AI service',
          );
          jobStore.updateJob(failedJob);

          return _jobResponse(failedJob);
        } else {
          // Still processing, update progress
          final updatedJob = job.copyWith(
            progress: status.progress ?? job.progress,
          );
          if (updatedJob.progress != job.progress) {
            jobStore.updateJob(updatedJob);
          }
          return _jobResponse(updatedJob);
        }
      } catch (e) {
        // Failed to check status, return cached job data
        return _jobResponse(job);
      }
    }

    return _jobResponse(job);
  }

  Future<Response> _deleteJob(Request request, String id) async {
    final job = jobStore.getJob(id);

    if (job == null) {
      return Response.notFound(
        jsonEncode({'error': 'Job not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Cancel on fal.ai if still processing
    if (job.status == JobStatus.processing && job.falRequestId != null) {
      try {
        await falService.cancelJob(job.falRequestId!);
      } catch (e) {
        // Ignore cancellation errors
      }
    }

    jobStore.deleteJob(id);

    return Response.ok(
      jsonEncode({'status': 'deleted'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _pollJob(Request request, String id) async {
    // Same as getJob but forces a fresh check
    return _getJob(request, id);
  }

  Response _jobResponse(Job job) {
    return Response.ok(
      jsonEncode({
        'job_id': job.id,
        'status': job.status.name,
        'progress': job.progress,
        'layers': job.layers?.map((l) => l.toJson()).toList(),
        'error': job.error,
        'created_at': job.createdAt.toIso8601String(),
        'expires_at': job.expiresAt.toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
