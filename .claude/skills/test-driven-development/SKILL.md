---
name: test-driven-development
description: RED-GREEN-REFACTOR cycle enforcement for disciplined implementation
version: 1.0.0
author: {{OWNER_NAME}}
tags: [testing, tdd, methodology, quality]
---

# Test-Driven Development Skill

## Purpose

Enforce the RED-GREEN-REFACTOR cycle for all implementation work. This skill ensures tests are written before implementation code, catching design issues early and guaranteeing test coverage.

## When to Use

- Implementing any new functionality
- Fixing bugs (write test that exposes bug first)
- Refactoring (ensure tests exist first)
- Adding features to existing code

## The Cycle

### 1. RED — Write Failing Test

Write a test for the specific behavior you're about to implement.

```python
def test_user_can_be_created_with_email():
    user = User(email="test@example.com")
    assert user.email == "test@example.com"
```

**Run the test:**
```bash
pytest tests/test_user.py::test_user_can_be_created_with_email -v
```

**Expected result:** `FAILED` (RED)

**If test passes immediately:**
- Test is wrong (doesn't test new behavior)
- Behavior already exists (check spec)
- **Action:** Rewrite test or reconsider what you're building

### 2. GREEN — Minimal Implementation

Write the **minimum code** to make the test pass.

```python
class User:
    def __init__(self, email: str):
        self.email = email
```

**Run the test:**
```bash
pytest tests/test_user.py::test_user_can_be_created_with_email -v
```

**Expected result:** `PASSED` (GREEN)

**Rules:**
- No extra features
- No premature optimization
- No "while I'm here" additions
- Just enough to pass the test

### 3. REFACTOR — Clean Up

Improve code quality while keeping tests green.

**Refactoring activities:**
- Extract methods/functions
- Rename for clarity
- Remove duplication
- Improve structure

**After each change:**
```bash
pytest tests/
# All tests MUST pass
```

**If tests fail:** Revert the refactoring change.

### 4. COMMIT

```bash
git add -A
git commit -m "feat: <what the test proves works>"
```

**Then repeat** for the next behavior.

---

## Violations

### Violation 1: Code Before Test

**Symptom:** Implementation file modified before test file.

**Detection:**
```
Modified: src/models/user.py
Missing:  tests/models/test_user.py (no changes)
```

**Action:** Delete implementation code. Start at RED.

### Violation 2: Test Passes Immediately

**Symptom:** New test passes without writing any implementation.

**Detection:**
```
New test: test_user_has_email
Result:   PASSED (but no new implementation)
```

**Action:** Test is meaningless. Either:
- Behavior already exists (don't need to implement)
- Test doesn't test what you think (rewrite)

### Violation 3: Multiple Behaviors

**Symptom:** Implementing several things before writing tests for all.

**Detection:**
```
Modified: src/models/user.py (+50 lines)
Tests:    1 new test (doesn't cover all changes)
```

**Action:** Revert to last commit. Implement one behavior at a time.

### Violation 4: Refactor Breaks Tests

**Symptom:** Tests fail after refactoring.

**Detection:**
```
Before refactor: 47 passed
After refactor:  45 passed, 2 failed
```

**Action:** Revert refactoring change immediately. Refactoring must not change behavior.

---

## Task Size

Each TDD cycle should be **2-5 minutes**:

| Phase | Time |
|-------|------|
| RED (write test) | 30-60 sec |
| GREEN (implement) | 1-2 min |
| REFACTOR | 0-2 min |
| COMMIT | 10 sec |

**If a cycle takes longer:**
- Task is too big → break it down
- Requirements unclear → clarify first
- Fighting the design → step back, rethink

---

## Examples

### Example 1: New Function

**Task:** Add password hashing function

**RED:**
```python
# tests/test_crypto.py
def test_hash_password_returns_different_value():
    result = hash_password("secret")
    assert result != "secret"
```

```bash
pytest tests/test_crypto.py -v
# FAILED - hash_password doesn't exist
```

**GREEN:**
```python
# src/crypto.py
import bcrypt

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
```

```bash
pytest tests/test_crypto.py -v
# PASSED
```

**REFACTOR:** None needed.

**COMMIT:** `feat: add password hashing`

---

### Example 2: Bug Fix

**Bug:** User email not validated

**RED:** Write test that exposes the bug
```python
def test_user_rejects_invalid_email():
    with pytest.raises(ValidationError):
        User(email="not-an-email")
```

```bash
pytest tests/test_user.py::test_user_rejects_invalid_email -v
# FAILED - no validation exists (bug confirmed)
```

**GREEN:** Fix the bug
```python
class User:
    def __init__(self, email: str):
        if "@" not in email:
            raise ValidationError("Invalid email")
        self.email = email
```

```bash
pytest tests/test_user.py -v
# PASSED (bug fixed, test proves it)
```

**COMMIT:** `fix: validate user email format`

---

### Example 3: Refactoring

**Task:** Extract validation logic

**Before refactoring:** Ensure tests exist
```bash
pytest tests/test_user.py -v
# 5 passed - good baseline
```

**Refactor:**
```python
# Extract to separate function
def validate_email(email: str) -> None:
    if "@" not in email:
        raise ValidationError("Invalid email")

class User:
    def __init__(self, email: str):
        validate_email(email)
        self.email = email
```

**After each change:**
```bash
pytest tests/test_user.py -v
# 5 passed - refactoring didn't break anything
```

**COMMIT:** `refactor: extract email validation`

---

## Anti-Patterns

### ❌ Test After

Writing implementation first, then tests to cover it.

**Problem:** Tests follow implementation, don't drive design. Easy to miss edge cases.

### ❌ Test Everything at Once

Writing all tests before any implementation.

**Problem:** Overwhelming. Can't iterate on design. Tests may be wrong.

### ❌ Too Much Green

Implementing more than needed to pass the current test.

**Problem:** YAGNI violation. Untested code. Wasted effort.

### ❌ Skipping Refactor

Never cleaning up, just RED-GREEN-RED-GREEN.

**Problem:** Technical debt accumulates. Code becomes unmaintainable.

### ❌ Refactoring Without Tests

Refactoring code that doesn't have tests.

**Problem:** No safety net. Bugs introduced silently.

---

## Integration with run-milestone

When `run-milestone` executes tasks:

1. **Reads task spec** with RED/GREEN code examples
2. **Writes test** (from RED section)
3. **Verifies FAILED**
4. **Implements** (from GREEN section)
5. **Verifies PASSED**
6. **Refactors** if needed
7. **Commits**

**Violation detection:**
- If implementation file changes before test → TDD violation stop
- If test passes immediately → warning, may skip

---

## See Also

- [run-milestone](../run-milestone/SKILL.md) — Uses TDD for all tasks
- [systematic-debugging](../systematic-debugging/SKILL.md) — TDD for bug fixes
