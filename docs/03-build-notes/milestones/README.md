# Milestones

This directory contains milestone implementation plans and issue definitions.

## Directory Structure

```
milestones/
├── README.md                       # This file
├── IMPLEMENTATION_PLAN_TEMPLATE.md # Template for creating milestone plans
└── m0/                             # Example: M0 starter milestone
```

## Milestone Structure

Each milestone directory contains:

```
m{n}/
├── IMPLEMENTATION_PLAN.md       # Source of truth and progress manifest (REQUIRED)
├── _milestone.md                # Milestone metadata (title, description)
├── 00-epic.md                   # Epic/tracking issue for the milestone
├── 01-{short-name}.md           # Individual issues, numbered for ordering
├── 02-{short-name}.md
└── ...
```

## Implementation Plan

**Every milestone must have an `IMPLEMENTATION_PLAN.md` file** that serves as the source of truth and progress manifest.

The Implementation Plan:
- Tracks issue status (✅ Done, ⛔ Needs Review, ⏭️ Skipped)
- Lists open PRs and their status
- Tracks current phase and issue being worked on
- Documents blocked issues and stop conditions
- Defines issue dependencies and execution order

**To create a new milestone Implementation Plan:**
1. Copy `IMPLEMENTATION_PLAN_TEMPLATE.md` to `milestones/m{n}/IMPLEMENTATION_PLAN.md`
2. Fill in milestone-specific details (title, issues, phases, etc.)
3. The plan will be automatically updated by workflow tools (run-milestone command/skill)

All workflow tools (run-milestone command, Claude skill, automation scripts) use this file to:
- Determine which issue to work on next
- Track progress and status
- Update issue completion status
- Manage dependencies and execution order

## Related Documentation

- [Implementation Workflow](../../guides/implementation-workflow.md) - Daily issue-to-PR workflow
- [Development Cadence](../../guides/dev-cadence.md) - Team workflow and milestone process
