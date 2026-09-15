# load-agents-dot-md

A `SessionStart` hook that prints the project root `AGENTS.md` into the context.

```
/plugin marketplace add zaeku/skills
/plugin install load-agents-dot-md@zaeku
```

Claude Code injects `CLAUDE.md` on its own. It does not inject `AGENTS.md` at
any depth, and the lazy load of a nested instruction file fires on the Read
tool, which auto mode does not use. So a repository that keeps its agent rules
in `AGENTS.md` hands them to an agent that never asks.

The hook runs on every session start, including the restart after a compaction.
It prints a header naming the file, then the file. It prints a one-line notice
instead when `CLAUDE_PROJECT_DIR` is unset or the root holds no `AGENTS.md`, and
it exits 0 in every case.

This plugin is for Claude Code only. Other harnesses load `AGENTS.md` on their
own, and the `hooks/hooks.json` format here is Claude Code's.

It reads the root file only. A nested `AGENTS.md` stays the agent's job to read
before it edits under that directory.
