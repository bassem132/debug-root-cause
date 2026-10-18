# Debug root cause

Makes your AI agent find and prove the root cause of a bug before changing code, instead of guess-and-patch debugging.

A portable agent skill (`SKILL.md`) that works in **Claude Code**, **Codex** and **Cursor**.

## Install

### Claude Code (plugin)

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

### Cursor

Copy the folder into your project's `.cursor/skills/`, or paste the body of `SKILL.md` into a rule in `.cursor/rules/debug-root-cause.mdc`.

## What's inside

```
skills/debug-root-cause/SKILL.md   the skill
```

See [skills/debug-root-cause/SKILL.md](skills/debug-root-cause/SKILL.md) for when it triggers and what it does.

## Author

Bassem Mo’men — [@bassem132](https://github.com/bassem132)

## License

MIT — see [LICENSE](LICENSE).
