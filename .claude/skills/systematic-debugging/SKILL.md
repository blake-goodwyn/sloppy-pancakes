---
name: systematic-debugging
description: 4-phase root cause debugging process - reproduce, isolate, analyze, fix
version: 1.0.0
author: {{OWNER_NAME}}
tags: [debugging, testing, methodology, quality]
---

# Systematic Debugging Skill

## Purpose

Provide a disciplined approach to debugging that finds root causes instead of guessing at fixes. This skill prevents the common anti-pattern of randomly changing code until something works.

## When to Use

- Test failure persists after fix attempts
- Bug reported but cause unclear
- System behaving unexpectedly
- "It works on my machine" situations
- Intermittent failures

## The 4-Phase Process

```
┌─────────────────┐
│  1. REPRODUCE   │  Confirm bug exists, make it repeatable
└────────┬────────┘
         ↓
┌─────────────────┐
│   2. ISOLATE    │  Find minimal reproduction case
└────────┬────────┘
         ↓
┌─────────────────┐
│  3. ROOT CAUSE  │  Trace to exact source
└────────┬────────┘
         ↓
┌─────────────────┐
│ 4. FIX & VERIFY │  Fix cause, prove it's fixed
└─────────────────┘
```

---

## Phase 1: REPRODUCE

**Goal:** Confirm the bug exists and can be triggered reliably.

### Steps

1. **Run the failing test/scenario:**
```bash
pytest tests/test_auth.py::test_login_flow -v
```

2. **Document exact failure:**
```
FAILED test_login_flow
  > assert response.status_code == 200
  E AssertionError: assert 401 == 200
  
  Input: {"email": "user@test.com", "password": "secret"}
  Response: {"error": "Invalid credentials"}
```

3. **Verify reproducibility:**
```bash
# Run multiple times
pytest tests/test_auth.py::test_login_flow -v --count=3
# Should fail consistently
```

### Exit Criterion

✅ Can reproduce bug on demand with documented steps.

### If Can't Reproduce

- Check environment differences
- Check test data/fixtures
- Check timing/race conditions
- Add logging to capture state

---

## Phase 2: ISOLATE

**Goal:** Find the minimal reproduction case.

### Steps

1. **Simplify the test:**
```python
# Start with failing test
def test_login_flow():
    # 20 lines of setup
    # 10 lines of action
    # 5 assertions
    
# Simplify to minimal
def test_login_minimal():
    response = client.post("/login", json={"email": "x", "password": "y"})
    assert response.status_code == 200  # Still fails?
```

2. **Remove unrelated setup:**
```python
# Remove each fixture/setup one at a time
# Does it still fail? If yes, that setup wasn't relevant
```

3. **Find smallest input that triggers bug:**
```python
# Try smaller/simpler inputs
# What's the minimum that fails?
```

### Exit Criterion

✅ Minimal test case that still fails (ideally <10 lines).

### Isolation Questions

- Does it fail with simpler input?
- Does it fail without database?
- Does it fail without network?
- Does it fail with mocked dependencies?

---

## Phase 3: ROOT CAUSE

**Goal:** Trace to the exact line(s) causing the bug.

### Techniques

#### 1. Binary Search (Bisect)

For "it used to work" bugs:
```bash
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# Git will find the commit that introduced the bug
```

#### 2. Add Strategic Logging

```python
def authenticate(email, password):
    logger.debug(f"authenticate called: {email=}")
    user = get_user(email)
    logger.debug(f"user found: {user}")
    if not user:
        logger.debug("no user, returning False")
        return False
    valid = check_password(password, user.password_hash)
    logger.debug(f"password valid: {valid}")
    return valid
```

#### 3. Debugger

```python
def authenticate(email, password):
    import pdb; pdb.set_trace()  # Pause here
    user = get_user(email)
    # Step through, inspect values
```

#### 4. Print State

```python
def authenticate(email, password):
    user = get_user(email)
    print(f"DEBUG: {user=}, {user.password_hash=}")
    print(f"DEBUG: check result = {check_password(password, user.password_hash)}")
```

### Exit Criterion

✅ Know exactly which line(s) cause the bug and WHY.

### Root Cause Statement

Write a clear statement:
> "The bug occurs because `check_password()` on line 45 of auth.py 
> compares the raw password to the hash instead of hashing first."

---

## Phase 4: FIX & VERIFY

**Goal:** Fix the root cause and prove it's fixed.

### Steps

1. **Write test that exposes bug** (if not already):
```python
def test_password_check_hashes_input():
    hashed = hash_password("secret")
    assert check_password("secret", hashed) == True
    assert check_password("wrong", hashed) == False
```

2. **Verify test fails** (confirms bug):
```bash
pytest tests/test_auth.py::test_password_check_hashes_input -v
# FAILED - good, bug confirmed
```

3. **Fix the root cause:**
```python
def check_password(password: str, hash: str) -> bool:
    # WRONG: return password == hash
    # RIGHT: 
    return bcrypt.checkpw(password.encode(), hash.encode())
```

4. **Verify test passes:**
```bash
pytest tests/test_auth.py::test_password_check_hashes_input -v
# PASSED - fix works
```

5. **Run full test suite:**
```bash
pytest tests/
# All tests pass - no regressions
```

6. **Remove debug logging:**
```bash
git diff  # Check for leftover print/debug statements
```

7. **Commit:**
```bash
git commit -m "fix: hash password before comparison in check_password"
```

### Exit Criterion

✅ Test passes, no regressions, debug code removed.

---

## Anti-Patterns

### ❌ Guess and Check

Randomly changing code hoping something works.

**Problem:** Might "fix" symptoms without fixing cause. Often introduces new bugs.

### ❌ Fix Symptoms

Adding defensive code without understanding why it's needed.

```python
# BAD: Hiding the bug
if user is None:
    return False  # Why would user be None here?

# GOOD: Understanding the bug
# User is None because get_user doesn't handle case-insensitive email
```

### ❌ Declare Victory Early

Saying "fixed" after code change without running tests.

**Problem:** Bug might not be fixed. Might have introduced regressions.

### ❌ Debug in Production

Adding logging/debugging to production to "see what's happening."

**Problem:** Reproduce locally first. Production debugging is last resort.

### ❌ Blame External

Assuming it's a library bug, framework bug, or "the tests are wrong."

**Problem:** 99% of the time, it's your code. Check yours first.

---

## Checklist

Before declaring a bug fixed:

- [ ] Can reproduce the bug reliably (Phase 1)
- [ ] Have minimal reproduction case (Phase 2)
- [ ] Know exact root cause and can explain it (Phase 3)
- [ ] Test exists that exposes the bug (Phase 4)
- [ ] Test failed before fix (Phase 4)
- [ ] Test passes after fix (Phase 4)
- [ ] Full test suite passes (Phase 4)
- [ ] Debug code removed (Phase 4)
- [ ] Committed with clear message (Phase 4)

---

## Integration with run-milestone

When test failures persist after fix attempts:

```
🛑 Tests failing (attempt 2/2)

Recommended: Use systematic-debugging skill

invoke | skip | abort
```

If user chooses `invoke`:
1. Skill guides through 4-phase process
2. Root cause identified
3. TDD fix applied (test first)
4. Resume milestone

---

## Examples

### Example 1: Flaky Test

**Symptom:** Test passes sometimes, fails sometimes.

**Phase 1 - Reproduce:**
```bash
pytest tests/test_async.py -v --count=10
# Fails 3/10 times
```

**Phase 2 - Isolate:**
- Fails more often under load
- Fails more with slower network
- Involves async operations

**Phase 3 - Root Cause:**
```python
# Bug: Race condition
async def get_data():
    result = cache.get(key)  # Might not be set yet
    return result

# Root cause: cache.set() in another coroutine hasn't completed
```

**Phase 4 - Fix:**
```python
async def get_data():
    await cache.wait_for_key(key)  # Wait for set to complete
    result = cache.get(key)
    return result
```

### Example 2: Works Locally, Fails in CI

**Symptom:** Tests pass locally, fail in CI.

**Phase 1 - Reproduce:**
```bash
# Run in CI-like environment
docker run --rm -v $(pwd):/app python:3.11 pytest tests/
# Reproduces failure
```

**Phase 2 - Isolate:**
- Only date-related tests fail
- CI is in UTC, local is PST

**Phase 3 - Root Cause:**
```python
# Bug: Assumes local timezone
def is_today(dt):
    return dt.date() == datetime.now().date()  # Timezone-naive
```

**Phase 4 - Fix:**
```python
def is_today(dt):
    return dt.date() == datetime.now(timezone.utc).date()  # Explicit UTC
```

---

## See Also

- [test-driven-development](../test-driven-development/SKILL.md) — TDD for fixes
- [run-milestone](../run-milestone/SKILL.md) — Invokes this skill on persistent failures
