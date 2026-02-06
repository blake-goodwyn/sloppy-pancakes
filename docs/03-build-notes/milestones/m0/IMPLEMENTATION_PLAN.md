# M0: Project Bootstrap — Implementation Plan

This document outlines the complete implementation plan for M0: Project Bootstrap, integrating the [Implementation Workflow](../../../guides/implementation-workflow.md).

**This file serves as the source of truth and progress manifest for the milestone.** All workflow tools (run-milestone command/skill) use this file to track progress, determine next issues, and update status.

## Overview

**Milestone:** `m0`
**Implementation Plan Path:** `docs/03-build-notes/milestones/m0/IMPLEMENTATION_PLAN.md`
**Milestone Folder:** `docs/03-build-notes/milestones/m0/`
**Milestone Branch:** `milestone/m0-project-bootstrap` (base branch for PRs; create from `main` if missing)
**Epic Issue:** TBD — "Epic: M0 — Project Bootstrap"
**Total Issues:** 1
**Status:** Not Started

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

1. **Database Changes:** Any DB migration or schema change
2. **Sensitive Code Changes:** Auth, permissions, rate-limit, or billing code
3. **Dependency Changes:** Dependency, lockfile, or license changes
4. **Issue Spec Problems:** Issue spec is missing, ambiguous, or dependencies unclear

### Soft Stops (Skip Issue Automatically - Workflow Continues)

1. **Test/Lint/Typecheck Failures:** Auto-fix attempted, then skip
2. **Large Diff:** >8 files or >400 lines — skip with warning
3. **Merge Conflicts:** Skip to next issue

## Always Load Context (required reads)

- `docs/guides/implementation-workflow.md`
- `docs/guides/dev-cadence.md`

## Issue Inventory (source of truth)

Issue specs live in: `docs/03-build-notes/milestones/m0/*.md`

## Issue Breakdown by Phase (ordered execution list)

### Phase 1: Bootstrap — Issue #01

**Goal:** Set up project structure, first endpoint, first test, CI pipeline.

| Issue # | Issue File | Title | Priority | Dependencies | Feature Branch | PR Title Token | Est. Size |
|---------|------------|-------|----------|--------------|----------------|----------------|-----------|
| #01 | 01-project-bootstrap.md | Set up project structure and first endpoint | P0 | None | `feat/m0-01-project-bootstrap` | `feat(m0)` | M |

**Dependencies notes:** No dependencies — this is the first issue.

## Tracking (agent-updated)

### Completed Issues

* [ ] #01 — Set up project structure and first endpoint

### Open PRs (autopilot)

* (none)

### Blocked / Needs Review (STOP)

* (none)

### Skipped Issues (Soft Stops)

* (none)

### Current Phase

* **Phase:** Phase 1: Bootstrap
* **Current Issue:** #01
* **Blockers:** None

---

**Last Updated:** —
**Status:** Not Started
