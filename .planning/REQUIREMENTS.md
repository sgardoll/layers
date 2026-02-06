# Requirements: Layers v1.3 Monetization & Settings

**Defined:** 2026-02-06
**Core Value:** The 3D layer viewer must feel magical

## v1.3 Requirements

Requirements for this milestone. Each maps to roadmap phases.

### Per-Export Pricing (MON)

- [ ] **MON-01**: User can purchase a single export credit for $0.50
- [ ] **MON-02**: Credit is consumed immediately at moment of export (not at purchase)
- [ ] **MON-03**: Pro subscribers receive bonus credits monthly (loyalty reward)
- [ ] **MON-04**: Export flow checks credits before allowing export for non-Pro users
- [ ] **MON-05**: Clear price display before purchase with configure-before-pay flow
- [ ] **MON-06**: Restore purchases capability works for both subscriptions and consumables

### Settings Enhancement (SET)

- [ ] **SET-01**: Settings screen displays current user email address
- [ ] **SET-02**: Settings screen displays current subscription status (Free/Pro)
- [ ] **SET-03**: Settings screen shows export statistics (total exports, credits remaining)
- [ ] **SET-04**: Settings screen includes "Manage Subscription" button (deep link to platform settings)
- [ ] **SET-05**: Settings screen includes "Delete Account" option with confirmation flow
- [ ] **SET-06**: Account deletion performs full data cleanup including projects, layers, exports, and storage files

### Database & Infrastructure (DB)

- [ ] **DB-01**: Create `user_credits` table for credit tracking with RLS policies
- [ ] **DB-02**: Fix `projects.user_id` foreign key from SET NULL to CASCADE
- [ ] **DB-03**: Create `delete_user_account` Edge Function for secure cascade deletion
- [ ] **DB-04**: Create `purchase_transactions` table for idempotency and audit

### State Management (STATE)

- [ ] **STATE-01**: Create `CreditsProvider` following existing `entitlement_provider.dart` pattern
- [ ] **STATE-02**: Create `StatsProvider` for aggregating user statistics
- [ ] **STATE-03**: Realtime subscription for credit updates

## v2 Requirements (Deferred)

Deferred to future releases. Tracked but not in current roadmap.

### Per-Export Pricing v2

- **MON-V2-01**: Bulk credit packs (5-pack, 10-pack) with volume discount
- **MON-V2-02**: Credit gifting between users
- **MON-V2-03**: Promotional credit campaigns (referrals, etc.)

### Settings Enhancement v2

- **SET-V2-01**: Credit purchase history view
- **SET-V2-02**: Export history with thumbnails
- **SET-V2-03**: Push notification preferences

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Credit wallet system | Adds complexity, one-purchase-one-export is simpler |
| Credit expiration | Unnecessary for v1, complicates UX |
| In-app refund handling | Platforms handle this, don't duplicate |
| Auto-subscription conversion | Surprising behavior, users should choose |
| Watermarked previews | Degrades trust in the product |
| Server-side webhook verification | Client-side sufficient for MVP, add for production scale |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| MON-01 | Phase 16 | Pending |
| MON-02 | Phase 16 | Pending |
| MON-03 | Phase 16 | Pending |
| MON-04 | Phase 16 | Pending |
| MON-05 | Phase 16 | Pending |
| MON-06 | Phase 16 | Pending |
| SET-01 | Phase 17 | Pending |
| SET-02 | Phase 17 | Pending |
| SET-03 | Phase 17 | Pending |
| SET-04 | Phase 17 | Pending |
| SET-05 | Phase 17 | Pending |
| SET-06 | Phase 17 | Pending |
| DB-01 | Phase 16 | Pending |
| DB-02 | Phase 16 | Pending |
| DB-03 | Phase 17 | Pending |
| DB-04 | Phase 16 | Pending |
| STATE-01 | Phase 16 | Pending |
| STATE-02 | Phase 17 | Pending |
| STATE-03 | Phase 16 | Pending |

**Coverage:**
- v1.3 requirements: 18 total
- Mapped to phases: 18
- Unmapped: 0 ✓

---
*Requirements defined: 2026-02-06*
*Last updated: 2026-02-06 after research synthesis*
