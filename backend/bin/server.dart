import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';

import 'package:layers_backend/services/fal_service.dart';
import 'package:layers_backend/services/job_store.dart';
import 'package:layers_backend/routes/jobs_routes.dart';

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final host = env['HOST'] ?? '0.0.0.0';
  final port = int.parse(env['PORT'] ?? '8080');
  final falApiKey = env['FAL_API_KEY'];
  final dbPath = env['DATABASE_PATH'] ?? './data/layers.db';

  if (falApiKey == null || falApiKey.isEmpty) {
    stderr.writeln('ERROR: FAL_API_KEY environment variable is required');
    exit(1);
  }

  // Ensure data directory exists
  final dbDir = Directory(dbPath).parent;
  if (!dbDir.existsSync()) {
    dbDir.createSync(recursive: true);
  }

  // Initialize services
  final jobStore = JobStore(dbPath);
  final falService = FalService(apiKey: falApiKey);

  // Create routes
  final jobsRoutes = JobsRoutes(jobStore: jobStore, falService: falService);

  // Build the router
  final router = Router();

  // Health check
  router.get('/health', (Request request) {
    return Response.ok(
      '{"status": "ok"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Mount job routes
  router.mount('/api/jobs', jobsRoutes.router.call);

  // Build the pipeline with CORS
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  // Start the server
  final server = await shelf_io.serve(handler, host, port);
  print('Server running at http://${server.address.host}:${server.port}');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down...');
    jobStore.dispose();
    falService.dispose();
    await server.close();
    exit(0);
  });

  // Cleanup expired jobs periodically (every hour)
  Future.doWhile(() async {
    await Future.delayed(const Duration(hours: 1));
    final cleaned = jobStore.cleanupExpiredJobs();
    if (cleaned > 0) {
      print('Cleaned up $cleaned expired jobs');
    }
    return true;
  });
}
