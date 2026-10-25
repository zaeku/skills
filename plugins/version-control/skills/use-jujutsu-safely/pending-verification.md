# Verification record

Not part of the skill. `SKILL.md` does not link this file, and no reference does. It is the
worklist for whoever maintains the skill next.

The skill is stamped at **jj 0.46.0**. Every claim in it was reproduced in a throwaway repository
under jj's default config, except the four items under "Still open" below. The 0.46.0 pass
re-measured only what that release could move; the rest carries its own 0.45.1 or 0.44.0 stamp in
the line that states it. How each claim came to be worded the way it is lives in the commit log;
`git log v0.2.0..v0.3.0` is the audit trail for the 0.45.1 pass.

## Measured for 0.46.0

Four changes in the release notes touch what this skill defends. Each was run in a throwaway
repository, not read from the notes:

- **Cross-workspace `jj undo`.** The refusal is in `--help`; what is not is the cost of the
  override. `jj undo --allow-cross-workspace` of an operation performed in another workspace puts
  that workspace in the stale state, and clearing it removes its unsnapshotted files. Reproduced
  twice. So `jj undo` joins `jj rebase -r` and `jj abandon -r` in the loss class, for that case
  alone: undoing an operation performed in your own workspace left the other workspace untouched.
- **`jj workspace add` in a colocated repository makes the Git worktree itself.** A `.git` in a
  directory no longer tells a workspace from a hand-made worktree; a `.jj` does. The 0.45.1 claim
  about a `jj` command inside a hand-made worktree holds on 0.46.0, and gained one detail: a file
  written there is in neither tree. Beside the repository rather than inside it, the same command
  answers `There is no jj repo in "."`.
- **`git.push` with a list of remotes.** One `jj git push -b <name>` pushed the bookmark to both
  remotes, one output block each. Unset, it pushed to `origin`.
- **`jj workspace remove`.** It snapshotted a file no `jj` command had seen into a commit, then
  deleted the directory. The `--help` claim holds.

Not re-measured, and not changed: `jj split` now opens one editor session for every split commit's
description, which costs nothing this skill protects.

## Still open

- **Signing with a locked key store.** The claim in `recovering.md` — that a signing failure
  fails every command, reads included — was measured once on 0.44.0 against 1Password's
  op-ssh-sign, and re-measured on 0.45.1 only through an emulated always-failing signer
  (`program = /usr/bin/false`). The two disagree about `--ignore-working-copy`: the emulated
  signer let it through, the locked store did not. 0.45.1 also changed where signatures are
  stored for SHA-256 Git repositories.
- **The `git filter-repo` recovery.** One run, on 0.44.0, with `git filter-repo` a40bce5.
  `filter-branch` and BFG are named in `rewriting-history.md` by inference from that same repack,
  not by measurement.
- **Git hooks other than `pre-push`.** `pre-push` is measured twice: `git push` runs it and
  `jj git push` ignores it. No other hook is tested.
- **Whether `protected branch hook declined` is specific to the signature rule.** The cause of the
  0.44.0 rejection is settled: it was an unsigned push. `zaeku/skills` main carries
  `required_signatures` and `enforce_admins`, no rulesets, and no other rule that can decline a
  push over its content — read from the API on 2026-09-08 — and four signed commits went through
  that same rule the same day. What is untested is whether another rule, such as a required check
  or a required review, declines with the same string. This repository cannot answer that, because
  no other rule is enabled on it.

Untried rather than open, and lower value: `jj --at-op <old> new` (files survived, no divergence
appeared, and the behavior is documented nowhere), a genuinely concurrent second `jj` process,
sparse checkouts, and network filesystems.

## Do not reintroduce these

- That an operation-log rewrite removes another workspace's files by itself. `jj op restore` to a
  later operation, and `jj undo` of an operation performed in your own workspace, left them on disk
  under both values of `snapshot.auto-update-stale`. It is rewriting a workspace's own `@` that
  costs it files, by way of the stale state — which `jj undo --allow-cross-workspace` does do, on
  0.46.0.
- That the removal happens without `jj workspace update-stale`. That command is the removal,
  whether a person runs it or `snapshot.auto-update-stale = true` runs it for them.
- That the operation log never holds a copy of a removed unsnapshotted file. Jujutsu snapshots
  before it resets, and after `jj rebase -r` the content was readable by commit ID, sometimes only
  through `jj --at-op`. The converse is not safe either: after a cross-workspace `jj undo` on
  0.46.0, one removed file was in no commit the log held.
- That a large-file refusal blocks the whole snapshot. It is per file.
- That a per-command table of workspace outcomes stands on its own. Two audits built one and both
  got it wrong, because the deciding variable was a config value neither recorded.

## Judgment calls, deliberately settled

- The workspace section names one mechanism first — the stale working copy, cleared by
  `jj workspace update-stale` — and only then lists what each command does. The list is
  defensible now because the mechanism explains every row. It was not before.
- The snapshot-first precaution still covers `jj undo` and `jj op restore`, which measured as
  harmless. Cost is one `jj util snapshot` per workspace, against a class of operation whose
  behavior has been misread twice.
- `jj op integrate` is in the skill now, as the recovery for the sibling-operation error that
  `jj op abandon` leaves in another workspace. Both earlier passes left it out for want of a
  measured trigger.
- The skill states jj's built-in defaults and tells the reader to check the value in force. It
  carries no second set of numbers for what any particular machine configures.
- Not covered, judged low frequency for this audience: sparse checkouts, `jj fix`,
  `jj simplify-parents`, and colocated-repo Git index interactions beyond the `git fsck` note in
  `recovering.md`.

## Where the measurements live

- `git log v0.2.0..v0.3.0` — everything the 0.44.0 to 0.45.1 pass changed, and why.
- Commit `Attribute the workspace file loss to the setting that decides it` — the
  `snapshot.auto-update-stale` finding, the two puzzles it closed, and the corrections that
  followed.
- Commit `Re-run the remaining 0.44.0 claims and stamp the skill at 0.45.1` — the claims
  re-measured unchanged on 0.45.1, listed one by one.
