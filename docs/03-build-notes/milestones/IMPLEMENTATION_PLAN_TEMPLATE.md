# M{n} Implementation Plan

This document outlines the complete implementation plan for M{n}: {Milestone Title}, integrating the [Implementation Workflow](../../guides/implementation-workflow.md).

**This file serves as the source of truth and progress manifest for the milestone.** All workflow tools (run-milestone command/skill) use this file to track progress, determine next issues, and update status.

## Overview

**Milestone:** `m{n}`
**Implementation Plan Path:** `docs/03-build-notes/m{n}/IMPLEMENTATION_PLAN.md`
**Milestone Folder:** `docs/03-build-notes/m{n}/`
**Milestone Branch:** `milestone/m{n}-<short-name>` (base branch for PRs; create from `main` if missing)
**Epic Issue:** #00 — "Epic: M{n} — {Milestone Title}"
**Total Issues:** {N} (including epic)
**Status:** Not Started | In Progress | Complete

## Autopilot Contract (run-milestone)

Autopilot mode executes issues with no explicit approvals required.

**Core policy**
- **One issue → one feature branch → one PR** (always)
- **Never commit directly** to the base branch
- Always open a PR and attempt to enable **auto-merge**
- Proceed issue-by-issue in priority order unless a **Stop Condition** is hit
- **GitHub issue numbers are the source of truth** for naming conventions (branches, commits, PRs)

**Base branch resolution**
- The agent uses the value of **Milestone Branch** above as the base branch.
- If that line is missing, the base branch defaults to `main`.

## Stop Conditions (per-issue)

### Hard Stops (Require User Attention - Workflow Pauses)

When any of these occur, the agent should **STOP work on that issue**, **alert the user**, and **wait for user action** before continuing:

1. **Database Changes:** Any DB migration or schema change is introduced or modified
2. **Sensitive Code Changes:** Auth, permissions, rate-limit, or billing code is touched
3. **Dependency Changes:** Dependency, lockfile, or license changes are made
4. **Issue Spec Problems:** Issue spec is missing, ambiguous, or dependencies are unclear

### Soft Stops (Skip Issue Automatically - Workflow Continues)

When any of these occur, attempt auto-fix if applicable, then **skip to next eligible issue** without prompting:

1. **Test/Lint/Typecheck Failures:** Auto-fix attempted (`ruff check --fix src/`), then skip if still failing
2. **Large Diff:** >8 files changed OR >400 lines added+removed - skip with warning
3. **Merge Conflicts:** Skip to next issue automatically

**How to record a stop**
- For Hard Stops: Mark the issue status as **⛔ Needs Review (STOP)** in the tracking sections below.
- For Soft Stops: Mark the issue status as **⏭️ Skipped** in the tracking sections below.
- Add a short "STOP reason" and what's needed from the user (decision, review, or guidance).
- If a PR already exists, link it and leave it as **draft** unless it is fully green.

## Always Load Context (required reads)

- `docs/guides/implementation-workflow.md`
- `docs/guides/dev-cadence.md`

## Issue Inventory (source of truth)

Issue specs live in: `docs/03-build-notes/m{n}/*.md`
Exclude:
- `IMPLEMENTATION_PLAN.md`
- `_milestone.md` (fallback plan, if used)
- `00-epic.md` (optional epic)

## Issue Breakdown by Phase (ordered execution list)

Execution order is:
1) P0 top-to-bottom, then 2) P1 top-to-bottom, respecting dependencies.

---

### Phase 1: {Phase Name} — Issues #01, #02
**Goal:** {Brief goal description}

| Issue # | Issue File | Title | Priority | Dependencies | Feature Branch | PR Title Token | Est. Size |
|---------|------------|-------|----------|--------------|----------------|----------------|-----------|
| #01 | 01-{short-name}.md | {Issue Title} | P0 | None | `feat/m{n}-01-{short-slug}` | `feat(m{n})` | S/M/L |
| #02 | 02-{short-name}.md | {Issue Title} | P0 | #01 | `feat/m{n}-02-{short-slug}` | `feat(m{n})` | S/M/L |

**Dependencies notes:** {Explain dependencies}

---

### Phase 2: {Phase Name} — Issue #03
**Goal:** {Brief goal description}

| Issue # | Issue File | Title | Priority | Dependencies | Feature Branch | PR Title Token | Est. Size |
|---------|------------|-------|----------|--------------|----------------|----------------|-----------|
| #03 | 03-{short-name}.md | {Issue Title} | P0 | None | `feat/m{n}-03-{short-slug}` | `feat(m{n})` | S/M/L |

**Dependencies notes:** {Explain dependencies}

---

{Add more phases as needed}

## Execution Workflow (agent checklist)

### 1) Bootstrap (once per run)

1. Verify `docs/03-build-notes/m{n}/` exists
2. Read this plan (`docs/03-build-notes/m{n}/IMPLEMENTATION_PLAN.md`) (if missing, STOP)
3. Determine base branch:
   - Use **Milestone Branch** value above if present
   - Else use `main`
4. Ensure base branch exists:
   - If milestone branch missing, create from `main` and push

### 2) Reconcile (each run)

- List open PRs targeting the base branch where the title contains `feat(m{n})` or `(m{n})`
- Update this plan's tracking sections:
  - "Open PRs (autopilot)" section
  - "Completed Issues" section for confidently merged PRs

### 3) Select next eligible issue

- Select next issue in this plan by:
  - P0 then P1
  - Top-to-bottom
  - Skip issues blocked by unmet dependencies
  - Skip issues already ✅ Done
  - Skip issues ⛔ Needs Review (STOP) unless user explicitly clears them
  - Skip issues ⏭️ Skipped (soft stop) unless user explicitly clears them

### 4) Execute one issue

```bash
# Sync base branch
git checkout milestone/m{n}-<short-name>
git pull
```

Create feature branch:

```bash
git checkout -b feat/m{n}-<ISSUE_NUMBER>-<SHORT_SLUG>
```

Implement exactly per spec:

* Read: `docs/03-build-notes/m{n}/<ISSUE_FILE>`
* Implement + tests together
* Run incremental tests while working

Run full checks (required before PR is marked ready):

```bash
pytest tests/
ruff check src/
mypy src/
```

**If lint fails:** Try auto-fix (`ruff check --fix src/`), then re-check
**If any check still fails after auto-fix:** Skip to next issue (soft stop)
- Record in "Blocked / Needs Review" section with failure reason
- Proceed to next eligible issue automatically

### 5) Create PR (always)

Commit message format:

```
{type}(m{n}): {brief description}

Implements issue #<ISSUE_NUMBER>: <ISSUE_TITLE>

- {change 1}
- {change 2}

Closes #<ISSUE_NUMBER>
```

Push + create PR targeting base branch:

```bash
git push origin feat/m{n}-<ISSUE_NUMBER>-<SHORT_SLUG>

gh pr create \
  --title "feat(m{n}): <ISSUE_TITLE> (#<ISSUE_NUMBER>)" \
  --base "milestone/m{n}-<short-name>" \
  --body "Implements issue #<ISSUE_NUMBER>: <ISSUE_TITLE>

## Changes
- <change 1>
- <change 2>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

Closes #<ISSUE_NUMBER>"
```

Attempt to enable auto-merge:

```bash
gh pr merge --auto --squash --delete-branch
```

**If auto-merge cannot be enabled → STOP (per-issue).**

* Report why (e.g., branch protection, required reviews, failing checks)
* Record in "Blocked / Needs Review" section
* Proceed to next eligible issue (if any)

### 6) Update this Implementation Plan

**This is critical:** Always update the tracking sections below after creating a PR or when status changes:

1. **Add PR entry** to "Open PRs (autopilot)" section:
   - Issue #, PR link, status (checks pending/green)

2. **Update "Completed Issues"** when PR merges:
   - Mark checkbox as ✅ Done
   - Add PR link if not already present

3. **Update "Current Phase"** and "Current Issue"**:
   - Update to next planned issue
   - Update phase if phase changed

## Milestone Completion Checklist (before base → main)

### 1) All Issues Closed

* [ ] All milestone issues are closed (auto-closed via PR merges)
* [ ] Epic updated to reflect completion

### 2) Run Full CI

```bash
pytest tests/
ruff check src/
mypy src/
```

### 3) Run Integration / Performance Tests (if applicable)

```bash
docker-compose up -d
pytest tests/integration/
```

### 4) Verify Epic Acceptance Criteria

From `docs/03-build-notes/m{n}/00-epic.md`:

* [ ] {Criterion 1}
* [ ] {Criterion 2}
* [ ] {Criterion 3}

### 5) Final PR (if using milestone branch)

Create PR: `milestone/m{n}-<short-name>` → `main`

**PR Description Template:**

```markdown
# M{n} Milestone: {Milestone Title}

## Summary
Completes all M{n} issues and meets all acceptance criteria.

## Acceptance Criteria Verification
- [x] {Criterion 1}
- [x] {Criterion 2}
- [x] {Criterion 3}

## NFR Targets
- [x] {NFR 1}
- [x] {NFR 2}

## Issues Completed
Closes #01, #02, #03, ... (all issues)
```

### 6) After Merge

```bash
git tag -a v0.{n}.0 -m "M{n}: {Milestone Title}"
git push origin v0.{n}.0

gh milestone close "M{n} - {Milestone Title}"
```

## Tracking (agent-updated)

**This section is the source of truth for milestone progress. Always update it when:**
- A PR is created (add to "Open PRs")
- A PR is merged (mark issue as ✅ Done)
- A stop condition is hit (add to "Blocked / Needs Review" or mark as ⏭️ Skipped)
- Moving to next issue (update "Current Phase" and "Current Issue")

### Completed Issues

* [ ] #01 — {Issue Title}
* [ ] #02 — {Issue Title}
* [ ] #03 — {Issue Title}
{Add all issues here}

### Open PRs (autopilot)

* (none)
* **Enhanced format** (with code review):
  ```markdown
  * [PR #{pr_num}](link) — <ISSUE_TITLE> (#<GITHUB_ISSUE_NUM>)
    - Status: ✓ Checks passing | ⚠ Failing
    - Code Review: ✓ No issues | ⚠ {N} issues found | ⏳ Pending
    - Created: {date}
  ```

### Blocked / Needs Review (STOP)

Use this section whenever a hard stop condition is hit; the agent should proceed to other issues where possible.

* (none)
* **Standard format**: `#XX — {Issue Title} — STOP: {reason} — Needs: {what's needed}`
* **Code review findings format**:
  ```markdown
  * **#<GITHUB_ISSUE_NUM>** (plan #N) — <ISSUE_TITLE>
    - Reason: Code review found {count} critical issues (PR #{pr_num})
    - Findings:
      1. {Issue description} (score: {N}, file: {path}, line: {N})
      2. {Issue description} (score: {N}, file: {path}, line: {N})
    - Fix: Address critical issues before continuing
    - PR: #{pr_num}
    - Blocked Date: {timestamp}
  ```

### Skipped Issues (Soft Stops)

Issues that were automatically skipped due to soft stop conditions (test failures, large diffs, merge conflicts).

* (none)
* Format: `#XX — {Issue Title} — Skipped: {reason}`

### Current Phase

* **Phase:** Phase 1: {Phase Name}
* **Current Issue:** #01
* **Blockers:** None

---

**Last Updated:** {YYYY-MM-DD}
**Status:** Not Started | In Progress | Complete
