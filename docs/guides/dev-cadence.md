# Development Cadence

This document defines the repeatable engineering cadence for progressing a project from one milestone to the next (M0 → M1 → …), with a workflow that is fast, audit-friendly, and compatible with a "TPM (you) + agent engineer" model.

---

## Goals of the cadence

- **Deterministic progress:** each milestone ends with a shippable slice and a demonstrable outcome.
- **Low integration risk:** merge frequently, keep main always deployable.
- **Decision traceability:** every meaningful decision is captured (lightweight) so you can move quickly without losing context.
- **Operational readiness:** each milestone adds a small amount of observability, reliability, and cost control—not just features.

---

## Roles and responsibilities

**TPM / Product Owner**
- Own milestone scope, acceptance criteria, priorities, and "no surprises" constraints (licensing, cost, data provenance).
- Break down work into Issues (1–8 hours each where possible) and clarify decisions.
- Perform final acceptance: demo + checklist + release notes.

**Engineer (human or agent)**
- Implement Issues, keep PRs small, maintain test coverage, update docs.
- Propose decisions with options + tradeoffs when blocked.

**Optional reviewer (future)**
- Spot-check PRs for security, data correctness, and maintainability.

---

## Repos, branches, and PR strategy

### Branching model (recommended)
- `main`: always deployable.
- `milestone/M{n}-<short-name>`: a **single integration branch per milestone** (e.g., `milestone/M1-feature-name`).
- `feat/<issue-key>-<short-name>`: optional, for larger milestones; otherwise implement directly on the milestone branch.

### Merge strategy
- PRs merge into the **milestone branch** throughout the week.
- One final PR merges the milestone branch → `main` when acceptance criteria are met.
- After merge: tag a release and close the milestone.

### PR size guidance
- Prefer PRs that are reviewable in **<30 minutes**.
- If a PR feels too big: split by vertical slice (API + storage + tests) or by bounded module.

---

## Standard milestone loop (repeat every milestone)

### 0) Milestone kickoff
Create a single "Milestone Epic" issue that includes:
- Outcome statement
- Acceptance criteria (measurable)
- Demo script (how you'll prove it works)
- NFR additions (latency/uptime/cost/lineage as relevant)
- Out-of-scope list (explicit)

Deliverables:
- Milestone Epic issue
- Milestone branch created from `main`

---

### 1) Backlog shaping
Break the Epic into Issues. Each Issue should have:
- Clear "done" definition
- Test expectations (unit/integration/e2e)
- Impacted modules (adapt to your project structure)
- Any needed decisions (link to decision log entry)

Issue sizing rule-of-thumb:
- **Agent-friendly:** 1–8 hours each (smaller is better).
- Include at most **1 unknown** per Issue; push unknowns into a spike.

Deliverables:
- **Implementation Plan:** Create `docs/03-build-notes/milestones/m{n}/IMPLEMENTATION_PLAN.md`
- Issue list with priority order (P0/P1) organized by phases
- Updated decision log entries for open decisions

**The Implementation Plan serves as the source of truth and progress manifest** for the milestone. It tracks issue status, dependencies, open PRs, and current progress. All workflow tools (run-milestone command/skill) use this file to determine next steps and update status.

---

### 2) Risk & spike window (only when needed)
If the milestone includes uncertainty (licensing, performance, data quirks, auth edge cases):
- Run a timeboxed spike that ends in a decision + next steps.

Deliverables:
- Short spike note (what was tested, what was learned)
- Decision recorded (even if "defer")

---

### 3) Implementation cadence
Daily loop per engineer:
1. Pick the highest-priority Issue.
2. Implement with tests.
3. Commit frequently with clear messages.
4. **Push to branch regularly** (after each commit or every few commits) to back up work and keep CI running.
5. Open PR early (draft) and update continuously.
6. Keep a running changelog snippet (bullet list) in the PR description.

**Autopilot Mode (run-milestone):**
- Workflow continues automatically for recoverable issues (soft stops: test failures, large diffs, merge conflicts)
- Only pauses for high-level concerns requiring user attention (hard stops: database changes, sensitive code, dependencies, missing specs)
- Auto-fixes lint errors before skipping issues
- See [Implementation Workflow](implementation-workflow.md) for stop condition details

Daily loop per TPM:
- Triage blockers, answer questions, and resolve decisions quickly.
- Keep scope stable: if new work appears, add it explicitly and trade off something else.
- Review hard stop alerts promptly to unblock workflow.

---

### 4) Integration & verification (end of milestone)
Before merging milestone → main:
- Run full CI
- Run integration tests against local stack (adapt to your infrastructure)
- Execute the demo script end-to-end

Deliverables:
- Demo video or notes (optional but helpful)
- Passing CI, green checks
- Updated docs and runbooks

---

### 5) Release, tag, and close
After merge to `main`:
- Tag: `v0.M{n}` (or `v0.0.<n>`—pick one and stay consistent)
- Publish release notes (short bullets: features, breaking changes, migrations)
- Close Issues and the milestone
- Add 2–5 retro bullets: what to keep, what to change

Deliverables:
- Release tag + notes
- Closed milestone with linked PRs
- Retro bullets appended to the milestone Epic

---

## Definition of Done (DoD) for every milestone

A milestone is "done" only when all of the following are true:

### Functionality
- Acceptance criteria met
- Demo script succeeds reliably (repeat twice)

### Quality
- Tests added/updated (unit + integration as applicable)
- Lint/type checks pass (or explicit reason documented)

### Operability
- Logs are meaningful (request IDs / correlation IDs where relevant)
- Basic metrics exist for the new path (latency, error rate, job duration)
- Alerting/monitors updated if the milestone introduced a new dependency or queue

### Cost & licensing
- Any new dataset/source has a recorded license/redistribution decision
- Any new compute-heavy path has a guardrail (rate limit, async threshold, or budget hook)

### Documentation
- API changes documented
- DB migrations documented (if applicable)
- Any new background job has a short runbook entry (how to run, how to debug)

---

## CI/CD gates

### Required checks (minimum)
- Linter (e.g., `ruff`, `eslint`, `gofmt`)
- Unit tests (e.g., `pytest`, `jest`, `go test`)
- Build verification
- Integration test job (if applicable)
- Migration check (if applicable - ensure migrations apply cleanly)

### Optional but high leverage
- Contract tests for API response shapes (especially for "core" endpoints)
- Load smoke test for critical endpoint class
- Security scanning
- Dependency vulnerability checks

---

## Documentation cadence (kept lightweight)

Update these as part of the milestone PR(s):
- `docs/decision-logs.md` (or ADRs): decisions made this milestone
- `docs/02-architecture/system-overview.md`: only if architecture changes
- `docs/01-specs/api-specs.md`: if endpoints/schemas changed
- `docs/ops/runbooks.md`: if new jobs/services introduced

Rule: **docs move with code**, not after.

---

## Decision logging (fast, not bureaucratic)

When you hit a decision:
- Write a 5–10 line entry:
  - Context
  - Options considered
  - Decision
  - Consequences
  - Follow-ups (if any)

This keeps velocity high while preventing future rework.

---

## Milestone-to-milestone handoff checklist

At the end of each milestone, confirm:
- [ ] Main is green and deployable
- [ ] Milestone tag created + release notes written
- [ ] Open decisions reviewed (carry forward only the important ones)
- [ ] Next milestone Epic drafted (scope + acceptance criteria)
- [ ] A short retro captured and reflected in the next milestone plan

---

## Practical tips for "TPM + agent engineer" execution

- Prefer Issues with **explicit inputs/outputs** (request/response shapes, DB tables, acceptance tests).
- Put "decision required" at the top of an Issue when needed.
- Keep the agent unblocked: if there's uncertainty, create a spike Issue rather than letting it stall implementation.
- Treat every milestone as a **vertical slice**: small, end-to-end, demoable.

---

## Example milestone artifact set (template)

For each milestone `M{n}` create:
- `Epic: M{n} — <Outcome>`
- 5–20 Issues with labels:
  - Module labels (adapt to your project structure)
  - `type:feature`, `type:bug`, `type:spike`, `type:docs`
  - `prio:P0/P1`
- A milestone branch: `milestone/M{n}-<name>`
- A final merge PR: `milestone/M{n} → main`
- A release tag: `v0.M{n}`

---

## Appendix: What changes as milestones progress

Early milestones (M0–M2) emphasize:
- reliability foundations, deterministic outputs, storage correctness, and basic monitoring.

Mid milestones (M3–M5) emphasize:
- async jobs, alerting flows, auth scopes, and cost enforcement behaviors.

Later milestones emphasize:
- dataset expansion, commercial-facing controls, and stronger auditability.

The cadence stays the same; only the **content** of acceptance criteria and NFRs evolves.

---

## Customization Notes

When adapting this cadence to your project:

1. **Update file paths:** Replace paths with your documentation structure (e.g., `docs/03-build-notes/milestones`, etc.)

2. **Adjust tooling:** Replace tool references with your stack:
   - Linters: `ruff`, `eslint`, `gofmt`, etc.
   - Test runners: `pytest`, `jest`, `go test`, etc.
   - Type checkers: `mypy`, `tsc`, etc.

3. **Module structure:** Update module labels and impacted modules to match your project architecture

4. **CI/CD:** Adapt CI/CD gates to your infrastructure and requirements

5. **Branch naming:** Adjust branch naming conventions if your team uses different patterns

6. **Issue tracking:** Adapt issue creation and tracking workflows to your tooling (GitHub, GitLab, Jira, etc.)
