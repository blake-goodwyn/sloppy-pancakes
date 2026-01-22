# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

<!-- TODO: Replace with your project description -->
[PROJECT_NAME] is a [brief description of what your project does]. Built with [primary technologies].

## Commands

```bash
# Installation
<!-- TODO: Replace with your installation commands -->
pip install -e ".[dev]"          # Python example
npm install                       # Node.js example

# CLI commands (if applicable)
<!-- TODO: Replace with your CLI commands -->
[project] [command] --[options]

# Testing
<!-- TODO: Replace with your test commands -->
pytest                           # Run all tests
pytest tests/test_*.py           # Run single test file
pytest -k "test_name"            # Run tests matching pattern

# Linting
<!-- TODO: Replace with your lint commands -->
ruff check src/                  # Python
eslint .                         # JavaScript/TypeScript

# Type checking (if applicable)
mypy src/                        # Python
tsc --noEmit                     # TypeScript
```

## Architecture

<!-- TODO: Replace with your architecture description -->

### Key Modules
- `src/main.py` - Entry point
- `src/core/` - Core business logic
- `src/api/` - API layer
- `src/storage/` - Data persistence
- `tests/` - Test suite

### Data Storage
- Database: `data/app.sqlite` (or describe your storage)
- Config: `configs/` directory

## Environment Variables

<!-- TODO: Replace with your environment variables -->
- `API_KEY` - API key for external service
- `DATABASE_URL` - Database connection string
- `DEBUG=1` - Enable debug mode

## Configuration

<!-- TODO: Replace with your configuration details -->
Configuration files are located in `configs/`. Start from `configs/sample.json`.

## Development Workflow

### Branching Strategy
- `main` (or `master`) - always deployable main branch
- `milestone/M{n}-<short-name>` - integration branch per milestone
- `feat/m{n}-{issue}-<short-name>` - feature branches for individual issues

### Milestone Structure
Issue specs and implementation plans live in `docs/03-build-notes/milestones/m{n}/`:
- `IMPLEMENTATION_PLAN.md` - source of truth for milestone progress
- `00-epic.md` - milestone epic with acceptance criteria
- `{nn}-{short-name}.md` - individual issue specs

### Commit Convention
Use `feat(m{n})`, `fix(m{n})`, `docs(m{n})`, `test(m{n})`, `chore(m{n})` prefixes with issue number in body and `Closes #XX` when done.

### Stop Conditions
- **Hard stops** (require review): DB migrations, auth changes, dependency changes, unclear specs
- **Soft stops** (skip and continue): test failures after attempted fixes, large diffs (>8 files or >400 lines), merge conflicts

See `docs/guides/implementation-workflow.md` and `docs/guides/dev-cadence.md` for full workflow details.

## Claude Code Skills

Custom skills in `.claude/skills/`:

- **run-milestone** - Automates milestone execution: processes issues from implementation plans, creates PRs, manages branches. Invoke with `/run-milestone m{n}`.
- **interview** - Conducts in-depth interviews about features/specs to surface edge cases and tradeoffs before implementation. Invoke with `/interview`.
