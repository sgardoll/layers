# Layers

## What This Is

A Flutter app that turns any image into editable layers using AI (Qwen Image Layered). Users import an image, the app separates it into transparent layer stacks, and they can view, rearrange, and export layers through a signature 3D "cards in space" viewer. Ships to iOS, Android, macOS, and web.

## Core Value

The 3D layer viewer must feel magical — selecting and navigating layers should be delightful, fast, and unlike anything else. If the viewer doesn't wow users, nothing else matters.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Import image (camera roll, share sheet, drag-drop)
- [ ] Run Qwen Image Layered inference via cloud GPU
- [ ] Present results in 3D Layer Space View (signature feature)
- [ ] Present results in 2D Stack View (utility fallback)
- [ ] Layer actions: select, multi-select, hide/show, reorder
- [ ] Basic per-layer transforms: move, scale, rotate, opacity
- [ ] Export: individual PNGs, ZIP of all layers, .layers pack
- [ ] Project save/load
- [ ] Processing states: uploading, layering, packaging, ready, failed
- [ ] Failure UX: retry presets, "try again" options
- [ ] Freemium monetization: free tier limits, Pro subscription
- [ ] Cross-platform: iOS, Android, macOS, web

### Out of Scope

- Full editing (brushes, masks, adjustments) — not Photoshop, stay focused
- PSD/KRA export — ship .layers pack first, add if users demand
- Cloud library / sharing links — post-MVP feature
- Version history — post-MVP feature
- Layer grouping — post-MVP feature
- Smart refinements (mask cleanup, feather, expand/contract) — post-MVP
- Background removal as separate tool — post-MVP
- Text detection as separate layers — post-MVP

## Context

**AI Model**: Qwen Image Layered (qwen-lm/qwen-image-layered) — takes a flattened image and produces segmented visual elements with transparency.

**Target Users**:
- Designers: professionals pulling apart images for compositing/asset extraction
- Hobbyists: casual users who want to "pull apart" images without pro tools

**Technical Approach**:
- "Fake 3D" with transforms recommended for MVP (real 3D is a rabbit hole)
- Server-side inference required (not on-device)
- Cloud GPU provider: Replicate, Modal, or RunPod
- Temporary storage with auto-expire (24h unless user saves)

**Key UX Considerations**:
- Layer quality varies by image — need retry presets and expectation setting
- Soft cap on layers (~30 live in 3D) to prevent UI hell
- Use thumbnails during navigation, full-res only for export/focus

## Constraints

- **Tech stack**: Flutter (cross-platform requirement)
- **Backend**: Cloud GPU inference (Replicate/Modal/RunPod) — no on-device processing for v1
- **Timeline**: Quick build to validate with real paying users
- **Performance**: 60fps in 3D viewer, aggressive thumbnail caching
- **Platform scope**: iOS, Android, macOS, web — all from Flutter codebase

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter for all platforms | Single codebase for iOS/Android/macOS/web | — Pending |
| "Fake 3D" over real 3D engine | Ship faster, avoid plugin complexity rabbit hole | — Pending |
| .layers pack over PSD for v1 | Control the format, add PSD later if demanded | — Pending |
| Cloud GPU over on-device | Required for model size, simpler mobile app | — Pending |
| Freemium over one-time purchase | Recurring revenue, validates ongoing value | — Pending |

---
*Last updated: 2026-01-23 after initialization*
