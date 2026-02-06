# Run Milestone Skill v2.0.0

Automate milestone development with **TDD enforcement**, **two-stage code review**, and **three execution modes** — designed for safe remote/autonomous operation.

---

## Day-1 Safety Rails

Before running autonomously (especially via Telegram bridge on a cloud VM), ensure these four guardrails are in place:

### 1. PR-Only Autonomy

Agents work on feature branches and create PRs. **Never direct push to `main`.**

- All work targets `milestone/...` branch
- You are the merge gate for `milestone → main`
- Agent cannot bypass PR workflow

### 2. CI is the Judge

No green CI = no merge. Period.

- Required checks must pass before auto-merge
- Even minimal tests + lint is enough to start
- Flaky tests block the pipeline (fix them first)

### 3. No Production Secrets

Assume anything printed can leak via logs/notifications.

- Use dev-only tokens with least privilege
- Never put production credentials in agent environment
- Redact sensitive output before forwarding to Telegram

### 4. Kill Switch

One command to stop everything:

```bash
# In chat or terminal
panic

# Or manually
pkill -f "claude"
gh auth logout
```

Revoke tokens, stop all runs, save state.

---

## Branch Strategy

```
main (protected)
  ↑
  │ Human review required
  │
milestone/m5-feature (agent integration branch)
  ↑
  │ Auto-merge when CI green
  │
feat/m5-301-add-model (agent feature branches)
feat/m5-302-add-api
feat/m5-303-add-tests
```

| Branch | Who Merges | Requirements |
|--------|------------|--------------|
| `feat/* → milestone/*` | Agent (auto) | CI green, no protected surfaces |
| `milestone/* → main` | **Human only** | Code review, all checks pass |

---

## GitHub Repository Settings

### Required Setup

```
Settings → Branches → Add rule

Branch: main
☑ Require a pull request before merging
  ☑ Require approvals: 1
  ☑ Dismiss stale approvals
☑ Require status checks to pass
  ☑ Require branches to be up to date
  Add checks: test, lint, typecheck
☑ Do not allow bypassing the above settings

Branch: milestone/*
☑ Require status checks to pass
  Add checks: test, lint
☐ Require approvals (optional for agent flow)
```

### Enable Auto-Merge

```
Settings → General → Pull Requests
☑ Allow auto-merge
```

Only for PRs into `milestone/*`, never into `main`.

---

## What's New in v2.0

| Feature | v1.4 | v2.0 |
|---------|------|------|
| TDD | Run tests after | RED-GREEN-REFACTOR enforced |
| Code Review | Single pass | Two-stage (spec + quality) |
| Task Granularity | 1-4 hour issues | 2-5 minute tasks |
| Git Isolation | Feature branches | Worktrees |
| Execution | Interactive only | Interactive / Autonomous / Subagent |

## Quick Start

```bash
# Interactive (default)
run-milestone m5

# Autonomous (overnight runs)
run-milestone m5 --autonomous

# Subagent-driven (maximum parallelism)
run-milestone m5 --subagent
```

## Execution Modes

### Interactive (Default)

User commands at every decision point:

```
🛑 Spec compliance: 1 issue

1. Extra: caching (not in spec)

fix | skip | abort
```

### Autonomous

No prompts, auto-fix/skip, summary at end:

```
run-milestone m5 --autonomous

# Runs unattended
# Auto-fixes issues (max 2 attempts)
# Auto-skips if stuck
# Summary when complete
```

### Subagent-Driven

Fresh agent per issue with dedicated reviewers:

```
Orchestrator
    ├── Implementer Subagent (TDD)
    ├── Spec Reviewer Subagent
    └── Quality Reviewer Subagent
```

## TDD Enforcement

Every task follows RED-GREEN-REFACTOR:

```
📝 RED: Writing failing test...
   pytest → FAILED ✓

📝 GREEN: Implementing...
   pytest → PASSED ✓

📝 REFACTOR: Cleaning up...
   pytest → PASSED ✓

📝 COMMIT: feat(m5): add validation (#301)
```

**Violations are caught:**
```
🛑 TDD Violation: code before test

restart | skip | abort
```

## Two-Stage Code Review

### Stage 1: Spec Compliance

Does it match the issue spec exactly?
- All criteria met?
- Nothing extra? (YAGNI)

### Stage 2: Code Quality

Is the code well-written?
- Security?
- Performance?
- Patterns?

## Task-Level Issue Specs

Issues now contain 2-5 minute tasks:

```markdown
### Task 1: Create User model (3 min)

**RED:**
```python
def test_user_has_email():
    user = User(email="test@example.com")
    assert user.email == "test@example.com"
```

**GREEN:**
```python
class User:
    def __init__(self, email: str):
        self.email = email
```
```

## Git Worktrees

Isolated workspace per milestone:

```bash
# Auto-created at bootstrap
../<project>-worktree/   # Milestone worktree

# Auto-cleaned on completion
git worktree remove ../<project>-worktree
```

## Commands

| Command | When | Effect |
|---------|------|--------|
| `continue` | Phase boundary | Proceed |
| `fix` | Review issues | Fix and retry |
| `skip` | Any stop | Skip issue |
| `approve` | Schema/license | Accept risk |
| `abort` | Any stop | Stop (resume later) |
| `restart` | TDD violation | Restart task |

## Flags

| Flag | Effect |
|------|--------|
| `--autonomous` | Unattended execution |
| `--subagent` | Subagent orchestration |
| `--dry-run` | Preview only |
| `--verbose` | Detailed logging |
| `--metrics` | Output metrics JSON |
| `--no-worktree` | Skip worktree creation |

## Workflow

```
1. Bootstrap
   - Quality gate (plan-review)
   - Create worktree
   - Verify test baseline

2. For each issue:
   - For each task (2-5 min):
     - RED: Write failing test
     - GREEN: Implement
     - REFACTOR: Clean up
     - COMMIT

3. Two-stage review:
   - Stage 1: Spec compliance
   - Stage 2: Code quality

4. Create PR

5. Phase boundary → User review

6. Milestone complete → Cleanup worktree
```

## Required Skills

| Skill | When |
|-------|------|
| `plan-review` | Bootstrap (quality gate) |
| `interview` | Unclear issue specs |

## Recommended Skills

| Skill | When |
|-------|------|
| `systematic-debugging` | Persistent test failures |
| `test-driven-development` | Implementation reference |

## Migration from v1.4

1. **Issue specs need tasks**: Break issues into 2-5 min tasks with RED/GREEN code
2. **Worktrees by default**: Use `--no-worktree` to opt out
3. **Two-stage review**: Spec compliance runs first, then quality
4. **TDD enforced**: Cannot write implementation before test

## See Also

- [SKILL.md](./SKILL.md) — Full specification
- [stop-conditions.md](./resources/stop-conditions.md) — All stop conditions
- [create-milestone](../create-milestone/SKILL.md) — Generate task-level specs
