# Plan Review Skill

This Claude skill reviews milestone implementation plans and specs for completeness, quality, and risks before execution begins.

## Quick Start

To use this skill, simply ask Claude:

```
plan-review m4.1
```

or

```
Please review the plan for milestone M3
```

The skill will:
1. Load all milestone artifacts (plan, epic, spec, issue files)
2. Run 5 parallel review agents
3. Score findings by severity (Critical / Warning / Info)
4. Present a structured review report with a verdict

## Skill Structure

```
.claude/skills/plan-review/
├── SKILL.md              # Main skill definition
├── README.md             # This file
├── examples/             # Example inputs/outputs
│   ├── example-input.md
│   └── example-output.md
└── resources/            # Supporting resources
    └── scoring-rubric.md
```

## Review Dimensions

The skill runs 5 parallel review agents:

1. **Structure & Completeness** — Files exist, sections present, frontmatter valid
2. **Specification Quality** — Thresholds concrete, edge cases documented, error handling specified
3. **Dependency & Sequencing** — Valid DAG, phase ordering correct, no circular deps
4. **Epic Coverage & Alignment** — Epic criteria covered, spec decisions implemented, no contradictions
5. **Risk & Feasibility** — Hard stops identified, broad issues flagged, integration risks noted

## Verdicts

- **READY** — 0 critical findings, safe to run `run-milestone`
- **ADDRESS CRITICALS** — 1+ critical findings, fix before execution
- **REVIEW WARNINGS** — 5+ warnings (no criticals), proceed with caution

## When to Use

- After writing issue specs, before running `run-milestone`
- After significant edits to specs or the implementation plan
- When onboarding to an unfamiliar milestone to assess readiness

## See Also

- [Interview Skill](../interview/README.md) — Interactive pre-spec exploration
- [Run Milestone Skill](../run-milestone/README.md) — Automated execution after review
- [Implementation Workflow](../../../docs/guides/implementation-workflow.md)
- [Development Cadence](../../../docs/guides/dev-cadence.md)
