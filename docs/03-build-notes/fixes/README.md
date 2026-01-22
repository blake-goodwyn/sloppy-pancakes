# Fixes

## Purpose

Track fixes, regressions, and recovery steps outside of active milestones.

## Format

- Use numbered files: `01-*.md`, `02-*.md`
- Use the same YAML frontmatter and sections as milestone issue files

## Usage

1. Create a new file when addressing regressions or hotfixes
2. Number sequentially (e.g., `01-critical-bug.md`)
3. Include impacted versions and repro steps
4. Link the corresponding GitHub issue in `github_issue:` after creation

## Template

```markdown
---
title: Fix Title
priority: P0
labels: [bug, fix]
github_issue:
---

# Fix Title

## Problem
[Description of the issue]

## Impact
- [Who/what is affected]
- [Severity]

## Root Cause
[What caused this issue]

## Solution
[How it was fixed]

## Verification
- [ ] [How to verify the fix]

## Prevention
[How to prevent this in the future]
```

## Current Fixes

<!-- Add fixes here as they're created -->
None yet.
