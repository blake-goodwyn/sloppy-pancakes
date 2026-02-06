# Example Input: Plan Review for M4.1

## Invocation

```
plan-review m4.1
```

## What Happens

1. **Bootstrap:** Resolves `m4.1` → milestone folder `docs/03-build-notes/milestones/m4.1/`

2. **Load Context:** Reads the following files:
   - `docs/guides/implementation-workflow.md`
   - `docs/guides/dev-cadence.md`
   - `docs/03-build-notes/milestones/IMPLEMENTATION_PLAN_TEMPLATE.md`

3. **Load Milestone Artifacts:**
   - `IMPLEMENTATION_PLAN.md` (source of truth — 17 issues across 6 phases)
   - `00-epic.md` (epic acceptance criteria and NFRs)
   - `00-SPECIFICATION.md` (technical decisions: FWI thresholds, trend algorithm, API contracts)
   - `_milestone.md` (brief summary)
   - 17 issue spec files (`01-risk-database-models.md` through `17-downstream-integration-notes.md`)

4. **Launch 5 Review Agents in Parallel:**
   - Agent 1: Structure & Completeness
   - Agent 2: Specification Quality
   - Agent 3: Dependency & Sequencing
   - Agent 4: Epic Coverage & Alignment
   - Agent 5: Risk & Feasibility

5. **Collect, Score, and Present Report**

## Alternative Invocations

```
# Direct path
plan-review docs/03-build-notes/milestones/m4.1/IMPLEMENTATION_PLAN.md

# Various ID formats (all equivalent)
plan-review M4.1
plan-review 4.1
```
