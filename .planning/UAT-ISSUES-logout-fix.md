# UAT Issues: Logout State Persistence Fix

**Tested:** 2026-02-03  
**Severity:** 🔴 **CRITICAL - Revenue/Billing Impact**  
**Status:** ✅ **FIX APPLIED - AWAITING VERIFICATION**  

**Initial Fix Applied:** Reset entitlement state on logout  
**Comprehensive Fix Applied:** 2026-02-03  

**Files Changed:**
- `lib/screens/settings_screen.dart` - Reordered sign-out flow + added provider invalidation
- `lib/providers/entitlement_provider.dart` - Added linkedRevenueCatServiceProvider for user scoping
- `lib/providers/project_provider.dart` - Added reset() method (previously applied)
- `lib/providers/layer_provider.dart` - Added reset() method (previously applied)

---

## 🔴 CRITICAL ISSUES (DISCOVERED)

### UAT-001: Pro subscription persists after logout (REVENUE IMPACT)

**Discovered:** 2026-02-03 during UAT  
**Severity:** 🔴 **CRITICAL**  
**Feature:** Subscription / RevenueCat Integration  
**Status:** 🔧 **FIX APPLIED - NEEDS RETEST**

**Description:**  
After user signs out, Settings screen still displays "Subscription - Pro" status. This indicates RevenueCat entitlement state is NOT being properly cleared.

**Root Cause Identified:**  
1. `revenueCatServiceProvider` is a singleton that persists across the app lifecycle
2. `Purchases.logOut()` doesn't immediately clear the customer info cache
3. When a new user signs in, RevenueCat still returns the previous user's cached entitlements
4. The `entitlementProvider` wasn't properly re-initializing when the user changed

**Fix Applied:**  
1. Added `linkedRevenueCatServiceProvider` that watches `currentUserProvider` and calls `Purchases.logIn(userId)` to properly link RevenueCat to each user
2. Updated `entitlementProvider` to watch the linked service so it re-initializes when user changes
3. Added explicit `ref.invalidate()` calls for all user-scoped providers after logout
4. Reordered sign-out operations: reset local state → RevenueCat logout → auth signout → invalidate providers

---

### UAT-002: User projects persist after logout across all tabs (PRIVACY ISSUE)

**Discovered:** 2026-02-03 during UAT  
**Severity:** 🔴 **CRITICAL**  
**Feature:** Project Data / Privacy  
**Status:** 🔧 **FIX APPLIED - NEEDS RETEST**

**Description:**  
Logged-out user's projects remain visible in Projects tab and Exports tab. This is a privacy issue as device could be passed to another user.

**Root Cause Identified:**  
1. `ref.invalidate()` was not being called on providers, so they retained old state
2. Provider reset methods were called but didn't trigger UI rebuilds properly
3. The order of operations was wrong: auth signout happened before state reset, causing widget disposal issues

**Fix Applied:**  
1. Added `ref.invalidate()` calls for `projectListProvider`, `layerProvider`, `currentProjectProvider`, and `entitlementProvider` after logout
2. Reordered operations: reset local state first, then RevenueCat logout, then auth signout, then invalidate
3. This ensures providers are completely recreated with fresh state on next login

---

### UAT-003: NEW USERS INCORRECTLY GET PRO STATUS (BILLING FRAUD RISK)

**Discovered:** 2026-02-03 during UAT  
**Severity:** 🔴 **CRITICAL - BILLING FRAUD**  
**Feature:** RevenueCat / User Onboarding  
**Status:** 🔧 **FIX APPLIED - NEEDS RETEST**

**Description:**  
If a Pro user logs out and a new user signs up on the same device, the new user is automatically granted Pro subscription status. This is a **billing and security issue**.

**Root Cause Identified:**  
1. RevenueCat SDK caches customer info and doesn't automatically clear it on `logOut()`
2. When a new user signs up, if we don't explicitly call `Purchases.logIn(newUserId)`, RevenueCat returns the cached entitlements from the previous user
3. The entitlement provider wasn't scoped to the user - it used a singleton service

**Fix Applied:**  
1. Created `linkedRevenueCatServiceProvider` that:
   - Watches `currentUserProvider` for auth state changes
   - Calls `Purchases.logIn(user.id)` whenever a user is authenticated
   - This ensures each user gets their own RevenueCat customer info
2. Updated `entitlementProvider` to depend on `linkedRevenueCatServiceProvider` instead of the raw service
3. This ensures RevenueCat properly scopes entitlements to each user

**Business Impact if Not Fixed:**  
- Lost revenue from users getting free Pro access
- Cannot launch to App Store with this bug (violates subscription guidelines)
- Potential fraud if users share devices to get free Pro

---

## Test Results Summary

| Test | Initial Result | Fix Applied | Status |
|------|----------------|-------------|--------|
| Sign-out flow | ⚠️ PARTIAL | Reordered operations + added invalidation | 🔧 Needs retest |
| Pro status reset | ❌ **FAIL** | Added linkedRevenueCatServiceProvider | 🔧 Needs retest |
| Project data reset | ❌ **FAIL** | Added ref.invalidate() calls | 🔧 Needs retest |
| Exports data reset | ❌ **FAIL** | Added ref.invalidate() calls | 🔧 Needs retest |
| New user Pro grant | ❌ **FAIL** | RevenueCat logIn() on auth | 🔧 Needs retest |
| RevenueCat logOut | ❌ **FAIL** | Proper ordering + user linking | 🔧 Needs retest |

---

## 🔴 VERDICT

**Initial Status:** ❌❌❌ **FIX COMPLETELY FAILED**

**Current Status:** 🔧 **FIXES APPLIED - REQUIRES RETESTING**

Comprehensive fix applied addressing all three critical issues:

1. ✅ **RevenueCat user scoping** - Added `linkedRevenueCatServiceProvider` to ensure each user gets properly linked RevenueCat session
2. ✅ **Provider invalidation** - Added `ref.invalidate()` calls to force fresh provider state
3. ✅ **Operation ordering** - Fixed sequence: local reset → RevenueCat logout → auth signout → invalidation

**⚠️ CRITICAL: Must be retested before any App Store release**

---

## Technical Changes Made

### 1. lib/providers/entitlement_provider.dart

**Added:**
```dart
/// Provider that links RevenueCat to the current authenticated user
/// This ensures RevenueCat customer info is properly scoped to the user
final linkedRevenueCatServiceProvider = FutureProvider<RevenueCatService>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user != null) {
    // Link this RevenueCat session to the authenticated user
    await service.logIn(user.id);
    debugPrint('RevenueCat: Linked to user ${user.id}');
  }
  
  return service;
});
```

**Updated:** `entitlementProvider` now watches `linkedRevenueCatServiceProvider` instead of raw service

### 2. lib/screens/settings_screen.dart

**Reordered sign-out operations:**
```dart
// BEFORE (broken):
await ref.read(authStateProvider.notifier).signOut();
await ref.read(revenueCatServiceProvider).logOut();
ref.read(entitlementProvider.notifier).reset();
// ... other resets

// AFTER (fixed):
// 1. Reset local state first
ref.read(projectListProvider.notifier).reset();
ref.read(layerProvider.notifier).reset();
ref.read(currentProjectProvider.notifier).state = null;
ref.read(entitlementProvider.notifier).reset();

// 2. RevenueCat logout
await ref.read(revenueCatServiceProvider).logOut();

// 3. Auth signout (triggers navigation)
await ref.read(authStateProvider.notifier).signOut();

// 4. Invalidate providers to force fresh state
ref.invalidate(entitlementProvider);
ref.invalidate(projectListProvider);
ref.invalidate(layerProvider);
ref.invalidate(currentProjectProvider);
```

---

## Retest Instructions

### Critical Test: New User Pro Inheritance
1. Log in with User A (Pro subscriber)
2. Confirm Settings shows "Pro"
3. Sign out
4. Create User B (new account) on same device
5. Log in with User B
6. **VERIFY:** Settings should show "Free" (not Pro)

### Test: State Reset After Logout
1. Log in with user who has projects
2. Navigate to Projects tab (confirm projects visible)
3. Go to Settings → Sign Out
4. Navigate back to Projects tab
5. **VERIFY:** Should show empty state or login prompt
6. Navigate to Exports tab
7. **VERIFY:** Should show empty state

### Test: Pro Status After Logout
1. Log in with Pro user
2. Settings shows "Pro"
3. Sign out
4. Stay on or navigate to Settings
5. **VERIFY:** Should NOT show "Pro" (should show "Free" or loading)

---

## Related Files

- `lib/screens/settings_screen.dart` - Sign out and delete account handlers
- `lib/providers/auth_provider.dart` - Auth state management
- `lib/providers/entitlement_provider.dart` - Pro status management + RevenueCat linking
- `lib/providers/project_provider.dart` - Project list state
- `lib/providers/layer_provider.dart` - Layer state
- `lib/services/revenuecat_service.dart` - RevenueCat integration

---

## Next Steps

1. 🔥 **RETEST IMMEDIATELY** - Run all three critical test scenarios above
2. If tests pass: ✅ Clear for App Store submission
3. If tests fail: 🐛 Debug further and apply additional fixes

---

*Created: 2026-02-03*  
*Last Updated: 2026-02-03 (fixes applied)*  
*Test Session: UAT for logout state persistence fix - AWAITING RETEST*
