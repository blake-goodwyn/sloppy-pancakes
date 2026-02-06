# Implementation Workflow

This guide provides step-by-step instructions for implementing issues during milestone development. It covers the daily workflow from picking up an issue to merging a PR, including branch management, commit conventions, PR creation, and issue tracking.

---

## Quick Start

Use the workflow helper script to find and start the next issue:

```bash
# Find and start the next open issue
python scripts/workflow/next-issue.py

# List all issues for a milestone
python scripts/workflow/next-issue.py --list

# Start a specific issue by number
python scripts/workflow/next-issue.py --start 52
```

The script automates:
- Finding the next open issue
- Showing acceptance criteria
- Setting up the correct branch
- Providing next steps

**Note:** The script and all workflow tools use `docs/03-build-notes/m{n}/IMPLEMENTATION_PLAN.md` as the source of truth for milestone progress. This file tracks issue status, dependencies, open PRs, and current progress.

For detailed manual workflow steps, see the [Daily Implementation Loop](#daily-implementation-loop) section below.

---

## Branch Structure

- **Main branch:** `main` (always deployable)
- **Milestone branch:** `milestone/M{n}-<short-name>` (single integration branch per milestone, e.g., `milestone/m1-deterministic-aoi`)
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
git checkout -b feat/m1-01-aoi-schemas
```

### 3. Verify Issue Exists

Before starting implementation:

```bash
# Check if GitHub issue exists
grep "github_issue:" docs/03-build-notes/m{n}/{issue-file}.md

# If missing, create issue
./scripts/push-issues.sh m{n} {issue-file}.md

# Update frontmatter with issue number after creation
# Edit docs/03-build-notes/m{n}/{issue-file}.md
# Add: github_issue: {number}
```

### 4. Implement with Tests

- Write code following issue specifications from `docs/03-build-notes/m{n}/{issue-file}.md`
- Write tests alongside implementation (don't defer testing)
- Run tests locally: `pytest tests/`
- Run linter: `ruff check src/`
- **Auto-fix lint errors:** `ruff check --fix src/` (automatically applied in autopilot mode)
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
git commit -m "feat(m1): Add AOI Pydantic schemas

Implements issue #01: Define AOI Pydantic schemas

- Add AOICreateRequest, AOIUpdateRequest, AOIValidateRequest
- Add AOIResponse, AOIListResponse, AOIValidationResult
- Integrate GeoJSON validation with shapely

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

### 6. Open PR Early (Draft)

Create a draft PR as soon as you have initial code:

```bash
# Push branch
git push origin feat/m1-01-aoi-schemas

# Create draft PR via GitHub CLI
gh pr create --draft \
  --title "feat(m1): Add AOI Pydantic schemas (#01)" \
  --body "Implements issue #01: Define AOI Pydantic schemas

## Changes
- Add AOI request/response schemas
- Integrate GeoJSON validation

## Acceptance Criteria
- [ ] All schemas importable
- [ ] Geometry validation works

Closes #01"
```

**Or via GitHub Web UI:**
- Push branch to remote
- Click "Compare & pull request"
- Mark as "Draft"
- Fill in PR description using template below

### 7. Update PR Continuously

As you make progress:

1. **Push commits frequently:**
   ```bash
   git push
   ```

2. **Update PR description with running changelog:**
   ```markdown
   ## Changelog
   - Added AOICreateRequest schema
   - Added AOIResponse schema
   - Integrated shapely geometry validation
   - Added unit tests for schema validation
   ```

3. **Mark acceptance criteria as complete:**
   ```markdown
   ## Acceptance Criteria
   - [x] All schemas importable
   - [x] Geometry validation works
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

Located at: `docs/03-build-notes/m{n}/IMPLEMENTATION_PLAN.md`

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
   cat docs/03-build-notes/m{n}/IMPLEMENTATION_PLAN.md
   ```

2. **Check if issue exists:**
   ```bash
   grep "github_issue:" docs/03-build-notes/m{n}/{issue-file}.md
   ```

3. **Create issue if missing:**
   ```bash
   ./scripts/push-issues.sh m{n} {issue-file}.md
   ```

4. **Update frontmatter:**
   - Edit `docs/03-build-notes/m{n}/{issue-file}.md`
   - Add: `github_issue: {number}`

### During Implementation

- Comment on issue when starting work
- Update with progress if blocked
- Link PR to issue: Include `Closes #{issue-number}` in PR description
- **Update Implementation Plan:** Add PR to "Open PRs (autopilot)" section

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
  - `feat/m1-01-aoi-schemas`
  - `feat/m1-05-aoi-validate-endpoint`
  - `feat/m1-11-13-aoi-summary-caching` (multiple issues)

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
# Start local stack
docker-compose up -d

# Run integration tests
pytest tests/test_integration/

# Run E2E validation
python scripts/validate_map_flow.py
```

### 3. Verify Acceptance Criteria

- Check epic acceptance criteria (from `docs/03-build-notes/m{n}/00-epic.md`)
- Verify NFR targets met
- Run demo script
- Check test coverage

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

### 5. After Merge

```bash
# Tag release
git tag -a v0.{n}.0 -m "M{n}: {Milestone Title}"
git push origin v0.{n}.0

# Close milestone on GitHub
gh milestone close "M{n} - {Milestone Title}"
```

---

## Common Workflows

### Starting a New Issue

```bash
# 1. Ensure on milestone branch
git checkout milestone/m1-deterministic-aoi
git pull origin milestone/m1-deterministic-aoi

# 2. Create feature branch (if needed)
git checkout -b feat/m1-01-aoi-schemas

# 3. Verify/create issue
./scripts/push-issues.sh m1 01-aoi-schemas.md

# 4. Start implementing
# ... write code ...

# 5. Commit
git add .
git commit -m "feat(m1): Add AOI Pydantic schemas

Implements issue #01: Define AOI Pydantic schemas
Closes #01"

# 6. Push and create draft PR
git push origin feat/m1-01-aoi-schemas
gh pr create --draft --title "feat(m1): Add AOI Pydantic schemas (#01)"
```

### Updating an Existing PR

```bash
# 1. Make changes
# ... edit files ...

# 2. Test locally
pytest tests/

# 3. Commit
git add .
git commit -m "feat(m1): Add geometry validation tests

- Add unit tests for AOI geometry validation
- Test invalid geometries are rejected"

# 4. Push (updates existing PR)
git push

# 5. Update PR description if needed
gh pr edit {pr-number} --body "Updated description..."
```

### Fixing Review Comments

```bash
# 1. Make requested changes
# ... edit files ...

# 2. Commit fix
git add .
git commit -m "fix(m1): Address review comments

- Fix geometry validation edge case
- Update error messages"

# 3. Push
git push

# 4. Re-request review (via GitHub UI or comment)
```

### Merging Multiple Related Issues

```bash
# 1. Create feature branch for grouped work
git checkout -b feat/m1-11-13-aoi-summary-caching

# 2. Implement all related issues
# ... implement issue 11, 12, 13 ...

# 3. Commit with references to all issues
git commit -m "feat(m1): Implement AOI summary with caching

Implements issues #11, #12, #13:
- Add summary endpoint
- Add preview endpoint
- Add caching layer

Closes #11
Closes #12
Closes #13"

# 4. Create PR referencing all issues
gh pr create --draft \
  --title "feat(m1): AOI summary with caching (#11, #12, #13)" \
  --body "Implements issues #11, #12, #13

Closes #11
Closes #12
Closes #13"
```

---

## Autopilot Workflow Stop Conditions

When using the `run-milestone` autopilot workflow, stop conditions are categorized as:

### Hard Stops (Require User Attention)
These pause the workflow and require manual review:
- **Database Changes:** Any migration or schema change
- **Sensitive Code Changes:** Auth, permissions, rate-limit, or billing code
- **Dependency Changes:** Lockfile or license modifications
- **Issue Spec Problems:** Missing or ambiguous issue specifications

### Soft Stops (Skip Automatically)
These skip the current issue and continue to the next:
- **Test/Lint/Typecheck Failures:** Auto-fix attempted (`ruff check --fix src/`), then skip if still failing
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
   git commit -m "fix(m1): Fix CI failures"
   git push
   ```

### Merge Conflicts

1. **Update local branch:**
   ```bash
   git checkout milestone/m1-deterministic-aoi
   git pull origin milestone/m1-deterministic-aoi
   ```

2. **Rebase feature branch:**
   ```bash
   git checkout feat/m1-01-aoi-schemas
   git rebase milestone/m1-deterministic-aoi
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

# Push
git push origin {branch-name}

# Create draft PR
gh pr create --draft --title "..." --body "..."

# Update PR
git push  # Updates existing PR

# Merge PR
gh pr merge {pr-number} --squash --delete-branch
```

### File Locations

- Issue definitions: `docs/03-build-notes/m{n}/`
- Source code: `src/{{PROJECT_SLUG}}/`
- Tests: `tests/`
- Migrations: `alembic/versions/`
- Scripts: `scripts/`

---

## Workflow Automation

The `scripts/workflow/next-issue.py` script automates the initial steps of the workflow:
- Finds the next open issue based on priority and dependencies
- Shows acceptance criteria from the issue file
- Helps set up the correct branch (milestone or feature branch)
- Provides next steps for implementation

This is particularly useful when working through a milestone systematically. For manual workflows, follow the steps in the [Daily Implementation Loop](#daily-implementation-loop) section above.

---

## Related Documents

- [Development Cadence](dev-cadence.md) - High-level milestone process
- [Testing Strategy](testing-strategy.md) - Testing guidelines
- [Setup Guide](setup.md) - Environment setup
