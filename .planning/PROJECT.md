# Layers

## What This Is

A Flutter app that turns any image into editable layers using AI (fal.ai BiRefNet). Users import an image, the app separates it into transparent layer stacks, and they can view, rearrange, and export layers through a signature 3D "cards in space" viewer. Ships to iOS, Android, macOS, and web.

## Core Value

The 3D layer viewer must feel magical — selecting and navigating layers should be delightful, fast, and unlike anything else. If the viewer doesn't wow users, nothing else matters.

## Current State

**Version:** v1.0 (build 7) — SHIPPED 2026-01-25
**Platforms:** Android (Play Store), macOS (App Store), iOS (TestFlight)
**Codebase:** 6,757 lines Dart, 352 files
**Tech Stack:** Flutter, Supabase, BuildShip, RevenueCat, fal.ai

## Current Milestone: v1.3 Monetization & Settings

**Goal:** Add per-export consumable IAP and improve settings screen with user info, subscription status, and account management

**Target features:**
- Per-export pricing: $0.50 consumable IAP alongside existing subscriptions
- Settings screen: Display user email, subscription status, usage statistics
- Account management: Delete account functionality with data cleanup
- Export credit system: Track and display export usage

## Requirements

### Validated

- Import image (camera roll, share sheet, drag-drop) — v1.0
- Present results in 3D Layer Space View (signature feature) — v1.0
- Present results in 2D Stack View (utility fallback) — v1.0
- Layer actions: select, multi-select, hide/show, reorder — v1.0
- Basic per-layer transforms: move, scale, rotate, opacity — v1.0
- Export: individual PNGs, ZIP of all layers — v1.0
- Project save/load — v1.0
- Processing states: uploading, layering, packaging, ready, failed — v1.0
- Freemium monetization: free tier limits, Pro subscription — v1.0
- Cross-platform: iOS, Android, macOS — v1.0
- Email authentication with RevenueCat linking — v1.0
- Account deletion with data cleanup — v1.0
- Dual theme system (Light/Dark) — v1.4 Phase 18
- Responsive layout (mobile/tablet/desktop) — v1.4 Phase 19

### Active

- [ ] Per-export consumable IAP ($0.50) — v1.3
- [ ] Settings screen with user info and subscription status — v1.3
- [ ] Export usage tracking and statistics — v1.3
- [ ] Delete account functionality — v1.3
- [ ] Run AI layer extraction via BuildShip (workflows specified, needs implementation)
- [ ] Web platform deployment
- [ ] .layers pack export format

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

**AI Model**: fal.ai BiRefNet — takes a flattened image and produces segmented visual elements with transparency.

**Backend Architecture**:
- Supabase: Database (projects, project_layers, exports) + Storage + Auth + Realtime
- BuildShip: Serverless workflows triggered by DB events (spec complete, implementation pending)
- RevenueCat: Subscription management with Supabase user linking

**Known Issues**:
- BuildShip workflow processing nodes need manual setup using `.planning/phases/09-buildship-workflow-spec/SPEC.md`
- Old `backend/` folder contains deprecated Dart Shelf backend (can be deleted)

## Constraints

- **Tech stack**: Flutter (cross-platform requirement)
- **Backend**: Supabase + BuildShip (serverless)
- **Performance**: 60fps in 3D viewer, aggressive thumbnail caching
- **Platform scope**: iOS, Android, macOS, web — all from Flutter codebase

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter for all platforms | Single codebase for iOS/Android/macOS/web | Good |
| "Fake 3D" over real 3D engine | Ship faster, avoid plugin complexity rabbit hole | Good |
| Supabase + BuildShip over custom backend | Serverless, realtime, no server management | Good |
| RevenueCat for subscriptions | Cross-platform, handles receipt validation | Good |
| fal.ai BiRefNet for layer extraction | Production-ready API, no GPU infrastructure | Pending (needs BuildShip impl) |
| Email auth over anonymous | Subscription persistence across devices | Good |

---
*Last updated: 2026-02-06 — Started milestone v1.3 Monetization & Settings*
