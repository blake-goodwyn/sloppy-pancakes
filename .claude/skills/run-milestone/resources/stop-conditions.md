# Stop Conditions Reference v2.0.0

## Overview

Stop conditions are categorized into three tiers:

1. **Hard Stops** — Prompt user (or auto-handle in autonomous mode)
2. **Elevated Soft Stops** — Auto-continue with PR label
3. **Soft Stops** — Auto-skip silently

---

## Critical Safety Stops

These stops are **never auto-skipped**, even in autonomous mode.

### 0. PR Targets `main` Branch

**Trigger:** Attempt to create PR with `--base main`

**Detection:** PR base branch is `main` or `master`

**Prompt:**
```
🚨 SAFETY VIOLATION: PR targets main

PRs must target milestone branch, not main.
Expected: --base milestone/m5-detection-ingest
Actual:   --base main

This is a hard block. Cannot proceed.

abort (required)
```

**Autonomous:** Immediate halt, alert sent.

---

### 0b. Direct Push to `main`

**Trigger:** Attempt to push directly to `main`

**Prompt:**
```
🚨 SAFETY VIOLATION: Direct push to main

Agents must never push directly to main.
All changes must go through PRs to milestone branch.

abort (required)
```

**Autonomous:** Immediate halt, alert sent.

---

### 0c. Secret Exposure Detected

**Trigger:** Secret pattern found in output/diff

**Patterns:**
- `ghp_[a-zA-Z0-9]{36}` — GitHub token
- `sk-[a-zA-Z0-9]{48}` — OpenAI key
- `AKIA[A-Z0-9]{16}` — AWS access key
- `-----BEGIN.*PRIVATE KEY-----` — Private key
- Password/secret/token assignments

**Prompt:**
```
🚨 SECRET EXPOSURE DETECTED

Pattern: GitHub token
Location: src/config.py line 23
Content: ghp_xxxx[REDACTED]

IMMEDIATE ACTION REQUIRED:
1. Output blocked from notifications
2. Execution halted
3. Token may be compromised — rotate immediately

Revoke and rotate credentials now.

abort (required)
```

**Autonomous:** Immediate halt, output blocked, alert sent.

**Post-incident:**
1. Revoke exposed token
2. Check git history
3. Rotate all potentially exposed secrets

---

### 0d. CI Checks Failing (Auto-Merge Block)

**Trigger:** Required CI checks not passing

**Prompt:**
```
🛑 CI checks failing — auto-merge blocked

Failed checks:
  ✗ test (exit 1)
  ✓ lint
  ✗ typecheck (exit 1)

PR #315 cannot be auto-merged.

fix | skip | abort
```

**Autonomous:** Retry once, then skip issue.

---

### 0e. Protected Surface Modified

**Trigger:** Changes to auth, secrets, infra, or CI

**Protected patterns:**
- `**/auth/**`, `**/middleware/auth*`
- `**/.env*`, `**/secrets*`
- `**/deploy/**`, `**/infra/**`
- `.github/workflows/**`

**Prompt:**
```
🛑 Protected surface modified

Files:
  - src/middleware/auth.py
  - .github/workflows/ci.yml

These require human review. PR labeled: needs-human

continue (PR stays open) | abort
```

**Autonomous:** Label `needs-human`, continue to next issue.

---

## Kill Switch

### Trigger

User command: `panic`

Or external signal: `SIGTERM`, `SIGINT`

### Behavior

```
🚨 PANIC — Kill Switch Activated

1. ✓ Execution halted immediately
2. ✓ Current state saved to IMPLEMENTATION_PLAN.md
3. ✓ Open PR #315 left as draft
4. ✓ Telegram alert sent

Token revocation:
  GitHub: gh auth logout
  
Resume later with: run-milestone m5

Revoke tokens now? yes | no
```

### What Gets Saved

- Current issue and task number
- PRs created (IDs and status)
- Phase progress
- Stop condition that was active

### What Must Be Revoked

- GitHub token (`gh auth logout`)
- Any API keys in environment
- Database connections

### Manual Kill

```bash
# Terminal
pkill -f "claude"
pkill -f "run-milestone"

# Revoke tokens
gh auth logout
```

---

## Hard Stops

### 1. TDD Violation

**Trigger:** Implementation code detected before corresponding test

**Detection:**
- File modified that isn't a test file
- No corresponding test file change in same commit
- Test passes immediately without implementation

**Prompt:**
```
🛑 TDD Violation: implementation before test

Detected: src/models/user.py modified
Expected: tests/models/test_user.py first

restart | skip | abort
```

**Commands:**
- `restart` — Delete implementation, restart at RED
- `skip` — Skip issue
- `abort` — Stop milestone

**Autonomous:** Auto-restart (max 2), then auto-skip

---

### 2. Spec Compliance Issues (Stage 1 Review)

**Trigger:** Implementation doesn't match issue spec

**Types:**
- Missing acceptance criteria
- Extra functionality (YAGNI violation)
- Path/contract mismatch

**Prompt:**
```
🛑 Spec compliance: 2 issues (attempt 1/2)

1. Missing: rate limiting (criterion #3)
2. Extra: caching layer (not in spec)

fix | skip | abort
```

**Commands:**
- `fix` — Address issues, re-review Stage 1
- `skip` — Skip issue
- `abort` — Stop milestone

**Autonomous:** Auto-fix (max 2), then auto-skip

---

### 3. Code Quality Issues (Stage 2 Review)

**Trigger:** Code has quality problems

**Severity:**
- `[CRITICAL]` — Must fix (security, data loss)
- `[WARNING]` — Should fix (patterns, performance)

**Prompt:**
```
🛑 Code quality: 1 critical issue (attempt 1/2)

1. [CRITICAL] SQL injection — src/api/users.py#L45

fix | skip | abort
```

**Commands:**
- `fix` — Address issues, re-review Stage 2 only
- `skip` — Skip issue
- `abort` — Stop milestone

**Note:** Warnings alone don't block; only CRITICAL issues require fix.

**Autonomous:** Auto-fix (max 2), then auto-skip

---

### 4. Breaking Schema Changes

**Trigger:** Destructive migrations
- `DROP TABLE`, `DROP COLUMN`
- Column type changes
- Column renames

**Prompt:**
```
🛑 Breaking schema: DROP COLUMN "legacy_status"

File: alembic/versions/005_remove_legacy.py
Risk: Data loss (column has 50k rows)

approve | skip | abort
```

**Commands:**
- `approve` — Accept risk, continue
- `skip` — Skip issue
- `abort` — Stop milestone

**Autonomous:** Auto-skip (logged for manual review)

---

### 5. License/Security Dependencies

**Trigger:**
- Restrictive license (GPL, AGPL, SSPL)
- Security advisory
- Unknown license

**Prompt:**
```
🛑 License: some-pkg v2.0.0 (GPL-3.0)

approve | skip | abort
```

**Autonomous:** Auto-skip

---

### 6. Cross-Boundary Sensitive Code

**Trigger:** Sensitive code modified outside scope
- Auth code in non-auth milestone
- Billing code in non-billing milestone

**Prompt:**
```
🛑 Scope creep: auth code in M5.1 (detection)

Modified: src/middleware/auth.py
Scope tags: [detection, ingest]

approve | skip | abort
```

**Note:** If milestone IS scoped for that area → Elevated Soft Stop instead.

**Autonomous:** Auto-skip

---

### 7. Issue Spec Problems

**Trigger:**
- Missing `github_issue` field
- No tasks defined
- Unclear acceptance criteria

**Prompt:**
```
🛑 Issue spec problem: no tasks defined

File: 05-caching.md
Recommendation: Use /interview to refine spec

skip | abort
```

**Commands:** `skip` or `abort` only (no `fix` — requires manual spec edit)

**Autonomous:** Auto-skip

---

### 8. Phase Boundary

**Trigger:** Last issue in phase has PR created

**Prompt:**
```
✓ Phase 1 complete — 5 PRs ready

* PR #310 — Add models (#295) ✓
* PR #311 — Add endpoints (#296) ✓
* PR #312 — Add validation (#297) [needs-test-review]
* PR #313 — Add service (#298) ✓
* PR #314 — Add migration (#299) [needs-db-review]

continue | skip-phase | abort
```

**Commands:**
- `continue` — Approve phase, start next
- `skip-phase` — Skip remaining issues in phase
- `abort` — Stop milestone

**Autonomous:** Auto-continue

---

### 9. Test Failures (after auto-fix)

**Trigger:** Tests still failing after ruff auto-fix

**Prompt:**
```
🛑 Tests failing (attempt 1/2)

Failed:
- test_user_validation
- test_user_creation

fix | skip | abort
```

**Autonomous:** Auto-fix (max 2), then auto-skip

---

### 10. Git/PR Errors

**Trigger:** Git or GitHub CLI operation failed

**Prompt:**
```
🛑 Push failed

Error: Permission denied (publickey)

retry | skip | abort
```

**Commands:**
- `retry` — Re-attempt operation
- `skip` — Skip issue
- `abort` — Stop milestone

**Autonomous:** Auto-retry (max 2), then auto-skip

---

## Elevated Soft Stops

Auto-continue with label. User not prompted.

### 1. Additive Schema Changes

**Trigger:** Safe migrations
- `CREATE TABLE`
- `ADD COLUMN` (with default)
- `CREATE INDEX`

**Label:** `needs-db-review`

---

### 2. Permissive License Dependencies

**Trigger:** New packages with permissive license
- MIT, Apache-2.0, BSD, ISC, MPL-2.0

**Label:** `needs-dep-review`

---

### 3. In-Scope Sensitive Code

**Trigger:** Sensitive code in matching milestone
- Auth in M3 (auth milestone)
- Billing in M11 (billing milestone)

**Label:** `sensitive-review`

---

### 4. Low Test Coverage

**Trigger:** Coverage delta < 50% for changed lines

**Label:** `needs-test-review`

---

### 5. Lockfile-Only Changes

**Trigger:** Only lockfiles modified

**Label:** `lockfile-update`

---

## Soft Stops

Auto-skip silently. Logged but no prompt.

### 1. Large Diff

**Trigger:**
- >8 files changed, OR
- >400 lines added+removed

**Action:** Skip, log reason

---

### 2. Merge Conflicts

**Trigger:** Cannot push or rebase cleanly

**Action:** Skip, log details

---

### 3. Code Review Timeout

**Trigger:** No review response after 2 minutes

**Action:** Mark pending, continue

---

## Autonomous Mode Summary

| Stop Type | Autonomous Behavior |
|-----------|---------------------|
| TDD violation | Auto-restart (2x), then skip |
| Spec compliance | Auto-fix (2x), then skip |
| Code quality | Auto-fix (2x), then skip |
| Breaking schema | Skip (flag for review) |
| License issues | Skip (flag for review) |
| Cross-boundary | Skip (flag for review) |
| Spec problems | Skip |
| Phase boundary | Auto-continue |
| Test failures | Auto-fix (2x), then skip |
| Git errors | Auto-retry (2x), then skip |

---

## Required Labels

| Label | Color | When |
|-------|-------|------|
| `needs-db-review` | `#D93F0B` | Additive schema |
| `needs-dep-review` | `#FBCA04` | Permissive license |
| `sensitive-review` | `#B60205` | In-scope sensitive |
| `needs-test-review` | `#1D76DB` | Low coverage |
| `lockfile-update` | `#C5DEF5` | Lockfile only |
| `tdd-violation` | `#FF0000` | TDD cycle broken |
| `auto-skipped` | `#FFA500` | Skipped in autonomous |

---

## Command Reference

| Command | When | Effect |
|---------|------|--------|
| `panic` | Any time | **Kill switch** — halt, save state, revoke tokens |
| `continue` | Phase boundary | Approve, proceed |
| `fix` | Review issues, tests | Attempt fix, retry |
| `skip` | Any hard stop | Skip issue |
| `approve` | Schema, license, scope | Accept risk |
| `abort` | Any hard stop | Stop milestone |
| `restart` | TDD violation | Restart at RED |
| `retry` | Git errors | Re-attempt operation |
| `status` | Any time | Show state |
