# Workflow Tools

This directory contains development workflow tools that are separate from the main application source code.

## Purpose

These tools are designed to help with development workflow tasks such as:
- Issue management and tracking
- Branch management
- Development process automation

They are **not** part of the application runtime and should **never** import from application source code.

## Tools

### `next-issue.py`

Issue workflow helper script that helps you work through issues one-by-one.

**Usage:**
```bash
# Find and start the next open issue
python scripts/workflow/next-issue.py

# List all issues for a milestone
python scripts/workflow/next-issue.py --list

# Start a specific issue by number
python scripts/workflow/next-issue.py --start 52
```

## Design Principles

1. **Separation from Source Code**: These tools are standalone scripts that do not depend on the application codebase
2. **Development Only**: These are developer tools, not runtime dependencies
3. **Self-Contained**: Each tool should be runnable independently

## Adding New Workflow Tools

When adding new workflow tools:

1. Place them in this `scripts/workflow/` directory
2. Ensure they do not import from application source code
3. Use standard library or external dependencies only
4. Update this README with documentation for the new tool
