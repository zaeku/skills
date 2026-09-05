# Verification record

Not part of the skill. `SKILL.md` does not link this file, and no reference does. It is a
worklist for whoever maintains the skill next.

Two independent audits have now measured this skill against **jj 0.44.0**. Their corrections
are applied. This file records only what is still open.

## Verified on jj 0.44.0

Reproduced in throwaway repositories, and reflected in the skill text:

- No staging area; `jj status`, `jj log` and `jj file list` snapshot before they run.
- After an operation-log rewrite (`jj undo`, `jj op restore`, `jj op abandon`) or a rewrite of
  another workspace's `@` (`jj rebase -r`, `jj abandon`), the next `jj` command in that
  workspace removes its unsnapshotted files from disk. Exit 0, no warning, only
  `Added 0 files, modified 0 files, removed <n> files`.
- The removed content survives: readable by commit ID, sometimes only via `jj --at-op`.
- `jj describe -r <that workspace's @>` leaves the other workspace's files alone.
- `jj describe` takes `[REVSETS]...`; one `-m` over a multi-commit revset rewrites every
  description and prints `Updated <n> commits.`
- `jj commit` takes `[FILESETS]...` and silently commits only the named paths.
- `jj abandon -r @` removes the working copy's files from disk.
- Large-file refusal is per file: exit 0, file stays untracked, siblings recorded.
- Rewriting an immutable commit fails with exit 1 and `Error: Commit <id> is immutable`,
  including `jj edit`. The new-commit-on-top behaviour fires only when `@` *becomes*
  immutable during another command.
- `jj bookmark set` forward-only, `--allow-backwards`, and the exact refusal message.
- `--allow-new` is gone; `jj git push -b <new>` tracks automatically; `-c <rev>` creates
  `push-<full-change-id>`; `--allow-empty-description` and `--allow-conflicts` are
  `jj git push` flags.
- The whole `experimental-advance-branches` section, all four bullets, end to end.
- `jj file untrack` rejects a non-ignored path; the symlink caveat, both directions.
- Conflicts: off-`@` conflicts, `Error: No conflicts found at this revision`, the disk file
  holding one side with no markers, jj printing the `jj new` / resolve / `jj squash`
  procedure, and `:ours` = side #1 = the rebase destination.
- Every template expression in `ids-and-templates.md`, and the ambiguity error.
- `jj workspace list` does not show a Git worktree, in a colocated repository.

## Refuted, and removed from the skill

Do not reintroduce these:

- That `jj op restore` elsewhere makes another workspace *stale* and leaves its files intact.
- That `jj workspace update-stale` is the command that clears the files.
- That the operation log holds no copy of a removed unsnapshotted file.
- That `jj rebase -r` or `jj abandon` of another workspace's `@` leaves its files on disk.
- That a large-file refusal blocks the whole snapshot.

## Still untested

- **The stale working copy.** Neither audit could enter the state
  (`Error: The working copy is stale (not updated since operation <id>)`), across roughly
  fifteen attempts and nine trigger shapes. The error string exists in jj. Untried: sparse
  checkouts, network filesystems, a genuinely concurrent second `jj` process, and a workspace
  whose `.jj/working_copy` was written by a different jj version. The `cp`-first procedure in
  `concurrent-agents.md` is kept as defensive and is labelled unreproduced.
- **Whether a stale workspace refuses `jj util snapshot`.** Untestable while the state cannot
  be produced.
- **Why the two audits disagree on the same triggers and version.** Probably setup detail
  neither recorded: which operation was restored to, whether the second workspace had ever run
  a `jj` command, and whether the first workspace advanced the head after the rewrite. That
  last one flipped one audit's own result to `No working copy.` with files intact. The skill
  now states the invariant both audits agree on and carries no mechanism story.
- **Restore to an operation predating a workspace's creation**, then advance the head: the
  workspace printed `No working copy.` and kept its files. Measured once, not characterised.
- **`jj status --ignore-working-copy` first, then a normal command**: removed the previously
  snapshotted file too. Measured once, not characterised.
- **`jj --at-op <old> new`**: files survived and no divergence appeared, contradicting the
  skill's former table row. The row is gone; the behaviour is not documented anywhere.

## Judgment calls, deliberately settled

- The six-row per-command table is replaced by one invariant plus the single row that has held
  in both audits. A table of per-command outcomes has been wrong twice across one minor
  version.
- The snapshot-first precaution is widened to `jj undo`, `jj rebase -r` and `jj abandon`. Cost
  is one `jj util snapshot` per workspace.
- `jj op integrate` exists on 0.44.0 and is deliberately absent from the skill. Its help scopes
  it to `--no-integrate-operation` and internal errors, and no run of either audit suggested it.
- "Silent" is kept as the description of the loss, alongside the exact `removed <n> files`
  string.
- Not covered, judged low frequency for this audience: sparse checkouts, `jj fix`, `jj sign`,
  `jj simplify-parents`, colocated-repo Git index interactions.
