# Use Jujutsu Safely

An agent skill for working inside a Jujutsu repository without losing anyone's files.

Jujutsu has no staging area, and almost every command snapshots the working copy before it runs. That is safer than Git for most of what an agent does, and it fails differently: a command an agent thinks of as read-only records state, a revision named by position resolves to a different commit after a rebase, and a rewrite of what a second workspace has checked out leaves that workspace stale, where clearing the stale state removes files instead of snapshotting them — with no warning and exit 0, if one config setting is on. An agent that translates Git commands mechanically finds these one at a time, in someone's repository.

This skill is what to read first. `SKILL.md` holds what applies before you know which task you are in; each reference under `references/` covers one class of work, and the table at the end of `SKILL.md` says when to read which.

## What it is verified against

**jj 0.45.1.** Two independent audits reproduced the claims on 0.44.0 in throwaway repositories. A re-verification pass on 0.45.1 re-ran them and found that the central workspace claim had been attributed to the wrong command: `snapshot.auto-update-stale`, not the rewrite itself, decides whether another workspace stops with a stale error or loses its files silently. `pending-verification.md` carries every measurement, what each pass refuted, and what is still open — the locked-key-store signing case, the `git filter-repo` recovery, and Git-hook coverage beyond `pre-push`. It is not part of the skill and nothing links it — it is the worklist for whoever maintains this next.

A skill about a tool's failure modes goes stale when the tool changes. The version above is the claim; check it before you trust a detail on a newer jj.

## Install

```
/plugin marketplace add zaeku/skills
/plugin install version-control@zaeku
```

Without a plugin loader, copy `skills/use-jujutsu-safely/` into wherever your
agent scans for skills. `skills/use-jujutsu-safely/agents/openai.yaml` carries
the same skill for runtimes that want a manifest.

## License

MIT, with the rest of [zaeku/skills](https://github.com/zaeku/skills).
