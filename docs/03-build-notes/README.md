# Build Notes

## Purpose

Track milestone development, release documentation, and fixes/regressions.

## Structure

- **milestones/** - Implementation plans and issue specs per milestone
- **releases/** - Release documentation per version
- **fixes/** - Hotfix and regression tracking

## Active Links

- Milestones: [milestones/](milestones/)
- Release docs: [releases/README.md](releases/README.md)
- Fixes: [fixes/README.md](fixes/README.md)

## Milestone Lifecycle

1. Create milestone folder: `milestones/m{n}/`
2. Add epic: `00-epic.md`
3. Add implementation plan: `IMPLEMENTATION_PLAN.md`
4. Add issue specs: `{nn}-{short-name}.md`
5. Execute with `/run-milestone m{n}`
6. After merge, create release docs in `releases/`
