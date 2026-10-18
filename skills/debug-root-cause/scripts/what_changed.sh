#!/usr/bin/env bash
# What changed recently? A one-screen view for "it worked before" bugs.
#
# Usage:
#   what_changed.sh [since] [path]
#     since  git date or ref: "3 days ago" (default), "2026-10-01", "v1.4.0", "HEAD~20"
#     path   limit to a folder or file (default: whole repo)
#
# Shows: uncommitted changes, recent commits, changed files ranked by churn,
# dependency/lockfile changes, config/env/CI changes, and runtime versions.
# Works with bash 3.2+ (macOS default) and git. Read-only: changes nothing.

set -u
since="${1:-3 days ago}"
scope="${2:-.}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository. Check file modification times instead:" >&2
  echo "  find . -type f -mtime -3 -not -path '*/node_modules/*' -not -path '*/.git/*' | head -50" >&2
  exit 1
fi

cd "$(git rev-parse --show-toplevel)" || exit 1

# A ref (tag, sha, HEAD~n) gives a range; anything else is treated as a date.
if git rev-parse --verify --quiet "${since}^{commit}" >/dev/null; then
  range="${since}..HEAD"
  log_args=("$range")
  label="since $since"
else
  base="$(git rev-list -1 --before="$since" HEAD 2>/dev/null)"
  if [ -n "$base" ]; then range="${base}..HEAD"; else range="$(git rev-list --max-parents=0 HEAD | tail -1)..HEAD"; fi
  log_args=(--since="$since")
  label="since $since"
fi

section() { printf '\n== %s ==\n' "$1"; }

section "Branch"
git status -sb | head -1
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
[ -n "$upstream" ] && echo "Upstream: $upstream ($(git rev-list --left-right --count "$upstream"...HEAD 2>/dev/null | awk '{print $2" ahead, "$1" behind"}'))"

section "Uncommitted changes"
if [ -z "$(git status --porcelain -- "$scope")" ]; then
  echo "(none)"
else
  git status --short -- "$scope" | head -40
  git diff --stat HEAD -- "$scope" | tail -1
fi

section "Commits $label"
commits="$(git log "${log_args[@]}" --no-merges --date=short --format='%h %ad %an: %s' -- "$scope" | head -30)"
if [ -z "$commits" ]; then echo "(none)"; else echo "$commits"; fi

section "Most-changed files $label"
git log "${log_args[@]}" --no-merges --name-only --format= -- "$scope" \
  | grep -v '^$' | sort | uniq -c | sort -rn | head -15
[ -z "$commits" ] && echo "(none)"

deps_regex='(^|/)(package\.json|package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?|requirements[^/]*\.txt|pyproject\.toml|poetry\.lock|uv\.lock|Pipfile(\.lock)?|Gemfile(\.lock)?|go\.(mod|sum)|Cargo\.(toml|lock)|composer\.(json|lock)|pubspec\.(yaml|lock)|Podfile(\.lock)?|build\.gradle(\.kts)?|deno\.lock)$'
config_regex='(^|/)(\.env[^/]*|.*\.config\.(js|cjs|mjs|ts)|tsconfig[^/]*\.json|\.nvmrc|\.node-version|\.python-version|\.tool-versions|Dockerfile[^/]*|docker-compose[^/]*\.ya?ml|\.github/workflows/.*|\.gitlab-ci\.yml|vercel\.json|netlify\.toml|wrangler\.(toml|jsonc?)|nginx[^/]*\.conf|settings\.py|config/.*)$'

changed_files="$( (git diff --name-only "$range" -- "$scope" 2>/dev/null; git diff --name-only HEAD -- "$scope" 2>/dev/null) | sort -u)"

section "Dependency changes $label"
deps="$(printf '%s\n' "$changed_files" | grep -E "$deps_regex")"
if [ -z "$deps" ]; then
  echo "(none)"
else
  echo "$deps"
  for f in $(printf '%s\n' "$deps" | grep -E '(package\.json|pyproject\.toml|requirements[^/]*\.txt|go\.mod|Cargo\.toml|Gemfile|composer\.json|pubspec\.yaml)$'); do
    echo "--- $f (version lines changed)"
    git diff "$range" -- "$f" 2>/dev/null | grep -E '^[+-][^+-]' | grep -E '[0-9]+\.[0-9]+' | head -20
  done
fi

section "Config / env / CI changes $label"
cfg="$(printf '%s\n' "$changed_files" | grep -E "$config_regex")"
if [ -z "$cfg" ]; then echo "(none)"; else echo "$cfg"; fi
echo "(Values in .env files are not shown. Compare them by hand if one is listed.)"

section "Runtime versions here"
for tool in node npm pnpm bun python3 go rustc ruby php; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-8s %s\n' "$tool" "$("$tool" --version 2>&1 | head -1)"
  fi
done
for pin in .nvmrc .node-version .python-version .tool-versions; do
  [ -f "$pin" ] && echo "pinned in $pin: $(tr '\n' ' ' < "$pin")"
done

printf '\nNext: pick the change most likely to cause the bug and test it, e.g. with `git stash`, `git checkout <sha> -- <file>`, or `git bisect`.\n'
