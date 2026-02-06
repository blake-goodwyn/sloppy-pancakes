---
name: create-milestone
description: Create complete milestone documentation (epic, specification, issues, implementation plan) by interviewing the user and leveraging the roadmap. Produces all artifacts needed for /run-milestone.
version: 1.1.0
tags: [development, workflow, planning, milestone, specification]
---

# Create Milestone Skill

## Purpose

This skill creates complete milestone documentation by conducting structured interviews and generating all artifacts required for `/run-milestone` to execute. It bridges the gap between roadmap vision and actionable implementation plans.

## When to Use

- Starting a new milestone from the roadmap
- Breaking down a roadmap item into detailed specs
- Creating milestone documentation from scratch
- Refining a partially-defined milestone

## Configuration

The skill auto-detects project structure. Override in `CLAUDE.md` if needed.

### Path Detection

Auto-detection order (first match wins):
1. Explicit `Milestone folder:` directive in CLAUDE.md
2. `milestones/` in project root
3. `docs/milestones/`
4. `docs/build-notes/milestones/`

**Override example:**
```markdown
# In CLAUDE.md
Milestone folder: docs/03-build-notes/milestones/
Roadmap file: docs/01-roadmap/roadmap.md
```

## Output Artifacts

The skill produces these files in `<milestone-folder>/<milestone>/`:

| File | Purpose | Required for run-milestone |
|------|---------|---------------------------|
| `00-epic.md` | High-level goals, success criteria | Optional but recommended |
| `00-SPECIFICATION.md` | Technical design, architecture | Optional but recommended |
| `01-*.md` ... `NN-*.md` | Individual issue specs | ✅ Required |
| `IMPLEMENTATION_PLAN.md` | Execution manifest with phases | ✅ Required |

## Input

```
create-milestone <milestone> [--from-roadmap] [--interactive]
```

### Arguments

| Argument | Description |
|----------|-------------|
| `<milestone>` | Milestone identifier (e.g., `m5`, `m5.1`, `M5`) |
| `--from-roadmap` | Extract context from `docs/01-roadmap/roadmap.md` |
| `--interactive` | Full interview mode (default) |
| `--quick` | Minimal questions, generate defaults |

### Examples

```
create-milestone m5
create-milestone m5.1 --from-roadmap
create-milestone m6 --quick
```

## Optional Context Files

Load if present (graceful degradation if missing):

| File | Purpose |
|------|---------|
| `roadmap.md` | Milestone definitions, scope, dependencies |
| `implementation-workflow.md` | Workflow conventions |
| `dev-cadence.md` | Milestone structure |
| `IMPLEMENTATION_PLAN_TEMPLATE.md` | Plan format |

## Core Workflow

```
Load Roadmap Context
        ↓
Extract Milestone Scope
        ↓
Interview: Epic & Goals ──→ Generate 00-epic.md
        ↓
Interview: Technical Design ──→ Generate 00-SPECIFICATION.md
        ↓
Interview: Issue Breakdown ──→ Generate NN-*.md (each issue)
        ↓
Interview: Dependencies & Phases ──→ Generate IMPLEMENTATION_PLAN.md
        ↓
Create GitHub Issues (optional)
        ↓
Summary & Next Steps
```

## Execution Steps

### 1. Initialize

1. **Normalize milestone identifier**
   - `m5`, `M5`, `5` → `m5`
   - `m5.1`, `M5.1`, `5.1` → `m5.1`

2. **Create milestone folder** (if needed)
   ```bash
   mkdir -p <milestone-folder>/<milestone>/
   ```

3. **Load roadmap context** (if roadmap exists)
   - Read `roadmap.md` (auto-detected or from CLAUDE.md)
   - Find section for this milestone
   - Extract: title, description, scope, dependencies, acceptance criteria

4. **Check for existing artifacts**
   - If files exist, offer to refine vs overwrite
   - Load existing content as starting context

### 2. Epic Interview

**Goal:** Define high-level goals and success criteria.

**Interview areas** (invoke `/interview` or ask directly):

```
Epic Context:
- What problem does this milestone solve?
- Who are the primary users/stakeholders?
- What does success look like?
- What are the key deliverables?
- What is explicitly out of scope?
- What are the dependencies on other milestones?
- What are the risks and mitigation strategies?
```

**Generate:** `00-epic.md`

```markdown
---
title: "M{n}: {Milestone Title}"
milestone: m{n}
status: planning
---

# M{n}: {Milestone Title}

## Overview

{Brief description from roadmap + interview clarifications}

## Goals

- {Goal 1}
- {Goal 2}
- {Goal 3}

## Success Criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Scope

### In Scope
- {Item 1}
- {Item 2}

### Out of Scope
- {Item 1}
- {Item 2}

## Dependencies

- **Requires:** {Prior milestones or external dependencies}
- **Enables:** {Future milestones this unblocks}

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| {Risk 1} | {H/M/L} | {Strategy} |

## Timeline

- **Target Start:** {Date or milestone}
- **Target Complete:** {Date or milestone}
```

### 3. Specification Interview

**Goal:** Define technical architecture and design decisions.

**Interview areas:**

```
Technical Design:
- What is the high-level architecture?
- What are the key components/modules?
- What data models or schemas are needed?
- What APIs or interfaces are required?
- What are the integration points?
- What technology choices need to be made?
- What are the key technical tradeoffs?
- What patterns or conventions should be followed?
```

**Generate:** `00-SPECIFICATION.md`

```markdown
---
title: "M{n} Technical Specification"
milestone: m{n}
---

# M{n}: {Title} — Technical Specification

## Architecture Overview

{High-level architecture description}

```
{ASCII diagram or description of components}
```

## Components

### {Component 1}
- **Purpose:** {Description}
- **Responsibilities:** {List}
- **Interfaces:** {APIs, events, etc.}

### {Component 2}
...

## Data Models

### {Model 1}
```
{Schema or model definition}
```

## API Design

### {Endpoint/Interface 1}
- **Method:** {GET/POST/etc.}
- **Path:** {/api/v0/...}
- **Request:** {Schema}
- **Response:** {Schema}

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| {Decision 1} | {Choice} | {Why} |

## Integration Points

- **{System 1}:** {How it integrates}
- **{System 2}:** {How it integrates}

## Conventions

- {Convention 1}
- {Convention 2}
```

### 4. Issue Breakdown Interview

**Goal:** Break milestone into discrete, implementable issues.

**Interview areas:**

```
Issue Decomposition:
- What are the major work items?
- What is the logical order of implementation?
- Which items can be parallelized?
- What are the dependencies between items?
- What is the right granularity? (aim for 1-4 hour tasks)
- Are there any items that could be split further?
- Are there any items that should be combined?
```

**For each issue, interview:**

```
Issue Details (invoke /interview for complex issues):
- What is the done definition?
- What are the acceptance criteria?
- What are the implementation notes?
- What are the test expectations?
- What are the edge cases?
- What could go wrong?
```

**Generate:** `NN-{short-name}.md` for each issue

```markdown
---
title: "{Issue Title}"
github_issue: {number or empty}
labels: ["{label1}", "{label2}"]
priority: P0 | P1
dependencies: ["{issue-file-1}", "{issue-file-2}"]
---

# {Issue Title}

## Done Definition

{Clear statement of what "done" means}

## Implementation Notes

- {Note 1}
- {Note 2}
- {Note 3}

## Test Expectations

- {Test 1}
- {Test 2}

## Acceptance Criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}
- [ ] {Criterion 4}
```

### 5. Implementation Plan Interview

**Goal:** Organize issues into phases with dependencies.

**Interview areas:**

```
Planning:
- How should issues be grouped into phases?
- What is the critical path?
- Which issues block others?
- What is the milestone branch name?
- Are there any scope tags for sensitive code?
- What is the review strategy between phases?
```

**Generate:** `IMPLEMENTATION_PLAN.md`

```markdown
# M{n}: {Title} — Implementation Plan

## Milestone Metadata

- **Milestone Branch:** `milestone/m{n}-{short-name}`
- **Base Branch:** `main`
- **Scope Tags:** {tag1}, {tag2}
- **Target:** {Date or sprint}

## Issue Inventory

| # | Issue File | Title | Priority | Dependencies | Status |
|---|------------|-------|----------|--------------|--------|
| 01 | `01-{name}.md` | {Title} | P0 | — | ⬚ |
| 02 | `02-{name}.md` | {Title} | P0 | 01 | ⬚ |
| ... | ... | ... | ... | ... | ... |

**Exclude from enumeration:** `IMPLEMENTATION_PLAN.md`, `00-epic.md`, `00-SPECIFICATION.md`

## Execution Phases

### Phase 1: {Phase Name}

Foundation work, no external dependencies.

| # | Issue | Branch | PR |
|---|-------|--------|-----|
| 01 | {Title} | `feat/m{n}-{issue}-{slug}` | |
| 02 | {Title} | `feat/m{n}-{issue}-{slug}` | |

### Phase 2: {Phase Name}

{Phase description}

| # | Issue | Branch | PR |
|---|-------|--------|-----|
| 03 | {Title} | | |
| 04 | {Title} | | |

### Phase 3: {Phase Name}

{Phase description}

| # | Issue | Branch | PR |
|---|-------|--------|-----|
| 05 | {Title} | | |
| 06 | {Title} | | |

## Execution Log

- **Quality Gate:** ⬚ Not run
- **Gate Date:** —

## Open PRs (autopilot)

*None yet*

## Blocked / Needs Review

*None yet*

## PR Description Template

```markdown
## M{n} → main

### Summary
{Milestone summary}

### Changes
- {Change 1}
- {Change 2}

### Testing
- [ ] All tests passing
- [ ] Manual testing complete

### Checklist
- [ ] Code review approved
- [ ] Documentation updated
```
```

### 6. Create GitHub Issues (Optional)

**Prompt user:**

```
Create GitHub issues for each spec? yes | no | later
```

**If yes:**

For each issue spec:
```bash
gh issue create \
  --title "{Issue Title}" \
  --body "$(cat <milestone-folder>/<milestone>/<issue-file>.md)" \
  --label "{labels}" \
  --milestone "M{n} - {Title}"
```

Update issue specs with `github_issue: {number}`.

### 7. Summary

**Output:**

```
═══════════════════════════════════════════════
✓ Milestone M{n} Created
═══════════════════════════════════════════════

Artifacts:
  ✓ <milestone-folder>/m{n}/00-epic.md
  ✓ <milestone-folder>/m{n}/00-SPECIFICATION.md
  ✓ <milestone-folder>/m{n}/01-{name}.md
  ✓ <milestone-folder>/m{n}/02-{name}.md
  ... ({N} issue specs)
  ✓ <milestone-folder>/m{n}/IMPLEMENTATION_PLAN.md

GitHub Issues: {Created N | Skipped}

Next Steps:
1. Review generated specs
2. Create milestone branch:
   git checkout -b milestone/m{n}-{name} main
3. Run milestone:
   run-milestone m{n}
```

## Interview Integration

This skill uses `/interview` for deep-dive exploration:

| Phase | Interview Usage |
|-------|-----------------|
| Epic | Direct questions or `/interview "M{n} goals and scope"` |
| Specification | `/interview "M{n} technical design"` |
| Issue breakdown | `/interview <issue-file>` for complex issues |
| Planning | Direct questions about phases |

**When to invoke full interview:**
- Issue has unclear requirements
- Technical design has multiple options
- Dependencies are complex
- User requests deeper exploration

**When to use direct questions:**
- Scope is clear from roadmap
- Issue is straightforward
- User prefers speed over depth

## Quick Mode (`--quick`)

When `--quick` flag is provided:

1. Extract maximum context from roadmap
2. Generate reasonable defaults
3. Ask only critical questions:
   - Confirm milestone scope (yes/no)
   - Confirm issue breakdown (yes/no)
   - Confirm phase structure (yes/no)
4. Generate all artifacts
5. User can refine later

## Examples

### Example 1: New Milestone from Roadmap

```
create-milestone m5 --from-roadmap
```

**Process:**
1. Load roadmap, find M5 section
2. Extract milestone title and scope
3. Interview about epic (goals, success criteria)
4. Interview about technical design (architecture, data flow)
5. Break down into issues
6. Organize into phases
7. Generate all artifacts
8. Offer to create GitHub issues

### Example 2: Sub-Milestone

```
create-milestone m5.1
```

**Process:**
1. Load roadmap, find M5.1 section
2. Check if M5 epic exists (load for context)
3. Interview about M5.1 specific scope
4. Generate focused specification
5. Break down into issues
6. Generate implementation plan

### Example 3: Quick Generation

```
create-milestone m6 --quick
```

**Process:**
1. Load roadmap, extract M6 context
2. Generate epic from roadmap description
3. Generate specification skeleton
4. Propose issue breakdown based on scope
5. Ask: "Proceed with this breakdown? yes | no"
6. Generate all artifacts
7. Summary with edit suggestions

## Error Handling

| Error | Response |
|-------|----------|
| Milestone not in roadmap | Ask for description or abort |
| Folder already exists | Offer: refine, overwrite, or abort |
| Missing roadmap.md | Proceed with interview-only mode |
| User unavailable | Save progress, can resume |

## Limitations

- Requires user participation for interviews
- Cannot make final design decisions without user input
- Generated specs may need refinement
- GitHub issue creation requires `gh` CLI configured

## Notes

- Always reference roadmap for context
- Balance thoroughness with speed
- Generate actionable specs, not documentation for its own sake
- Issue granularity: aim for 1-4 hour tasks
- Phases should be 3-7 issues each
- Leave room for user refinement

## See Also

- [Interview Skill](../interview/SKILL.md) — Deep-dive requirement exploration
- [Run Milestone Skill](../run-milestone/SKILL.md) — Execute generated plans
