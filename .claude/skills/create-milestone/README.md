# Create Milestone Skill

Create complete milestone documentation from roadmap items — produces all artifacts needed for `/run-milestone`.

## Quick Start

```
create-milestone m5
```

The skill will:
1. Load roadmap context
2. Interview you about goals, design, and breakdown
3. Generate epic, specification, issue specs, and implementation plan
4. Optionally create GitHub issues

## Output

Creates these files in `<milestone-folder>/<milestone>/`:

```
m5/
├── 00-epic.md              # Goals, success criteria, scope
├── 00-SPECIFICATION.md     # Technical design, architecture
├── 01-first-issue.md       # Issue spec
├── 02-second-issue.md      # Issue spec
├── ...
└── IMPLEMENTATION_PLAN.md  # Phases, dependencies, tracking
```

## Usage

### From Roadmap (Recommended)

```
create-milestone m5 --from-roadmap
```

Extracts context from your roadmap file to seed the interview.

### Interactive (Default)

```
create-milestone m5
```

Full interview mode — thorough exploration of all areas.

### Quick Mode

```
create-milestone m5 --quick
```

Minimal questions, generates defaults from roadmap. Good for well-defined milestones.

## Workflow

```
┌─────────────────────────────────────────────────┐
│                  create-milestone               │
├─────────────────────────────────────────────────┤
│  1. Load roadmap context                        │
│  2. Interview: Epic & Goals → 00-epic.md        │
│  3. Interview: Technical → 00-SPECIFICATION.md  │
│  4. Interview: Issues → NN-*.md (each)          │
│  5. Interview: Phases → IMPLEMENTATION_PLAN.md  │
│  6. Create GitHub issues (optional)             │
│  7. Summary & next steps                        │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│                  run-milestone                  │
│  Executes the generated plan                    │
└─────────────────────────────────────────────────┘
```

## Interview Areas

The skill explores:

| Area | Questions |
|------|-----------|
| **Epic** | Problem, users, success criteria, scope, risks |
| **Technical** | Architecture, components, data models, APIs |
| **Issues** | Breakdown, granularity, dependencies |
| **Planning** | Phases, critical path, review strategy |

For complex areas, invokes `/interview` skill for deep exploration.

## Generated Artifacts

### Epic (`00-epic.md`)

```markdown
# M1: User Authentication

## Goals
- Enable secure user login and registration
- Support password reset flow
- Ensure session management

## Success Criteria
- [ ] Users can register and log in
- [ ] Password reset via email works
- [ ] Sessions expire after 24h of inactivity
```

### Specification (`00-SPECIFICATION.md`)

```markdown
# M1: Technical Specification

## Architecture
┌─────────┐    ┌──────────┐    ┌─────────┐
│ Auth API│───▶│ Validate │───▶│ Session │
└─────────┘    └──────────┘    └─────────┘

## Components
- Auth API: Handles login/register/logout
- Validator: Input validation and password rules
- Session: JWT-based session management
```

### Issue Specs (`NN-*.md`)

```markdown
---
title: "Add user login endpoint"
github_issue: 101
priority: P0
dependencies: []
---

# Add user login endpoint

## Done Definition
POST /api/v0/auth/login accepts credentials and returns JWT.

## Acceptance Criteria
- [ ] Endpoint accepts email/password
- [ ] Returns JWT on success
- [ ] Returns 401 on invalid credentials
```

### Implementation Plan

```markdown
# M1: Implementation Plan

## Milestone Metadata
- **Branch:** milestone/m1-user-auth
- **Scope Tags:** auth, api

## Phases

### Phase 1: Foundation
| # | Issue | Priority |
|---|-------|----------|
| 01 | Add user login endpoint | P0 |
| 02 | Add password hashing | P0 |

### Phase 2: Sessions
| # | Issue | Priority |
|---|-------|----------|
| 03 | Add JWT generation | P0 |
| 04 | Add session middleware | P0 |
```

## Integration with /interview

| Scenario | Behavior |
|----------|----------|
| Complex issue | Invoke `/interview <issue-file>` |
| Technical uncertainty | Invoke `/interview "M5 architecture"` |
| Simple/clear scope | Direct questions |

## Next Steps After Creation

```bash
# 1. Review generated specs
cat <milestone-folder>/m1/IMPLEMENTATION_PLAN.md

# 2. Create milestone branch
git checkout -b milestone/m1-user-auth main

# 3. Run milestone
run-milestone m1
```

## See Also

- [SKILL.md](./SKILL.md) — Full specification
- [Interview Skill](../interview/SKILL.md) — Deep-dive exploration
- [Run Milestone Skill](../run-milestone/SKILL.md) — Execute plans
