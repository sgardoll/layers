# Pitfalls Research: v1.3 Monetization & Settings

**Domain:** Flutter app with RevenueCat IAP + Supabase, adding consumables and account deletion  
**Researched:** 2026-02-06  
**Confidence:** HIGH (based on official docs, community issues, and actual UAT findings from project)

---

## Critical Pitfalls

### Pitfall 1: Consumable Repurchase Blocking (Android)

**What goes wrong:**  
Users cannot repurchase consumable products on Android after the first purchase. The SDK returns error: `Ignoring purchase request for already subscribed package` even though consumables should allow multiple purchases.

**Why it happens:**  
- RevenueCat SDK consumes all Android purchases by default  
- Google Play Billing requires explicit consumption of consumables before they can be repurchased  
- RevenueCat Paywalls had a bug (fixed Jan 2025) that blocked consumable repurchases  
- Product may not be marked as "Multi-quantity" in Google Play Console

**How to avoid:**
1. Ensure product is configured as CONSUMABLE (not subscription) in RevenueCat dashboard
2. Verify "Multi-quantity" is checked in Google Play Console (though this may not be the root cause)
3. Use custom paywall for consumables instead of RevenueCat Paywalls if issues persist
4. Test repurchase flow extensively on Android physical devices (not just emulator)
5. Handle the specific error and show user-friendly message: "You have an unconsumed purchase. Please contact support."

**Warning signs:**
- First consumable purchase works, subsequent ones fail  
- Error mentions "already subscribed" for a non-subscription product  
- Issue only affects Android (iOS works fine)

**Phase to address:** Phase 16 (Per-Export Pricing) - Implementation and testing

**Sources:**
- RevenueCat Community: https://community.revenuecat.com/sdks-51/ignoring-purchase-request-for-already-subscribed-package-error-when-trying-to-repurchase-a-consumable-4442
- GitHub fix: https://github.com/RevenueCat/purchases-android/pull/2044 (Jan 2025)

---

### Pitfall 2: Stale CustomerInfo Cache Leading to Double-Purchase Prompts

**What goes wrong:**  
Users who already purchased Pro subscription are still prompted to pay for exports because `getCustomerInfo()` returns stale cached data showing no active entitlements.

**Why it happens:**  
- RevenueCat SDK caches CustomerInfo aggressively (performance optimization)  
- Listeners don't always fire on subscription status changes  
- Fetch policies (`FETCH_CURRENT`, `CACHED_OR_FETCHED`) don't guarantee fresh data  
- Network issues can cause cache to be used even when explicitly requesting fresh data

**How to avoid:**
1. Always use `getCustomerInfo()` with `CacheFetchPolicy.FETCH_CURRENT` before gating features
2. Implement listener (`addCustomerInfoUpdateListener`) AND periodic refresh (e.g., on app foreground)
3. Add local persistence of Pro status with timestamp, refresh if > 5 minutes old
4. Implement server-side entitlement verification for critical operations (webhook to Supabase)
5. Show loading state while verifying entitlement instead of immediate paywall

```dart
// Anti-pattern: Direct cache check
final customerInfo = await Purchases.getCustomerInfo();  // May be stale!

// Better: Force fresh fetch with fallback
CustomerInfo? customerInfo;
try {
  customerInfo = await Purchases.getCustomerInfo(
    fetchPolicy: CacheFetchPolicy.fetchCurrent,
  );
} catch (e) {
  // Use cached as fallback
  customerInfo = await Purchases.getCustomerInfo();
}
```

**Warning signs:**
- Users report being charged twice or prompted after purchase  
- Entitlement status inconsistent between app restarts  
- `getCustomerInfo()` returns different results on successive calls

**Phase to address:** Phase 16 (Per-Export Pricing) - Core service methods

**Sources:**
- GitHub Issue #863: https://github.com/RevenueCat/purchases-flutter/issues/863
- RevenueCat Community: https://community.revenuecat.com/sdks-51/purchases-getcustomerinfo-returns-incorrect-cached-value-no-matter-what-fetch-policy-i-try-4452

---

### Pitfall 3: Unconsumed Purchase Queue Blocking New Purchases

**What goes wrong:**  
If a consumable purchase completes but isn't "consumed" (acknowledged as delivered), Google Play blocks all future purchases of that product. The purchase is stuck in a pending state.

**Why it happens:**  
- Purchase succeeds but app crashes or network fails before credits are delivered  
- User kills app mid-transaction  
- Server-side credit update fails but purchase succeeds  
- Google Play Billing requires explicit consumption for consumables

**How to avoid:**
1. **Idempotent credit delivery:** Track purchase transaction ID in Supabase, don't grant credits twice for same transaction
2. **Queue inspection on startup:** Check for pending purchases using `Purchases.syncPurchases()` or `getCustomerInfo()`
3. **Deliver-before-consume pattern:** 
   - Purchase succeeds → Record transaction ID → Grant credits → Mark consumed
   - If any step fails, retry on next app launch
4. **Server-side validation:** Webhook from RevenueCat to Supabase confirms purchase before granting credits
5. **Transaction log table:** Track all purchases with status (pending, granted, failed)

```dart
// Transaction tracking schema (Supabase)
create table purchase_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade,
  revenuecat_transaction_id text unique not null,
  product_id text not null,
  credits_granted integer not null,
  status text check (status in ('pending', 'granted', 'failed')),
  created_at timestamptz default now(),
  granted_at timestamptz
);
```

**Warning signs:**
- Purchase fails with "Item already owned" or "Already subscribed"  
- User reports paying but not receiving credits  
- Purchase shows in Google Play order history but not in app

**Phase to address:** Phase 16 (Per-Export Pricing) - Credit tracking system

**Sources:**
- Google Play Billing docs: https://developer.android.com/google/play/billing/integrate
- RevenueCat Community: https://community.revenuecat.com/sdks-51/consumables-iaps-5272

---

### Pitfall 4: Account Deletion Cascade Missing Storage Cleanup

**What goes wrong:**  
Deleting a user from `auth.users` cascades to database rows via foreign keys, but leaves orphaned files in Supabase Storage buckets. These files consume storage costs indefinitely with no way to clean them up.

**Why it happens:**  
- Supabase Storage is NOT linked to auth.users via foreign key  
- `ON DELETE CASCADE` only works within the database, not external storage  
- Storage.objects table has no referential integrity to auth schema  
- Files have their own ownership metadata separate from RLS policies

**How to avoid:**
1. **Track file ownership:** Store `owner_id` in a database table (e.g., `user_files`) with foreign key to `auth.users`
2. **Database trigger for storage cleanup:** Use `pg_net` extension or Supabase Edge Function to delete files after user deletion
3. **Pre-deletion cleanup:** Before calling `auth.admin.deleteUser()`, manually delete all user files:
   ```dart
   // 1. Query all user files from database
   // 2. Delete from storage: supabase.storage.from('layers').remove(paths)
   // 3. Delete database records
   // 4. Delete user from auth
   ```
4. **Mark-and-sweep pattern:** Soft-delete user, queue cleanup job, hard-delete after verification

**Warning signs:**
- Storage usage grows over time despite user count decreasing  
- Cannot trace storage files to active users  
- GDPR/data retention compliance issues

**Phase to address:** Phase 10 (Account Delete Cleanup) - Database functions and RPC

**Sources:**
- Hacker News discussion: https://news.ycombinator.com/item?id=40093168
- Supabase GitHub: https://github.com/supabase/storage-api/issues/276
- Supabase File Helper: https://github.com/GaryAustin1/supa-file-helper

---

### Pitfall 5: RevenueCat-Supabase User Linking Orphaning

**What goes wrong:**  
When a user deletes their account and later recreates with same email, RevenueCat may link new account to old purchase history, or new user may see old user's entitlements.

**Why it happens:**  
- RevenueCat identifies users by `appUserID` (typically Supabase `user.id`)  
- If same user ID is reused or device has cached RevenueCat ID, purchases may be linked incorrectly  
- `Purchases.logOut()` doesn't fully clear customer info from device  
- Anonymous IDs can cause confusion between users

**How to avoid:**
1. **Always call `logOut()` before account deletion:**
   ```dart
   await Purchases.logOut();  // Clears association
   ```
2. **Call `logIn()` with new user ID on account creation:**
   ```dart
   await Purchases.logIn(newUserId);
   ```
3. **RevenueCat customer cleanup:** Use RevenueCat REST API to delete customer data when user deletes account (requires server-side call with API key)
4. **Device wipe on logout:** Clear any local purchase caches or state

**Warning signs:**
- New user sees "Restore Purchases" option they shouldn't have  
- Subscription status incorrect for new accounts  
- RevenueCat dashboard shows unexpected user ID mappings

**Phase to address:** Phase 10 (Account Delete Cleanup) - Auth service integration

**Sources:**
- RevenueCat Docs: https://www.revenuecat.com/docs/customers/user-ids
- RevenueCat Community: https://community.revenuecat.com/sdks-51/syncpurchases-non-consumable-iaps-1830

---

### Pitfall 6: RPC Function Security for Account Deletion

**What goes wrong:**  
Account deletion RPC function is vulnerable to privilege escalation, allowing users to delete other users' accounts or bypass Row Level Security.

**Why it happens:**  
- RPC functions execute with user's privileges by default  
- `auth.uid()` check can be bypassed if function doesn't validate properly  
- Service role key accidentally exposed in client-side code  
- Missing authorization checks before executing destructive operations

**How to avoid:**
1. **Always verify `auth.uid()` matches target user:**
   ```sql
   create or replace function delete_user_account()
   returns void
   language plpgsql
   security definer  -- Runs as function owner
   as $$
   declare
     target_user_id uuid;
   begin
     -- Get authenticated user ID
     target_user_id := auth.uid();
     
     -- Security: Verify user is authenticated
     if target_user_id is null then
       raise exception 'Not authenticated';
     end if;
     
     -- Delete user data (cascade handles related tables)
     delete from public.projects where user_id = target_user_id;
     delete from public.exports where user_id = target_user_id;
     
     -- Delete from auth (requires admin privileges - see alternative below)
   end;
   $$;
   ```
2. **Use Edge Function for admin operations:** 
   - Client calls Edge Function with user JWT
   - Edge Function validates JWT
   - Edge Function uses service role key to delete user
3. **Never expose service role key in client:** Only use in Edge Functions or server environments
4. **Audit logging:** Log all deletion attempts with user ID, timestamp, IP

**Warning signs:**
- Users report account deleted without their action  
- Database logs show deletions from unexpected user IDs  
- Can delete other users' data by manipulating RPC params

**Phase to address:** Phase 10 (Account Delete Cleanup) - RPC security review

**Sources:**
- Supabase Security Best Practices: https://www.pentestly.io/blog/supabase-security-best-practices-2025-guide
- Supabase Docs: https://supabase.com/docs/guides/functions/auth

---

### Pitfall 7: Sandbox Testing Silent Failures (iOS)

**What goes wrong:**  
During development/testing, iOS sandbox purchases appear to succeed but silently fail or get stuck, making it impossible to test the purchase flow.

**Why it happens:**  
- Non-sandbox Apple ID on development build  
- Consumable product not fully configured in App Store Connect (missing metadata, screenshots)  
- Sandbox tester account not properly set up  
- RevenueCat SDK not initialized with correct API key for sandbox environment

**How to avoid:**
1. **Use proper sandbox tester accounts:**
   - Create in App Store Connect → Users and Access → Sandbox Testers
   - Use separate Apple ID (not your production Apple ID)
   - Sign out of production Apple ID in device Settings before testing
2. **Verify product configuration:**
   - Product status: "Ready to Submit" (not "Missing Metadata")
   - Price tier set
   - At least one screenshot uploaded
3. **Add debug bypass flag for development:**
   ```dart
   // In export_bottom_sheet.dart
   bool _debugSkipPaymentGate = false;  // Set true for dev testing
   
   if (kDebugMode && _debugSkipPaymentGate) {
     // Skip to export directly
   }
   ```
4. **Check RevenueCat logs:** Enable verbose logging to see exact failure reason

**Warning signs:**
- Purchase sheet shows then immediately dismisses  
- No error message shown to user  
- Works on Android but not iOS (or vice versa)  
- RevenueCat dashboard shows no purchase attempt

**Phase to address:** Phase 16 (Per-Export Pricing) - Testing and verification

**Sources:**
- Project UAT findings: `.planning/phases/16-per-export-pricing/16-ISSUES.md` (UAT-004)
- RevenueCat Troubleshooting: https://production-docs.revenuecat.com/docs/test-and-launch/debugging/troubleshooting-the-sdks

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skip transaction ID tracking for consumables | Faster implementation | Cannot verify purchases, double-grant credits, support nightmare | NEVER - always track transaction IDs |
| Client-side credit balance only | No server complexity | Credit sync issues across devices, easy to hack | Only for offline-first apps with no sync |
| Soft delete only (no actual deletion) | Safer recovery | GDPR violations, storage costs, data retention issues | Acceptable during MVP with plan to implement hard delete |
| No RevenueCat logout on account delete | Simpler auth flow | Orphaned customer records, purchase linking issues | NEVER - always logOut() |
| Use anon key for account deletion RPC | No Edge Function needed | Security vulnerability - users can delete other users | NEVER - use service role via Edge Function |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| RevenueCat + Supabase Auth | Using email as user ID (changes if user updates email) | Use Supabase `user.id` (UUID) as RevenueCat `appUserID` |
| RevenueCat Consumables | Not consuming purchases on Android | Always consume after granting credits, track transaction IDs |
| Supabase Storage + Account Deletion | Assuming CASCADE deletes files | Files are NOT deleted with CASCADE - must delete manually before user deletion |
| Supabase Auth Delete | Using `auth.admin.deleteUser()` client-side | Call Edge Function that uses service role key server-side |
| RevenueCat Customer Info | Caching entitlement status indefinitely | Refresh on app foreground and before critical operations |
| Export Credit Balance | Storing only in local state | Store in Supabase with user_id, sync on app start |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Synchronous storage deletion | Account deletion hangs UI | Queue deletions, use background job, show progress | > 50 files per user |
| No debounced purchase checks | Multiple rapid entitlement checks spam RevenueCat | Cache result for 5 minutes, use listener pattern | High-traffic screens |
| Full table scan on user cleanup | Deletion RPC times out | Add indexes on user_id columns, batch deletions | > 1000 projects per user |
| No pagination on export history | Slow settings screen load | Paginate exports query, limit to recent 20 | > 100 exports per user |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Client-side credit modification | User can hack to get unlimited credits | Credits stored in Supabase only, verified server-side |
| Missing RLS on credits table | Any user can read/modify any user's credits | Enable RLS, policy: `auth.uid() = user_id` |
| Exposing service role key in app | Full database access for attackers | Only use service role in Edge Functions |
| No transaction ID uniqueness | Replay attacks granting duplicate credits | Unique constraint on transaction_id in purchase_transactions table |
| Logging sensitive purchase data | PCI compliance issues, data leaks | Never log full receipts or tokens, only transaction IDs |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Immediate paywall on export | Users don't understand value proposition | Show preview of what they'll get, explain the $0.50 cost |
| No purchase progress indicator | User taps purchase, nothing happens for 2-3 seconds | Show loading spinner, disable button during purchase |
| Silent purchase failures | User thinks purchase succeeded but didn't | Always show success/error feedback, verify entitlement after |
| No restore purchases option | User reinstalls app, loses Pro status | Add "Restore Purchases" button in settings |
| No confirmation on account deletion | Accidental data loss | Require email confirmation, show countdown, explain consequences |
| "Delete Account" too accessible | Accidental taps | Place in settings submenu, require authentication confirmation |

---

## "Looks Done But Isn't" Checklist

- [ ] **Consumable purchase:** Transaction ID is being tracked to prevent double-grant — verify `purchase_transactions` table exists with unique constraint
- [ ] **Consumable purchase:** Credits are granted idempotently (same transaction ID can't grant twice) — test by simulating network failure mid-grant
- [ ] **Account deletion:** All user files deleted from storage buckets — verify by checking storage after deletion
- [ ] **Account deletion:** RevenueCat `logOut()` called before deletion — verify in auth service code
- [ ] **Account deletion:** Proper authorization (not just `auth.uid()` in client) — verify via Edge Function or `security definer` RPC
- [ ] **Entitlement checking:** CustomerInfo is refreshed on app foreground — verify listener is registered in main.dart
- [ ] **Restore purchases:** Button exists and works — test on fresh install with existing subscription
- [ ] **Purchase verification:** Server-side webhook or RPC validates purchase before granting credits — verify no client-side credit granting

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Double credit grant | MEDIUM | Deduct excess credits, add transaction log entry, notify user |
| Orphaned storage files | LOW (but ongoing cost) | Run cleanup script to find files with no matching user_id in database |
| Stuck pending purchase | LOW | Call `syncPurchases()` on app start, consume unconsumed purchases |
| RevenueCat user linking issue | MEDIUM | Use RevenueCat dashboard to transfer/merge customer records |
| Accidental account deletion | HIGH (if no backup) | Soft-delete pattern with 30-day grace period for recovery |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Consumable repurchase blocking | Phase 16 - Implementation | Test repurchase flow on Android physical device 3+ times |
| Stale CustomerInfo cache | Phase 16 - Core service | Unit test with mocked stale cache, verify force refresh works |
| Unconsumed purchase queue | Phase 16 - Credit tracking | Simulate app crash during purchase, verify recovery on restart |
| Storage cleanup orphaned files | Phase 10 - Account deletion | Create user with files, delete, verify storage bucket empty |
| RevenueCat user linking | Phase 10 - Auth integration | Delete account, create new with same email, verify no purchase history |
| RPC security | Phase 10 - Security review | Attempt to delete other user via modified RPC call, verify blocked |
| Sandbox testing failures | Phase 16 - Testing | Document sandbox tester account setup in README |

---

## Sources

- RevenueCat Community Issues: https://community.revenuecat.com/sdks-51/ignoring-purchase-request-for-already-subscribed-package-error-when-trying-to-repurchase-a-consumable-4442
- GitHub purchases-flutter #863: https://github.com/RevenueCat/purchases-flutter/issues/863 (stale CustomerInfo)
- Supabase Cascade Deletes Docs: https://supabase.com/docs/guides/database/postgres/cascade-deletes
- Supabase Storage Cascade Discussion: https://news.ycombinator.com/item?id=40093168
- Project UAT Findings: `.planning/phases/16-per-export-pricing/16-ISSUES.md`
- Google Play Billing Integration: https://developer.android.com/google/play/billing/integrate
- Supabase Security Best Practices 2025: https://www.pentestly.io/blog/supabase-security-best-practices-2025-guide
- RevenueCat Caching Documentation: https://production-docs.revenuecat.com/docs/test-and-launch/debugging/caching

---

*Pitfalls research for: v1.3 Monetization & Settings (Consumable IAPs + Account Deletion)*
*Researched: 2026-02-06*