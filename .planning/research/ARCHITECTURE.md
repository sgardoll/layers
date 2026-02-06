# Architecture Patterns: v1.3 Monetization & Settings

**Project:** Layers - AI Image Layer Extraction  
**Milestone:** v1.3 - Per-Export Pricing & Enhanced Settings  
**Researched:** 2026-02-06  
**Overall Confidence:** HIGH

---

## Executive Summary

The v1.3 milestone adds per-export consumable IAPs (In-App Purchases) and enhanced settings to an existing Flutter app with Riverpod state management, Supabase backend, and RevenueCat for subscription handling. The architecture follows established patterns from the existing codebase while introducing new components for credit tracking and purchase flow.

**Key Integration Approach:**
1. **Consumable IAPs** integrate with existing RevenueCat infrastructure
2. **Credit Tracking** uses a new database schema + provider pattern (mirrors entitlement_provider.dart)
3. **Enhanced Settings** extends existing settings_screen.dart with stats section
4. **Account Deletion** requires Supabase RPC + cascade cleanup

---

## Current Architecture Overview

### Existing Component Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  Paywall Screen │  │  Export Screen  │  │ Settings Screen │  │
│  │  (existing)     │  │  (existing)     │  │  (extend)       │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
│           │                    │                    │           │
│  ┌────────▼────────────────────▼────────────────────▼────────┐  │
│  │                     Riverpod Providers                    │  │
│  │  entitlement_provider.dart  (Pro status)                  │  │
│  │  project_provider.dart      (Projects list)               │  │
│  │  layer_provider.dart        (Layer state)                 │  │
│  │  auth_provider.dart         (Auth state)                  │  │
│  └────────┬───────────────────────────────────────────────────┘  │
│           │                                                      │
├───────────┼──────────────────────────────────────────────────────┤
│           │                    SERVICE LAYER                     │
│  ┌────────▼────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ RevenueCat      │  │ SupabaseProject │  │ SupabaseExport  │  │
│  │ Service         │  │ Service         │  │ Service         │  │
│  │ (existing)      │  │ (existing)      │  │ (existing)      │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
│           │                    │                    │           │
├───────────┼────────────────────┼────────────────────┼───────────┤
│           │                    │      DATA LAYER               │
│  ┌────────▼────────┐  ┌────────▼────────┐  ┌────────▼────────┐  │
│  │ RevenueCat API  │  │   Supabase DB   │  │  Supabase Auth  │  │
│  │ (purchases_fl)  │  │  (PostgreSQL)   │  │   (GoTrue)      │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Existing Database Schema

```sql
-- Current tables (from supabase/schema.sql)
projects           -- User projects
  - id, user_id, source_image_path, status, params, manifest_path, thumbnail_path
  - created_at, updated_at

project_layers     -- Individual layers per project
  - id, project_id, name, png_path, png_url, width, height
  - z_index, visible, bbox, transform, created_at

exports            -- Export jobs
  - id, project_id, type, status, error_message
  - options, asset_path, asset_url, created_at, updated_at

-- No profiles table exists currently
-- No user_credits table exists
```

### Existing RevenueCat Integration

The app already has a well-structured RevenueCat integration:

1. **RevenueCatService** (`lib/services/revenuecat_service.dart`)
   - Handles initialization with platform-specific keys
   - Manages subscription purchases (`purchasePackage`)
   - Has placeholder for consumable purchases (`purchaseExportCredit`)
   - Customer info listener setup for real-time entitlement updates

2. **EntitlementProvider** (`lib/providers/entitlement_provider.dart`)
   - StateNotifier pattern for Pro subscription status
   - Listens to auth changes to link/unlink RevenueCat user
   - Integrates with project count for free tier limits
   - Uses `Purchases.addCustomerInfoUpdateListener` for real-time updates

---

## v1.3 New Components

### 1. Export Credit System

#### Database Schema Additions

```sql
-- New table: user_credits (per-user export credit tracking)
CREATE TABLE user_credits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Credit tracking
  total_credits INTEGER NOT NULL DEFAULT 0,
  used_credits INTEGER NOT NULL DEFAULT 0,
  
  -- Metadata
  last_purchase_at TIMESTAMPTZ,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Constraints
CREATE UNIQUE INDEX idx_user_credits_user_id ON user_credits(user_id);

-- RLS Policies (mirror existing patterns from projects table)
ALTER TABLE user_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own credits" ON user_credits
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own credits" ON user_credits
  FOR UPDATE USING (auth.uid() = user_id);

-- Service role can insert/update for purchase webhook
CREATE POLICY "Service can manage credits" ON user_credits
  FOR ALL USING (false) WITH CHECK (false); -- Modified by Edge Function
```

**Migration File:** `supabase/migrations/20260207_add_user_credits.sql`

#### New Provider: Credits Provider

Following the pattern of `entitlement_provider.dart`:

```dart
// lib/providers/credits_provider.dart

class CreditsState {
  final int totalCredits;
  final int usedCredits;
  final bool isLoading;
  final String? errorMessage;
  
  const CreditsState({
    this.totalCredits = 0,
    this.usedCredits = 0,
    this.isLoading = true,
    this.errorMessage,
  });
  
  int get availableCredits => totalCredits - usedCredits;
  bool get hasCredits => availableCredits > 0;
  
  CreditsState copyWith({...}) => ...;
}

class CreditsNotifier extends StateNotifier<CreditsState> {
  final SupabaseExportService _exportService;
  final String? _userId;
  
  // Load credits from user_credits table
  // Listen to realtime updates
  // Consume credit on export
  // Add credits on purchase
}

final creditsProvider = StateNotifierProvider<CreditsNotifier, CreditsState>(...);

// Computed providers
final availableCreditsProvider = Provider<int>((ref) => ...);
final canExportWithCreditsProvider = Provider<bool>((ref) => ...);
```

#### Modified Service: SupabaseExportService

Extend existing service to include credit operations:

```dart
// Additions to lib/services/supabase_export_service.dart

class SupabaseExportService {
  // ... existing methods ...
  
  // NEW: Credit management
  Future<Result<UserCredits>> getUserCredits(String userId) async {...}
  
  Future<Result<void>> consumeCredit(String userId) async {...}
  
  Future<Result<void>> addCredits(String userId, int amount) async {...}
  
  // NEW: Modified createExport to check/consume credits
  Future<Result<ExportJob>> createExport({
    required String projectId,
    required ExportType type,
    List<String>? layerIds,
    bool useCredit = false, // NEW parameter
  }) async {...}
}
```

### 2. Enhanced Settings

#### Modified Screen: SettingsScreen

Extend existing `lib/screens/settings_screen.dart`:

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final entitlement = ref.watch(entitlementProvider);
    final credits = ref.watch(creditsProvider); // NEW
    final themeMode = ref.watch(themeModeProvider);
    
    return ListView(
      children: [
        // ... existing sections ...
        
        // NEW: User Stats Section
        _UserStatsSection(
          projectCount: ref.watch(projectListProvider).projects.length,
          exportCount: ref.watch(exportCountProvider), // New provider
          creditsAvailable: credits.availableCredits,
        ),
        
        // ... rest of settings ...
      ],
    );
  }
}
```

#### New Providers for Stats

```dart
// lib/providers/stats_provider.dart

// Provider for total export count across all projects
final exportCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(supabaseExportServiceProvider);
  final result = await service.listAllExports();
  return result.when(
    success: (exports) => exports.length,
    failure: (_, __) => 0,
  );
});

// Provider for account age
final accountAgeProvider = Provider<Duration?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return DateTime.now().difference(user.createdAt);
});
```

### 3. Account Deletion

#### Supabase RPC Function

```sql
-- supabase/migrations/20260207_add_delete_user_account.sql

-- Function to delete user account with cascade cleanup
CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Get current user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Delete user data (cascades via FK constraints)
  -- 1. exports - deleted via cascade from projects
  -- 2. project_layers - deleted via cascade from projects
  -- 3. projects - manual delete to trigger storage cleanup webhook
  -- 4. user_credits - deleted via cascade from auth.users
  
  -- Delete all projects (triggers cleanup webhook)
  DELETE FROM projects WHERE user_id = v_user_id;
  
  -- Delete user_credits record
  DELETE FROM user_credits WHERE user_id = v_user_id;
  
  -- Delete auth user (this is handled by Supabase Auth API call)
  -- The actual auth.users deletion happens in Flutter via auth API
  
  RETURN;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account() TO authenticated;
```

#### Modified SettingsScreen

The account deletion flow already exists in `settings_screen.dart` but needs enhancement:

```dart
// In _AccountActionsSection._deleteAccount

Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
  try {
    // 1. Call RPC to clean up user data
    await client.rpc('delete_user_account');
    
    // 2. Call RevenueCat to clean up purchase data
    // Note: RevenueCat doesn't support user deletion via API
    // The user remains in RevenueCat but loses appUserID link
    
    // 3. Sign out from auth (triggers cascade state reset)
    // ... existing sign out logic ...
    
  } catch (e) {
    // Handle errors
  }
}
```

---

## Integration Points

### 1. Export Flow Integration

```
User taps Export
       │
       ▼
┌─────────────────────┐
│ Check Entitlement   │◄── entitlementProvider
└──────────┬──────────┘
           │
     ┌─────┴─────┐
     │           │
  isPro      not Pro
     │           │
     ▼           ▼
┌─────────┐  ┌─────────────────────┐
│ Allow   │  │ Check Credits       │◄── creditsProvider
│ Export  │  └──────────┬──────────┘
│         │             │
│         │        hasCredits?
│         │        ┌────┴────┐
│         │       yes       no
│         │        │         │
│         │        ▼         ▼
│         │   ┌─────────┐  ┌─────────────────────┐
│         │   │ Consume │  │ Show Purchase Sheet │
│         └──►│ Credit  │  │ (export_purchase)   │
│             └────┬────┘  └─────────────────────┘
│                  │
└──────────────────┘
                   │
                   ▼
            ┌─────────────┐
            │ Create      │
            │ Export Job  │
            └─────────────┘
```

**Code Changes Required:**

```dart
// In ExportBottomSheet._startExport()

Future<void> _startExport(ExportType type) async {
  final revenueCat = ref.read(revenueCatServiceProvider);
  final credits = ref.read(creditsProvider);
  final entitlement = ref.read(entitlementProvider);
  
  // Check if Pro
  if (entitlement.isPro) {
    // Pro users can export without credits
    await _createExport(type);
    return;
  }
  
  // Check if has credits
  if (credits.hasCredits) {
    // Consume credit and export
    final consumed = await ref.read(creditsProvider.notifier).consumeCredit();
    if (consumed) {
      await _createExport(type, useCredit: true);
    }
    return;
  }
  
  // No Pro, no credits - show purchase sheet
  final purchased = await ExportPurchaseSheet.show(...);
  if (purchased) {
    // Credit added via webhook, refresh and export
    await ref.read(creditsProvider.notifier).refresh();
    await _createExport(type, useCredit: true);
  }
}
```

### 2. Purchase Flow Integration

```
User purchases export credit
       │
       ▼
┌─────────────────────┐
│ RevenueCat Purchase │
│ (existing flow)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐     ┌─────────────────────┐
│ Purchase Success    │────►│ Webhook/Edge Func   │
└─────────────────────┘     │ (optional)          │
                            └──────────┬──────────┘
                                       │
                                       ▼
                            ┌─────────────────────┐
                            │ Add Credit to DB    │
                            │ (user_credits)      │
                            └──────────┬──────────┘
                                       │
                                       ▼
                            ┌─────────────────────┐
                            │ Realtime Update     │
                            │ → creditsProvider   │
                            └─────────────────────┘
```

**Alternative: Direct Credit Addition (Simpler)**

Instead of webhooks, add credits directly in the purchase success callback:

```dart
// In ExportPurchaseSheet._purchase()

Future<void> _purchase() async {
  final result = await widget.revenueCatService.purchaseExportCredit(package);
  
  if (result.isSuccess) {
    // Add credit directly via Supabase
    final creditsNotifier = ref.read(creditsProvider.notifier);
    await creditsNotifier.addCredits(1); // Add 1 export credit
    
    widget.onPurchaseSuccess();
  }
}
```

### 3. Auth State Integration

Following existing pattern in `entitlement_provider.dart`:

```dart
// In CreditsNotifier._init()

void _init() {
  // Listen to auth state changes
  _ref?.listen(currentUserProvider, (previous, current) {
    if (previous == null && current != null) {
      // User logged in - load their credits
      _loadCredits();
    } else if (previous != null && current == null) {
      // User logged out - clear credits
      reset();
    }
  });
}

void reset() {
  state = const CreditsState(isLoading: false);
}
```

---

## Build Order

Based on dependencies, recommended implementation order:

### Phase 1: Foundation (Database + Core Services)

1. **Database Migration**
   - Create `user_credits` table
   - Create `delete_user_account` RPC function
   - Apply RLS policies

2. **Service Layer Extensions**
   - Extend `SupabaseExportService` with credit methods
   - Test service methods

### Phase 2: State Management (Providers)

3. **Credits Provider**
   - Create `credits_provider.dart` (follow `entitlement_provider.dart` pattern)
   - Add realtime subscription for credit updates
   - Integrate with auth provider

4. **Stats Providers**
   - Create `stats_provider.dart` for user statistics
   - Export count, account age, etc.

### Phase 3: UI Integration

5. **Export Flow Update**
   - Modify `ExportBottomSheet` to check credits
   - Update purchase flow to add credits
   - Test full export with credit consumption

6. **Settings Enhancement**
   - Add `_UserStatsSection` to SettingsScreen
   - Display credits, project count, export count
   - Polish UI

### Phase 4: Account Deletion

7. **Account Deletion Flow**
   - Verify RPC function works
   - Test cascade cleanup
   - Ensure RevenueCat unlink happens

---

## Architecture Patterns to Follow

### Pattern 1: Provider Dependencies

```dart
// GOOD: Explicit dependencies
final creditsProvider = StateNotifierProvider<CreditsNotifier, CreditsState>(
  (ref) {
    final service = ref.watch(supabaseExportServiceProvider);
    final user = ref.watch(currentUserProvider);
    return CreditsNotifier(service: service, userId: user?.id);
  },
  dependencies: [supabaseExportServiceProvider, currentUserProvider],
);
```

### Pattern 2: Result Type for Async Operations

```dart
// GOOD: Use existing Result type from lib/core/result.dart
Future<Result<ExportJob>> createExport(...) async {
  try {
    // ... operation
    return Success(exportJob);
  } catch (e) {
    return Failure('Failed to create export: $e');
  }
}
```

### Pattern 3: Realtime Subscriptions

```dart
// GOOD: Follow existing pattern in SupabaseExportService
Stream<UserCredits> subscribeToCredits(String userId) {
  return _client
      .from('user_credits')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((rows) => rows.isNotEmpty 
          ? _creditsFromRow(rows.first) 
          : UserCredits.empty(userId));
}
```

### Pattern 4: StateNotifier Reset Pattern

```dart
// GOOD: Reset state on logout (see existing providers)
void reset() {
  state = const CreditsState(isLoading: false);
  _subscription?.cancel();
  _subscription = null;
}
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Storing Credits in Local State Only

**Don't:** Track credits only in memory or SharedPreferences  
**Why:** User loses credits if they reinstall app or switch devices  
**Instead:** Always persist to Supabase with auth.uid() as key

### Anti-Pattern 2: Race Condition in Credit Consumption

**Don't:** Check credits in UI, then consume in separate call  
```dart
// BAD
if (credits.available > 0) {  // Time-of-check
  await consumeCredit();      // Time-of-use (might fail!)
  await createExport();
}
```
**Instead:** Use database transaction or atomic operation  
```dart
// GOOD: Single RPC or transaction
await _client.rpc('consume_credit_and_create_export', 
  params: {'user_id': userId, 'project_id': projectId});
```

### Anti-Pattern 3: Blocking UI on Purchase

**Don't:** Show blocking loading indicator during purchase  
**Why:** Purchase flow goes to App Store, may take time  
**Instead:** Show non-blocking state, update on completion

### Anti-Pattern 4: Hard-Coding Credit Amounts

**Don't:** Assume 1 purchase = 1 credit  
**Instead:** Make credit amount configurable (e.g., "5-pack" vs "10-pack")

### Anti-Pattern 5: Missing RevenueCat Webhook Verification

**Don't:** Trust client-side purchase success alone  
**Why:** Purchase could be fraudulent or refunded  
**Instead:** For production apps, verify with server-side webhook  
**Note:** For MVP, client-side is acceptable with proper error handling

---

## Testing Considerations

### Unit Tests

1. **CreditsProvider**
   - Initial state has 0 credits
   - Add credits updates state
   - Consume credit reduces available
   - Cannot consume when 0 credits

2. **SupabaseExportService**
   - getUserCredits returns correct count
   - consumeCredit succeeds with available credits
   - consumeCredit fails when 0 credits

### Integration Tests

1. **Export Flow**
   - Pro user exports without credit check
   - Free user with credits exports successfully
   - Free user without credits sees purchase sheet
   - Purchase adds credits and allows export

2. **Account Deletion**
   - All projects deleted
   - All exports deleted
   - Credits record deleted
   - User signed out

---

## Files to Create/Modify

### New Files

| File | Purpose |
|------|---------|
| `lib/providers/credits_provider.dart` | Export credit state management |
| `lib/providers/stats_provider.dart` | User statistics |
| `supabase/migrations/20260207_add_user_credits.sql` | Database schema |
| `supabase/migrations/20260207_add_delete_user_account.sql` | Account deletion RPC |

### Modified Files

| File | Changes |
|------|---------|
| `lib/services/supabase_export_service.dart` | Add credit methods |
| `lib/screens/settings_screen.dart` | Add stats section |
| `lib/widgets/export_bottom_sheet.dart` | Check/consume credits |
| `lib/widgets/export_purchase_sheet.dart` | Add credits on purchase |

---

## Sources

- Context7: RevenueCat Purchases Flutter documentation (/revenuecat/purchases-flutter)
- Existing codebase: `lib/services/revenuecat_service.dart`
- Existing codebase: `lib/providers/entitlement_provider.dart`
- Existing codebase: `supabase/schema.sql`

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| RevenueCat Integration | HIGH | Existing implementation is solid, just adding consumable flow |
| Database Schema | HIGH | Follows existing patterns, simple table structure |
| Provider Pattern | HIGH | Mirrors existing entitlement_provider.dart exactly |
| Account Deletion | MEDIUM | RPC function needs testing, cascade behavior critical |
| Credit Consumption Race | MEDIUM | May need transaction/RPC for production, simple approach OK for MVP |

---

## Open Questions

1. **Credit Pack Sizes**: Should we support multiple pack sizes (1, 5, 10 credits) or just single?
2. **Credit Expiration**: Do credits ever expire?
3. **Credit Restoration**: If user restores purchases, should credits be restored? (Consumables typically aren't)
4. **Credit Transfer**: Should credits be tied to user account or device?
5. **Server-Side Verification**: Do we need webhook verification for purchases, or is client-side sufficient for MVP?
