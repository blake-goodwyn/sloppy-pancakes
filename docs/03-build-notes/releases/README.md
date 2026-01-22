# Releases

## Purpose

Track release notes and versioned changes.

## Structure

After each milestone merges to `main`, create:
- `vX.Y.Z-RELEASE_NOTES.md` - What's new
- `vX.Y.Z-GETTING_STARTED.md` - Setup instructions
- `vX.Y.Z-API_REFERENCE.md` - API documentation (if applicable)

## Release Cadence

- One release per milestone merge
- Version format: `v0.{milestone}.{patch}` (e.g., `v0.1.0` for M1)
- Each release file should include:
  - Linked PRs/issues
  - Notable migrations or setup changes
  - Breaking changes (if any)

## Templates

Use these templates for new releases:
- [RELEASE_NOTES_TEMPLATE.md](RELEASE_NOTES_TEMPLATE.md)
- [GETTING_STARTED_TEMPLATE.md](GETTING_STARTED_TEMPLATE.md)
- [API_REFERENCE_TEMPLATE.md](API_REFERENCE_TEMPLATE.md)
