# Example Output: Run Milestone

All examples show **in-chat interactions** — user commands inline with workflow output.

---

## Fresh Start

```
run-milestone m3
```

```
═══════════════════════════════════════════════
Starting Milestone: m3
═══════════════════════════════════════════════

📋 Bootstrap
✓ Milestone folder exists
✓ Implementation plan loaded
✓ First run detected

🔍 Quality Gate
Invoking plan-review...

✓ Passed (0 critical, 1 warning)
  ⚠️ Issue #05 has 6 acceptance criteria

✓ Base branch: milestone/m3-user-auth
✓ State validated

→ Starting Issue #01
```

---

## Clean Issue Execution

```
═══════════════════════════════════════════════
Issue #01: Add user login endpoint (#101)
═══════════════════════════════════════════════

✓ Branch: feat/m3-101-user-login
✓ Implemented (4 files, 156 lines)
✓ Auto-fixed (lint)
✓ Tests: 47 passed
✓ PR #310 created

🤖 Code review...
✓ No issues found

→ Proceeding to Issue #02
```

---

## Code Review with Fix

```
═══════════════════════════════════════════════
Issue #03: Add API key service (#239)
═══════════════════════════════════════════════

✓ Branch: feat/m3-239-api-key-service
✓ Implemented
✓ Tests passing
✓ PR #312 created

🛑 Code review: 2 issues (attempt 1/2)

1. Missing docstring — src/services/api_key.py#L15
2. Unused import — src/services/api_key.py#L3

fix | skip | abort
```

**User:** `fix`

```
🔧 Fixing...
✓ Added docstring
✓ Removed import
✓ Tests passing
✓ Pushed

🤖 Re-running code review...
✓ No issues found

→ Proceeding to Issue #04
```

---

## Fix Exhausted

```
🛑 Code review: 1 issue (attempt 2/2)

1. Complex logic needs refactor — src/auth.py#L45

fix | skip | abort
```

**User:** `fix`

```
🔧 Fixing...
⚠️ Issue persists

🛑 Fix attempts exhausted (2/2)

skip | abort
```

**User:** `skip`

```
⏭️ Skipped Issue #05

Recorded in "Blocked / Needs Review"

→ Proceeding to Issue #06
```

---

## Test Failures

```
═══════════════════════════════════════════════
Issue #07: Add tenant isolation (#243)
═══════════════════════════════════════════════

✓ Implemented
✗ Tests: 2 failed, 45 passed

🛑 Tests failing (attempt 1/2)

Failed:
- test_tenant_isolation_read
- test_tenant_isolation_write

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

→ Proceeding to Issue #08
```

---

## Elevated Soft Stop (Auto-Continues)

```
═══════════════════════════════════════════════
Issue #04: Add API keys migration (#240)
═══════════════════════════════════════════════

✓ Implemented
✓ Migration: CREATE TABLE "api_keys"

⚠️ Additive schema change
✓ Label: needs-db-review
✓ PR #313 created

→ Proceeding to Issue #05
```

---

## Hard Stop: Breaking Schema

```
═══════════════════════════════════════════════
Issue #09: Remove legacy fields (#245)
═══════════════════════════════════════════════

✓ Implemented
✓ Migration: DROP COLUMN "legacy_status"

🛑 Breaking schema: DROP COLUMN

File: alembic/versions/009_remove_legacy.py
Risk: Data loss (column has 15k rows)

approve | skip | abort
```

**User:** `approve`

```
✓ Approved (recorded)

✓ PR #318 created
✓ Code review: No issues

→ Proceeding to Issue #10
```

---

## Hard Stop: License

```
═══════════════════════════════════════════════
Issue #11: Add PDF generation (#247)
═══════════════════════════════════════════════

✓ Implemented
⚠️ New dependency: weasyprint (GPL-3.0)

🛑 License: weasyprint v60.0 (GPL-3.0)

approve | skip | abort
```

**User:** `skip`

```
⏭️ Skipped Issue #11

Recorded: "GPL dependency requires legal review"

→ Proceeding to Issue #12
```

---

## Hard Stop: Cross-Boundary

```
═══════════════════════════════════════════════
Issue #06: Add caching layer (#242)
═══════════════════════════════════════════════

✓ Implemented

🛑 Scope creep: billing code in M3 (auth)

Modified: src/services/billing.py
Scope tags: [auth, permissions]

approve | skip | abort
```

**User:** `approve`

```
✓ Approved (recorded)

→ Continuing Issue #06
```

---

## Phase Boundary

```
✓ Phase 1 complete — 5 PRs ready

* PR #310 — Add user login endpoint (#101) ✓
* PR #311 — Add password hashing (#102) ✓
* PR #312 — Add session service (#103) ✓
* PR #313 — Add users migration (#104) [needs-db-review]
* PR #314 — Add auth middleware (#105) ✓

continue | skip-phase | abort
```

**User:** `continue`

```
✓ Phase 1 approved

→ Starting Phase 2, Issue #06
```

---

## Quality Gate Blocked

```
run-milestone m4
```

```
═══════════════════════════════════════════════
Starting Milestone: m4
═══════════════════════════════════════════════

📋 Bootstrap
✓ First run detected

🔍 Quality Gate
Invoking plan-review...

🛑 Quality gate: 2 critical issues

1. Issue #03 depends on #99 (doesn't exist)
2. Circular: #04 → #06 → #04

approve | abort
```

**User:** `abort`

```
⛔ Milestone aborted

Fix issues in IMPLEMENTATION_PLAN.md
Resume with: run-milestone m4
```

---

## Git Error

```
═══════════════════════════════════════════════
Issue #08: Add rate limiting (#244)
═══════════════════════════════════════════════

✓ Implemented
✓ Tests passing

🛑 Push failed

Error: Permission denied (publickey)

retry | skip | abort
```

**User:** `retry`

```
🔄 Retrying push...
✓ Pushed

✓ PR #317 created

→ Proceeding to Issue #09
```

---

## Resume After Abort

```
run-milestone m3
```

```
═══════════════════════════════════════════════
Resuming Milestone: m3
═══════════════════════════════════════════════

🔄 Reconcile
✓ Found 8 open PRs
✓ 2 PRs merged since last run
✓ Current: Issue #09

→ Continuing Issue #09
```

---

## Milestone Complete

```
═══════════════════════════════════════════════
✓ Milestone M3 Complete
═══════════════════════════════════════════════

Issues: 12 total
  ✅ Completed: 10
  ⏭️ Skipped: 2 (#07, #11)

PRs: 10 created
  ✓ Clean: 7
  ⚠️ Warnings: 2
  🏷️ Labels: needs-db-review (2), sensitive-review (3)

Commands used:
  continue: 3
  fix: 4
  skip: 2
  approve: 1

Next steps:
1. Merge open PRs
2. Address skipped issues if needed
3. Create milestone PR → main
4. Tag: v0.3.0
```

---

## Status Command

At any prompt, user can type `status`:

```
🛑 Code review: 2 issues

fix | skip | abort
```

**User:** `status`

```
📊 Current State

Milestone: m3
Phase: 2 of 3
Issue: #09 — Add rate limiting (#244)
PR: #317 (open)

Progress:
  ✅ Done: 8
  ⏳ Current: 1
  📋 Remaining: 3
  ⏭️ Skipped: 2

Open PRs: 5
  #313, #314, #315, #316, #317

---

🛑 Code review: 2 issues

fix | skip | abort
```