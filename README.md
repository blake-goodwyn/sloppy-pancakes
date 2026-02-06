# Milestone-Dev Boilerplate

A reusable boilerplate for milestone-based development with [Claude Code](https://claude.ai/code). Clone, customize, and immediately have an autonomous TDD-enforced development workflow operational for any project.

## What Is This?

This repo provides the **workflow infrastructure** for structured, milestone-based software development powered by Claude Code skills. It includes:

- **7 Claude Code skills** for the full development lifecycle
- **CLAUDE.md template** with git workflow, TDD enforcement, and documentation standards
- **Workflow scripts** for issue management and automation
- **Documentation templates** for milestones, specs, and implementation plans
- **Setup scripts** for instant customization

**No application code included** — this is framework-agnostic. Works with Python, Node.js, Go, or any stack.

## Quick Start

### 1. Clone

```bash
git clone https://github.com/YOUR_ORG/milestone-dev-boilerplate.git my-project
cd my-project
rm -rf .git && git init
```

### 2. Run Setup

**Unix/macOS:**
```bash
chmod +x setup.sh
./setup.sh "My Project" "my_project" "my-project" "Your Name" "you@example.com" "org/my-project"
```

**Windows PowerShell:**
```powershell
.\setup.ps1 "My Project" "my_project" "my-project" "Your Name" "you@example.com" "org/my-project"
```

The setup script replaces all `{{TOKEN}}` placeholders and self-deletes.

### 3. Customize CLAUDE.md

Edit `CLAUDE.md` to add your:
- Tech stack details
- Directory structure
- Development commands
- Domain-specific patterns

### 4. Start Building

```bash
# Create your first milestone branch
git checkout -b milestone/m0-project-bootstrap main

# Run the example milestone
/run-milestone m0

# Or create a new milestone from scratch
/create-milestone m1
```

## What's Included

### Claude Code Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| **Interview** | `/interview` | Explore requirements, surface edge cases and tradeoffs |
| **Create Milestone** | `/create-milestone m1` | Generate milestone docs (epic, specs, issues, plan) |
| **Plan Review** | `/plan-review m1` | 5-agent parallel review of plans before execution |
| **Run Milestone** | `/run-milestone m1` | Automated TDD development with code review |
| **PR Review** | `/pr-review 123` | Multi-agent code review with confidence scoring |
| **Systematic Debugging** | `/systematic-debugging` | 4-phase root cause analysis |
| **Test-Driven Development** | `/test-driven-development` | RED-GREEN-REFACTOR enforcement |

### Workflow Chain

```
/interview → /create-milestone → /plan-review → /run-milestone → /pr-review
     │              │                  │                │              │
  Explore      Generate           Quality gate     Build with     Review
  requirements  docs & specs      before execution  TDD + review   PRs
```

### Directory Structure

```
├── .claude/
│   ├── settings.local.json        # Pre-approved CLI permissions
│   └── skills/                    # 7 Claude Code skills
│       ├── create-milestone/
│       ├── interview/
│       ├── plan-review/
│       ├── pr-review/
│       ├── run-milestone/
│       ├── systematic-debugging/
│       └── test-driven-development/
│
├── CLAUDE.md                      # AI instruction template (customize this!)
│
├── docs/
│   ├── 00-context/                # Product vision
│   ├── 01-specs/                  # Technical specifications
│   ├── 02-architecture/           # Architecture decisions
│   ├── 03-build-notes/            # Milestones and fixes
│   │   ├── milestones/
│   │   │   ├── IMPLEMENTATION_PLAN_TEMPLATE.md
│   │   │   └── m0/               # Example starter milestone
│   │   └── fixes/
│   └── guides/
│       ├── setup.md               # Getting started guide
│       ├── implementation-workflow.md  # Daily workflow
│       └── dev-cadence.md         # Milestone lifecycle
│
├── scripts/
│   ├── push-issues.sh             # Create GitHub issues from specs
│   └── workflow/
│       └── next-issue.py          # Find next issue to work on
│
├── setup.sh                       # Unix setup (self-deleting)
├── setup.ps1                      # Windows setup (self-deleting)
└── .gitignore
```

## Placeholder Tokens

The setup scripts replace these tokens across all files:

| Token | Meaning | Example |
|-------|---------|---------|
| `{{PROJECT_NAME}}` | Human-readable project name | `My Platform` |
| `{{PROJECT_SLUG}}` | Python/package name (snake_case) | `my_platform` |
| `{{PROJECT_SLUG_HYPHEN}}` | Repo/pip name (kebab-case) | `my-platform` |
| `{{OWNER_NAME}}` | Git author name | `Blake` |
| `{{OWNER_EMAIL}}` | Git author email | `blake@example.com` |
| `{{GITHUB_ORG_REPO}}` | GitHub org/repo path | `org/my-platform` |

## Key Features

### TDD Enforcement
Every implementation follows RED-GREEN-REFACTOR. The `/run-milestone` skill enforces this cycle and catches violations.

### Two-Stage Code Review
1. **Spec Compliance** — Does the implementation match the issue spec exactly?
2. **Code Quality** — Security, performance, patterns

### Three Execution Modes
- **Interactive** (default) — User commands at decision points
- **Autonomous** (`--autonomous`) — Unattended, auto-fix/skip
- **Subagent** (`--subagent`) — Fresh agent per issue

### Branch Safety
```
main (protected — human merge only)
  ↑ milestone/m{n}-{name} (agent integration)
    ↑ feat/m{n}-{issue}-{slug} (agent work)
```
Agents never target `main` directly. Protected surfaces (auth, CI, migrations) require human review.

### Stop Conditions
Hard stops for database changes, sensitive code, and dependency modifications. Soft stops for test failures and large diffs. Kill switch (`panic`) for emergencies.

## How to Customize

### 1. CLAUDE.md
The most important file. Add your:
- **Tech stack** — Languages, frameworks, databases
- **Directory structure** — Your project layout
- **Development commands** — Build, test, lint commands
- **Key patterns** — Domain-specific conventions
- **Environment variables** — Required configuration

### 2. Issue Labels
Create labels for your project:
```bash
gh label create "type:feature" --color "0E8A16"
gh label create "type:bug" --color "D93F0B"
gh label create "prio:P0" --color "B60205"
gh label create "prio:P1" --color "FBCA04"
```

### 3. CI Pipeline
Add `.github/workflows/ci.yml` for your stack. The workflow requires CI to pass before merges.

### 4. Milestone Content
The `m0/` example shows the format. Create new milestones with:
```
/create-milestone m1
```

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh`) — authenticated
- Git 2.5+ (for worktree support)

## License

MIT
