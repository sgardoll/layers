---
phase: quick
plan: 006
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/screens/settings_screen.dart
autonomous: true

must_haves:
  truths:
    - "Subscription row is hidden when no user is logged in"
    - "Subscription row is visible when a user is logged in"
    - "No visible divider appears when subscription section is hidden"
  artifacts:
    - path: "lib/screens/settings_screen.dart"
      provides: "Conditional subscription section rendering"
  key_links:
    - from: "SettingsScreen"
      to: "currentUserProvider"
      via: "ref.watch"
      pattern: "if \(user != null\)"
---

<objective>
Hide the Subscription section in Settings screen when no user is logged in.

Purpose: Clean UX - showing subscription info to logged-out users is confusing and irrelevant
Output: Settings screen with subscription row conditionally rendered based on auth state
</objective>

<execution_context>
@.planning/templates/summary.md
</execution_context>

<context>
@lib/screens/settings_screen.dart
</context>

<tasks>

<task type="auto">
  <name>Wrap Subscription Section in User Conditional</name>
  <files>lib/screens/settings_screen.dart</files>
  <action>
    Modify the build method in `SettingsScreen` to conditionally show `_SubscriptionSection` only when a user is logged in.

    Current code (lines 33-38):
    ```dart
    // Subscription Section
    _SubscriptionSection(
      isPro: entitlement.isPro,
      isLoading: entitlement.isLoading,
    ),
    const Divider(height: 1),
    ```

    Change to:
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

    Note: The `user` variable is already available from `ref.watch(currentUserProvider)` at line 31. The `_UserInfoSection` above already uses this same pattern.
  </action>
  <verify>Run `flutter build appbundle --release --target-platform android-arm64` or check with `dart analyze lib/screens/settings_screen.dart`</verify>
  <done>Subscription section is wrapped in `if (user != null)` conditional, divider is included in the conditional block, code compiles without errors</done>
</task>

</tasks>

<verification>
- [ ] Code compiles without errors
- [ ] Subscription section is inside the conditional block
- [ ] Divider is included in the conditional (not orphaned when hidden)
</verification>

<success_criteria>
- Subscription row is hidden when user is logged out (user == null)
- Subscription row is visible when user is logged in (user != null)
- No orphaned dividers appear when section is hidden
</success_criteria>

<output>
After completion, update `NOW.md` queue to mark this task complete.
</output>
