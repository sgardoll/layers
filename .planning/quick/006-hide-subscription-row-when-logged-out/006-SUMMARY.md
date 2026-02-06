# Quick Task 006 Summary

## Task
Hide subscription row when user is not logged in.

## Changes Made
**File:** `lib/screens/settings_screen.dart`

Wrapped the `_SubscriptionSection` and its divider in a conditional check:
```dart
// Subscription Section
if (user != null) ...[
  _SubscriptionSection(
    isPro: entitlement.isPro,
    isLoading: entitlement.isLoading,
  ),
  const Divider(height: 1),
],
```

This follows the same pattern used for `_UserInfoSection` and `_AccountActionsSection`.

## Verification
- [x] Code compiles without errors (LSP diagnostics passed)
- [x] Subscription section is inside the conditional block
- [x] Divider is included in the conditional (not orphaned when hidden)

## Behavior
- When user is logged out (`user == null`): Subscription row is NOT shown
- When user is logged in (`user != null`): Subscription row IS shown with Pro/Free status
