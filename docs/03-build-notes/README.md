# Build Notes

This directory contains build notes organized by category: milestones and fixes.

## Directory Structure

```
docs/03-build-notes/
├── README.md                    # This file
├── milestones/                  # Milestone implementation plans and issues
│   ├── IMPLEMENTATION_PLAN_TEMPLATE.md
│   └── m0/                      # Example starter milestone
└── fixes/                       # Bug fixes and improvements
    └── *.md                     # Individual fix issues
```

## Milestones

The `milestones/` directory contains implementation plans and issue definitions for each milestone.

**Every milestone must have an `IMPLEMENTATION_PLAN.md` file** that serves as the source of truth and progress manifest.

See [Milestones README](milestones/README.md) for detailed information about milestone structure and workflow.

## Fixes

The `fixes/` directory contains markdown-based issue definitions for bug fixes, improvements, and enhancements that are not part of a specific milestone.

These issues can be pushed to GitHub using the `push-issues.sh` script.

## Markdown Issue Format

Each issue file uses YAML frontmatter for metadata:

```markdown
---
title: "Issue Title"
labels: ["module:api", "type:feature", "prio:P0", "milestone:M0"]
github_issue: 123  # Added after pushing (for tracking)
---

## Done Definition

- Clear criteria for when this issue is complete

## Implementation Notes

Details about how to implement this issue.

## Test Expectations

- What tests should be written
- How to verify the implementation

## Acceptance Criteria

- [ ] Criteria 1
- [ ] Criteria 2
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Issue title (will be used as GitHub issue title) |
| `labels` | Yes | Array of GitHub labels to apply |
| `github_issue` | No | GitHub issue number (added after pushing) |

## Using the Push Script

The `scripts/push-issues.sh` script creates GitHub issues from these markdown files.

### Prerequisites

1. Install GitHub CLI: https://cli.github.com/
2. Authenticate: `gh auth login`
3. Ensure required labels exist in the repository

### Usage

```bash
# Push a single issue
./scripts/push-issues.sh m0 01-project-bootstrap.md

# Push all issues for a milestone
./scripts/push-issues.sh m0 --all

# Dry-run to preview without creating
./scripts/push-issues.sh m0 --all --dry-run

# Force push even if github_issue already set
./scripts/push-issues.sh m0 01-project-bootstrap.md --force
```

### Duplicate Prevention

The script prevents duplicates by:

1. **Checking `github_issue` field**: If the frontmatter already has a `github_issue` number, the file is skipped (unless `--force` is used)
2. **Checking GitHub by title**: Before creating, the script checks if an issue with the same title already exists

## Creating Labels

Before pushing issues, ensure the required labels exist:

```bash
# Type labels
gh label create "type:feature" --description "New functionality" --color "0E8A16"
gh label create "type:bug" --description "Bug fixes" --color "D93F0B"
gh label create "type:spike" --description "Research/exploration tasks" --color "FBCA04"
gh label create "type:docs" --description "Documentation tasks" --color "0E8A16"

# Priority labels
gh label create "prio:P0" --description "Critical, blocks other work" --color "B60205"
gh label create "prio:P1" --description "Important, should be done soon" --color "FBCA04"
```

## Workflow for New Milestones

1. Create a new directory: `docs/03-build-notes/milestones/m{n}/`
2. **Create `IMPLEMENTATION_PLAN.md`** (copy from `IMPLEMENTATION_PLAN_TEMPLATE.md`)
3. Add `_milestone.md` with milestone metadata
4. Add `00-epic.md` for the milestone epic
5. Add numbered issue files: `01-*.md`, `02-*.md`, etc.
6. Run the push script to create issues in GitHub
7. Update `IMPLEMENTATION_PLAN.md` with GitHub issue numbers
