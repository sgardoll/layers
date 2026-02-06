# Technology Stack Additions

**Project:** Layers - v1.3 Monetization & Settings  
**Milestone:** Per-export consumable IAP and enhanced settings  
**Researched:** 2026-02-07  
**Confidence:** HIGH

---

## Summary

For v1.3, no new dependencies are required. The existing stack already supports all new features:

| Feature | Current Stack Status | Action Required |
|---------|---------------------|-----------------|
| Per-export consumable IAP | RevenueCat configured, methods exist | Configure offering in dashboard |
| Export credit tracking | Supabase PostgreSQL ready | Add table migration |
| Delete account cleanup | Supabase RPC needed | Create database function |
| Enhanced settings | Flutter + Riverpod ready | Build UI components |

---

## Recommended Stack (No New Dependencies)

### Core Framework - NO CHANGES

| Technology | Current | Purpose | Status |
|------------|---------|---------|--------|
| purchases_flutter | ^9.10.7 (latest: 9.11.0) | IAP subscriptions + consumables | Ready for consumables |
| supabase_flutter | ^2.x | Auth, Database, Storage | User deletion via RPC |
| flutter_riverpod | ^2.x | State management | Already manages entitlement state |
| url_launcher | Existing | External links | Manage subscription URLs |

### Stack Decision Rationale

**RevenueCat for consumables (not in_app_purchase):**

The project already uses RevenueCat for subscriptions. RevenueCat supports consumables through the same `Purchases.purchase()` API used for subscriptions. Context7 docs confirm (HIGH confidence):

> "Non-consumables are products that are meant to be bought only once, for example, lifetime subscriptions... If they're incorrectly configured as consumables, RevenueCat will consume these purchases."  
> — Context7: RevenueCat Purchases Flutter

The existing `RevenueCatService` already implements `getExportPackage()` and `purchaseExportCredit()` methods. The pattern for consumables is:

```dart
// Same API as subscriptions - RevenueCat handles store differences
final result = await Purchases.purchase(PurchaseParams.package(package));
// For consumables: success = purchase went through, no entitlement check needed
```

**Why NOT add `in_app_purchase` package:**
- Adds complexity of managing two IAP SDKs
- RevenueCat already abstracts App Store / Google Play differences
- Would lose unified customer view (subscriptions + consumables in one place)
- Would require separate receipt validation logic

**Why NOT upgrade purchases_flutter to 9.11.0:**
- 9.10.7 to 9.11.0 is a patch release with no breaking changes
- Current version fully supports consumables
- Upgrade optional, not required for this milestone

---

## Database Changes Required

### New Table: Export Credits Tracking

```sql
-- Track export credits per user
CREATE TABLE IF NOT EXISTS export_credits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Credit tracking
  credits_remaining INTEGER NOT NULL DEFAULT 0,
  credits_purchased_total INTEGER NOT NULL DEFAULT 0,
  credits_used_total INTEGER NOT NULL DEFAULT 0,
  
  -- Last purchase reference (for debugging)
  last_purchase_transaction_id TEXT,
  last_purchase_date TIMESTAMPTZ,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast user lookup
CREATE INDEX IF NOT EXISTS idx_export_credits_user_id ON export_credits(user_id);

-- RLS: Users can only see/update their own credits
ALTER TABLE export_credits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own credits" ON export_credits
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own credits" ON export_credits
  FOR UPDATE USING (auth.uid() = user_id);

-- Only service role can insert (after RevenueCat webhook verification)
CREATE POLICY "Service role can insert credits" ON export_credits
  FOR INSERT WITH CHECK (false); -- Insert via service_role only
```

**Why track credits in database:**
- RevenueCat handles purchase validation but doesn't persist consumable counts
- Client-side storage is insecure (could be tampered with)
- Database = single source of truth for credit balance
- Enables usage analytics (credits purchased vs used)

### RPC Function: Delete User Account

```sql
-- Complete user deletion with cascading cleanup
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Get the authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Delete user's projects (cascades to project_layers, exports via FK)
  DELETE FROM public.projects WHERE user_id = v_user_id;
  
  -- Delete user's export credits record
  DELETE FROM public.export_credits WHERE user_id = v_user_id;
  
  -- Delete user storage files (requires service_role - may need Edge Function)
  -- Storage cleanup is best handled async via Edge Function or webhook
  
  -- Delete from auth.users (requires admin privileges)
  -- This must be done via Supabase Admin API or service_role
  -- DELETE FROM auth.users WHERE id = v_user_id; -- Won't work from client
  
  -- Mark for deletion instead (have Edge Function clean up)
  -- Or call auth.admin.deleteUser() via Edge Function
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
```

**Important:** Deleting from `auth.users` requires admin/service_role privileges. Options:

1. **Edge Function approach (RECOMMENDED):**
   - Create Supabase Edge Function `delete-user` with service_role
   - Function deletes all user data + calls `auth.admin.deleteUser()`
   - App calls this function instead of RPC

2. **Database trigger + cleanup job:**
   - Mark user for deletion in a `deleted_users` table
   - Scheduled Edge Function cleans up marked users

3. **RPC + manual auth cleanup:**
   - RPC deletes app data
   - App signs out (doesn't delete auth user)
   - Admin manually cleans orphaned auth users later

**Recommendation:** Option 1 (Edge Function) is cleanest and handles full deletion.

---

## Integration Points

### RevenueCat ↔ Supabase Integration

**Webhook flow for consumable credits:**

```
User purchases export credit
    ↓
RevenueCat processes payment
    ↓
RevenueCat sends webhook to BuildShip/Edge Function
    ↓
Server verifies purchase with RevenueCat API
    ↓
Server increments user's credits in Supabase (export_credits table)
    ↓
App polls/refreshes credit balance
```

**Why webhook approach:**
- Purchase confirmation from server = secure
- Prevents client-side credit manipulation
- RevenueCat webhooks include receipt validation

**Alternative (simpler, less secure):**
- App calls `purchaseExportCredit()`
- On success, app calls Supabase to increment credits
- Race condition risk: user could replay the success callback

**Recommendation:** Implement webhook for production, simple callback for MVP with rate limiting.

### Settings Screen Data Sources

| Setting | Source | API |
|---------|--------|-----|
| User email | Supabase Auth | `supabase.auth.currentUser?.email` |
| Sign-up date | RevenueCat CustomerInfo | `customerInfo.firstSeen` |
| Subscription status | RevenueCat Entitlements | `customerInfo.entitlements.all['Layers Pro']?.isActive` |
| Subscription expiration | RevenueCat | `entitlement.expirationDate` |
| Export credits balance | Supabase | `supabase.from('export_credits').select()` |
| Projects count | Supabase | `supabase.from('projects').count()` |
| Total exports | Supabase | `supabase.from('exports').count()` |

---

## What NOT to Add

| Technology | Why Not | What to Use Instead |
|------------|---------|---------------------|
| `in_app_purchase` package | Duplicates RevenueCat functionality | Continue with `purchases_flutter` |
| `purchases_ui_flutter` | Adds paywall UI dependency, not needed for settings | Build custom settings UI |
| Local storage (Hive/SharedPrefs) for credits | Insecure, easily tampered | PostgreSQL with RLS |
| Custom receipt validation | RevenueCat handles this | Trust RevenueCat validation |
| Firebase Auth | Already using Supabase Auth | Continue with Supabase |
| Stripe SDK | App stores require native IAP for digital goods | RevenueCat consumables |

---

## Migration Notes

### For Existing Users

Current schema has `projects.user_id` with `ON DELETE SET NULL`. This means:
- Deleting a user orphans their projects (user_id becomes NULL)
- Orphaned projects become "anonymous" and visible to all users

**Fix before v1.3 release:**
```sql
-- Change to cascade delete for proper cleanup
ALTER TABLE projects 
  DROP CONSTRAINT projects_user_id_fkey,
  ADD CONSTRAINT projects_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) 
    ON DELETE CASCADE;
```

### Credit Initialization

Existing Pro subscribers should get free credits on first use:
```dart
// When checking credits, if no record exists for Pro user:
if (userIsPro && creditsRecord == null) {
  // Grant initial free credits as loyalty bonus
  await createCreditsRecord(initialCredits: 3);
}
```

---

## Testing Strategy

### RevenueCat Sandbox
- Use sandbox environment for testing purchases
- Consumables can be purchased multiple times in sandbox
- No real charges applied

### Supabase Local Dev
- Use `supabase start` for local testing
- Test RPC functions with `supabase db test`
- Verify RLS policies with different user roles

### Delete Account Testing
1. Create test user
2. Add test projects and exports
3. Trigger delete
4. Verify:
   - Projects deleted (or orphaned if SET NULL)
   - Storage files removed
   - Auth user deleted (via admin check)
   - Cannot sign in again with same credentials

---

## Sources

| Source | Confidence | Used For |
|--------|------------|----------|
| Context7: purchases_flutter | HIGH | Consumable purchase API patterns |
| Context7: supabase-flutter | HIGH | Auth and database operations |
| GitHub: RevenueCat/purchases-flutter | HIGH | Version verification |
| Supabase Official Docs | MEDIUM | User management patterns |
| Existing codebase analysis | HIGH | Current implementation patterns |

---

## Roadmap Implications

**Phase ordering:**
1. **Database setup** - Create `export_credits` table and RPC function
2. **RevenueCat configuration** - Set up consumable offering in dashboard
3. **Purchase flow** - Connect UI to existing `purchaseExportCredit()` method
4. **Settings enhancement** - Add user stats and subscription details
5. **Delete account** - Implement Edge Function for full cleanup

**No blockers identified.** All technologies are already in place and production-tested.
