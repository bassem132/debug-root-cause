# Debug log: <bug in one line>

Keep this updated while you debug. It stops you re-testing ideas you already ruled out, and it becomes the final report.

## Symptom
<Exact error / wrong output / what the user sees.>

## Reproduction
```bash
<command or steps that fail every time>
```
Fails: <always / 1 in N / only in CI / only for some users>

## Facts (observed, not assumed)
- <e.g. "amount is 15000 at the API boundary (logged)">

## Hypotheses
| # | Hypothesis | Test | Result |
| - | ---------- | ---- | ------ |
| 1 | <...> | <cheapest check that would rule it out> | ✅ confirmed / ❌ ruled out / ⏳ |

## Cause
<"It fails because X." The bug should appear and disappear on purpose when you toggle X.>

## Fix
<Smallest change at the cause, and the file.>

## Evidence
- Failing test before fix: <name>
- After fix: <test output, full suite result>
