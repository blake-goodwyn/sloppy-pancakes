# CLAUDE.md - {{PROJECT_NAME}}

## Project Overview

**{{PROJECT_NAME}}** — <!-- Add a brief description of your project here -->

**Version:** 0.1.0
**License:** MIT

## Tech Stack

<!-- Customize this section for your project -->

### Backend
<!-- Example: -->
<!-- - **Python 3.11+** with FastAPI -->
<!-- - **PostgreSQL 15+** with PostGIS -->
<!-- - **SQLAlchemy 2.0** (async) -->
<!-- - **Alembic** for database migrations -->
<!-- - **Pydantic 2.x** for validation -->

### Frontend
<!-- Example: -->
<!-- - **React 19** with Vite -->
<!-- - **Vitest** for testing -->

## Directory Structure

<!-- Customize this for your project layout -->

```
/workspace
├── src/{{PROJECT_SLUG}}/       # Backend source code
├── tests/                       # Backend tests
├── docs/                        # Documentation
│   ├── 00-context/              # Product context
│   ├── 01-specs/                # Technical specifications
│   ├── 02-architecture/         # Architecture docs
│   └── 03-build-notes/          # Milestones and build notes
└── scripts/                     # Utility scripts
```

## Development Commands

<!-- Customize these for your project -->

### Backend

```bash
# Install dependencies
pip install -e ".[dev]"

# Run tests
pytest tests/

# Run tests in parallel
pytest -n auto tests/

# Linting
ruff check src/ tests/
ruff format src/ tests/

# Type checking
mypy src/{{PROJECT_SLUG}}/
```

### Frontend

```bash
cd frontend

# Install dependencies
npm install

# Run tests
npm test

# Build
npm run build
```

## Code Conventions

<!-- Customize for your project. Common defaults: -->

### Python
- **Ruff** for linting (line length: 100)
- **mypy** with strict typing
- **Google-style docstrings**
- **async/await** patterns throughout
- Import order: stdlib, third-party, first-party (`{{PROJECT_SLUG}}`)

### TypeScript/JavaScript
- **Vitest** for testing
- Functional components with hooks

### API Design
- Versioned routes under `/api/v0/`
- RFC 7807 Problem+JSON for errors

## Key Patterns

<!-- Add your domain-specific patterns here -->
<!-- Examples: -->
<!-- - Trust Envelope pattern for data provenance -->
<!-- - Adapter framework for external data sources -->
<!-- - Event source attribution -->

## Testing

### Backend Tests
- Unit tests: `tests/test_*/`
- Integration tests: `tests/integration/`
- E2E tests: `tests/e2e/`
- Fixtures in `tests/conftest.py`

### Frontend Tests
- Component tests: `frontend/src/**/*.test.jsx`
- Test utilities: `frontend/src/test/`

## Environment Variables

Key variables (see `.env.example`):
```
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/mydb
JWT_SECRET=your-secret-key
```

## Git Workflow

### Commit Attribution

**All commits must be attributed to the project owner:**

```bash
git config user.email "{{OWNER_EMAIL}}"
git config user.name "{{OWNER_NAME}}"
```

**Prohibited:**
- Never use AI-attributed email addresses
- Never include `Co-authored-by: Claude` or similar AI attribution
- Commits represent work done on behalf of the project owner

All work, including AI-assisted development, is attributed to the human project owner.

### Branch Strategy

```
main (protected — human merge only)
  ↑
  │ Requires: human approval + all CI checks
  │
milestone/m{n}-{name} (agent integration branch)
  ↑
  │ Auto-merge: CI green + no protected surfaces
  │
feat/m{n}-{issue}-{slug} (feature work)
```

### Branch Naming
- **Milestone branch:** `milestone/m{n}-{short-name}` (e.g., `milestone/m5-detection-ingest`)
- **Feature branch:** `feat/m{n}-{issue}-{slug}` (e.g., `feat/m5-382-satellite-markers`)

### Commit Message Format

```
{type}(m{n}): {brief description} (#{issue})

- {change 1}
- {change 2}

Closes #{issue-number}
```

**Types:** `feat`, `fix`, `test`, `docs`, `refactor`, `chore`

**Example:**
```bash
git commit -m "feat(m1): Add user authentication (#12)

- Add JWT token generation
- Add login endpoint
- Add auth middleware

Closes #12"
```

### PR Guidelines

- **Target:** Never target `main` directly — always target `milestone/*` branch
- **Size:** Reviewable in <30 minutes; split large PRs by vertical slice
- **Description:** Include acceptance criteria checklist and `Closes #{issue}`
- **Squash merge:** Use `gh pr merge --squash --delete-branch`
- **Post-merge validation:** After merge, verify:
  1. Server starts without import errors
  2. New endpoints/adapters are accessible
  3. No console errors in frontend (for UI PRs)

### Protected Surfaces (require human review)

| Surface | Files/Patterns |
|---------|----------------|
| Auth | `**/auth/**`, `**/middleware/auth*` |
| Secrets | `**/.env*`, `**/credentials*` |
| Infrastructure | `**/deploy/**`, `Dockerfile*` |
| CI/CD | `.github/workflows/**` |
| Migrations | `**/alembic/**`, `**/migrations/**` |
| Dependencies | `requirements*.txt`, `package*.json` |

## Milestone Development Process

### Milestone Documentation Structure

Each milestone has documentation in `docs/03-build-notes/milestones/m{n}/`:

```
m{n}/
├── _milestone.md           # Milestone metadata
├── 00-epic.md              # Epic with acceptance criteria
├── IMPLEMENTATION_PLAN.md  # Issue tracking & progress
└── {nn}-{issue-name}.md    # Individual issue specs
```

### Running a Milestone

Use the `/run-milestone` skill for automated development:

```bash
/run-milestone m1              # Interactive mode (default)
/run-milestone m1 --autonomous # No prompts, auto-fix/skip
/run-milestone m1 --subagent   # Fresh agent per issue
```

### TDD Enforcement (Mandatory)

Every implementation follows **RED-GREEN-REFACTOR**:

1. **RED:** Write failing test first
   ```bash
   pytest tests/ -k "test_new_feature" -v  # Must FAIL
   ```

2. **GREEN:** Implement minimum code to pass
   ```bash
   pytest tests/ -k "test_new_feature" -v  # Must PASS
   ```

3. **REFACTOR:** Clean up while keeping tests green

4. **COMMIT:** `git commit -m "feat(m{n}): {behavior} (#{issue})"`

### Two-Stage Code Review

**Stage 1: Spec Compliance**
- All acceptance criteria met?
- No extra functionality? (YAGNI)
- File paths/API contracts match spec?

**Stage 2: Code Quality**
- Security vulnerabilities?
- Performance anti-patterns?
- Proper error handling?

### Pre-Merge Checklist (Required)

Before merging any PR, verify the following:

**Dependencies & Imports**
- [ ] All new dependencies added to requirements/package files
- [ ] New modules importable without errors
- [ ] No missing runtime dependencies

**Registration & Initialization**
- [ ] New services/adapters registered in startup sequence
- [ ] Background tasks scheduled if required
- [ ] Database models importable for migration detection

**Code Quality**
- [ ] No hardcoded magic values (use constants from config)
- [ ] UI components manually tested in browser (for frontend PRs)

**Integration**
- [ ] Smoke test: server starts without errors
- [ ] Health check endpoints respond
- [ ] New endpoints are accessible

### Issue Status Markers

In `IMPLEMENTATION_PLAN.md`:
- `⬜` Pending
- `🔄` In Progress
- `✅` Done
- `⏭️` Skipped
- `⛔` Blocked/Needs Review

### Workflow Commands

During `/run-milestone`, use these commands:
- `continue` — Approve and proceed
- `fix` — Attempt fix, retry
- `skip` — Skip issue, continue to next
- `approve` — Acknowledge risk, proceed
- `abort` — Stop (resume later)
- `panic` — Emergency halt

## Documentation Maintenance (Required)

**Documentation must be kept in sync with code changes.** This is not optional.

### IMPLEMENTATION_PLAN.md Updates

The `IMPLEMENTATION_PLAN.md` file is the **source of truth** for milestone progress. Update it when:

| Event | Action |
|-------|--------|
| Starting an issue | Mark as `🔄 In Progress` |
| Creating a PR | Add PR number to "Open PRs" section |
| Merging a PR | Mark issue as `✅ Done`, remove from "Open PRs" |
| Skipping an issue | Mark as `⏭️ Skipped` with reason |
| Encountering blocker | Mark as `⛔ Blocked`, document reason |

### Issue File Updates

Each issue spec (`{nn}-{issue-name}.md`) should be updated:
- Add `github_issue: {number}` to frontmatter after issue creation
- Update acceptance criteria if scope changes during implementation
- Add notes about implementation decisions or deviations

### GitHub Issues & Milestones Synchronization

**GitHub is the external source of truth for project tracking.** Keep it synchronized with local documentation.

#### GitHub Milestone Management

| Event | Action |
|-------|--------|
| Starting a new milestone | Create GitHub Milestone via `gh api repos/{owner}/{repo}/milestones -f title="M{n}: {Title}" -f description="..." -f due_on="YYYY-MM-DDT00:00:00Z"` |
| Milestone scope change | Update milestone description and due date |
| Milestone complete | Close milestone: `gh api repos/{owner}/{repo}/milestones/{number} -X PATCH -f state="closed"` |

#### GitHub Issue Management

| Event | Action |
|-------|--------|
| Creating issue from spec | Use `./scripts/push-issues.sh` or `gh issue create --milestone "M{n}: {Title}"` |
| Starting work on issue | Assign yourself: `gh issue edit {number} --add-assignee @me` |
| Issue blocked | Add `blocked` label and comment with blocker details |
| PR merged for issue | Verify issue auto-closed (via `Closes #{number}`), or close manually |
| Scope change | Update issue body and add comment explaining change |

#### Required GitHub Updates During Development

**When starting an issue:**
```bash
# Assign and add in-progress label
gh issue edit {number} --add-assignee @me --add-label "in-progress"
```

**When creating a PR:**
- Include `Closes #{issue}` or `Fixes #{issue}` in PR description
- Ensure PR is linked to the correct milestone
- Add relevant labels (`feat`, `fix`, `test`, etc.)

**When merging a PR:**
- Verify the linked issue was auto-closed
- If not auto-closed, close manually: `gh issue close {number}`
- Update `IMPLEMENTATION_PLAN.md` to reflect completion

**When completing a milestone:**
```bash
# Verify all issues closed
gh issue list --milestone "M{n}: {Title}" --state open

# Close the milestone
gh api repos/{owner}/{repo}/milestones/{number} -X PATCH -f state="closed"
```

#### Synchronization Checklist

Before ending any work session, verify:
- [ ] All in-progress issues have `in-progress` label on GitHub
- [ ] All merged PRs have their linked issues closed
- [ ] `IMPLEMENTATION_PLAN.md` matches GitHub issue states
- [ ] Milestone progress (open/closed issues) reflects actual status

### What Gets Updated When

| Change Type | Update These Docs |
|-------------|-------------------|
| New API endpoint | API docs, OpenAPI schema, README if public |
| New feature | IMPLEMENTATION_PLAN, issue file, README if user-facing |
| Bug fix | IMPLEMENTATION_PLAN, issue file |
| Schema change | Migration notes, architecture docs if significant |
| Config change | `.env.example`, README setup section |
| New dependency | README prerequisites, `docs/guides/setup.md` |

## Quick Reference

### Find Next Issue
```bash
python scripts/workflow/next-issue.py
python scripts/workflow/next-issue.py --list  # List all
```

### Create GitHub Issue
```bash
./scripts/push-issues.sh m{n} {issue-file}.md
```

### Standard PR Creation
```bash
gh pr create \
  --title "feat(m{n}): {title} (#{issue})" \
  --body "..." \
  --base milestone/m{n}-{name}
```

### End of Milestone
1. Verify all acceptance criteria (from `00-epic.md`)
2. Run full test suite: `pytest tests/`
3. Run E2E tests with database: `pytest tests/e2e/ -m e2e`
4. Manual smoke test:
   - Start backend
   - Start frontend (if applicable)
   - Verify new features work end-to-end
5. Create milestone → main PR
6. Tag release: `git tag -a v0.{n}.0 -m "M{n}: {Title}"`

## Current Milestone

<!-- Update this as you progress -->
M0 in progress. See `docs/03-build-notes/milestones/` for milestone documentation and implementation plans.

## Lessons Learned

<!-- Add retrospective notes after each milestone -->
<!-- Example format:
### M1 Retrospective
**What worked well:**
- Item 1
**What to improve:**
- Item 1
-->
