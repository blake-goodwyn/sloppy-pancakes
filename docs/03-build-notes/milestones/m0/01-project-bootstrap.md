---
title: "Set up project structure and first endpoint"
labels: ["type:feature", "prio:P0", "milestone:M0"]
github_issue:
priority: P0
dependencies: []
---

# Set Up Project Structure and First Endpoint

## Done Definition

Project has a working development environment with a health check endpoint that returns 200 OK, verified by at least one passing test.

## Tasks

### Task 1: Create project structure (2 min)

**Files:**
- Create: Project configuration files (pyproject.toml, package.json, etc.)

**RED:**
```
# No test yet — this is scaffolding
# Verify: project directory structure exists
```

**GREEN:**
Create the basic project layout following CLAUDE.md conventions.

**Verify:** Project files exist and are valid

---

### Task 2: Add health check endpoint (3 min)

**Files:**
- Create: Health check route
- Test: Health check test

**RED:**
```python
def test_health_check_returns_200():
    response = client.get("/health")
    assert response.status_code == 200
```

**GREEN:**
```python
@app.get("/health")
async def health_check():
    return {"status": "ok"}
```

**Verify:** `pytest tests/ -v`

---

### Task 3: Add CI configuration (3 min)

**Files:**
- Create: `.github/workflows/ci.yml`

**RED:**
```
# CI should run lint + test on every PR
# Verify: workflow file is valid YAML
```

**GREEN:**
Create GitHub Actions workflow with lint and test jobs.

**Verify:** YAML is valid, workflow structure correct

## Implementation Notes

- Follow the project conventions defined in CLAUDE.md
- Keep the health check endpoint minimal — just prove the server works
- CI should run the same checks developers run locally

## Test Expectations

- Health check endpoint returns 200 with `{"status": "ok"}`
- At least one test file exists and passes
- Lint passes with zero warnings

## Acceptance Criteria

- [ ] Project structure matches CLAUDE.md conventions
- [ ] `GET /health` returns 200 with status "ok"
- [ ] At least one passing test
- [ ] CI workflow file exists and is valid
- [ ] Development server starts without errors
