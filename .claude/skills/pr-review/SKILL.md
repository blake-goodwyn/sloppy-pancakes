---
name: pr-review
description: Automated code review for pull requests with configurable confidence threshold. Use /pr-review to avoid conflict with global code-review skill.
version: 1.0.0
author: {{OWNER_NAME}}
tags: [code-review, pr, quality]
---

# PR Review Skill

## Purpose

Provide automated code review for pull requests, checking for bugs, CLAUDE.md compliance, and code quality issues. This skill uses a multi-agent approach with parallel review and confidence scoring.

## When to Use

- After creating a PR in the run-milestone workflow
- When explicitly requested via `/pr-review <PR_NUMBER>`
- For post-merge reviews when a PR was merged without review

## Configuration

### Confidence Threshold

**Threshold: 50** (issues scoring below 50 are filtered out)

The confidence scale for issue scoring:
- **0**: Not confident at all. False positive that doesn't stand up to scrutiny, or pre-existing issue.
- **25**: Somewhat confident. Might be real but could be false positive. Stylistic issues not in CLAUDE.md.
- **50**: Moderately confident. Verified real issue, might be a nitpick or rare in practice.
- **75**: Highly confident. Double-checked, very likely real issue that will be hit in practice.
- **100**: Absolutely certain. Confirmed real issue that will happen frequently.

## Workflow

1. **Eligibility Check** - Verify PR is open, not a draft, and hasn't been reviewed already
2. **Gather Context** - Find relevant CLAUDE.md files from the codebase
3. **Summarize Changes** - Get a summary of what the PR modifies
4. **Parallel Review** - Launch 5 independent review agents:
   - Agent 1: CLAUDE.md compliance audit
   - Agent 2: Shallow bug scan (obvious bugs only)
   - Agent 3: Git history context (bugs in light of history)
   - Agent 4: Previous PR comments (patterns from past reviews)
   - Agent 5: Code comment compliance (inline guidance)
5. **Score Issues** - Each issue gets a confidence score (0-100)
6. **Filter** - Remove issues with score < 50
7. **Comment** - Post results to the PR

## Input

```
pr-review <PR_NUMBER>
```

### Arguments

- `PR_NUMBER` (required): The GitHub PR number to review

## Output Format

### Issues Found

```markdown
### Code review

Found N issues:

1. <brief description> (CLAUDE.md says "<...>")
   <link to file and line with full sha1>

2. <brief description> (bug due to <context>)
   <link to file and line with full sha1>

Generated with [Claude Code](https://claude.ai/code)

<sub>- If this code review was useful, please react with thumbs up. Otherwise, react with thumbs down.</sub>
```

### No Issues

```markdown
### Code review

No issues found. Checked for bugs and CLAUDE.md compliance.

Generated with [Claude Code](https://claude.ai/code)
```

## False Positives to Avoid

The following are NOT flagged as issues:

- Pre-existing issues (not introduced in this PR)
- Issues that look like bugs but aren't
- Pedantic nitpicks a senior engineer wouldn't call out
- Issues caught by linters/typecheckers/compilers (formatting, imports, types)
- General code quality (coverage, docs) unless required in CLAUDE.md
- Issues silenced via lint ignore comments
- Intentional functionality changes related to the PR's purpose
- Real issues on lines not modified in the PR

## Integration with run-milestone

When invoked from run-milestone:

1. Code review runs AFTER PR creation
2. PR is created WITHOUT auto-merge enabled
3. If issues found (score >= 50): prompt user with `fix | skip | abort`
4. If no issues: update PR status and continue
5. Auto-merge can only be enabled AFTER code review passes

**Critical**: No PR may be merged until code review completes successfully or is explicitly approved by the user.

## Execution Steps

```python
# Step 1: Check eligibility
if pr.is_closed or pr.is_draft or pr.has_review_from_claude:
    return "PR not eligible for review"

# Step 2: Find CLAUDE.md files
claude_md_files = find_claude_md_files(pr.modified_paths)

# Step 3: Get PR summary
summary = summarize_pr_changes(pr)

# Step 4: Parallel review (5 agents)
issues = []
for agent in [claude_md_agent, bug_scan_agent, history_agent, prev_pr_agent, comment_agent]:
    issues.extend(agent.review(pr, claude_md_files))

# Step 5: Score each issue
scored_issues = []
for issue in issues:
    score = score_issue(issue, pr, claude_md_files)
    scored_issues.append((issue, score))

# Step 6: Filter by threshold (50)
filtered = [(i, s) for i, s in scored_issues if s >= 50]

# Step 7: Post comment
if filtered:
    post_issues_comment(pr, filtered)
else:
    post_clean_comment(pr)
```

## Notes

- Uses `gh` CLI for all GitHub interactions
- Never uses web fetch for authenticated GitHub URLs
- Links must use full SHA1 (not `HEAD` or short SHA)
- Line range format: `#L{start}-L{end}` with 1 line context before/after
- Maximum 2 fix attempts when issues are found
