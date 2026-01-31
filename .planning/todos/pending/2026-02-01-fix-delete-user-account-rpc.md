---
created: 2026-02-01T14:30
title: Fix missing delete_user_account RPC function
area: database
files:
  - lib/services/auth_service.dart
  - lib/screens/settings_screen.dart
---

## Problem

The Supabase RPC function `public.delete_user_account` is not defined in the database schema. When attempting to delete a user account from the app, the following error occurs:

```
PostgrestException(
  message: Could not find the function public.delete_user_account without parameters in the schema cache,
  code: PGRST202,
  details: Searched for the function public.delete_user_account without parameters or with a single unnamed json/jsonb parameter,
  but no matches were found in the schema cache.
  hint: null
)
```

After the RPC failure, the app signs out the user locally with `SignOutScope.local` but the user record remains in Supabase auth.

## Solution

**Option A: Create the RPC function in Supabase**
Add a PostgreSQL function to handle complete user deletion:
- Delete user data from `projects` table (cascade should handle `project_layers`)
- Delete user data from `exports` table
- Delete user from `auth.users` table
- Clean up any storage files

**Option B: Use Supabase Admin API**
Instead of RPC, use a server-side endpoint (BuildShip workflow) with service role key to delete the user.

**Option C: Row-level cleanup**
Mark user as deleted via database trigger and have BuildShip clean up asynchronously.

## Context

This was discovered during UAT testing of the auth guard fix. The app expects to call `delete_user_account()` RPC but it doesn't exist in the current Supabase schema. This is a gap from Phase 10 (Account Delete Cleanup) which may have been planned but not fully implemented.

## Related

- Phase 10: Account Delete Cleanup (marked complete but may have gaps)
- RevenueCat user linking may need cleanup too when account is deleted
