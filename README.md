# Agent-Developed Project Boilerplate

This folder contains a skeleton project structure designed for agent-developed projects. It provides the documentation scaffolding, workflow guides, and Claude Code skills needed to run a milestone-driven development workflow with AI agents.

## What's Included

```
boilerplate/
├── README.md                 # This file
├── CLAUDE.md                 # Claude Code instructions template
├── docs/
│   ├── README.md             # Documentation index
│   ├── 00-context/           # Strategic context (vision, glossary, roadmap)
│   ├── 01-specs/             # Requirements and specifications
│   ├── 02-architecture/      # System design templates
│   ├── 03-build-notes/       # Release docs and milestone tracking
│   │   ├── milestones/       # Milestone implementation plans
│   │   ├── releases/         # Release documentation templates
│   │   └── fixes/            # Hotfix tracking
│   └── guides/               # Development workflow guides
└── .claude/
    └── skills/               # Claude Code custom skills
        ├── run-milestone/    # Automated milestone execution
        └── interview/        # Feature interview skill
```

## How to Use

1. **Copy to your project root:**
   ```bash
   cp -r boilerplate/* /path/to/your/project/
   cp -r boilerplate/.claude /path/to/your/project/
   ```

2. **Customize CLAUDE.md:**
   - Update project overview section
   - Add your CLI commands
   - Define architecture and key modules
   - Set environment variables

3. **Fill in docs/00-context/:**
   - `product-vision.md` - Your product vision
   - `domain-glossary.md` - Domain-specific terminology
   - `roadmap.md` - Milestone roadmap

4. **Create your first milestone:**
   - Copy `docs/03-build-notes/milestones/m0-example/` to `m1-your-milestone/`
   - Fill in the epic and implementation plan
   - Add issue specs for each task

5. **Run the workflow:**
   - Use `/interview` to refine issue specs
   - Use `/run-milestone m1` to automate implementation

## Workflow Overview

This boilerplate supports a **TPM + agent engineer** model:

1. **TPM (you):** Define milestones, break down into issues, review PRs
2. **Agent (Claude):** Implement issues, create PRs, run tests

### Milestone Lifecycle

1. **Kickoff** - Create epic with acceptance criteria
2. **Planning** - Break epic into issues, create implementation plan
3. **Execution** - Agent implements issues one-by-one
4. **Integration** - Verify all acceptance criteria met
5. **Release** - Merge to main, tag release

### Stop Conditions

The workflow respects these safety boundaries:

**Hard Stops (require human review):**
- Database migrations or schema changes
- Auth, permissions, or billing code changes
- Dependency or license changes
- Ambiguous or missing specifications

**Soft Stops (auto-skip to next issue):**
- Test failures after attempted fixes
- Large diffs (>8 files or >400 lines)
- Merge conflicts

## Customization Checklist

Before using this boilerplate, customize these files:

- [ ] `CLAUDE.md` - Project-specific instructions
- [ ] `docs/00-context/product-vision.md` - Your product vision
- [ ] `docs/00-context/domain-glossary.md` - Your terminology
- [ ] `docs/00-context/roadmap.md` - Your milestones
- [ ] `docs/guides/dev-cadence.md` - Adjust tooling (linters, test runners)
- [ ] `docs/guides/implementation-workflow.md` - Adjust paths and commands
- [ ] `.claude/skills/*/SKILL.md` - Update paths if needed

## Documentation Structure

| Folder | Purpose |
|--------|---------|
| `00-context/` | Strategic direction: vision, glossary, roadmap |
| `01-specs/` | Requirements: PRD, functional/non-functional specs |
| `02-architecture/` | System design: components, data flow, integrations |
| `03-build-notes/` | Development tracking: milestones, releases, fixes |
| `guides/` | Developer workflows: cadence, implementation, testing |

## Skills

### `/run-milestone`
Automates milestone execution:
- Reads implementation plan
- Implements issues sequentially
- Creates PRs with auto-merge
- Respects stop conditions

### `/interview`
Surfaces non-obvious concerns:
- Probes technical, operational, security areas
- Identifies edge cases and tradeoffs
- Refines issue specs before implementation

## License

This boilerplate is provided as-is. Adapt it to your project's needs.
