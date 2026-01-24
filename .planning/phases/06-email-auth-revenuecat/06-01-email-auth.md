# Plan 06-01: Email Authentication with Supabase

## Goal
Implement email/password authentication using Supabase Auth, triggered lazily on first user action (New Project), and link authenticated user to RevenueCat.

## Current State
- No auth - app uses anonymous Supabase access
- RevenueCat has `logIn(userId)` and `logOut()` ready but unused
- Paywall checks `canCreateProjectProvider` but no user identity
- Projects stored in Supabase but not user-scoped

## Target State
- Users prompted to sign in/up on first "New Project" tap
- Supabase Auth handles email/password
- User ID passed to RevenueCat to link purchases
- Projects scoped to authenticated user
- Existing anonymous projects: prompt to claim on first auth

## Implementation

### Step 1: Create Auth Service
**File:** `lib/services/auth_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;
  
  AuthService(this._client);
  
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  Future<AuthResponse> signUp({required String email, required String password}) async {
    return await _client.auth.signUp(email: email, password: password);
  }
  
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
```

### Step 2: Create Auth Provider
**File:** `lib/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session?.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
```

### Step 3: Create Auth Screen
**File:** `lib/screens/auth_screen.dart`

Simple email/password form with:
- Toggle between Sign In / Sign Up
- Email field with validation
- Password field (min 6 chars)
- Submit button
- "Forgot password?" link
- Error display
- Loading state

### Step 4: Make RevenueCat a Provider
**Modify:** `lib/providers/revenuecat_provider.dart` (new file)

```dart
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});
```

**Modify:** `lib/main.dart`
- Remove local RevenueCatService instantiation
- Initialize via provider after Supabase init

### Step 5: Link Auth to RevenueCat
**Modify:** `lib/main.dart` or create `lib/services/auth_revenuecat_bridge.dart`

Listen to auth state changes:
- On sign in: call `revenueCat.logIn(user.id)`
- On sign out: call `revenueCat.logOut()`

### Step 6: Gate New Project on Auth
**Modify:** `lib/screens/project_screen.dart`

In `_pickAndCreateProject()`:
```dart
// Before paywall check, ensure authenticated
final isAuthenticated = ref.read(isAuthenticatedProvider);
if (!isAuthenticated) {
  final result = await Navigator.push(context, MaterialPageRoute(
    builder: (_) => const AuthScreen(),
  ));
  if (result != true) return; // User cancelled
}

// Then existing paywall check
final canCreate = await ref.read(canCreateProjectProvider.future);
// ...
```

### Step 7: Scope Projects to User
**Modify:** `lib/services/supabase_project_service.dart`

- Add `user_id` filter to queries
- Set `user_id` on project creation
- Handle migration of anonymous projects (optional v2)

## Database Migration
```sql
-- Add user_id column to projects table
ALTER TABLE projects ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- RLS policy: users can only see their own projects
CREATE POLICY "Users can view own projects" ON projects
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects" ON projects
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects" ON projects
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects" ON projects
  FOR DELETE USING (auth.uid() = user_id);
```

## Files to Create
- `lib/services/auth_service.dart`
- `lib/providers/auth_provider.dart`
- `lib/providers/revenuecat_provider.dart`
- `lib/screens/auth_screen.dart`

## Files to Modify
- `lib/main.dart` - Auth-RevenueCat bridge
- `lib/screens/project_screen.dart` - Auth gate on FAB
- `lib/services/supabase_project_service.dart` - User scoping

## Testing
1. Fresh install → tap New Project → auth screen appears
2. Sign up → returns to project screen → can create project
3. Kill app → reopen → still authenticated
4. Sign out → projects hidden → sign in → projects return
5. Purchase subscription → sign out → sign in on new device → subscription restored

## Success Criteria
- [ ] Auth screen shows on first New Project tap
- [ ] Sign up/in works with email/password
- [ ] RevenueCat receives user ID on auth
- [ ] Projects scoped to user
- [ ] Subscription persists across devices via RevenueCat user ID
