# Scripts

Utility scripts for development workflow and project management.

## Directory Structure

```
scripts/
├── README.md              # This file
├── push-issues.sh         # Create GitHub issues from markdown specs
└── workflow/
    ├── README.md           # Workflow tools documentation
    └── next-issue.py       # Find and start next issue
```

## push-issues.sh

Creates GitHub issues from markdown issue spec files with YAML frontmatter.

```bash
# Push a single issue
./scripts/push-issues.sh m0 01-project-bootstrap.md

# Push all issues for a milestone
./scripts/push-issues.sh m0 --all

# Dry-run to preview
./scripts/push-issues.sh m0 --all --dry-run
```

**Prerequisites:**
- GitHub CLI (`gh`) installed and authenticated
- Issue spec files with YAML frontmatter (`title`, `labels` fields)
- `_milestone.md` file in milestone directory

## workflow/

Development workflow automation tools. See [workflow/README.md](workflow/README.md) for details.
