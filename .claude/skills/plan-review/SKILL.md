---
name: plan-review
description: Review milestone implementation plans and specs for completeness, quality, and risks before execution. Runs 5 parallel review agents and produces a scored findings report.
version: 1.0.0
author: {{OWNER_NAME}}
tags: [development, workflow, review, specification, quality]
---

# Plan Review Skill

## Purpose

This skill provides a quality gate between spec-writing and execution. It systematically reviews a milestone's implementation plan, specification, epic, and issue specs to catch structural, quality, dependency, coverage, and risk issues before `run-milestone` begins building.

Think of the workflow as: `interview` → write specs → **`plan-review`** → `run-milestone` → `pr-review`

## When to Use

- After assembling a new milestone's issue specs and implementation plan
- Before invoking `run-milestone` for the first time on a milestone
- After significant edits to specs or the implementation plan
- When onboarding to an unfamiliar milestone to assess execution readiness

## Input

The skill accepts a milestone identifier:
- Format: `m{n}` or `m{n.x}` (e.g., `m3`, `M3`, `3`, `m4.1`, `M4.1`, `4.1`)
- Normalization: Converts to lowercase `m{n}` or `m{n.x}` format (preserves sub-milestone decimals)
- Alternative: Direct path to `IMPLEMENTATION_PLAN.md`
- If missing, prompts user for milestone ID

## Paths and Structure

Paths are derived from `Milestone folder:` in CLAUDE.md (default: `docs/03-build-notes/milestones/`).

### Milestone Folder
- Path: `<milestone-folder>/<milestone>/`
- Example: `docs/03-build-notes/milestones/m4.1/`

### Required Files
- Primary: `<milestone-folder>/<milestone>/IMPLEMENTATION_PLAN.md`
- If missing: STOP with error

### Optional Files (checked but not required)
- `<milestone-folder>/<milestone>/00-epic.md`
- `<milestone-folder>/<milestone>/00-SPECIFICATION.md`
- `<milestone-folder>/<milestone>/_milestone.md`

### Issue Specs
- Pattern: `<milestone-folder>/<milestone>/NN-*.md`
- Exclude from issue enumeration: `IMPLEMENTATION_PLAN.md`, `_milestone.md`, `00-epic.md`, `00-SPECIFICATION.md`

## Required Context Files

Always load before starting review:
- `docs/guides/implementation-workflow.md`
- `docs/guides/dev-cadence.md`
- `<milestone-folder>/IMPLEMENTATION_PLAN_TEMPLATE.md`

## Core Workflow

The skill follows this execution pattern:

1. **Bootstrap** — Resolve milestone, verify folder exists, load implementation plan
2. **Load Context** — Read all milestone artifacts (plan, epic, spec, all issue files)
3. **Launch 5 Review Agents** — Run in parallel using Task tool (subagent_type=general-purpose)
4. **Collect Findings** — Gather results from all 5 agents
5. **Score & Deduplicate** — Assign severity, remove duplicates across agents
6. **Generate Report** — Produce structured markdown report
7. **Present to User** — Display summary with verdict and option to save report

## Review Agents

Five agents run in parallel, each focusing on one review dimension. Each agent receives the full milestone context and returns structured findings.

### Agent 1: Structure & Completeness

**Focus:** Do all expected files exist and have required content?

Checks:
- `IMPLEMENTATION_PLAN.md` has all template sections (Overview, Autopilot Contract, Stop Conditions, Issue Inventory, Issue Breakdown by Phase, Tracking)
- Every issue file listed in the plan's phase tables exists on disk
- Every issue spec has `## Acceptance Criteria` with at least one checkbox item
- Every issue spec has a done definition (section titled `## Done Definition`, `## Done`, or equivalent)
- YAML frontmatter present with `title` field
- YAML frontmatter has `github_issue` field (assigned, not empty/TBD)
- YAML frontmatter has `labels` array
- `00-epic.md` exists (warn if missing for milestones with >3 issues)
- `00-SPECIFICATION.md` exists (warn if missing for milestones with >5 issues)
- Overview section has `Milestone Branch`, `Epic Issue`, `Total Issues`, `Status` fields
- Phase tables have required columns: Plan #, GitHub #, Issue File, Title, Priority, Dependencies, Feature Branch, Status
- No orphan issue files (files matching `NN-*.md` in folder but not referenced in plan)
- No phantom references (plan references files that don't exist on disk)

### Agent 2: Specification Quality

**Focus:** Are technical decisions concrete and complete?

Checks:
- `00-SPECIFICATION.md` sections have concrete thresholds (numeric values, not "fast" / "reasonable" / "appropriate")
- Edge cases documented for each specification decision
- Error handling specified (what happens on failure for each external dependency or error path)
- Code examples provided for non-trivial algorithms or logic
- Units specified for all numeric values (seconds, meters, dimensionless, etc.)
- Open questions section exists and items are clearly marked as deferred (not silently blocking)
- Each issue spec's `## Implementation Notes` references the specification where relevant
- API contracts specify error responses (not just happy path)
- Configuration values have defaults and descriptions
- Data model fields have types, constraints, and nullability specified

If `00-SPECIFICATION.md` does not exist:
- Report as WARNING (not CRITICAL) unless milestone has >5 issues
- Check issue specs individually for specification-level concerns
- Note that no cross-cutting technical decisions are documented

### Agent 3: Dependency & Sequencing

**Focus:** Is the execution order valid and efficient?

Checks:
- Dependency graph is a valid DAG (no circular dependencies)
- No issue depends on an issue in a later phase
- All declared dependencies reference valid issue numbers that exist in the plan
- P0 issues come before P1 issues within each phase (or P1 has no P0 dependents)
- Phase boundaries are logical groupings (related issues together)
- Issues that could run in parallel are not artificially serialized (no unnecessary dependency)
- No issue has >3 direct dependencies (complexity smell — consider splitting)
- Feature branch naming follows convention: `feat/m{n}-{github_issue}-{slug}`
- Each "Dependencies notes" section accurately describes the relationships in its phase table
- GitHub issue numbers in phase tables are consistent (no duplicates, no gaps)

### Agent 4: Epic Coverage & Alignment

**Focus:** Do the issues fully implement what the epic and spec promise?

Checks:
- Every acceptance criterion in `00-epic.md` maps to at least one issue spec
- Every specification decision in `00-SPECIFICATION.md` is implemented by at least one issue
- API endpoints listed in spec or plan have corresponding endpoint issues
- Data models listed in spec or plan have corresponding model/migration issues
- Test expectations in spec have corresponding test issues or test criteria in implementing issues
- NFR targets from epic (latency, uptime, cost, etc.) have issues or test criteria addressing them
- Configuration values in spec have an issue that adds them to `config.py`
- ADR references in spec point to valid entries in `docs/02-architecture/decision-logs.md`
- No issue spec contradicts the specification (conflicting field names, types, thresholds, behavior)
- Architecture overview in plan is consistent with spec's data flow

If `00-epic.md` does not exist:
- Skip epic coverage checks, report as INFO
- Still check spec-to-issue alignment if spec exists

### Agent 5: Risk & Feasibility

**Focus:** What could go wrong during execution?

Checks:
- Issues involving DB migrations identified (will trigger hard stop in `run-milestone`)
- Issues involving auth/permissions/billing code identified (hard stop)
- Issues involving new dependencies or lockfile changes identified (hard stop)
- External API dependencies noted with error/fallback handling in spec or issue
- Issues that seem too broad (>6 acceptance criteria or multiple unrelated concerns)
- Issues with vague done definitions ("working correctly", "properly handles", "as expected")
- Integration risks between phases (Phase N depends on Phase N-1 output — what if blocked?)
- Test-only issues have clear scope (not just "add all tests")
- Frontend issues have API dependencies satisfied in earlier phases
- Stubs/scaffolding issues clearly delineate what is real implementation vs. placeholder
- Total hard-stop count summarized so user can anticipate workflow pauses

## Scoring Rubric

Each finding is assigned one of three severity levels:

| Severity | Meaning | Action Required |
|----------|---------|-----------------|
| **CRITICAL** | Will cause `run-milestone` to fail, produce wrong output, or miss requirements | Must fix before execution |
| **WARNING** | Likely to cause friction, rework, or reduced quality during execution | Should fix, but can proceed with awareness |
| **INFO** | Improvement opportunity or informational note | Optional, consider for future |

### Verdict Thresholds

- **0 Critical findings** → Verdict: `READY` — "Ready for execution"
- **1+ Critical findings** → Verdict: `ADDRESS CRITICALS` — "Address critical findings before starting run-milestone"
- **5+ Warnings, 0 Criticals** → Verdict: `REVIEW WARNINGS` — "Review warnings — proceed with caution"

See `resources/scoring-rubric.md` for detailed examples of each severity level.

## Output Format

The skill produces a structured markdown report displayed to the user. The user may optionally request the report be saved to the milestone folder as `PLAN_REVIEW.md`.

```markdown
# Plan Review: M{n} — {Milestone Title}

**Reviewed:** {date}
**Plan:** `docs/03-build-notes/milestones/m{n}/IMPLEMENTATION_PLAN.md`
**Issues reviewed:** {count}
**Files scanned:** {count}

## Verdict

{READY | ADDRESS CRITICALS | REVIEW WARNINGS}

- **Critical:** {count}
- **Warning:** {count}
- **Info:** {count}

## Critical Findings

### [C1] {Finding title}
- **Agent:** {Agent name}
- **File:** `{path}`
- **Detail:** {description}
- **Fix:** {suggested action}

## Warnings

### [W1] {Finding title}
- **Agent:** {Agent name}
- **File:** `{path}`
- **Detail:** {description}
- **Fix:** {suggested action}

## Info

### [I1] {Finding title}
- **Agent:** {Agent name}
- **Detail:** {description}

## Agent Reports

### 1. Structure & Completeness
{summary paragraph}
{checklist of pass/fail items}

### 2. Specification Quality
{summary paragraph}
{key observations}

### 3. Dependency & Sequencing
{summary paragraph}
{dependency graph notes}

### 4. Epic Coverage & Alignment
{summary paragraph}
{coverage matrix}

### 5. Risk & Feasibility
{summary paragraph}
{risk register}
```

## Execution Steps

### 1. Bootstrap

1. **Resolve milestone identifier**
   - Accept: `m{n}`, `M{n}`, `{n}`, `m{n.x}`, `M{n.x}`, or `{n.x}` → normalize to `m{n}` or `m{n.x}`
   - Alternative: Accept direct path to `IMPLEMENTATION_PLAN.md` → derive milestone from path
   - If missing, ask user for milestone ID

2. **Verify milestone folder exists**
   - Check: `docs/03-build-notes/milestones/<milestone>/`
   - If missing: STOP with error

3. **Read implementation plan**
   - Read: `docs/03-build-notes/milestones/<milestone>/IMPLEMENTATION_PLAN.md`
   - If missing: STOP with error — cannot review without a plan

### 2. Load Context

1. **Load required context files:**
   - `docs/guides/implementation-workflow.md`
   - `docs/guides/dev-cadence.md`
   - `docs/03-build-notes/milestones/IMPLEMENTATION_PLAN_TEMPLATE.md`

2. **Load milestone artifacts:**
   - `00-epic.md` (if exists)
   - `00-SPECIFICATION.md` (if exists)
   - `_milestone.md` (if exists)
   - All issue spec files matching `NN-*.md` pattern

3. **Enumerate issue files:**
   - List all `*.md` files in milestone folder
   - Separate into: plan, epic, spec, milestone summary, and issue specs
   - Cross-reference with plan's phase tables

### 3. Launch Review Agents

Launch all 5 agents in parallel using the Task tool:

```
Agent 1: Structure & Completeness — Verify all files exist and have required sections
Agent 2: Specification Quality — Assess concreteness and completeness of technical decisions
Agent 3: Dependency & Sequencing — Validate dependency DAG and phase ordering
Agent 4: Epic Coverage & Alignment — Check that issues cover all epic and spec commitments
Agent 5: Risk & Feasibility — Identify execution risks and hard-stop issues
```

Each agent receives:
- The full implementation plan content
- The epic content (if available)
- The specification content (if available)
- All issue spec contents
- The template (for structural comparison)
- The milestone folder path

Each agent returns:
- A list of findings, each with: severity (CRITICAL/WARNING/INFO), title, file path, detail, suggested fix
- A summary paragraph for its dimension
- A pass/fail checklist of items reviewed

### 4. Collect and Score Findings

1. Gather findings from all 5 agents
2. Deduplicate: If two agents flag the same file for the same issue, keep the higher-severity finding
3. Sort: CRITICAL first, then WARNING, then INFO
4. Number findings: [C1], [C2], ..., [W1], [W2], ..., [I1], [I2], ...

### 5. Generate Report

1. Compile findings into the output format described above
2. Compute verdict based on thresholds
3. Include per-agent summary reports

### 6. Present to User

1. Display the verdict and finding counts
2. Display all CRITICAL and WARNING findings in full
3. Summarize INFO findings (show count, list titles)
4. Ask user if they want the full report saved to `docs/03-build-notes/milestones/<milestone>/PLAN_REVIEW.md`

## Examples

### Example 1: Reviewing M4.1 Before Execution

**Input:**
```
plan-review m4.1
```

**Process:**
1. Normalize to `m4.1`
2. Verify `docs/03-build-notes/milestones/m4.1/` exists
3. Load IMPLEMENTATION_PLAN.md, 00-epic.md, 00-SPECIFICATION.md, 17 issue files
4. Launch 5 review agents
5. Collect findings
6. Present report with verdict

### Example 2: Reviewing After Spec Edits

**Input:**
```
plan-review docs/03-build-notes/milestones/m4.1/IMPLEMENTATION_PLAN.md
```

**Process:**
1. Derive milestone `m4.1` from path
2. Load all artifacts
3. Run full review
4. Compare against previous review (if PLAN_REVIEW.md exists)

### Example 3: Quick Review of Small Milestone

**Input:**
```
plan-review m0
```

**Process:**
1. Load M0 artifacts (small milestone, few issues)
2. Agents adapt checks to scope (skip spec quality if no 00-SPECIFICATION.md)
3. Produce lighter report

## Integration with Workflow

This skill fits into the development cadence defined in `docs/guides/dev-cadence.md`:

```
1. Milestone kickoff         ← Create epic, define scope
2. Backlog shaping           ← Write issue specs, create IMPLEMENTATION_PLAN.md
3. Risk & spike window       ← [interview] for unknowns
   ↓
   ** plan-review **          ← THIS SKILL: Quality gate before execution
   ↓
4. Implementation cadence    ← [run-milestone] autopilot
5. Integration & verification
6. Release, tag, close       ← [pr-review] on PRs along the way
```

The skill is read-only — it examines artifacts but does not modify them. Fixes are left to the user or a follow-up editing session.

## Limitations

- **Read-only:** Cannot fix issues, only reports them. The user must address findings manually.
- **Format-dependent:** Relies on consistent plan and spec formatting (YAML frontmatter, markdown sections, template structure). Unconventional formatting may produce false positives.
- **No code analysis:** Does not read source code. Checks are limited to documentation artifacts (plans, specs, issue files).
- **No GitHub validation:** Does not verify GitHub issue numbers exist on GitHub. Checks are limited to cross-referencing within the milestone folder.
- **Single milestone:** Reviews one milestone at a time. Does not check cross-milestone dependencies.

## Error Handling

- **Missing milestone folder:** STOP with clear error message and expected path
- **Missing implementation plan:** STOP with error — this file is required
- **Missing epic or spec:** Reduce scope (skip relevant checks), report as INFO or WARNING depending on milestone size
- **Malformed YAML frontmatter:** Report as CRITICAL for affected issue files, continue reviewing others
- **Empty issue specs:** Report as CRITICAL (file exists but has no content)
- **Agent failure:** If one review agent fails, report its error and present findings from the other 4

## Notes

- This skill is non-interactive — it runs to completion without user prompts (unlike `interview`)
- All findings include a suggested fix to make them actionable
- The report can be saved for comparison after edits (run review again, compare findings)
- The skill complements but does not replace human judgment — it catches mechanical issues, not conceptual ones

## See Also

- [Interview Skill](../interview/SKILL.md) — Interactive pre-spec exploration
- [Run Milestone Skill](../run-milestone/SKILL.md) — Automated execution after review
- [Implementation Workflow](../../../docs/guides/implementation-workflow.md) — Daily workflow guide
- [Development Cadence](../../../docs/guides/dev-cadence.md) — High-level milestone process
- [Implementation Plan Template](../../../docs/03-build-notes/milestones/IMPLEMENTATION_PLAN_TEMPLATE.md) — Template that defines expected structure
