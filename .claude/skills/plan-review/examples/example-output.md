# Example Output: Plan Review for M4.1

Below is a representative review report that the skill would produce for M4.1.

---

# Plan Review: M4.1 — Location Risk & Pre-Fire Intelligence

**Reviewed:** 2026-01-26
**Plan:** `docs/03-build-notes/milestones/m4.1/IMPLEMENTATION_PLAN.md`
**Issues reviewed:** 17
**Files scanned:** 21 (plan + epic + spec + milestone summary + 17 issue files)

## Verdict

**REVIEW WARNINGS** — Review warnings — proceed with caution

- **Critical:** 0
- **Warning:** 5
- **Info:** 4

## Critical Findings

(none)

## Warnings

### [W1] Epic issue not assigned
- **Agent:** Structure & Completeness
- **File:** `docs/03-build-notes/milestones/m4.1/IMPLEMENTATION_PLAN.md`
- **Detail:** Overview section shows `Epic Issue: TBD`. The epic GitHub issue has not been created, which means milestone completion cannot auto-close it.
- **Fix:** Create the epic issue on GitHub and update the `Epic Issue:` field in the plan.

### [W2] Issue #01 creates DB migration — expect hard stop
- **Agent:** Risk & Feasibility
- **File:** `docs/03-build-notes/milestones/m4.1/01-risk-database-models.md`
- **Detail:** Issue #01 (Risk database models and migration) introduces new database tables (`fwi_observations`, `risk_assessments`, `risk_assessment_history`) and an Alembic migration. This will trigger a hard stop during `run-milestone` execution, pausing the workflow for manual review.
- **Fix:** No action needed — this is expected behavior. Plan for manual review when the hard stop fires.

### [W3] Issue #03 introduces external API dependency without fallback
- **Agent:** Risk & Feasibility
- **File:** `docs/03-build-notes/milestones/m4.1/03-cams-fwi-adapter.md`
- **Detail:** The CAMS FWI adapter depends on the external Copernicus Atmosphere Monitoring Service API (`ads.atmosphere.copernicus.eu`). While the specification documents the `FWIDataUnavailableError` handling for missing grid data, there is no explicit fallback plan if the CAMS API is completely unreachable during development/testing.
- **Fix:** Ensure the adapter's test suite uses mocked HTTP responses. Consider documenting a stub/mock strategy in the issue spec for local development without CAMS access.

### [W4] Issue #06 has broad scope (6 acceptance criteria)
- **Agent:** Risk & Feasibility
- **File:** `docs/03-build-notes/milestones/m4.1/06-risk-computation-service.md`
- **Detail:** Issue #06 (Risk computation service) combines risk computation logic, FWI classification, trust envelope construction, cache integration, explanation generation integration, and event emission. At 6 acceptance criteria spanning multiple concerns, this issue may produce a large diff (soft stop trigger: >8 files or >400 lines).
- **Fix:** Consider whether the event emission or trust envelope construction could be split into a separate issue. If scope is intentional, note that a soft stop for diff size is possible.

### [W5] No issue explicitly adds configuration values to config.py
- **Agent:** Epic Coverage & Alignment
- **File:** `docs/03-build-notes/milestones/m4.1/00-SPECIFICATION.md` (Section 6)
- **Detail:** The specification defines 7 new configuration values (`cams_api_url`, `cams_api_key`, `cams_fetch_timeout_s`, `fwi_cache_ttl_s`, `risk_refresh_enabled`, `risk_refresh_cron`, `risk_stale_after_s`, `risk_history_retention_days`) but no single issue is dedicated to adding them. They are presumably added incrementally by the issues that need them.
- **Fix:** Verify that each configuration value is covered by the issue that first uses it. Alternatively, create a dedicated config issue if the incremental approach risks gaps.

## Info

### [I1] Issues #02 and #03 could be parallelized
- **Agent:** Dependency & Sequencing
- **Detail:** Issue #02 (Risk schemas) depends on #243 (models). Issue #03 (CAMS adapter) has no dependencies. These two issues have no dependency relationship and could execute in parallel if the workflow supported it. Under sequential `run-milestone` execution, #02 runs first (higher table position), which is fine.

### [I2] 3 hard-stop issues anticipated in first two phases
- **Agent:** Risk & Feasibility
- **Detail:** Phase 1 contains Issue #01 (DB migration — hard stop) and Issue #03 (new external dependency — potential hard stop). Phase 2 may introduce additional dependencies. Plan for 2-3 workflow pauses during early phases.

### [I3] Specification is thorough with concrete thresholds
- **Agent:** Specification Quality
- **Detail:** The 00-SPECIFICATION.md provides numeric thresholds for all key decisions: FWI danger class boundaries (5.2, 11.2, 21.3, 38.0, 50.0), trend threshold (±2.0 FWI units), centroid change threshold (>0.1°), cache TTL (3600s), stale threshold (10800s). All values include units, rationale, and code examples. Open questions are clearly deferred to M4B.

### [I4] All 17 issue specs have complete frontmatter and acceptance criteria
- **Agent:** Structure & Completeness
- **Detail:** Every issue file has YAML frontmatter with `title`, `labels`, and `github_issue` fields assigned. All 17 issue specs have `## Acceptance Criteria` sections with at least one checkbox item.

## Agent Reports

### 1. Structure & Completeness
All 17 issue files exist on disk and are referenced in the plan. YAML frontmatter is complete for all issues. The IMPLEMENTATION_PLAN.md contains all required template sections. One warning: the epic issue number is TBD.

- ✅ All issue files exist on disk
- ✅ All issue specs have acceptance criteria
- ✅ All issue specs have YAML frontmatter with `title`
- ✅ All issue specs have `github_issue` assigned
- ✅ All issue specs have `labels` array
- ✅ `00-epic.md` exists
- ✅ `00-SPECIFICATION.md` exists
- ✅ Plan has all template sections
- ✅ Phase tables have required columns
- ✅ No orphan files, no phantom references
- ⚠️ Epic issue number is TBD

### 2. Specification Quality
The specification is well-structured with 8 sections covering all major technical decisions. All numeric thresholds are concrete with units and rationale. Code examples are provided for FWI classification, trend computation, and trust envelope construction. Error responses are documented for API endpoints. Open questions are clearly marked as deferred.

- ✅ All thresholds are concrete and numeric
- ✅ Edge cases documented (missing grid data, large AOIs, geometry changes)
- ✅ Error handling specified for external dependencies
- ✅ Code examples for complex logic
- ✅ Units specified for all values
- ✅ Open questions clearly deferred
- ✅ API contracts include error responses
- ✅ Configuration values have defaults and descriptions

### 3. Dependency & Sequencing
The dependency graph is a valid DAG with no circular dependencies. All dependencies reference valid issues. Phase ordering respects dependencies. P0 issues precede P1 issues. Branch naming follows convention.

- ✅ Valid DAG (no cycles)
- ✅ No cross-phase dependency violations
- ✅ All dependency references valid
- ✅ P0 before P1 ordering correct
- ✅ Phase groupings logical
- ✅ Branch naming follows convention
- ℹ️ #02 and #03 could be parallelized (no mutual dependency)

### 4. Epic Coverage & Alignment
Epic acceptance criteria are well-covered by issue specs. Specification decisions map to implementing issues. API endpoints have corresponding issues. Data models have migration issues. One gap: configuration values are added incrementally rather than in a dedicated issue.

- ✅ Epic acceptance criteria covered
- ✅ Spec decisions map to issues
- ✅ API endpoints have corresponding issues
- ✅ Data models have migration issues
- ✅ Test expectations have test issues (#13, #14)
- ⚠️ Config values added incrementally (no dedicated issue)
- ⚠️ Epic issue number TBD (cannot verify GitHub issue exists)

### 5. Risk & Feasibility
3 hard-stop triggers identified across the first two phases. One external API dependency (CAMS) with partial fallback documentation. One broad-scope issue (#06) that may trigger diff-size soft stop. No auth/billing code changes. No frontend issues depend on unimplemented APIs.

- ⚠️ Issue #01: DB migration (hard stop expected)
- ⚠️ Issue #03: External API dependency, limited fallback docs
- ⚠️ Issue #06: Broad scope, 6 acceptance criteria
- ✅ No auth/permissions/billing code changes
- ✅ Frontend issue (#15) depends on Phase 3 endpoints (correct ordering)
- ✅ Stub/scaffolding issues (#16, #17) clearly scoped
- ✅ Test issues (#13, #14) have specific scope
