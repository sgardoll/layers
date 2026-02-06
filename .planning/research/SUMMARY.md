# Research Summary: v1.3 Monetization & Settings

**Project:** Layers - AI Image Layer Extraction  
**Milestone:** v1.3 Per-Export Pricing & Enhanced Settings  
**Research Date:** 2026-02-07  
**Overall Confidence:** HIGH

---

## Executive Summary

The v1.3 milestone adds per-export consumable IAP ($0.50) as an alternative monetization option alongside existing Pro subscriptions, enhances the settings screen with usage statistics and account management, and implements full account deletion with data cleanup. Research confirms that no new dependencies are required—the existing stack of Flutter + Riverpod + Supabase + RevenueCat fully supports all planned features.

The key architectural insight is that RevenueCat's consumable purchase API uses the same `Purchases.purchase()` method already implemented for subscriptions, with the only difference being that consumables don't grant entitlements. The codebase already contains `purchaseExportCredit()` and `getExportPackage()` methods in `RevenueCatService`, indicating prior planning for this feature. The main implementation work involves creating a `user_credits` table for tracking, updating the export flow to check/consume credits, and building the enhanced settings UI.

Critical pitfalls identified include: (1) Android consumable repurchase blocking if products aren't configured correctly, (2) stale RevenueCat cache causing double-purchase prompts, (3) Supabase Storage files not being cleaned up by CASCADE deletes during account deletion, and (4) security vulnerabilities if account deletion RPC isn't properly secured with `security definer`. All of these are addressable with the patterns documented in the research.

---

## Key Findings by Dimension

### Stack (No New Dependencies Required)

| Feature | Current Status | Action Required |
|---------|---------------|-----------------|
| Per-export consumable IAP | RevenueCat configured, methods exist | Configure offering in dashboard |
| Export credit tracking | Supabase PostgreSQL ready | Add `user_credits` table migration |
| Delete account cleanup | Supabase RPC needed | Create Edge Function for full cleanup |
| Enhanced settings | Flutter + Riverpod ready | Build UI components |

**Key Decision:** Continue using `purchases_flutter` (already at 9.10.7) for consumables. Do NOT add `in_app_purchase` package—it would duplicate functionality and lose the unified customer view.

**Database Changes Required:**
- Create `user_credits` table with RLS policies
- Fix existing `projects.user_id` FK from `ON DELETE SET NULL` to `ON DELETE CASCADE`
- Create `delete_user_account()` RPC or Edge Function
- Optional: `purchase_transactions` table for idempotency

### Features (Table Stakes + Differentiators)

**Table Stakes (Must-Have):**
1. **Clear price display** before consumable purchase ($0.49/0.50)
2. **Immediate credit consumption** at moment of export
3. **Dual export flow** — Pro users export freely, free users use credits
4. **Restore purchases** capability (App Store/Play Store requirement)
5. **Settings user info** — email, subscription status, basic stats
6. **Account deletion** with confirmation and data cleanup (GDPR/CCPA/AB 656)

**Differentiators (Competitive Advantage):**
1. **Transparent export stats** — show total exports, credits remaining (builds trust)
2. **Smart monetization messaging** — frame as "Pro flexibility" not punishment
3. **Configure-before-pay flow** — let users set export options before seeing paywall

**Anti-Features (Deliberately Avoiding):**
- Credit wallet/bulk purchases (adds complexity)
- Credit gifting/sharing (fraud vector)
- In-app refund handling (platforms handle this)
- Auto-subscription conversion after X purchases (surprising)
- Watermarked previews (degrades trust)

### Architecture (Provider Pattern + Service Layer)

**New Components:**
1. **CreditsProvider** — mirrors existing `entitlement_provider.dart` pattern
2. **StatsProvider** — aggregates export counts, project counts
3. **Enhanced SettingsScreen** — adds `_UserStatsSection`

**Integration Points:**
```
Export Flow:
  Check Entitlement (Pro?) → YES → Allow Export
                         → NO → Check Credits → HAS → Consume + Export
                                                  → NO → Show Purchase Sheet

Purchase Flow:
  Purchase Success → Add Credit to DB → Realtime Update → creditsProvider
```

**Build Order:**
1. Database migrations (user_credits table, RPC function)
2. Service layer extensions (SupabaseExportService credit methods)
3. Providers (CreditsProvider, StatsProvider)
4. UI integration (ExportBottomSheet, SettingsScreen)
5. Account deletion flow (Edge Function + UI)

### Pitfalls (Critical Issues to Prevent)

| Pitfall | Severity | Prevention |
|---------|----------|------------|
| **Consumable repurchase blocking (Android)** | CRITICAL | Configure as CONSUMABLE in RevenueCat, verify "Multi-quantity" in Play Console, test on physical device |
| **Stale CustomerInfo cache** | CRITICAL | Use `FETCH_CURRENT` policy, implement listener + periodic refresh, cache with timestamp |
| **Unconsumed purchase queue** | CRITICAL | Track transaction IDs, implement idempotent credit delivery, inspect queue on startup |
| **Storage cleanup orphaned files** | CRITICAL | Delete storage files BEFORE auth user deletion (not CASCADE), use Edge Function |
| **RevenueCat user linking orphaning** | MODERATE | Always call `logOut()` before account deletion, call `logIn()` on new account creation |
| **RPC security vulnerability** | CRITICAL | Use `SECURITY DEFINER`, verify `auth.uid()`, never expose service role key in client |
| **Sandbox testing silent failures** | MODERATE | Use proper sandbox testers, verify product configuration, add debug bypass flag |

---

## Roadmap Implications

### Recommended Phase Structure

**Phase 1: Foundation (Database + Core Services)** — 2-3 days
- Create `user_credits` table migration
- Fix `projects.user_id` foreign key to CASCADE
- Create `delete_user_account` Edge Function (not RPC)
- Extend `SupabaseExportService` with credit methods

**Phase 2: State Management** — 2 days
- Create `CreditsProvider` (follow `entitlement_provider.dart` pattern)
- Create `StatsProvider` for user statistics
- Add realtime subscription for credit updates

**Phase 3: Consumable Purchase Flow** — 2-3 days
- Configure consumable product in RevenueCat dashboard
- Update `ExportBottomSheet` with credit check/consume logic
- Create `ExportPurchaseSheet` UI
- Add purchase success → credit addition flow

**Phase 4: Settings Enhancement** — 2 days
- Add `_UserStatsSection` to SettingsScreen
- Display subscription status with RevenueCat data
- Show export count, credits remaining
- Add "Manage Subscription" button

**Phase 5: Account Deletion** — 1-2 days
- Implement Edge Function for cascade deletion
- Update SettingsScreen deletion flow
- Add confirmation dialog with data listing
- Test storage cleanup

**Phase 6: Testing & Polish** — 2 days
- Test consumable repurchase on Android
- Verify stale cache handling
- Test account deletion end-to-end
- Sandbox testing documentation

**Total Estimated Effort:** 11-14 dev days

### Research Flags (Where to Use `/gsd:research-phase`)

| Phase | Needs Research? | Rationale |
|-------|-----------------|-----------|
| Phase 1 (Database) | NO | Standard Supabase migrations, well-documented |
| Phase 2 (Providers) | NO | Follows existing codebase patterns |
| Phase 3 (Purchase Flow) | YES | Complex IAP edge cases, recommend research on consumable verification |
| Phase 4 (Settings) | NO | UI-only, Material 3 guidelines well-established |
| Phase 5 (Account Deletion) | MAYBE | Security-critical, Edge Function patterns worth verifying |

**Recommendation:** Use `/gsd:research-phase` for Phase 3 (consumable verification strategies) due to the complexity of server-side webhook validation vs. client-side approaches.

### Critical Path Dependencies

```
Database Migrations
      │
      ├──→ CreditsProvider
      │         │
      │         └──→ ExportBottomSheet (credit check)
      │
      ├──→ StatsProvider
      │         │
      │         └──→ SettingsScreen (user stats)
      │
      └──→ Edge Function
                │
                └──→ SettingsScreen (account deletion)
```

---

## Confidence Assessment

| Research Area | Confidence | Basis |
|---------------|------------|-------|
| **Stack recommendations** | HIGH | Context7 verified purchases_flutter API, existing codebase confirms compatibility |
| **Feature prioritization** | HIGH | Industry standard patterns (RevenueCat 2025 report), compliance requirements (GDPR/CCPA) |
| **Architecture patterns** | HIGH | Existing codebase provides clear patterns to follow (entitlement_provider.dart) |
| **Pitfall severity** | HIGH | Based on official docs, community issues, AND actual UAT findings from this project |
| **Effort estimates** | MEDIUM | Based on similar features in codebase, but consumable IAP complexity can vary |

### Why Confidence is HIGH

1. **Existing implementation:** `RevenueCatService` already has `purchaseExportCredit()` method
2. **Pattern established:** `entitlement_provider.dart` shows exactly how to build `CreditsProvider`
3. **UAT precedents:** Project already has UAT findings for similar features (Phase 16 issues documented)
4. **Official documentation:** RevenueCat and Supabase docs are comprehensive and current
5. **No unknown technologies:** All stack components are already in production use

---

## Gaps to Address

### Technical Gaps

1. **Credit Restoration Policy:** If user restores purchases, should consumable credits be restored? (Typically NO for consumables, but should document this decision)

2. **Partial Deletion Handling:** What happens if account deletion RPC partially fails? Need transaction rollback or compensation logic.

3. **Server-Side Verification:** For MVP, client-side credit addition is acceptable. For production, should implement RevenueCat webhook verification. This is a documented gap between MVP and production.

4. **Credit Expiration:** Do credits expire? Decision needed for terms of service.

### Research Gaps

1. **RevenueCat Customer Center:** Unclear if current RevenueCat plan includes Customer Center feature (may require upgrade)

2. **Edge Function vs RPC:** Need to verify Edge Function approach for account deletion is preferred over RPC in Supabase community

3. **Play Console Configuration:** "Multi-quantity" setting for consumables—need to verify exact steps

---

## Open Questions for Implementation

1. **Credit Pack Sizes:** Single export only, or support bulk packs (5, 10 credits)?
2. **Pro Subscriber Bonus:** Should existing Pro subscribers get free credits as loyalty bonus?
3. **Customer Center:** Is this included in current RevenueCat plan?
4. **Storage Cleanup Timing:** Synchronous (blocking) or asynchronous (queued) deletion?
5. **Transaction Log Retention:** How long to keep `purchase_transactions` records for audit?

---

## Immediate Action Items

### Before Implementation Starts

- [ ] Configure consumable product in RevenueCat dashboard ($0.49/0.50)
- [ ] Configure consumable in App Store Connect and Google Play Console
- [ ] Verify "Multi-quantity" enabled in Play Console
- [ ] Create sandbox tester accounts for iOS and Android
- [ ] Document credit restoration policy (likely: consumables NOT restored)

### During Implementation

- [ ] Add `purchase_transactions` table with unique constraint on `transaction_id`
- [ ] Implement idempotent credit addition (check transaction ID before granting)
- [ ] Add `syncPurchases()` call on app startup to handle stuck purchases
- [ ] Create Edge Function for account deletion (not RPC)
- [ ] Add debug bypass flag for development testing

### Before Release

- [ ] Test consumable repurchase 3+ times on Android physical device
- [ ] Verify storage cleanup (create user, upload files, delete, check buckets)
- [ ] Test account deletion with orphaned projects verification
- [ ] Verify RevenueCat `logOut()` called before auth deletion
- [ ] Document sandbox testing process in README

---

## Sources Summary

| Source | Type | Confidence | Used For |
|--------|------|------------|----------|
| Context7: purchases_flutter | Official API docs | HIGH | Consumable purchase patterns |
| Context7: supabase-flutter | Official API docs | HIGH | Auth and database operations |
| Project UAT findings (16-ISSUES.md) | Internal testing | HIGH | Actual pitfalls encountered |
| RevenueCat Community | Community issues | HIGH | Android consumable repurchase bug |
| Supabase GitHub/storage issues | Community discussion | MEDIUM | Storage CASCADE behavior |
| GitHub purchases-flutter #863 | Bug report | HIGH | Stale CustomerInfo cache issue |
| California AB 656 / GDPR docs | Legal requirements | HIGH | Account deletion compliance |
| RevenueCat State of Subscription Apps 2025 | Industry report | MEDIUM | Hybrid monetization trends |

---

## Ready for Roadmap Creation

**Status:** Research complete and synthesized. All 4 dimensions (Stack, Features, Architecture, Pitfalls) have been analyzed.

**Key Takeaway:** v1.3 is a straightforward implementation milestone with no new dependencies. The main risks are (1) Android consumable configuration, (2) cache staleness, and (3) storage cleanup during deletion—all addressable with documented patterns.

**Recommendation:** Proceed to requirements definition with confidence. Consider using `/gsd:research-phase` for the consumable verification strategy (Phase 3) due to IAP complexity.
