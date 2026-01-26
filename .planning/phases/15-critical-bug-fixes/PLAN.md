# Phase 15: Critical Bug Fixes

## Overview
Fix three critical bugs affecting core functionality across platforms.

## Bug Analysis

### Bug 1: iOS - Image selected but project not created
**Symptom:** Image picker opens, user selects image, but project not created in Supabase (works on Mac/Android)

**Root Cause:** iOS sandboxing issue. `ProjectScreen._pickAndCreateProject()` uses `ImagePicker.pickImage()` which returns an `XFile`, but then creates `File(image.path)` and calls `readAsBytes()`. On iOS, the picked image path may be in a temporary sandbox location that `dart:io File` can't access reliably.

**Fix:** Use `XFile.readAsBytes()` directly instead of converting to `dart:io File`. Pass bytes to service instead of File.

### Bug 2: All platforms - No image preview in Projects screen
**Symptom:** Projects show but without thumbnail preview of the source image

**Root Cause:** `_ProjectCard._buildThumbnail()` checks:
1. If `sourceImagePath` starts with 'http' → `Image.network()`
2. Else if `File.existsSync(sourceImagePath)` → `Image.file()`
3. Else → placeholder icon

But `sourceImagePath` is stored as a Supabase storage path (e.g., `userId/timestamp/source.jpg`), NOT a full URL or local path. Neither condition matches.

**Fix:** Generate signed URL from storage path using Supabase storage API, or store the full URL in the database.

### Bug 3: All platforms - RevenueCat subscription options not displaying
**Symptom:** Paywall shows "No subscription options available"

**Root Cause:** Multiple possibilities:
1. `.env` not loaded or keys missing
2. RevenueCat dashboard not configured with products
3. `offerings.current` is null (no "current" offering set in dashboard)

**Fix:** Add debug logging, verify .env keys, verify RevenueCat dashboard configuration.

## Tasks

### Task 1: Fix iOS image picker (Bug 1)
**Files:** 
- `lib/screens/project_screen.dart`
- `lib/services/supabase_project_service.dart`

**Changes:**
1. In `project_screen.dart`: Get bytes directly from XFile
   ```dart
   final bytes = await image.readAsBytes();
   final fileName = image.name;
   ```
2. Update `createProject()` signature to accept bytes + filename instead of File
3. Update `supabase_project_service.dart` to use bytes directly

### Task 2: Fix image preview thumbnails (Bug 2)
**Files:**
- `lib/screens/project_screen.dart`

**Changes:**
1. In `_buildThumbnail()`: Generate signed URL from storage path
   ```dart
   final url = Supabase.instance.client.storage
       .from('source-images')
       .getPublicUrl(project.sourceImagePath);
   ```
2. Use `Image.network(url)` with the generated URL
3. Add error handling and placeholder for failed loads

### Task 3: Debug and fix RevenueCat (Bug 3)
**Files:**
- `lib/services/revenuecat_service.dart`
- `lib/screens/paywall_screen.dart`

**Changes:**
1. Add debug logging to `initialize()` and `getOfferings()`
2. Verify .env has correct keys
3. Check RevenueCat dashboard for:
   - Products configured
   - Entitlements set up
   - Offering marked as "current"
4. Handle null offerings gracefully

## Execution Order
1. Task 1 (iOS picker) - Highest priority, blocks iOS usage
2. Task 2 (thumbnails) - High priority, affects all platforms
3. Task 3 (RevenueCat) - Medium priority, monetization

## Testing
- [ ] iOS: Pick image → project created in Supabase
- [ ] All: Projects show thumbnail previews
- [ ] All: Paywall shows subscription options

## Version
After fixes: 1.1.2+10
