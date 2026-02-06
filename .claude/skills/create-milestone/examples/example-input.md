# Example Input: Create Milestone

## Basic Usage

```
create-milestone m5
```

## With Roadmap Context

```
create-milestone m5 --from-roadmap
```

Loads `docs/01-roadmap/roadmap.md` and extracts M5 context:

```markdown
## M5: Detection Ingest Pipeline

Ingest detection data from field sensors and third-party feeds.

### Scope
- Real-time event ingestion API
- Schema validation
- TimescaleDB storage
- Basic monitoring

### Dependencies
- M4 (Risk Assessment) for risk scoring integration
```

## Sub-Milestone

```
create-milestone m5.1
```

Creates `docs/03-build-notes/milestones/m5.1/` with focused scope.

## Quick Mode

```
create-milestone m5 --quick
```

Minimal interview:
1. Confirm scope from roadmap
2. Confirm proposed issue breakdown
3. Confirm phase structure
4. Generate all artifacts

## Interactive Mode (Default)

```
create-milestone m5 --interactive
```

Full interview covering:
- Epic goals and success criteria
- Technical architecture
- Each issue in detail
- Phase organization

## Refine Existing

```
create-milestone m5
```

If `docs/03-build-notes/milestones/m5/` exists:

```
⚠️ Milestone folder exists with 3 files

Options:
  refine    — Load existing, interview for gaps
  overwrite — Start fresh, replace all
  abort     — Cancel

refine | overwrite | abort
```

## Combined with Interview

For complex issues during breakdown:

```
create-milestone m5
```

During issue breakdown phase:

```
Issue #03: Add validation service

This issue seems complex. Deep dive?

yes | no
```

If `yes`, invokes:
```
/interview "M5 validation service"
```

Then continues with remaining issues.
