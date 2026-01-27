---
phase: 16-per-export-pricing
plan: 16-FIX
type: fix
---

<objective>
Document BuildShip export workflow implementation to resolve UAT-002.

**Source:** 16-ISSUES.md
**Priority:** 1 blocker (infrastructure dependency)

**Context:** Phase 16 payment gate code is complete. Exports create records with status='queued' but BuildShip workflow is not configured to process them. Phase 9 has general spec — this plan creates implementation-ready documentation.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/ROADMAP.md

**Issues being fixed:**
@.planning/phases/16-per-export-pricing/16-ISSUES.md

**Existing BuildShip spec (Workflow 3):**
@.planning/phases/09-buildship-workflow-spec/SPEC.md

**Export service (creates records):**
@lib/services/supabase_export_service.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create Export Workflow Implementation Guide</name>
  <files>.planning/phases/16-per-export-pricing/EXPORT-WORKFLOW-GUIDE.md</files>
  <action>
Create a step-by-step BuildShip implementation guide for the export workflow.

Include:
1. **Prerequisites**
   - Supabase webhook URL from BuildShip
   - Service role key configured
   - Storage buckets exist (exports)

2. **Step-by-step BuildShip setup**
   - Create new workflow
   - Add Supabase webhook trigger for exports INSERT
   - Configure each node with exact settings

3. **Export record structure** (from supabase_export_service.dart)
   ```dart
   'project_id': projectId,
   'user_id': userId,
   'format': format, // 'png', 'jpg', etc.
   'status': 'queued',
   'include_layers': includedLayerIds,
   'output_url': null,
   ```

4. **Workflow nodes** (simplified from Phase 9 spec):
   - Update status → 'processing'
   - Get project and visible layers
   - Get signed URLs for layer PNGs
   - Composite layers (using Sharp or Canvas)
   - Upload to exports bucket
   - Update status → 'completed' with output_url

5. **Testing steps**
   - Trigger export from app
   - Verify status changes
   - Verify output file exists
   - Verify download works

Reference Phase 9 SPEC.md for detailed node specs, but make this guide actionable for manual BuildShip configuration.
  </action>
  <verify>File exists at .planning/phases/16-per-export-pricing/EXPORT-WORKFLOW-GUIDE.md</verify>
  <done>Implementation guide documents exact steps to configure BuildShip export workflow</done>
</task>

<task type="auto">
  <name>Task 2: Update 16-ISSUES.md with resolution path</name>
  <files>.planning/phases/16-per-export-pricing/16-ISSUES.md</files>
  <action>
Update UAT-002 to reference the new implementation guide:

```markdown
### UAT-002: Export processing workflow not configured

...existing content...

**Resolution Path:** 
- See: EXPORT-WORKFLOW-GUIDE.md
- Reference: Phase 9 SPEC.md (Workflow 3: Build Export)
- Status: Documentation complete, awaiting manual BuildShip configuration
```
  </action>
  <verify>grep "EXPORT-WORKFLOW-GUIDE" .planning/phases/16-per-export-pricing/16-ISSUES.md</verify>
  <done>UAT-002 updated with resolution path</done>
</task>

<task type="checkpoint:human-action" gate="blocking">
  <action>Configure BuildShip export workflow using the guide</action>
  <instructions>
I created EXPORT-WORKFLOW-GUIDE.md with step-by-step instructions.

You need to:
1. Open BuildShip dashboard
2. Follow the guide to create "Build Export" workflow
3. Configure Supabase webhook trigger on `exports` INSERT
4. Add processing nodes (see guide for details)
5. Deploy the workflow

After configuration:
- Test by creating an export in the app
- Verify status changes: queued → processing → completed
- Verify output_url is populated with storage path
  </instructions>
  <verification>Export triggers workflow, status changes to 'completed', download link works</verification>
  <resume-signal>Type "done" when workflow is configured and tested, or describe issues</resume-signal>
</task>

</tasks>

<verification>
Before declaring plan complete:
- [ ] EXPORT-WORKFLOW-GUIDE.md exists with implementation steps
- [ ] 16-ISSUES.md updated with resolution path
- [ ] BuildShip workflow configured and tested
</verification>

<success_criteria>
- Export workflow documentation complete
- UAT-002 has clear resolution path
- User can configure BuildShip using the guide
</success_criteria>

<output>
After completion, create `.planning/phases/16-per-export-pricing/16-FIX-SUMMARY.md`
</output>
