---
name: run-milestone
description: Automate milestone development with TDD enforcement, two-stage code review, and multiple execution modes (interactive, autonomous, subagent-driven)
version: 2.0.0
author: {{OWNER_NAME}}
tags: [development, workflow, automation, milestone, pr, tdd]
requires:
  - skill: plan-review
    when: bootstrap
  - skill: interview  
    when: issue_spec_unclear
recommends:
  - skill: systematic-debugging
    when: test_failure_persists
  - skill: test-driven-development
    when: implementation
---

# Run Milestone Skill

## Purpose

This skill automates milestone development using disciplined engineering practices: test-driven development, two-stage code review, and isolated git worktrees. It supports three execution modes from fully interactive to fully autonomous with subagent orchestration.

## When to Use

- Starting work on a new milestone
- Continuing an in-progress milestone
- Running milestone automation overnight (autonomous mode)
- Delegating implementation to subagents (subagent mode)

## Core Workflow

```
Bootstrap (worktree + quality gate)
           ↓
    Select Next Issue
           ↓
    ┌──────────────────────────────────┐
    │  For Each Task (2-5 min):        │
    │    1. Write failing test (RED)   │
    │    2. Implement (GREEN)          │
    │    3. Refactor                   │
    │    4. Commit                     │
    └──────────────────────────────────┘
           ↓
    Two-Stage Code Review
      Stage 1: Spec Compliance
      Stage 2: Code Quality
           ↓
    Create PR → Next Issue
           ↓
    Phase Boundary → User Review
           ↓
    Milestone Complete (cleanup worktree)
```

## Input

```
run-milestone <milestone> [flags]
```

### Milestone Identifier

- Format: `m{n}` or `m{n.x}` (e.g., `m3`, `M3`, `3`, `m4.1`)
- Normalization: Converts to lowercase `m{n}` or `m{n.x}`

### Execution Mode Flags

| Flag | Mode | Description |
|------|------|-------------|
| (default) | Interactive | User commands at all stop points |
| `--autonomous` | Autonomous | No prompts, auto-fix/skip, summary at end |
| `--subagent` | Subagent-Driven | Fresh agent per issue with reviewers |

### Other Flags

| Flag | Effect |
|------|--------|
| `--skip-code-review` | Skip automated code review |
| `--skip-plan-review` | Skip pre-execution quality gate |
| `--dry-run` | Preview without executing |
| `--verbose` | Detailed decision logging |
| `--metrics` | Output workflow metrics |
| `--no-worktree` | Use current directory (skip worktree) |

## Execution Modes

### Mode 1: Interactive (Default)

```bash
run-milestone m5
```

- Prompts user at every stop condition
- Commands: `fix | skip | approve | continue | abort`
- Best for: First runs, sensitive milestones, learning

### Mode 2: Autonomous

```bash
run-milestone m5 --autonomous
```

- No prompts except critical errors
- Auto-fix attempts (max 2), then auto-skip
- Auto-approve elevated soft stops
- Generates comprehensive summary at end
- Best for: Well-defined milestones, overnight runs

### Mode 3: Subagent-Driven

```bash
run-milestone m5 --subagent
```

- Orchestrator dispatches fresh subagent per issue
- Separate reviewer subagents for each review stage
- Maximum autonomy with quality gates
- Best for: Large milestones, maximum parallelism

## In-Chat Commands

### Universal Commands

| Command | Effect |
|---------|--------|
| `continue` | Approve and proceed |
| `fix` | Attempt fix, then retry |
| `skip` | Skip issue, continue to next |
| `approve` | Acknowledge risk, proceed |
| `abort` | Stop milestone (resume later) |
| `status` | Show current state |
| `help` | Show available commands |

### Context-Specific Availability

| Scenario | Commands |
|----------|----------|
| Spec compliance issues | `fix` `skip` `abort` |
| Code quality issues | `fix` `skip` `abort` |
| TDD violation | `restart` `skip` `abort` |
| Breaking schema | `approve` `skip` `abort` |
| Phase boundary | `continue` `skip-phase` `abort` |

### Kill Switch Command

| Command | Effect |
|---------|--------|
| `panic` | **Immediate halt** — stop all runs, save state, revoke tokens |

**Behavior:**
1. Stop current execution immediately
2. Save state to IMPLEMENTATION_PLAN.md
3. Close any pending operations
4. Log panic event with timestamp
5. If remote: send alert to Telegram
6. Prompt for token revocation

```
🚨 PANIC triggered

✓ Execution halted
✓ State saved to IMPLEMENTATION_PLAN.md
✓ PR #315 left in draft

Revoke GitHub token? yes | no
```

**Manual kill switch:**
```bash
pkill -f "claude"
gh auth logout
```

---

## Branch Strategy & Merge Policy

### Two-Tier Integration

```
main (protected — human only)
  ↑
  │ Requires: human approval + all checks
  │
milestone/m5-name (agent integration)
  ↑
  │ Auto-merge: CI green + policy pass
  │
feat/m5-301-slug (agent work)
```

### CRITICAL: Never Target `main`

**Agents must NEVER create PRs targeting `main` directly.**

```bash
# ✅ CORRECT
gh pr create --base milestone/m5-detection-ingest

# ❌ FORBIDDEN — hard stop triggered
gh pr create --base main
```

If `--base main` is detected, workflow halts immediately.

### Auto-Merge Policy (Milestone Branch Only)

PRs into `milestone/*` can auto-merge when ALL conditions met:

**Hard Requirements:**
- [ ] CI checks passing (all required)
- [ ] Branch up-to-date with base
- [ ] No merge conflicts
- [ ] No protected-surface changes (or labeled `needs-human`)

**Protected Surfaces (require human review):**

| Surface | Files/Patterns | Auto Label |
|---------|----------------|------------|
| Auth | `**/auth/**`, `**/middleware/auth*` | `needs-human` |
| Secrets | `**/.env*`, `**/secrets*`, `**/credentials*` | `needs-human` |
| Infrastructure | `**/deploy/**`, `**/infra/**`, `Dockerfile*` | `needs-human` |
| CI/CD | `.github/workflows/**`, `**/ci/**` | `needs-human` |
| Schema migrations | `**/migrations/**`, `**/alembic/**` | `needs-db-review` |
| Dependencies | `requirements*.txt`, `package*.json`, `*.lock` | `needs-dep-review` |

**Auto-Merge Allowed:**
- Documentation changes
- Test additions (with coverage)
- Refactors (tests pass, no behavior change)
- Bug fixes (with regression test)
- Features (all acceptance criteria met)

### CI is the Judge

```
┌─────────────────────────────┐
│ PR ready for merge?         │
└──────────────┬──────────────┘
               ↓
        CI checks pass?
               │
      No ──────┼────── Yes
               │         │
               ↓         ↓
         ┌─────────┐   Protected
         │ BLOCKED │   surface?
         └─────────┘     │
                   Yes ──┼── No
                         │     │
                         ↓     ↓
                   ┌─────────┐ │
                   │needs-   │ │
                   │human    │ │
                   │label    │ │
                   └─────────┘ │
                               ↓
                         AUTO-MERGE ✓
```

**No green CI = No merge.** No exceptions.

---

## Security & Secrets

### No Production Secrets Rule

**Assume anything printed can leak** via logs, notifications, or transcripts.

**Environment Setup:**
```bash
# ✅ Dev-only tokens with minimal scope
GITHUB_TOKEN=ghp_dev_only_token  # repo scope only
DATABASE_URL=postgresql://localhost/dev_db

# ❌ NEVER in agent environment
PROD_DATABASE_URL=...
AWS_SECRET_ACCESS_KEY=...
STRIPE_SECRET_KEY=...
```

**Required GitHub Scopes (minimum):**
- `repo` — Read/write repository (branches, PRs, issues)
- `read:org` — Read organization membership (for team checks)
- `workflow` — Read workflow runs (for CI status)

**Explicitly NOT needed (never grant):**
- `delete_repo` — Can destroy repository
- `admin:org` — Can modify organization settings
- `admin:repo_hook` — Can modify webhooks

**Other services:**
- Database: dev/test only, no prod access
- APIs: sandbox/test keys only

### Output Redaction

Before forwarding to Telegram/notifications:

```python
REDACT_PATTERNS = [
    r'ghp_[a-zA-Z0-9]{36}',      # GitHub tokens
    r'sk-[a-zA-Z0-9]{48}',        # OpenAI keys
    r'AKIA[A-Z0-9]{16}',          # AWS access keys
    r'(?i)password\s*[=:]\s*\S+', # Passwords
    r'(?i)secret\s*[=:]\s*\S+',   # Secrets
    r'(?i)token\s*[=:]\s*\S+',    # Tokens
]

def redact(text: str) -> str:
    for pattern in REDACT_PATTERNS:
        text = re.sub(pattern, '[REDACTED]', text)
    return text
```

### Secret Exposure Response

If secret pattern detected in output:

```
🚨 SECRET EXPOSURE DETECTED

Pattern: GitHub token (ghp_...)
Location: stdout line 47

Action taken:
✗ Output blocked from Telegram
✗ Execution halted
⚠️ Token may be compromised

IMMEDIATE ACTION REQUIRED:
1. Revoke token: gh auth logout && gh auth login
2. Rotate any exposed credentials
3. Check git history for commits

abort (required)
```

---

## Test-Driven Development (Mandatory)

**Every implementation follows the RED-GREEN-REFACTOR cycle.**

### The TDD Cycle

#### Step 1: RED — Write Failing Test

```bash
# Write test for specific behavior
pytest tests/ -k "test_new_feature" -v
# MUST see FAILED (red)
```

**If test passes:** Test is wrong or behavior exists. Rewrite test.

#### Step 2: GREEN — Minimal Implementation

```bash
# Write minimum code to pass test
pytest tests/ -k "test_new_feature" -v
# MUST see PASSED (green)
```

**If tempted to add extra:** Don't. YAGNI (You Aren't Gonna Need It).

#### Step 3: REFACTOR

```bash
# Clean up while keeping tests green
pytest tests/
# All tests must pass
```

#### Step 4: COMMIT

```bash
git add -A
git commit -m "feat(m<X>): <behavior> (#<issue>)"
```

### TDD Violations

| Violation | Action |
|-----------|--------|
| Implementation before test | Delete code, restart at RED |
| Test passes immediately | Rewrite test to be meaningful |
| Multiple behaviors at once | Revert, do one at a time |

```
🛑 TDD Violation: implementation code before test

Detected: src/models/user.py modified before test written

restart | skip | abort
```

---

## Two-Stage Code Review

### Stage 1: Spec Compliance

**Question:** Does implementation match issue spec exactly?

**Checklist:**
- [ ] All acceptance criteria addressed?
- [ ] No extra functionality added? (YAGNI)
- [ ] File paths match spec?
- [ ] API contracts match spec?
- [ ] Test coverage matches expectations?

```
🛑 Spec compliance: 2 issues (attempt 1/2)

1. Missing: rate limiting (criterion #3)
2. Extra: added caching (not in spec)

fix | skip | abort
```

**Fix behavior:** Address spec gaps, remove extras, re-review Stage 1.

### Stage 2: Code Quality

**Only runs after Stage 1 passes.**

**Question:** Is the code well-written?

**Checklist:**
- [ ] Clean code patterns?
- [ ] Security vulnerabilities?
- [ ] Performance anti-patterns?
- [ ] Adequate error handling?
- [ ] Proper documentation?

```
🛑 Code quality: 1 issue (attempt 1/2)

1. [CRITICAL] SQL injection — src/api/users.py#L45

fix | skip | abort
```

**Fix behavior:** Address quality issues, re-review Stage 2 only.

### Review Flow

```
Implementation Complete
        ↓
┌─────────────────────────┐
│ Stage 1: Spec Compliance │
└───────────┬─────────────┘
            ↓
      Pass? ──No──→ Fix → Re-review Stage 1
            │
           Yes
            ↓
┌─────────────────────────┐
│ Stage 2: Code Quality    │
└───────────┬─────────────┘
            ↓
      Pass? ──No──→ Fix → Re-review Stage 2
            │
           Yes
            ↓
      Create PR
```

---

## Issue Spec Format (Task-Level)

Issues contain 2-5 minute tasks with explicit RED/GREEN code.

```markdown
---
title: "Add user authentication"
github_issue: 301
priority: P0
dependencies: []
estimated_tasks: 5
---

# Add User Authentication

## Done Definition

Users can register and login via API.

## Tasks

### Task 1: Create User model (3 min)

**Files:**
- Create: `src/models/user.py`
- Test: `tests/models/test_user.py`

**RED:**
```python
def test_user_has_email_and_hashed_password():
    user = User(email="test@example.com", password="secret")
    assert user.email == "test@example.com"
    assert user.password_hash != "secret"
```

**GREEN:**
```python
class User:
    def __init__(self, email: str, password: str):
        self.email = email
        self.password_hash = hash_password(password)
```

**Verify:** `pytest tests/models/test_user.py -v`

---

### Task 2: Add password hashing (3 min)

**Files:**
- Create: `src/utils/crypto.py`
- Test: `tests/utils/test_crypto.py`

**RED:**
```python
def test_hash_password_returns_different_value():
    assert hash_password("secret") != "secret"
```

**GREEN:**
```python
import bcrypt
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
```

**Verify:** `pytest tests/utils/test_crypto.py -v`

---

### Task 3: Add registration endpoint (5 min)

...

## Acceptance Criteria

- [ ] POST /api/auth/register creates user
- [ ] POST /api/auth/login returns token
- [ ] Passwords are hashed with bcrypt
```

---

## Git Worktrees

### Why Worktrees?

- Main branch never polluted during development
- Can work on multiple milestones in parallel
- Clean test baseline guaranteed
- Easy to discard failed attempts

### Bootstrap: Create Worktree

```bash
# Create isolated worktree for milestone
WORKTREE_PATH="../$(basename $PWD)-m<X>"
git worktree add "$WORKTREE_PATH" -b milestone/m<X>-<name>

# Change to worktree
cd "$WORKTREE_PATH"

# Verify clean baseline
git status        # Should be clean
pytest tests/     # Should pass
```

### Completion: Remove Worktree

```bash
# Return to main project
cd ../<main-project>

# Remove worktree
git worktree remove "../<project>-m<X>"
git worktree prune
```

### Abort: Discard Worktree

```bash
git worktree remove --force "../<project>-m<X>"
```

---

## Execution Steps

### 1. Bootstrap

#### Step 0: Quality Gate (first run only)

```
Skill(skill="plan-review", args=IMPLEMENTATION_PLAN_PATH)
```

| Result | Action |
|--------|--------|
| Critical issues | Prompt: `approve \| abort` |
| Warnings | Log, continue |
| Clean | Continue |

#### Steps 1-6: Validation

1. Normalize milestone identifier
2. Verify milestone folder exists
3. Load Implementation Plan
4. Determine base branch
5. Validate base branch exists
6. Run plan integrity checks

#### Step 7: Create Worktree

```bash
WORKTREE="../$(basename $PWD)-m<X>"
git worktree add "$WORKTREE" -b milestone/m<X>-<name>
cd "$WORKTREE"
```

**Skip with `--no-worktree` flag.**

#### Step 8: Verify Clean Baseline

```bash
pytest tests/
# All tests MUST pass before starting
```

If failures: STOP. Do not proceed with failing baseline.

#### Step 9: Validate State Consistency

Cross-check plan against GitHub:
```bash
gh pr list --base <branch> --state open --json number,title
```

### 2. Reconcile

1. List open PRs targeting base branch
2. Update plan if PRs merged
3. Map PR → issue

### 3. Select Next Issue

Priority: P0 → P1, top-to-bottom
Skip: Done, Blocked, unmet dependencies

### 4. Execute Issue (Task-by-Task)

For each issue:

```
┌────────────────────────────────────────────┐
│ For each task in issue:                    │
│                                            │
│   1. Read task spec                        │
│   2. Write failing test (RED)              │
│   3. Verify test fails                     │
│   4. Implement minimal code (GREEN)        │
│   5. Verify test passes                    │
│   6. Refactor (keep green)                 │
│   7. Commit with task description          │
│                                            │
│ After all tasks:                           │
│   8. Run full test suite                   │
│   9. Pre-commit auto-fix (ruff)            │
│  10. Push branch                           │
│  11. Two-stage code review                 │
│  12. Create PR                             │
└────────────────────────────────────────────┘
```

### 5. Code Review

#### Stage 1: Spec Compliance

Check implementation against issue spec:
- All criteria met?
- Nothing extra?
- Paths/contracts match?

If issues → prompt → fix → re-review Stage 1

#### Stage 2: Code Quality

Check code quality:
- Security?
- Performance?
- Patterns?

If issues → prompt → fix → re-review Stage 2

### 6. Create PR

```bash
gh pr create \
  --title "feat(m<X>): <title> (#<issue>)" \
  --body "<description>" \
  --base milestone/m<X>-<name> \
  --label "<labels>"
```


**CRITICAL: Always target milestone branch, never `main`.**

**Auto-merge (milestone PRs only):**
```bash
# If CI green and no protected surfaces
gh pr merge --auto --squash
```


### 7. Loop

Continue until:
- All issues complete
- User aborts
- No eligible issues

---

## Subagent-Driven Mode (Experimental)

> **Note:** Subagent mode requires Claude Code with subagent dispatch support.
> This mode is experimental and the orchestration mechanism may change.

### Architecture

```
Orchestrator (this session)
    │
    ├── Per Issue:
    │   │
    │   ├── Dispatch Implementer Subagent
    │   │   └── Executes tasks with TDD
    │   │   └── Commits after each task
    │   │
    │   ├── Dispatch Spec Reviewer Subagent
    │   │   └── Reviews against issue spec
    │   │   └── Returns: PASS or issues
    │   │
    │   ├── (If issues) Implementer fixes → re-review
    │   │
    │   ├── Dispatch Quality Reviewer Subagent
    │   │   └── Reviews code quality
    │   │   └── Returns: APPROVED or issues
    │   │
    │   ├── (If issues) Implementer fixes → re-review
    │   │
    │   └── Create PR
    │
    └── Phase boundary: prompt user
```

### Subagent Prompts

#### Implementer Prompt

```markdown
You are implementing Issue #<N> for Milestone <M>.

## Issue Spec
<attached>

## Instructions
1. Execute each task using TDD:
   - Write failing test, verify RED
   - Implement minimal code, verify GREEN
   - Refactor, keep GREEN
   - Commit: "feat(m<X>): <task> (#<issue>)"
2. Run full test suite after all tasks
3. Report: tasks done, tests passing, files changed

## Constraints
- NO extra functionality (YAGNI)
- NO skipping tests
- NO committing failing code
```

#### Spec Reviewer Prompt

```markdown
You are reviewing for spec compliance.

## Issue Spec
<attached>

## Git Diff
<attached>

## Check
1. All acceptance criteria met?
2. Any extra functionality?
3. Paths/contracts match spec?

## Response
PASS — if compliant
ISSUES — list what's missing/extra/wrong
```

#### Quality Reviewer Prompt

```markdown
You are reviewing code quality.

## Diff
<attached>

## Check
1. Security vulnerabilities?
2. Performance issues?
3. Error handling?
4. Code clarity?

## Response
APPROVED — if quality is good
ISSUES — [CRITICAL] or [WARNING] with locations
```

---

## Stop Conditions

### Hard Stops (Prompt User)

| Condition | Prompt |
|-----------|--------|
| TDD violation | `restart \| skip \| abort` |
| Spec compliance issues | `fix \| skip \| abort` |
| Code quality issues | `fix \| skip \| abort` |
| Breaking schema | `approve \| skip \| abort` |
| Restrictive license | `approve \| skip \| abort` |
| Cross-boundary code | `approve \| skip \| abort` |
| Phase boundary | `continue \| skip-phase \| abort` |

### Elevated Soft Stops (Auto-Continue with Label)

| Condition | Label |
|-----------|-------|
| Additive schema | `needs-db-review` |
| Permissive license dep | `needs-dep-review` |
| In-scope sensitive code | `sensitive-review` |
| Low test coverage (<50%) | `needs-test-review` |

### Soft Stops (Auto-Skip)

| Condition | Action |
|-----------|--------|
| Large diff (>8 files, >400 lines) | Skip, log |
| Merge conflicts | Skip, log |
| Review timeout (2 min) | Mark pending, continue |

---

## Autonomous Mode Behavior

When `--autonomous`:

| Condition | Behavior |
|-----------|----------|
| TDD violation | Auto-restart (max 2), then skip |
| Spec issues | Auto-fix (max 2), then skip |
| Quality issues | Auto-fix (max 2), then skip |
| Breaking schema | Skip (log for manual review) |
| Phase boundary | Auto-continue |
| Critical error | STOP, alert user |

**Summary at end:**
```
═══════════════════════════════════════════════
Autonomous Run Complete: m5
═══════════════════════════════════════════════

Duration: 2h 34m
Issues: 12 attempted
  ✅ Completed: 10
  ⏭️ Auto-skipped: 2

Auto-skipped reasons:
  - #07: TDD violation persisted
  - #11: Breaking schema (needs approval)

PRs created: 10
  Review needed: 3 (breaking schema, low coverage)

Manual action required:
  - Review skipped issues
  - Approve PRs with labels
```

---

## Milestone Completion

```
═══════════════════════════════════════════════
✓ Milestone M5 Complete
═══════════════════════════════════════════════

Issues: 15 total
  ✅ Completed: 13
  ⏭️ Skipped: 2

PRs: 13 created
TDD cycles: 47 (all compliant)
Review stages: 26 (13 × 2)

Labels applied:
  needs-db-review: 2
  sensitive-review: 1

Worktree: ../<project>-worktree (ready to remove)

Next steps:
1. Merge open PRs
2. Address skipped issues
3. Remove worktree:
   git worktree remove ../<project>-worktree
4. Create milestone PR → main
5. Tag: v0.5.0
```

---

## Recovery Procedures

### Resume After Abort

```bash
run-milestone m5
# Reconcile detects state, continues where stopped
```

### Discard Failed Attempt

```bash
cd ../main-project
git worktree remove --force ../project-m5
```

### Skip Stuck Issue

At prompt, type `skip`. Or manually:
1. Mark ⏭️ Skipped in IMPLEMENTATION_PLAN.md
2. Close any open PR
3. Re-run milestone

### Revert Bad Merge

```bash
git revert -m 1 <merge-sha>
git push origin <branch>
```

### Rollback Auto-Merged PR

If an auto-merged PR to milestone causes issues:

```bash
# Option 1: Revert the merge commit
git checkout milestone/m<X>-<n>
git revert -m 1 <merge-sha>
git push origin milestone/m<X>-<n>

# Option 2: Reset to before merge (if no subsequent work)
git checkout milestone/m<X>-<n>
git reset --hard <commit-before-merge>
git push --force origin milestone/m<X>-<n>

# Option 3: Close PR and recreate
gh pr close <pr-number>
# Fix issues on feature branch
# Create new PR
```

---

## Metrics (--metrics)

```json
{
  "milestone": "m5",
  "mode": "interactive",
  "duration_seconds": 5420,
  "issues": {
    "attempted": 15,
    "completed": 13,
    "skipped": 2
  },
  "tasks": {
    "total": 47,
    "tdd_compliant": 47,
    "tdd_violations": 0
  },
  "reviews": {
    "spec_pass_first_try": 11,
    "spec_required_fix": 2,
    "quality_pass_first_try": 12,
    "quality_required_fix": 1
  },
  "commands_used": {
    "continue": 3,
    "fix": 3,
    "skip": 2
  }
}
```

---

## Required Labels

| Label | Color | Description |
|-------|-------|-------------|
| `needs-human` | `#B60205` | Protected surface requires human review |
| `needs-db-review` | `#D93F0B` | Database migrations |
| `needs-dep-review` | `#FBCA04` | Dependency changes |
| `sensitive-review` | `#B60205` | Auth/billing code |
| `needs-test-review` | `#1D76DB` | Low coverage |
| `tdd-violation` | `#FF0000` | TDD cycle broken |

---

## Examples

### Example 1: TDD Cycle

```
═══════════════════════════════════════════════
Issue #03: Add validation service
Task 1/3: Create ValidationError class
═══════════════════════════════════════════════

📝 RED: Writing failing test...

```python
def test_validation_error_has_field_and_message():
    err = ValidationError("email", "invalid format")
    assert err.field == "email"
    assert err.message == "invalid format"
```

Running: pytest tests/test_validation.py -v
Result: FAILED ✓ (expected)

📝 GREEN: Implementing...

```python
class ValidationError(Exception):
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
```

Running: pytest tests/test_validation.py -v
Result: PASSED ✓

📝 REFACTOR: No changes needed

📝 COMMIT: feat(m5): add ValidationError class (#301)

→ Task 2/3: Add email validation
```

### Example 2: Two-Stage Review

```
═══════════════════════════════════════════════
Issue #03: All tasks complete
Running two-stage review...
═══════════════════════════════════════════════

Stage 1: Spec Compliance
├─ Acceptance criteria: ✓ All met
├─ Extra functionality: ✗ Found caching (not in spec)
└─ Result: ISSUES

🛑 Spec compliance: 1 issue

1. Extra: added caching layer (not in spec)

fix | skip | abort
```

User: `fix`

```
🔧 Removing extra functionality...
✓ Removed caching
✓ Tests passing
✓ Committed

Stage 1: Spec Compliance (retry)
└─ Result: PASS ✓

Stage 2: Code Quality
├─ Security: ✓ No issues
├─ Performance: ✓ OK
├─ Patterns: ✓ Clean
└─ Result: APPROVED ✓

✓ PR #315 created

→ Proceeding to Issue #04
```

### Example 3: Autonomous Mode

```
run-milestone m5 --autonomous
```

```
═══════════════════════════════════════════════
Autonomous Mode: m5
═══════════════════════════════════════════════

✓ Worktree created: ../<project>-worktree
✓ Quality gate passed
✓ Baseline tests passing

Issue #01: Add user model
  Tasks: 3/3 ✓
  Review: PASS/APPROVED
  PR #310 ✓

Issue #02: Add auth endpoints
  Tasks: 5/5 ✓
  Review: PASS/APPROVED
  PR #311 ✓

Issue #03: Add rate limiting
  Tasks: 2/4 ✗
  TDD violation (auto-restart 1/2)
  Tasks: 4/4 ✓
  Review: PASS/APPROVED
  PR #312 ✓

...

Issue #11: Remove legacy tables
  Breaking schema detected
  ⏭️ Auto-skipped (needs approval)

═══════════════════════════════════════════════
Autonomous Run Complete
═══════════════════════════════════════════════

Duration: 1h 47m
Completed: 10/12 issues
Skipped: 2 (review summary above)
```

---

## Limitations

- Requires GitHub CLI (`gh`)
- Subagent mode requires Claude Code with subagent support
- TDD enforcement requires test framework configured
- Worktrees require git 2.5+
- Two-stage review adds overhead (but catches issues earlier)

---

## See Also

- [plan-review](../plan-review/SKILL.md) — Quality gate
- [interview](../interview/SKILL.md) — Spec clarification
- [systematic-debugging](../systematic-debugging/SKILL.md) — Root cause debugging
- [test-driven-development](../test-driven-development/SKILL.md) — TDD cycle
- [create-milestone](../create-milestone/SKILL.md) — Generate milestone docs
