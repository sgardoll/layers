# UAT Issues: Phase 19 Plan 01

**Tested:** 2026-02-05
**Source:** .planning/phases/19-mobile-ux/19-01-SUMMARY.md
**Tester:** User via /gsd-verify-work

## Open Issues

[None]

## Resolved Issues

### UAT-001: Riverpod provider initialization error on app launch

**Discovered:** 2026-02-05
**Phase/Plan:** 19-01
**Severity:** Blocker
**Feature:** App launch / Login flow
**Description:** App crashes with Riverpod assertion error during initialization. The FutureProvider<RevenueCatService> is modifying StateNotifierProvider<ProjectListNotifier> during build, which is not allowed.

**Error messages:**
1. `Providers are not allowed to modify other providers during their initialization`
2. `The provider FutureProvider<RevenueCatService>#4c53e modified StateNotifierProvider<ProjectListNotifier, ProjectListState>#25b5e while building`
3. `Tried to read Provider<bool>#6a0a3 from a place where one of its dependencies were overridden but the provider is not`

**Expected:** App launches successfully and shows project list
**Actual:** App crashes with unhandled exceptions, cannot access LayersScreen to test responsive layout
**Repro:**
1. Launch app on iPad simulator
2. App initializes Supabase and RevenueCat
3. Error occurs when ProjectListNotifier tries to load projects
4. Screen remains inaccessible

**Stack trace indicates:**
- ProjectListNotifier is being triggered during RevenueCatService initialization
- Provider dependency issue with overridden providers
- Likely in `lib/providers/project_provider.dart` or related files

**Fixed:** 2026-02-05
**Commit:** ad646ee
**Solution:**
- Removed circular dependency: entitlementProvider no longer watches projectListProvider
- ProjectListNotifier now updates entitlementProvider directly when project count changes
- This breaks the initialization cycle that was causing the assertion error

## Final UAT Results

**Tested:** 2026-02-05 (Final verification after fixes)
**Source:** .planning/phases/19-mobile-ux/19-01-SUMMARY.md

### Tests Completed:
1. ✅ **Desktop/Tablet Layout** - Side panel visible, works correctly
2. ✅ **Mobile Portrait Layout** - Bottom sheet works correctly
3. ✅ **3-Tab Navigation** - All 3 tabs work correctly
4. ✅ **Theme Integration** - Theme colors work correctly
5. ✅ **Export Screen Thumbnails** - Thumbnails show correctly (not blue squares)

**Tests run:** 5
**Passed:** 5
**Failed:** 0
**Partial:** 0
**Skipped:** 0

**Verdict:** All tests passed - Feature validated

---

*Phase: 19-mobile-ux*
*Plan: 01*
*Tested: 2026-02-05*
*Status: Complete and validated*
