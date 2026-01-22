# Implementation Workflow

This guide provides step-by-step instructions for implementing issues during milestone development. It covers the daily workflow from picking up an issue to merging a PR, including branch management, commit conventions, PR creation, and issue tracking.

---

## Quick Start

If you have workflow helper scripts, use them to find and start the next issue:

```bash
# Find and start the next open issue
python scripts/workflow/next-issue.py

# List all issues for a milestone
python scripts/workflow/next-issue.py --list

# Start a specific issue by number
python scripts/workflow/next-issue.py --start 52
```

**Note:** If using automation scripts, they typically use `docs/03-build-notes/milestones/m{n}/IMPLEMENTATION_PLAN.md` as the source of truth for milestone progress. This file tracks issue status, dependencies, open PRs, and current progress.

For detailed manual workflow steps, see the [Daily Implementation Loop](#daily-implementation-loop) section below.

---

## Branch Structure

- **Main branch:** `main` (always deployable)
- **Milestone branch:** `milestone/M{n}-<short-name>` (single integration branch per milestone, e.g., `milestone/m1-feature-name`)
- **Feature branches (optional):** `feat/m{n}-{issue-number}-{short-name}` for larger PRs or when working on multiple related issues

---

## Daily Implementation Loop

For each issue, follow this workflow:

### 1. Check Current Branch

```bash
git status
git branch --show-current  # Should be milestone/m{n}-<short-name>
```

Ensure you're on the correct milestone branch before starting work.

### 2. Create Feature Branch (If Needed)

**For small PRs (<3 files changed):**
- Work directly on the milestone branch
- No feature branch needed

**For larger PRs or when grouping multiple issues:**
```bash
git checkout -b feat/m{n}-{issue-number}-{short-name}
```

### 3. Verify Issue Exists

Before starting implementation:

```bash
# Check if issue exists (adapt to your issue tracking system)
grep "github_issue:" docs/03-build-notes/milestones/m{n}/{issue-file}.md

# If missing, create issue (adapt to your workflow)
./scripts/push-issues.sh m{n} {issue-file}.md

# Update frontmatter with issue number after creation
# Edit docs/03-build-notes/milestones/m{n}/{issue-file}.md
# Add: github_issue: {number}
```

### 4. Implement with Tests

- Write code following issue specifications from `docs/03-build-notes/milestones/m{n}/{issue-file}.md`
- Write tests alongside implementation (don't defer testing)
- Run tests locally: `pytest tests/` (or your test command)
- Run linter: `ruff check src/` (or your lint command)
- **Auto-fix lint errors:** `ruff check --fix src/` (or your fix command)
- Fix any remaining issues before committing

### 5. Commit Frequently with Clear Messages

**Commit Message Format:**
```
{type}(m{n}): {brief description}

Implements issue #XX: {issue title}

- {change 1}
- {change 2}
- {change 3}

Closes #{issue-number}
```

**Example:**
```bash
git add .
git commit -m "feat(m1): Add feature schemas

Implements issue #01: Define feature schemas

- Add CreateRequest, UpdateRequest, ValidateRequest
- Add Response, ListResponse, ValidationResult
- Integrate validation logic

Closes #01"
```

**Commit Types:**
- `feat(m{n}):` - New feature
- `fix(m{n}):` - Bug fix
- `test(m{n}):` - Test additions/changes
- `docs(m{n}):` - Documentation
- `refactor(m{n}):` - Code refactoring
- `chore(m{n}):` - Build/tooling changes

**Best Practices:**
- Commit frequently (after each logical unit of work)
- Always include issue number in commit body
- Include `Closes #{issue-number}` if PR completes the issue
- Keep commit messages clear and descriptive

### 5a. Push to Branch Regularly

**After each commit (or every few commits), push to the remote branch:**

```bash
# For feature branches
git push origin feat/m{n}-{issue-number}-{short-name}

# For milestone branches (when working directly on milestone)
git push origin milestone/m{n}-<short-name>

# If branch is already tracking remote, just:
git push
```

**Why push regularly:**
- Backs up your work to remote
- Makes progress visible to team members
- Enables collaboration if others need to see your changes
- Allows CI to run on your commits
- Prevents loss of work if local machine issues occur

**Best Practice:**
- Push after every commit or every 2-3 commits
- Push before switching branches or ending a work session
- Push immediately after creating a PR to ensure remote branch exists

### 6. Open PR Early (Draft)

Create a draft PR as soon as you have initial code:

```bash
# Push branch
git push origin feat/m{n}-{issue-number}-{short-name}

# Create draft PR via GitHub CLI
gh pr create --draft \
  --title "feat(m{n}): Add feature schemas (#{issue-number})" \
  --body "Implements issue #{issue-number}: Feature title

## Changes
- Add request/response schemas
- Integrate validation

## Acceptance Criteria
- [ ] All schemas importable
- [ ] Validation works

Closes #{issue-number}"
```

**Or via GitHub Web UI:**
- Push branch to remote
- Click "Compare & pull request"
- Mark as "Draft"
- Fill in PR description using template below

### 7. Update PR Continuously

As you make progress:

1. **Push commits frequently (after each commit or every few commits):**
   ```bash
   git push
   ```

   **Note:** Regular pushing ensures your work is backed up, visible to the team, and keeps CI running on the latest changes.

2. **Update PR description with running changelog:**
   ```markdown
   ## Changelog
   - Added CreateRequest schema
   - Added Response schema
   - Integrated validation logic
   - Added unit tests for validation
   ```

3. **Mark acceptance criteria as complete:**
   ```markdown
   ## Acceptance Criteria
   - [x] All schemas importable
   - [x] Validation works
   ```

4. **Request review when ready:**
   - Remove draft status
   - Add reviewers if needed
   - Comment "@reviewers ready for review"

### 8. Verify Acceptance Criteria

Before marking PR as ready for review:

- [ ] Check all acceptance criteria from issue file
- [ ] Run tests: `pytest tests/`
- [ ] Run linter: `ruff check src/` (auto-fix with `ruff check --fix src/` if needed)
- [ ] Run type checker: `mypy src/` (if configured)
- [ ] Check diff size: `git diff --stat` (if >8 files or >400 lines, consider splitting)
- [ ] Verify CI passes
- [ ] Manual testing completed (if applicable)

### 9. Address Review Feedback

- Respond to comments promptly
- Push fixes as new commits
- Update PR description if scope changes
- Re-request review after addressing feedback

### 10. Merge PR

After approval and CI passes:

```bash
# Merge via GitHub CLI
gh pr merge {pr-number} --squash --delete-branch

# Or merge via GitHub Web UI
# - Click "Merge pull request"
# - Choose "Squash and merge" (recommended)
# - Delete branch after merge
```

---

## PR Description Template

Use this template for all PRs:

```markdown
Implements issue #XX: {Issue Title}

## Summary
Brief description of what this PR does.

## Changes
- {change 1}
- {change 2}
- {change 3}

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Related Issues
Closes #XX
```

---

## PR Guidelines

### PR Size

- **Target:** Reviewable in **<30 minutes**
- **If too large:** Split by vertical slice (API + storage + tests) or by bounded module
- **Prefer:** Smaller, focused PRs over large ones

### PR Lifecycle

1. **Draft** - Create when starting work, update continuously
2. **Ready for Review** - Mark when acceptance criteria met
3. **In Review** - Address feedback, push fixes
4. **Approved** - Merge when CI passes and approved
5. **Merged** - Issue auto-closes (if `Closes #XX` included)

### PR Best Practices

- Open PR early (draft) to get early feedback
- Update PR description with running changelog
- Keep PR focused on single issue or related issues
- Include acceptance criteria checklist
- Link to related issues
- Add screenshots/logs for complex changes

---

## Issue Tracking Workflow

### Implementation Plan as Source of Truth

**The `IMPLEMENTATION_PLAN.md` file is the authoritative manifest for milestone progress.**

Located at: `docs/03-build-notes/milestones/m{n}/IMPLEMENTATION_PLAN.md`

This file tracks:
- Issue status (✅ Done, ⛔ Needs Review, ⏭️ Skipped)
- Open PRs and their status
- Current phase and issue being worked on
- Blocked issues and stop conditions
- Issue dependencies and execution order

**Always consult and update the Implementation Plan when:**
- Starting work on a new issue
- Creating a PR
- Merging a PR
- Encountering a stop condition
- Moving to the next issue

### Before Starting Work

1. **Review the Implementation Plan:**
   ```bash
   # Read the plan to understand current status
   cat docs/03-build-notes/milestones/m{n}/IMPLEMENTATION_PLAN.md
   ```

2. **Check if issue exists:**
   ```bash
   grep "github_issue:" docs/03-build-notes/milestones/m{n}/{issue-file}.md
   ```

3. **Create issue if missing:**
   ```bash
   ./scripts/push-issues.sh m{n} {issue-file}.md
   ```

4. **Update frontmatter:**
   - Edit `docs/03-build-notes/milestones/m{n}/{issue-file}.md`
   - Add: `github_issue: {number}`

### During Implementation

- Comment on issue when starting work
- Update with progress if blocked
- Link PR to issue: Include `Closes #{issue-number}` in PR description
- **Update Implementation Plan:** Add PR to "Open PRs" section

### After Merge

- Issue auto-closes when PR merges (if `Closes #XX` included)
- Verify issue is closed on GitHub
- **Update Implementation Plan:** Mark issue as ✅ Done in "Completed Issues" section

---

## Milestone Branch Management

### Working on Milestone Branch

**For small PRs (<3 files changed):**
- Work directly on `milestone/m{n}-<short-name>`
- Commit and push directly:
  ```bash
  git push origin milestone/m{n}-<short-name>
  ```
- Create PR: milestone branch → milestone branch (for review) or merge directly if confident

### Using Feature Branches

**For larger PRs or when grouping issues:**
- Create feature branch from milestone branch
- Work on feature branch
- Merge feature branch → milestone branch via PR
- Keep milestone branch always in working state

### Branch Naming

- Feature branches: `feat/m{n}-{issue-number}-{short-name}`
- Examples:
  - `feat/m1-01-feature-schemas`
  - `feat/m1-05-feature-endpoint`
  - `feat/m1-11-13-feature-caching` (multiple issues)

---

## Integration & Verification (End of Milestone)

Before merging milestone → main:

### 1. Run Full CI

```bash
# Ensure all tests pass
pytest tests/

# Run linter
ruff check src/

# Run type checker (if configured)
mypy src/
```

### 2. Run Integration Tests

```bash
# Start local stack (adapt to your infrastructure)
docker-compose up -d

# Run integration tests
pytest tests/integration/

# Run E2E validation (if applicable)
python scripts/validate.py
```

### 3. Verify Acceptance Criteria

- Check epic acceptance criteria (from `docs/03-build-notes/milestones/m{n}/00-epic.md`)
- Verify NFR targets met
- Run demo script
- Check test coverage
- **Update epic documentation:** Mark acceptance criteria as complete in `docs/03-build-notes/milestones/m{n}/00-epic.md`
- **Update implementation plan:** Set status to "Complete" in `docs/03-build-notes/milestones/m{n}/IMPLEMENTATION_PLAN.md`

### 4. Create Final PR

Create PR: `milestone/m{n}-<short-name>` → `main`

**PR Description Template:**
```markdown
# M{n} Milestone: {Milestone Title}

## Summary
Completes all {N} M{n} issues and meets all acceptance criteria.

## Acceptance Criteria Verification
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## NFR Targets
- [ ] Target 1
- [ ] Target 2

## Issues Completed
- Closes #01, #02, #03, ... (all issues)
```

### 5. Resolve Merge Conflicts (if any)

If the milestone PR has conflicts:
```bash
gh pr checkout {pr-number}
git fetch origin main
git merge origin/main
# Resolve conflicts, then:
git add .
git commit -m "Merge main into milestone branch - resolve conflicts"
git push origin milestone/m{n}-<short-name>
```

### 6. Merge Milestone PR

```bash
gh pr merge {pr-number} --squash --delete-branch
```

### 7. Clean Up After Milestone Merge

After the milestone PR is merged to main:

```bash
# 1. Switch to main and pull latest
git checkout main
git pull origin main

# 2. Prune deleted remote branches
git remote prune origin

# 3. Verify cleanup
git branch -a | grep -i "m{n}\|milestone"  # Should show no results

# 4. Update any remaining documentation
git add docs/
git commit -m "docs(m{n}): Final milestone documentation updates"
git push origin main
```

**Note:** Feature branches are automatically deleted when PRs merge (if using `--delete-branch`). The milestone branch is deleted when the milestone PR merges. Use `git remote prune origin` to clean up stale remote tracking references.

### 8. Tag Release and Close Milestone

```bash
# Tag release (optional)
git tag -a v0.{n}.0 -m "M{n}: {Milestone Title}"
git push origin v0.{n}.0

# Close milestone on GitHub
gh milestone close "M{n} - {Milestone Title}"
```

---

## Autopilot Workflow Stop Conditions

When using automated workflow tools, stop conditions are categorized as:

### Hard Stops (Require User Attention)
These pause the workflow and require manual review:
- **Database Changes:** Any migration or schema change
- **Sensitive Code Changes:** Auth, permissions, rate-limit, or billing code
- **Dependency Changes:** Lockfile or license modifications
- **Issue Spec Problems:** Missing or ambiguous issue specifications

### Soft Stops (Skip Automatically)
These skip the current issue and continue to the next:
- **Test/Lint/Typecheck Failures:** Auto-fix attempted, then skip if still failing
- **Large Diff:** >8 files or >400 lines changed - skip with warning
- **Merge Conflicts:** Skip to next issue automatically

For manual workflows, these conditions should still be addressed, but in autopilot mode they allow continuous progress.

## Troubleshooting

### PR CI Failing

1. **Run tests locally:**
   ```bash
   pytest tests/
   ```

2. **Check linter and auto-fix:**
   ```bash
   ruff check src/
   ruff check --fix src/  # Auto-fix lint errors
   ```

3. **Fix issues and push:**
   ```bash
   git add .
   git commit -m "fix(m{n}): Fix CI failures"
   git push
   ```

### Merge Conflicts

1. **Update local branch:**
   ```bash
   git checkout milestone/m{n}-<short-name>
   git pull origin milestone/m{n}-<short-name>
   ```

2. **Rebase feature branch:**
   ```bash
   git checkout feat/m{n}-{issue-number}-{short-name}
   git rebase milestone/m{n}-<short-name>
   ```

3. **Resolve conflicts:**
   - Edit conflicted files
   - `git add` resolved files
   - `git rebase --continue`

4. **Force push (if needed):**
   ```bash
   git push --force-with-lease
   ```

### Issue Not Auto-Closing

- Ensure PR description includes `Closes #{issue-number}`
- Check issue number is correct
- Verify PR is merged (not just closed)

---

## Quick Reference

### Essential Commands

```bash
# Check status
git status
git branch --show-current

# Create feature branch
git checkout -b feat/m{n}-{issue-number}-{short-name}

# Commit
git add .
git commit -m "feat(m{n}): Description

Implements issue #XX
Closes #XX"

# Push (do this regularly - after each commit or every few commits)
git push origin {branch-name}

# Create draft PR
gh pr create --draft --title "..." --body "..."

# Update PR
git push  # Updates existing PR

# Merge PR
gh pr merge {pr-number} --squash --delete-branch
```

### File Locations (Customize for Your Project)

- Issue definitions: `docs/03-build-notes/milestones/m{n}/`
- Source code: `src/`
- Tests: `tests/`
- Migrations: `db/migrations/` (if applicable)
- Scripts: `scripts/`

---

## Related Documents

- [Development Cadence](dev-cadence.md) - High-level milestone process
- [Testing Strategy](testing-strategy.md) - Testing guidelines (if available)
