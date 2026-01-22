# Milestones

## Purpose

Each milestone folder contains the implementation plan, epic, and issue specs for a development milestone.

## Structure

```
milestones/
├── m0-example/                    # Example milestone
│   ├── 00-epic.md                 # Milestone epic with acceptance criteria
│   ├── IMPLEMENTATION_PLAN.md     # Source of truth for progress
│   └── 01-example-issue.md        # Individual issue spec
└── m1-your-milestone/             # Your first real milestone
    ├── 00-epic.md
    ├── IMPLEMENTATION_PLAN.md
    └── *.md
```

## Creating a New Milestone

1. Copy `m0-example/` to `m{n}-{short-name}/`
2. Update `00-epic.md` with milestone goals and acceptance criteria
3. Update `IMPLEMENTATION_PLAN.md` with issue list and dependencies
4. Add issue specs: `{nn}-{short-name}.md`

## Files

### 00-epic.md
The milestone epic containing:
- Outcome statement
- Acceptance criteria
- Demo script
- NFR additions
- Out-of-scope list

### IMPLEMENTATION_PLAN.md
The source of truth for milestone progress:
- Issue list with status
- Dependencies and phases
- Open PRs tracking
- Blocked issues

### Issue Specs ({nn}-{short-name}.md)
Individual issue specifications:
- Done definition
- Implementation notes
- Test expectations
- Acceptance criteria
