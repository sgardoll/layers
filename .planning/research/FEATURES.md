# Feature Landscape: v1.3 Monetization & Settings

**Domain:** AI Image Layer Extraction App (Flutter)
**Research Date:** 2026-02-06
**Research Mode:** Subsequent Milestone (Adding to Existing Product)

---

## Executive Summary

This research covers three interrelated features for Layers v1.3:
1. **Per-export consumable IAP** ($0.50) as alternative to subscription
2. **Enhanced settings screen** with account management and export statistics
3. **Account deletion** with full data cleanup

The key insight: Per-export pricing is **table stakes** for this type of creative tool—users expect flexibility between subscriptions and one-off purchases. However, the **real differentiator** is transparency around usage and clear value communication. Users who feel "trapped" by unclear credit systems churn; those who understand the value proposition convert.

---

## Table Stakes (Must-Have)

Features users expect. Missing = product feels incomplete or broken.

### Per-Export Consumable IAP

| Feature | Why Expected | Complexity | Dependencies |
|---------|--------------|------------|--------------|
| **Clear price display before purchase** | Users expect to see the exact price ($0.50 equivalent) before confirming | Low | RevenueCat product configuration |
| **Immediate consumption on use** | Credits should deduct at moment of export, not purchase | Medium | Export flow integration |
| **Works alongside subscription** | Pro users shouldn't see paywall; free users get option | Medium | Entitlement checking |
| **Restore purchases capability** | App Store/Play Store requirement for consumables | Low | RevenueCat handles this |
| **Receipt validation** | Prevent fraud, required by Apple/Google | Low | RevenueCat handles server-side |

**Expected Behavior:**
- Free user taps export → sees bottom sheet with "$0.49 - One-time purchase" AND "Upgrade to Pro for unlimited"
- Purchase completes → credit consumed immediately → export proceeds
- No credit "wallet" UI needed for MVP—just consumption at point of use
- RevenueCat tracks `nonSubscriptionTransactions` for audit trail

### Enhanced Settings Screen

| Feature | Why Expected | Complexity | Dependencies |
|---------|--------------|------------|--------------|
| **Display user email** | Users need to know which account they're signed into | Low | Supabase auth provider |
| **Show subscription status** | Clear indicator of Pro vs Free | Low | Entitlement provider |
| **Export usage statistics** | Users want to know how many exports they've done | Medium | Database aggregation |
| **Theme toggle** | Already exists, keep it | Low | Existing implementation |
| **Legal links** | Privacy policy, terms of service | Low | URL launcher |

**Expected Behavior:**
- Settings shows: "Signed in as: user@email.com"
- Subscription section: "Pro" badge with expiry date, OR "Free - Upgrade"
- Stats section: "Total exports: 12" or "Exports this month: 3"

### Account Deletion

| Feature | Why Expected | Complexity | Dependencies |
|---------|--------------|------------|--------------|
| **Clear deletion button** | California AB 656, iOS 15+ requirement—must be in settings | Low | UI placement |
| **Confirmation dialog** | Prevent accidental deletion | Low | Alert dialog |
| **Data deletion confirmation** | GDPR/CCPA requirement—tell user what will be deleted | Low | Copywriting |
| **Actually delete data** | Legal requirement—projects, layers, exports, user record | High | Supabase RPC + storage cleanup |
| **RevenueCat unlink** | Prevent orphaned purchase records | Low | `logOut()` call |

**Expected Behavior:**
- Settings → Delete Account → Confirmation dialog with data list
- "This will delete: 3 projects, 12 layers, all export history"
- Delete executes RPC → deletes Supabase data → unlinks RevenueCat → signs out
- User sees "Account deleted" confirmation

---

## Differentiators (Competitive Advantage)

Features that set the product apart when done well.

### Transparent Export Credit Display

**What:** Show remaining/historical exports prominently in settings
**Why Valuable:** Most apps hide this—transparency builds trust
**Complexity:** Medium (requires caching/aggregating export counts)
**Implementation Notes:**
- Query Supabase `exports` table for count per user
- Cache in provider to avoid repeated queries
- Show: "You've exported 12 images with Layers"

### RevenueCat Customer Center Integration

**What:** Use RevenueCat's native subscription management UI
**Why Valuable:** Handles cancellation flows, promotional offers, restore purchases automatically
**Complexity:** Low (simple API call)
**Implementation Notes:**
- `RevenueCatUI.presentCustomerCenter()` (available in purchases_ui_flutter 8.6.0+)
- Self-service: users can cancel, restore, change plans without support
- **Note:** RevenueCat Customer Center is Pro/Enterprise plan feature—verify subscription tier

### Hybrid Monetization Communication

**What:** Clever UI that positions per-export as "Pro flexibility" not "paywall punishment"
**Why Valuable:** RevenueCat 2025 State of Subscription Apps report shows 35%+ of apps now mix subscriptions with consumables
**Complexity:** Low (copywriting + UI design)
**Implementation Notes:**
- Frame it: "Pay per export, or go unlimited with Pro"
- NOT: "Free limit reached—pay up"
- Show savings calculation: "3 exports = $1.47. Pro = $4.99/month"

### Smart Export Prompt Timing

**What:** Don't show purchase sheet immediately—let user configure export first
**Why Valuable:** Reduces friction, increases conversion
**Complexity:** Medium (flow redesign)
**Implementation Notes:**
- Current: Tap export → immediate paywall
- Better: Tap export → format options → then paywall/preview
- User has invested time configuring → more likely to convert

---

## Anti-Features (Deliberately NOT Building)

Features to explicitly avoid—common mistakes in this domain.

### Credit Wallet System

**What:** Let users buy multiple credits in bulk ($4.99 for 10 exports)
**Why Avoid:** Adds complexity, expectation of credit management UI, unused credits = support burden
**What to Do Instead:** Keep it simple—one purchase = one export, consumed immediately

### Export Credit Gifting/Sharing

**What:** Transfer credits between users
**Why Avoid:** Fraud vector, complex accounting, rare use case
**What to Do Instead:** Focus on individual user experience

### Refund Handling UI

**What:** In-app refund request flow
**Why Avoid:** Apple/Google handle refunds through their systems; building UI creates false expectation
**What to Do Instead:** Link to platform subscription management (App Store/Play Store)

### Automatic Subscription Conversion

**What:** Auto-upgrade to Pro after X per-export purchases
**Why Avoid:** Surprising, potentially unwanted, complex to implement correctly
**What to Do Instead:** Show savings message but let user decide: "You've spent $4.90 on 10 exports. Pro is $4.99/month for unlimited"

### Export Preview Watermarks

**What:** Watermarked preview before purchase to "tease" quality
**Why Avoid:** Degrades trust, AI exports are already variable quality
**What to Do Instead:** Show full preview in-app (already done), watermark only on actual exported file for free tier

---

## Feature Dependencies

```
Supabase Auth
    │
    ├── User Email Display (settings)
    ├── Account Deletion RPC
    │
RevenueCat
    │
    ├── Entitlement Check (Pro status)
    ├── Consumable Purchase Flow
    ├── Customer Center (subscription management)
    │
Supabase Database
    │
    ├── Export Count Statistics
    ├── Project/Layer Deletion (cascade)
    │
Export Flow
    │
    ├── Format Selection
    ├── Entitlement OR Consumable Check
    └── Export Execution
```

### Critical Path

1. **Export flow must check:** `isPro OR hasAvailableExportCredit`
2. **Consumable purchase must:** Complete before export proceeds
3. **Settings must:** Show real-time subscription status (listen to RevenueCat)
4. **Account deletion must:** Delete in order—layers → projects → exports → auth user

---

## MVP Recommendation

For v1.3, prioritize in this order:

### Phase 1: Core Consumable (Table Stakes)
1. RevenueCat consumable product setup ($0.49/0.50)
2. Export bottom sheet with dual CTA (per-export OR upgrade)
3. Consumable purchase flow
4. Consumption at export time

### Phase 2: Settings Enhancement (Table Stakes)
1. User email display
2. Subscription status with RevenueCat Customer Center
3. Basic export count statistics

### Phase 3: Account Deletion (Compliance)
1. Delete account button in settings
2. Confirmation dialog with data listing
3. Supabase RPC for cascade deletion
4. RevenueCat logout on completion

### Defer to Post-1.3:
- **Bulk credit purchases:** Adds complexity, solve if users request
- **Advanced statistics:** Export history timeline, format breakdown
- **Promotional offers:** Requires RevenueCat Pro plan

---

## Complexity Assessment

| Feature | Est. Dev Days | Risk Level | Notes |
|---------|---------------|------------|-------|
| Consumable IAP setup | 1 | Low | RevenueCat dashboard config + code |
| Export purchase sheet | 2 | Low | Bottom sheet UI + purchase flow |
| Settings enhancements | 2 | Low | Provider updates + UI |
| Export statistics | 1 | Low | Supabase query + display |
| Account deletion RPC | 2 | Medium | Cascade delete logic |
| Customer Center | 0.5 | Low | Single API call if plan supports |

**Total estimated:** 8-10 dev days for complete v1.3

---

## Confidence Assessment

| Area | Confidence | Reason |
|------|------------|--------|
| RevenueCat consumables | **HIGH** | Context7 docs confirm API, patterns well-established |
| Per-export pricing model | **HIGH** | Industry standard for creative tools, RevenueCat 2025 report confirms 35%+ apps use hybrid |
| Account deletion requirements | **HIGH** | Official Apple/Google docs, CCPA/GDPR well-documented |
| Settings UX patterns | **MEDIUM** | Material 3 guidelines, but specific "export stats" is less common |
| Customer Center availability | **MEDIUM** | Docs confirm Flutter support, but feature tier unclear |

---

## Open Questions for Implementation

1. **RevenueCat plan tier:** Is Customer Center included in current plan or requires upgrade?
2. **Export credit tracking:** Store count in RevenueCat subscriber attributes OR query Supabase exports table?
3. **Partial deletion handling:** What happens if RPC partially fails (some tables deleted, others not)?
4. **Subscription upgrade path:** If user buys per-export then upgrades to Pro, show credits remaining OR treat as sunk cost?

---

## Sources

- [RevenueCat Purchases Flutter Documentation](https://context7.com/revenuecat/purchases-flutter) (Context7 - HIGH confidence)
- [RevenueCat Customer Center Flutter Integration](https://www.revenuecat.com/docs/tools/customer-center/customer-center-flutter) (Official docs - HIGH confidence)
- [Android Settings UI Guidelines](https://developer.android.com/design/ui/mobile/guides/patterns/settings) (Official - HIGH confidence)
- [California AB 656 Account Deletion Requirements](https://cppa.ca.gov/announcements/2025/20251113.html) (State of California - HIGH confidence)
- [Google Play Account Deletion Policy](https://support.google.com/googleplay/android-developer/answer/13327111) (Official - HIGH confidence)
- [RevenueCat State of Subscription Apps 2025](https://s3.amazonaws.com/media.mediapost.com/uploads/state-of-subscription-apps-2025.pdf) (Industry report - MEDIUM confidence)
- [Hybrid Monetization Best Practices](https://adapty.io/blog/app-pricing-models/) (Industry blog - MEDIUM confidence)
- [Baymard Account Self-Service UX 2025](https://baymard.com/blog/current-state-accounts-selfservice) (UX research - MEDIUM confidence)
