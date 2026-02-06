# PR Review Skill

Automated code review for pull requests with a configurable confidence threshold.

> **Note:** This skill is named `/pr-review` to avoid conflict with the global `code-review:code-review` skill.

## Usage

```
/pr-review <PR_NUMBER>
```

## Features

- Multi-agent parallel review (5 independent reviewers)
- CLAUDE.md compliance checking
- Bug detection with git history context
- Confidence scoring (0-100 scale)
- Configurable threshold (default: 50)

## Threshold

Issues are only reported if they score **50 or higher** on the confidence scale:

| Score | Meaning |
|-------|---------|
| 0 | False positive, pre-existing issue |
| 25 | Might be real, could be false positive |
| **50** | Verified real issue (threshold) |
| 75 | Highly confident, will be hit in practice |
| 100 | Absolutely certain |

## Integration

Used automatically by `run-milestone` after PR creation. PRs cannot be merged until code review completes.
