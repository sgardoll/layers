# Roadmap: Layers

## Overview

Build a Flutter app that transforms images into editable layer stacks via AI inference. Start with foundation and architecture, integrate cloud GPU backend for Qwen model, build the signature 3D viewer experience, add export/persistence, then ship with freemium monetization across all platforms.

## Domain Expertise

None

## Phases

- [x] **Phase 1: Foundation** — Flutter project setup, architecture, navigation structure
- [ ] **Phase 2: Backend & API** — Cloud GPU inference integration, job queue, API endpoints
- [ ] **Phase 3: Core Experience** — 3D viewer, layer management, 2D stack view
- [ ] **Phase 4: Export & Persistence** — PNG/ZIP/.layers export, project save/load
- [ ] **Phase 5: Monetization & Launch** — Freemium gates, subscription, platform deployment

## Phase Details

### Phase 1: Foundation
**Goal**: Flutter project with clean architecture, navigation, and platform configs ready
**Depends on**: Nothing (first phase)
**Research**: Unlikely (standard Flutter setup patterns)
**Plans**: TBD

Plans:
- [x] 01-01: Project scaffold and architecture setup
- [x] 01-02: Navigation structure and core UI shell

### Phase 2: Backend & API
**Goal**: Working inference pipeline — image in, layers out via cloud GPU
**Depends on**: Phase 1
**Research**: Likely (new integration)
**Research topics**: Qwen Image Layered API/model usage, Replicate/Modal/RunPod patterns, job queue architecture
**Plans**: TBD

Plans:
- [ ] 02-01: Backend service setup and API design
- [ ] 02-02: Qwen model integration and job processing
- [ ] 02-03: Flutter client API integration

### Phase 3: Core Experience
**Goal**: The signature 3D viewer and layer management that makes the app special
**Depends on**: Phase 2
**Research**: Likely (new patterns)
**Research topics**: Flutter perspective transforms, gesture handling for orbit/pan/zoom, hit testing on transformed widgets
**Plans**: TBD

Plans:
- [ ] 03-01: 3D Layer Space View with transforms and camera controls
- [ ] 03-02: Layer selection, actions, and reordering
- [ ] 03-03: 2D Stack View (utility fallback)

### Phase 4: Export & Persistence
**Goal**: Users can export layers and save/load projects
**Depends on**: Phase 3
**Research**: Unlikely (standard file I/O patterns)
**Plans**: TBD

Plans:
- [ ] 04-01: PNG and ZIP export
- [ ] 04-02: .layers pack format and export
- [ ] 04-03: Project save/load

### Phase 5: Monetization & Launch
**Goal**: Freemium model working, app deployed to all platforms
**Depends on**: Phase 4
**Research**: Likely (external services)
**Research topics**: RevenueCat or native in-app purchase, Flutter multi-platform deployment (iOS/Android/macOS/web), App Store requirements
**Plans**: TBD

Plans:
- [ ] 05-01: Freemium gates and subscription integration
- [ ] 05-02: Platform builds and deployment
- [ ] 05-03: Launch polish and App Store submission

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 2/2 | Complete | 2026-01-23 |
| 2. Backend & API | 0/3 | Not started | — |
| 3. Core Experience | 0/3 | Not started | — |
| 4. Export & Persistence | 0/3 | Not started | — |
| 5. Monetization & Launch | 0/3 | Not started | — |
