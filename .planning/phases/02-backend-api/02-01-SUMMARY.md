# 02-01 Summary: Backend Service with fal.ai Integration

## Completed

### Backend Structure (`backend/`)
- Dart Shelf HTTP server with SQLite persistence
- fal.ai integration for Qwen-Image-Layered model

### Files Created
| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dependencies: shelf, dio, sqlite3, json_serializable |
| `lib/models/job.dart` | Job and LayerResult models with JSON serialization |
| `lib/services/fal_service.dart` | fal.ai API client for layer inference |
| `lib/services/job_store.dart` | SQLite persistence for job tracking |
| `lib/routes/jobs_routes.dart` | REST API: POST/GET/DELETE /api/jobs |
| `bin/server.dart` | Server entry point with CORS, health check |
| `Dockerfile` | Production container build |
| `.env.example` | Environment variable template |

### API Endpoints
| Method | Path | Purpose |
|--------|------|---------|
| POST | `/api/jobs` | Submit image for layer extraction |
| GET | `/api/jobs/:id` | Poll job status and get results |
| DELETE | `/api/jobs/:id` | Cancel/cleanup job |
| GET | `/health` | Health check |

### Key Decisions
- **Model**: `fal-ai/qwen-image-layered` (~$0.05/image, 15-30s)
- **Storage**: SQLite for simplicity (MVP), 24h job expiry
- **Architecture**: Async job queue pattern for long-running inference

## Verification
- `dart analyze`: Clean (info-level print warnings only)
- Generated code: `job.g.dart` created via build_runner
