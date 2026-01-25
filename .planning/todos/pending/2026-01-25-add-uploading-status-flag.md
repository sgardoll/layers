---
created: 2026-01-25T22:56
title: Add an "Uploading" status flag for when the file is uploading and before it's queued
area: ui
files:
  - lib/services/supabase_project_service.dart
  - lib/providers/project_provider.dart
  - lib/screens/project_screen.dart
---

## Problem

When a user selects an image to create a new project, there's no visual feedback during the upload phase. The current flow is:

1. User picks image → nothing visible happens
2. Image uploads to Supabase Storage (can take seconds)
3. Project row created with status "queued"
4. Only then does the UI show the project card with processing indicator

Users may think the app is broken or tap multiple times during the upload gap.

## Solution

Add an "uploading" status state that shows immediately after image selection:

- Option A: Add "uploading" to the project status enum/check constraint in Supabase
- Option B: Use local-only state in the provider (optimistic UI) before the project exists in DB
- Show a placeholder card or loading indicator during upload
- Transition to "queued" once upload completes and DB row is created

TBD: Decide between database-level status vs local-only UI state.
