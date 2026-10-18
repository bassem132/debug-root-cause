<!-- debug-root-cause by Bassem Mo'men (MIT). Paste into your AGENTS.md if you don't install the full skill. -->

## Debugging

- No fix until you can explain the cause: "it fails because X, and changing Y fixes X".
- Order: reproduce → read the full error → check what changed (git log, lockfile, config) → shrink the case → 2–3 hypotheses tested cheapest first → confirm → failing test → smallest fix at the cause → full suite.
- After two failed fixes, stop patching and go back to reproducing.
- Don't hide symptoms with try/catch, sleeps, retries or null guards before you know why the bad state happens.
- If stuck, report what you ruled out and your best hypothesis instead of guessing.
