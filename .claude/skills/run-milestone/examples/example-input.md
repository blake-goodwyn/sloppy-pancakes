# Example Input: Run Milestone

## Basic Usage

```
run-milestone m3
```

or

```
run-milestone M4.1
```

or

```
run-milestone 3
```

## Input Normalization

| Input | Normalized |
|-------|------------|
| `m3`, `M3`, `3` | `m3` |
| `m4.1`, `M4.1`, `4.1` | `m4.1` |

## With Flags

### Skip Code Review (Faster Iteration)

```
run-milestone m3 --skip-code-review
```

### Skip Quality Gate (Resume Without Re-check)

```
run-milestone m3 --skip-plan-review
```

### Preview Mode (No Changes)

```
run-milestone m3 --dry-run
```

**Output:**
```
[DRY-RUN] Milestone: m3
[DRY-RUN] Quality gate: Would invoke plan-review (first run)
[DRY-RUN] Base branch: milestone/m3-user-auth (exists)
[DRY-RUN] Next issue: #01 (GitHub #101) — Add user login endpoint
[DRY-RUN] Stop conditions: None predicted
[DRY-RUN] Would create branch: feat/m3-101-user-login
[DRY-RUN] Would create PR targeting: milestone/m3-user-auth

No changes made. Remove --dry-run to execute.
```

### Verbose Mode (Debug Decisions)

```
run-milestone m3 --verbose
```

**Output:**
```
[VERBOSE] Loading: <milestone-folder>/m3/IMPLEMENTATION_PLAN.md
[VERBOSE] Scope tags: [auth, api]
[VERBOSE] Base branch: milestone/m3-user-auth
[VERBOSE] Checking stop conditions for issue #01...
[VERBOSE] → Breaking schema: NO (no migrations)
[VERBOSE] → Sensitive code: NO (no auth files touched yet)
[VERBOSE] → Dependencies: NO (no lockfile changes)
[VERBOSE] Result: No stop conditions
```

### Collect Metrics

```
run-milestone m3 --metrics
```

Outputs to: `<milestone-folder>/m3/metrics.json`

### Combined Flags

```
run-milestone m3 --verbose --metrics
```

## Expected Behavior

### Fresh Start

1. Normalize input to `m3`
2. Detect fresh start (no PRs, no current issue)
3. Run quality gate (`plan-review`)
4. If blocked → prompt: `approve | abort`
5. If passed → load plan, start execution

### Resume In-Progress

1. Normalize input to `m3`
2. Detect in-progress (PRs exist or current issue set)
3. Skip quality gate
4. Reconcile: check existing PRs
5. Find next unblocked issue
6. Continue execution

### After Abort

1. User previously replied `abort`
2. Re-run: `run-milestone m3`
3. Reconcile detects state
4. Resume from where stopped