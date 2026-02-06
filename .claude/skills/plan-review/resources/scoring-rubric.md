# Scoring Rubric

This document defines the severity levels used by the plan-review skill to classify findings.

## Severity Levels

### CRITICAL

**Meaning:** Will cause `run-milestone` to fail, produce wrong output, or miss requirements.

**Action:** Must fix before execution.

**Examples:**
- Issue file referenced in plan does not exist on disk
- Circular dependency detected in the dependency graph
- Issue spec has no `## Acceptance Criteria` section
- Epic acceptance criterion has no implementing issue
- Specification uses vague language where a numeric threshold is required (e.g., "fast enough" instead of "<500ms")
- YAML frontmatter missing entirely from an issue spec
- Issue depends on an issue in a later phase (execution order violation)
- Plan references a GitHub issue number that doesn't match the issue file's frontmatter

### WARNING

**Meaning:** Likely to cause friction, rework, or reduced quality during execution.

**Action:** Should fix, but can proceed with awareness.

**Examples:**
- `github_issue` field empty or TBD in frontmatter (will cause `run-milestone` to stop and ask)
- API endpoint specifies success response but no error responses
- Issue has >6 acceptance criteria (may be too broad, consider splitting)
- Issue has >3 direct dependencies (complexity smell)
- `00-SPECIFICATION.md` not found for milestone with >5 issues
- Configuration value has default but no description of rationale
- ADR referenced in spec but not found in `decision-logs.md`
- Done definition uses vague language ("working correctly", "properly handles")
- No fallback plan for external API dependency
- Orphan issue file in folder not referenced by plan

### INFO

**Meaning:** Improvement opportunity or informational note.

**Action:** Optional, consider for future.

**Examples:**
- Issues with no dependency relationship could be parallelized
- `00-epic.md` not found (acceptable for small milestones)
- Hard-stop issue identified — informational note to expect workflow pause
- Feature branch name doesn't follow convention (cosmetic)
- Test issue scope could be more specific
- Configuration value rationale could be documented

## Verdict Thresholds

| Criticals | Warnings | Verdict | Message |
|-----------|----------|---------|---------|
| 0 | 0-4 | `READY` | Ready for execution |
| 0 | 5+ | `REVIEW WARNINGS` | Review warnings — proceed with caution |
| 1+ | Any | `ADDRESS CRITICALS` | Address critical findings before starting run-milestone |

## Deduplication Rules

When multiple agents flag the same file for the same issue:
- Keep the finding with the highest severity
- Merge detail text from both agents if they provide different context
- Credit both agents in the finding attribution
