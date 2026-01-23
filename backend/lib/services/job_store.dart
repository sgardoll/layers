import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import '../models/job.dart';
import 'dart:convert';

/// SQLite-backed job storage
class JobStore {
  final Database _db;
  final Uuid _uuid = const Uuid();

  JobStore(String dbPath) : _db = sqlite3.open(dbPath) {
    _initDatabase();
  }

  void _initDatabase() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS jobs (
        id TEXT PRIMARY KEY,
        status TEXT NOT NULL,
        image_url TEXT NOT NULL,
        fal_request_id TEXT,
        progress REAL DEFAULT 0.0,
        layers TEXT,
        error TEXT,
        created_at TEXT NOT NULL,
        expires_at TEXT NOT NULL
      )
    ''');

    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status)
    ''');

    _db.execute('''
      CREATE INDEX IF NOT EXISTS idx_jobs_expires_at ON jobs(expires_at)
    ''');
  }

  /// Create a new job
  Job createJob({required String imageUrl, int expiryHours = 24}) {
    final now = DateTime.now().toUtc();
    final job = Job(
      id: _uuid.v4(),
      status: JobStatus.pending,
      imageUrl: imageUrl,
      progress: 0.0,
      createdAt: now,
      expiresAt: now.add(Duration(hours: expiryHours)),
    );

    _db.execute(
      '''
      INSERT INTO jobs (id, status, image_url, fal_request_id, progress, layers, error, created_at, expires_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
      [
        job.id,
        job.status.name,
        job.imageUrl,
        job.falRequestId,
        job.progress,
        job.layers != null
            ? jsonEncode(job.layers!.map((l) => l.toJson()).toList())
            : null,
        job.error,
        job.createdAt.toIso8601String(),
        job.expiresAt.toIso8601String(),
      ],
    );

    return job;
  }

  /// Get a job by ID
  Job? getJob(String id) {
    final result = _db.select('SELECT * FROM jobs WHERE id = ?', [id]);

    if (result.isEmpty) return null;

    return _rowToJob(result.first);
  }

  /// Update a job
  void updateJob(Job job) {
    _db.execute(
      '''
      UPDATE jobs SET
        status = ?,
        fal_request_id = ?,
        progress = ?,
        layers = ?,
        error = ?
      WHERE id = ?
    ''',
      [
        job.status.name,
        job.falRequestId,
        job.progress,
        job.layers != null
            ? jsonEncode(job.layers!.map((l) => l.toJson()).toList())
            : null,
        job.error,
        job.id,
      ],
    );
  }

  /// Delete a job
  void deleteJob(String id) {
    _db.execute('DELETE FROM jobs WHERE id = ?', [id]);
  }

  /// Get all pending/processing jobs (for recovery on restart)
  List<Job> getActiveJobs() {
    final result = _db.select('SELECT * FROM jobs WHERE status IN (?, ?)', [
      JobStatus.pending.name,
      JobStatus.processing.name,
    ]);

    return result.map(_rowToJob).toList();
  }

  /// Delete expired jobs
  int cleanupExpiredJobs() {
    final now = DateTime.now().toUtc().toIso8601String();
    _db.execute('DELETE FROM jobs WHERE expires_at < ?', [now]);
    return _db.updatedRows;
  }

  Job _rowToJob(Row row) {
    final layersJson = row['layers'] as String?;
    List<LayerResult>? layers;

    if (layersJson != null) {
      final layersList = jsonDecode(layersJson) as List<dynamic>;
      layers = layersList
          .map((l) => LayerResult.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    return Job(
      id: row['id'] as String,
      status: JobStatus.values.firstWhere((s) => s.name == row['status']),
      imageUrl: row['image_url'] as String,
      falRequestId: row['fal_request_id'] as String?,
      progress: row['progress'] as double,
      layers: layers,
      error: row['error'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      expiresAt: DateTime.parse(row['expires_at'] as String),
    );
  }

  void dispose() {
    _db.dispose();
  }
}
