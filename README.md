# Debug root cause

Guess-and-patch debugging piles fixes on a bug nobody understood. This skill makes the agent reproduce the bug, check what changed, test hypotheses cheapest-first, prove the cause, and fix it with a failing test first.

A portable agent skill (`SKILL.md` plus scripts and references) for **Claude Code**, **Codex** and **Cursor**. The scripts have no dependencies (Python 3.8+ / bash 3.2+).

## What's inside

| File | What it does |
| --- | --- |
| `skills/debug-root-cause/SKILL.md` | When it triggers, the procedure, stop rules and the report format |
| `skills/debug-root-cause/scripts/what_changed.sh` | Read-only report: uncommitted changes, recent commits, churn, dependency bumps, config/env/CI changes, runtime versions |
| `skills/debug-root-cause/reference/bug-patterns.md` | Where to look first: CI-only, flaky, wrong totals, dates/Cairo DST, Arabic/encoding, caching, performance, nulls, auth |
| `skills/debug-root-cause/templates/debug-log.md` | Running debug log that becomes the final report |
| `adapters/cursor/debug-root-cause.mdc` | Ready-made Cursor rule |
| `adapters/codex/AGENTS.snippet.md` | Short version to paste into any `AGENTS.md` |
| `evals/evals.json` | Test prompts: should it trigger, and what should the agent do |
| `tests/` | Unit tests for the scripts |

## Install

### Claude Code (plugin, recommended)

```
/plugin marketplace add bassem132/debug-root-cause
/plugin install debug-root-cause@debug-root-cause
```

### Claude Code (manual)

```bash
git clone https://github.com/bassem132/debug-root-cause.git
cp -r debug-root-cause/skills/debug-root-cause ~/.claude/skills/
```

### Codex

```bash
cp -r debug-root-cause/skills/debug-root-cause ~/.codex/skills/
```

Or paste `adapters/codex/AGENTS.snippet.md` into your `AGENTS.md`.

### Cursor

```bash
mkdir -p .cursor/rules .cursor/skills
cp debug-root-cause/adapters/cursor/debug-root-cause.mdc .cursor/rules/
cp -r debug-root-cause/skills/debug-root-cause .cursor/skills/      # so the agent can run the scripts
```

## Try the script

```bash
bash skills/debug-root-cause/scripts/what_changed.sh "3 days ago"
```

## Develop

```bash
python3 -m unittest discover -s tests -v
claude plugin validate .
```

To check that the skill changes behaviour, run the prompts in `evals/evals.json` in a fresh session with the skill installed. Every `expect` item should hold, and prompts with `should_trigger: false` must not load the skill.

## Author

Bassem Mo’men · [@bassem132](https://github.com/bassem132)

## License

MIT, see [LICENSE](LICENSE).
