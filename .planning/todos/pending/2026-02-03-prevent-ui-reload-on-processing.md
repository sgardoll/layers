---
created: 2026-02-03T22:55
title: Prevent full UI reload when project enters Processing state
area: ui
files:
  - lib/screens/project_screen.dart
  - lib/widgets/processing_indicator.dart
  - lib/providers/project_provider.dart
---

## Problem

When a new project is added and hits the "Processing" screen, the entire UI reloads. This causes all project images to re-download, creating:
- Noticeable lag and visual flickering
- Previously loaded images disappear and show as blank
- Poor user experience during the already-long processing wait

This affects the core project creation flow — every user experiences this lag.

## Solution

TBD — needs investigation into state management

Possible approaches:
1. Use Riverpod's `select()` to only update the new project's state
2. Ensure `CachedNetworkImage` has proper cache configuration
3. Check if `projectProvider` is unnecessarily invalidating all projects
4. Consider optimistic UI updates with placeholder states

## Context

Issue observed during end-to-end testing. The processing indicator triggers some state change that cascades through the entire projects list, causing all images to fetch fresh from network instead of using cached versions.
