---
name: debug-root-cause
description: Find the root cause of a bug before changing code, using reproduce → hypothesize → test → fix. Use when something is broken, throws, fails a test, behaves differently than expected, or is slow — and especially after one fix attempt has already failed.
author: Bassem Mo'men
license: MIT
---

# Debug root cause

Guess-and-patch debugging piles fixes on top of a bug you never understood. Each failed guess adds noise. This skill forces understanding first, so the first real fix is usually the last.

## The rule

**No fix until you can explain the cause.** If you can't say "it fails because X, and changing Y fixes X", you're still guessing.

## Procedure

1. **Reproduce it.** Get a command, test or click path that fails every time. Write it down. If you can't reproduce, gather more data (logs, inputs, environment) before anything else.
2. **Read the actual error.** The full message and stack trace, not a summary. Note the first frame in *this* project's code.
3. **Shrink the case.** Remove inputs, steps and code until the failure is as small as possible. Smaller cases make causes obvious.
4. **Check what changed.** `git log`, `git diff`, dependency bumps, env/config changes. A bug that "just started" usually has a recent cause.
5. **List 2–3 hypotheses** and, for each, a quick test that would rule it out. Test the cheapest one first. Add logging or assertions to see real values instead of assuming them.
6. **Confirm the cause.** You should be able to make the bug appear and disappear on purpose.
7. **Write a failing test** that captures the bug (when the project has tests).
8. **Make the smallest fix** at the cause, not at the symptom. Remove your temporary logging.
9. **Verify:** the reproduction now passes, the new test passes, and the existing tests still pass.

## Stop rules

- **Two fixes failed?** Stop patching. Go back to step 1 — your model of the bug is wrong.
- **Fix needs a `try/catch`, `sleep`, retry or `if (x == null) return`** to "work"? You're probably hiding the symptom. Find out why the bad state happens.
- **Can't find it after real effort?** Report what you ruled out, what you observed and your best hypothesis. That's more useful than a speculative fix.

## Report format

```markdown
Cause: `formatPrice` received the amount in piasters but treated it as pounds, so totals were 100× too high. Introduced in a3f9c1 when the API switched units.

Fix: divide by 100 in `src/money/format.ts` at the API boundary.

Evidence: new test `formatPrice converts piasters` failed before, passes now; full suite 212/212.
```
