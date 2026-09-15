#!/usr/bin/env bash
set -u

d=${CLAUDE_PROJECT_DIR:-}
if [ -z "$d" ]; then
  echo '=== load-agents-dot-md: CLAUDE_PROJECT_DIR unset, AGENTS.md not injected ==='
  exit 0
fi
if [ ! -f "$d/AGENTS.md" ]; then
  echo "=== load-agents-dot-md: no AGENTS.md at $d ==="
  exit 0
fi
printf '=== %s/AGENTS.md (injected in full) ===\n' "$d"
cat "$d/AGENTS.md"
