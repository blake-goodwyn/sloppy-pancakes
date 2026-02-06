# Integrated Workflow Example

**Scenario:** Running milestone M4.1 (User Management API) with all features enabled.

**Features Demonstrated:**
- Quality gate with warnings
- Code review with fix command
- Elevated soft stops (auto-continue with labels)
- Hard stop with approve command
- Phase boundary review
- Skip command usage
- Milestone completion

---

## Start

```
run-milestone m4.1
```

---

## Bootstrap & Quality Gate

```
═══════════════════════════════════════════════
Starting Milestone: m4.1
═══════════════════════════════════════════════

📋 Bootstrap
✓ Milestone folder exists
✓ Implementation plan loaded
✓ First run detected

🔍 Quality Gate
Invoking plan-review...

✓ Passed (0 critical, 2 warnings)
  ⚠️ Issue #05 has 6 acceptance criteria
  ⚠️ Missing integration test spec in #08

✓ Base branch: milestone/m4.1-user-management
✓ Scope tags: [api, users, auth]
✓ State validated

→ Starting Issue #01
```

---

## Issue #01: Clean Pass

```
═══════════════════════════════════════════════
Issue #01: Add user profile endpoint (#295)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-295-user-profile
✓ Implemented (4 files, 156 lines)
✓ Auto-fixed (lint)
✓ Tests: 52 passed
✓ PR #310 created

🤖 Code review...
✓ No issues found

→ Proceeding to Issue #02
```

---

## Issue #02: Clean Pass

```
═══════════════════════════════════════════════
Issue #02: Add user data models (#296)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-296-user-models
✓ Implemented
✓ Tests passing
✓ PR #311 created

🤖 Code review...
✓ No issues found

→ Proceeding to Issue #03
```

---

## Issue #03: Code Review Fix

```
═══════════════════════════════════════════════
Issue #03: Add input sanitization (#297)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-297-sanitization
✓ Implemented
✓ Tests passing
✓ PR #312 created

🛑 Code review: 2 issues (attempt 1/2)

1. Missing docstring — src/users/sanitize.py#L15
2. Unused import — src/users/sanitize.py#L3

fix | skip | abort
```

**User:** `fix`

```
🔧 Fixing...
✓ Added docstring to InputSanitizer
✓ Removed unused import
✓ Tests passing
✓ Pushed

🤖 Re-running code review...
✓ No issues found

→ Proceeding to Issue #04
```

---

## Issue #04: Elevated Soft Stop (DB Migration)

```
═══════════════════════════════════════════════
Issue #04: Add user_profiles table (#298)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-298-user-profiles-table
✓ Implemented
✓ Migration: CREATE TABLE "user_profiles"

⚠️ Additive schema change
✓ Label: needs-db-review
✓ PR #313 created

🤖 Code review...
✓ No issues found

→ Proceeding to Issue #05
```

---

## Issue #05: Clean Pass (Phase 1 End)

```
═══════════════════════════════════════════════
Issue #05: Add user validation service (#299)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-299-validation-service
✓ Implemented
✓ Tests passing
✓ PR #314 created

🤖 Code review...
✓ No issues found

✓ Phase 1 complete — 5 PRs ready

* PR #310 — Add user profile endpoint (#295) ✓
* PR #311 — Add user data models (#296) ✓
* PR #312 — Add input sanitization (#297) ✓
* PR #313 — Add user_profiles table (#298) [needs-db-review]
* PR #314 — Add validation service (#299) ✓

continue | skip-phase | abort
```

**User:** `continue`

```
✓ Phase 1 approved

→ Starting Phase 2, Issue #06
```

---

## Issue #06: Elevated Soft Stop (Dependency)

```
═══════════════════════════════════════════════
Issue #06: Add email service client (#300)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-300-email-client
✓ Implemented
⚠️ New dependency: httpx v0.25.0 (MIT)

⚠️ Routine dependency addition
✓ Label: needs-dep-review
✓ PR #315 created

🤖 Code review...
✓ No issues found

→ Proceeding to Issue #07
```

---

## Issue #07: Test Failures → Skip

```
═══════════════════════════════════════════════
Issue #07: Add response caching (#301)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-301-response-cache
✓ Implemented

🛑 Tests failing (attempt 1/2)

Failed:
- test_cache_expiry
- test_cache_invalidation

fix | skip | abort
```

**User:** `fix`

```
🔧 Fixing...
✓ Auto-fix applied
✗ Tests: 2 failed

🛑 Tests failing (attempt 2/2)

skip | abort
```

**User:** `skip`

```
⏭️ Skipped Issue #07

Recorded: "Test failures - cache timing issues"

→ Proceeding to Issue #08
```

---

## Issue #08: Hard Stop (Security Finding)

```
═══════════════════════════════════════════════
Issue #08: Add external API integration (#302)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-302-external-api
✓ Implemented
✓ Tests passing
✓ PR #316 created

🛑 Code review: 1 critical issue

1. Hardcoded API key — src/clients/email_api.py#L23

fix | skip | abort
```

**User:** `fix`

```
🔧 Fixing...
✓ Moved API key to environment variable
✓ Updated config loader
✓ Tests passing
✓ Pushed

🤖 Re-running code review...
✓ No issues found

→ Proceeding to Issue #09
```

---

## Issue #09: Hard Stop (Breaking Schema)

```
═══════════════════════════════════════════════
Issue #09: Migrate legacy user data (#303)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-303-migrate-legacy
✓ Implemented
✓ Migration: DROP COLUMN "old_user_status"

🛑 Breaking schema: DROP COLUMN

File: alembic/versions/009_migrate_legacy.py
Risk: Data loss (column has 50k rows)

approve | skip | abort
```

**User:** `approve`

```
✓ Approved (recorded)

✓ PR #317 created

🤖 Code review...
✓ No issues found

→ Proceeding to Issue #10
```

---

## Issue #10: Clean Pass (Phase 2 End)

```
═══════════════════════════════════════════════
Issue #10: Add user analytics (#304)
═══════════════════════════════════════════════

✓ Branch: feat/m4.1-304-analytics
✓ Implemented
✓ Tests passing
✓ PR #318 created

🤖 Code review...
✓ No issues found

✓ Phase 2 complete — 5 PRs ready

* PR #315 — Add email client (#300) [needs-dep-review] ✓
* (Issue #07 skipped)
* PR #316 — Add external API (#302) ✓
* PR #317 — Migrate legacy (#303) ⚠️ Breaking change approved
* PR #318 — Add analytics (#304) ✓

continue | skip-phase | abort
```

**User:** `continue`

```
✓ Phase 2 approved

→ Starting Phase 3, Issue #11
```

---

## Issues #11-#13: Clean Passes

```
═══════════════════════════════════════════════
Issue #11: Add user export endpoint (#305)
═══════════════════════════════════════════════

✓ PR #319 created
✓ Code review: No issues

→ Proceeding to Issue #12

═══════════════════════════════════════════════
Issue #12: Add user notifications (#306)
═══════════════════════════════════════════════

✓ PR #320 created
✓ Code review: No issues

→ Proceeding to Issue #13

═══════════════════════════════════════════════
Issue #13: Add admin dashboard API (#307)
═══════════════════════════════════════════════

✓ PR #321 created
✓ Code review: No issues

✓ Phase 3 complete — 3 PRs ready

* PR #319 — Add user export (#305) ✓
* PR #320 — Add notifications (#306) ✓
* PR #321 — Add admin dashboard API (#307) ✓

continue | skip-phase | abort
```

**User:** `continue`

```
✓ Phase 3 approved
```

---

## Milestone Complete

```
═══════════════════════════════════════════════
✓ Milestone M4.1 Complete
═══════════════════════════════════════════════

Issues: 13 total
  ✅ Completed: 12
  ⏭️ Skipped: 1 (#07 - test failures)

PRs: 12 created
  ✓ Clean: 9
  🔧 Fixed: 2 (code review)
  ⚠️ Approved: 1 (breaking schema)

Labels applied:
  needs-db-review: 1
  needs-dep-review: 1

Commands used:
  continue: 3 (phase boundaries)
  fix: 3 (code review, tests)
  skip: 1 (test failures)
  approve: 1 (breaking schema)

Quality gates:
  ✅ Pre-execution: Passed (2 warnings)
  ✅ Phase 1: Approved
  ✅ Phase 2: Approved
  ✅ Phase 3: Approved

Next steps:
1. Merge 12 open PRs
2. Address skipped issue #07 if needed
3. Create milestone PR → main
4. Tag: v0.4.1
```

---

## Summary

| Step | Action | Command Used |
|------|--------|--------------|
| Quality gate | Warnings acknowledged | (auto-continue) |
| Issue #03 | Code review fix | `fix` |
| Issue #04 | Additive migration | (auto-continue + label) |
| Phase 1 | Review & approve | `continue` |
| Issue #06 | New dependency | (auto-continue + label) |
| Issue #07 | Tests failing | `fix` → `skip` |
| Issue #08 | Security fix | `fix` |
| Issue #09 | Breaking schema | `approve` |
| Phase 2 | Review & approve | `continue` |
| Phase 3 | Review & approve | `continue` |

**Total user interactions:** 8 commands

**Time saved vs manual:** ~4 hours (code review, fix cycles, tracking)