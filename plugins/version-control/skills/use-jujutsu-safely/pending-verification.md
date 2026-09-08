# Verification record

Not part of the skill. `SKILL.md` does not link this file, and no reference does. It is a
worklist for whoever maintains the skill next.

Two independent audits measured this skill against **jj 0.44.0**. A third pass re-ran their
claims on **jj 0.45.1**, which is what the skill is now stamped against. This file records every
measurement and what is still open.

## Measured on jj 0.45.1, 2026-09-08

This section is the 0.45.1 material. The sections after it are the 0.44.0 record, kept for the
history of what was measured when; where the two disagree, this one is current.

### The setting that explains both open puzzles

`snapshot.auto-update-stale` decides what another workspace does when its working copy goes stale.
jj's default is `false`. This machine's `~/.config/jj/config.toml` sets it to `true`, and both
earlier audits ran here. That accounts for the two things this file recorded as unexplained: why
no trigger ever produced the stale error, and why a per-command table of outcomes kept coming out
differently.

Measured on jj 0.45.1, one workspace rewriting the change another has checked out
(`jj rebase -r <ws2 @>`, `jj abandon -r <ws2 @>`):

- `false`: ws2's next `jj` command fails with `Error: The working copy is stale (not updated since
  operation <id>)`, exit 1, and keeps every file. `jj workspace update-stale` is what removes them,
  and it prints `Added 0 files, modified 0 files, removed <n> files`.
- `true`: ws2's next `jj` command runs update-stale itself, exits 0, prints that same line among
  ordinary output, and the files are gone.

So one mechanism, two faces. The removal is `jj workspace update-stale`, whoever runs it.

### Also measured on 0.45.1

- **A stale workspace refuses `jj util snapshot`**, with the same stale error and exit 1. The
  `cp`-first procedure in `concurrent-agents.md` is therefore the only route, and it is no longer
  labelled unreproduced.
- **`jj op restore` to an operation predating the workspace**: ws2 prints `No working copy.` and
  keeps its files, under both values of the setting. `jj util snapshot` there answers
  `No snapshot needed.` and protects nothing. `jj workspace update-stale` fails with
  `Error: Nothing checked out in this workspace`.
- **`jj op abandon ..<op>`**: ws2 fails with `Internal error: The repo was loaded at operation <a>,
  which seems to be a sibling of the working copy's operation <b>`, exit 255, files intact, and
  Jujutsu hints `jj op integrate <b>`. That is the measured trigger `jj op integrate` did not have
  when it was left out of the skill.
- **`jj op restore` to a later operation, and `jj undo`**: files stayed on disk in every run,
  snapshotted and unsnapshotted alike, under both values of the setting. The skill keeps the
  snapshot-first precaution for them anyway; it costs one command.
- **Content durability holds.** With a file that no `jj` command in ws2 had ever seen, the content
  was readable afterwards by commit ID through `jj --at-op`, in all four combinations of the two
  operations and the two setting values. A file written after the workspace was already stale
  survived too: update-stale snapshots before it resets.
- **`jj workspace list` still does not show a Git worktree** in a colocated repository. New and
  worse: a `jj` command run from inside the Git worktree acts on the main workspace — `jj root`
  prints the main root, `jj status` reports the main workspace's `@`.
- **The conflict claims all hold.** Off-`@` conflict after `jj rebase -r`; `jj status` silent about
  it while listing the working copy's own changes; bare `jj resolve --list` giving
  `Error: No conflicts found at this revision` (exit 2); the disk file carrying no markers;
  Jujutsu printing the `jj new` / resolve / `jj squash` procedure; `:ours` resolving to the rebase
  destination. New: the materialized conflict header now labels each side with its role
  (`(rebase destination)`, `(rebased revision)`), which is a cheaper way to tell the sides apart
  than a diff.
- **The colocated Git index fix is in.** An external `git add` after a `jj` command left `git fsck`
  clean. A repository corrupted by this before 0.45.0 is not repaired by the fix, and the skill
  does not cover that state.
- **`jj converge` exists**, added in 0.45.0, default revset `mutable() & divergent()`. With
  `--no-interactive`, on one change with two copies whose descriptions differed: `Could not
  converge change`, exit 1, nothing rewritten. jj's help says the flag prints a warning; what it
  did was fail. The successful path is unmeasured — that converge rebases descendants and moves
  local bookmarks comes from `jj converge --help`.
- **The default immutable set** is `trunk() | tags() | untracked_remote_bookmarks() |
  untracked_remote_tags()`. `untracked_remote_tags()` was added in 0.45.0.
- **jj's built-in `revsets.sign`** is `reachable(@, mutable())` at both the v0.44.0 and the v0.45.1
  tag, from `cli/src/config/revsets.toml`. The `reachable(@-, mutable())` seen here is a user
  override — which is why `SKILL.md` now warns that settings decide outcomes.
- **Unchanged from the 0.44.0 record**: `--allow-new` still absent from `jj git push`,
  `jj describe [REVSETS]...`, `jj commit [FILESETS]...`, and the names and defaults of
  `experimental-advance-branches.enabled-branches`, `revsets.bookmark-advance-from` and
  `revsets.bookmark-advance-to`.

### Refuted on 0.45.1, and corrected in the skill

- That an operation-log rewrite (`jj undo`, `jj op restore`, `jj op abandon`) removes another
  workspace's files. It is rewriting that workspace's own `@` that does it, by way of the stale
  state. The old five-operation list came from measuring only with `auto-update-stale = true` and
  attributing the result to the wrong command.
- That `jj workspace update-stale` is *not* the command that clears the files. It is. The 0.44.0
  record listed that as refuted; it was refuted only in the sense that no one had to run it by
  hand on this machine.
- That `--ignore-working-copy` cannot get past a signing failure. With a signing program that
  always fails, `jj status --ignore-working-copy` succeeded on 0.45.1: it skips the snapshot, so no
  commit is written and nothing is signed. Commands that write a commit still fail. The 0.44.0
  measurement against a locked 1Password store saw the flag fail, so the skill now states both.

### The 0.44.0 claims, re-run on 0.45.1

Each held, in a throwaway repository under jj's default config:

- Snapshot before a read: `jj status` recorded a file no command had seen yet.
- Large-file refusal is per file: `Warning: Refused to snapshot some files:` with the path, the
  size and the limit, exit 0, the file under `Untracked paths:`, every sibling recorded.
- `jj file untrack <non-ignored path>` fails with `Error: '<path>' is not ignored.`, exit 1.
- `.gitignore` and symlinks: `venv/` left a symlink named `venv` tracked; `venv` ignored it.
- `jj describe -r <two-commit revset> -m` rewrote both and printed `Updated <n> commits.`
- `jj commit -m <msg> <path>` committed that path only and left the rest in the new `@`.
- `jj abandon -r @` removed the working copy's files from disk, printing `removed <n> files`.
- Ambiguity: `Error: Change ID prefix 'o' is ambiguous`, with hints naming `o/0`, `o/1` and
  `change_id(o)`.
- Every template expression in `ids-and-templates.md`: `change_id.shortest()`,
  `commit_id.shortest()`, `change_id.short(8)`, `description.first_line()`, `bookmarks`,
  `author.email()`.
- `jj bookmark set` backwards: `Error: Refusing to move bookmark backwards or sideways: <name>`,
  exit 1, bookmark unmoved; `--allow-backwards` moves it.
- Immutability: `Error: Commit <id> is immutable`, exit 1, for `jj describe -r`, `jj rebase -r`
  and `jj edit` alike.
- `jj git push` against a local bare remote: a new bookmark pushed with no `--allow-new` and came
  back tracked as `@origin`; `-c <rev>` created `push-<full-change-id>`; an undescribed commit gave
  `Error: Won't push commit <id> since it has no description` with the `Hint: Rejected commit:`
  line, and `--allow-empty-description` pushed it; a conflicted commit gave `Error: Won't push
  commit <id> since it has conflicts`, and `--allow-conflicts` pushed it.
- `pre-push` still does not run: the same hook blocked `git push` and was ignored by
  `jj git push`.
- All four `experimental-advance-branches` limits: a bookmark on `@-` advanced, one further back
  did not, `jj new` advanced it onto an empty undescribed commit, and reading the key without
  `--include-defaults` printed `Warning: No matching config key for: <name>`.
- `jj op integrate <op>` recovers the sibling-operation state: exit 0, `The specified operation has
  been integrated with other existing operations.`, workspace usable, files intact. This is now in
  the skill.

### Still open on 0.45.1

- **Signing with a locked key store.** Re-measured only through an emulated always-failing signer
  (`program = /usr/bin/false`). The 1Password case was not re-run, and 0.45.1 changed where
  signatures are stored for SHA-256 Git repositories.
- **The `git filter-repo` recovery.** Still one 0.44.0 run. `filter-branch` and BFG are still
  inference from that run.
- **`jj git push` and Git hooks.** Still one 0.44.0 measurement of `pre-push`. No other hook tested.
- **The GitHub protected-branch rejection.** Still the one 0.44.0 observation; a local bare remote
  cannot produce `protected branch hook declined`.

## Verified on jj 0.44.0

Reproduced in throwaway repositories. Kept as the record of what was measured then, not as the
current text of the skill. The 0.45.1 section above supersedes the second bullet — the workspace
file-removal claim — and everything the "Refuted on 0.45.1" list names.

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
  including `jj edit`. The new-commit-on-top behavior fires only when `@` *becomes*
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

Resolved since, in the 0.45.1 section above: the stale working copy, whether a stale workspace
refuses `jj util snapshot`, why the two audits disagreed, and the restore predating a workspace.
The rest of this list still stands, `jj --at-op <old> new` included.

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
  skill's former table row. The row is gone; the behavior is not documented anywhere.

- **An external Git history rewrite in a colocated repository.** `git filter-repo` repacked away
  the working-copy commit, and every `jj` command afterwards failed to open the repository.
  Measured once on jj 0.44.0 with `git filter-repo` a40bce5. The recovery in
  [rewriting-history.md](references/rewriting-history.md) is written from that one run:
  `filter-branch` and BFG are named there by inference from the same repack, not by measurement.

- **Commit signing, and what it costs.** Measured once on jj 0.44.0 with 1Password's
  op-ssh-sign: with a signing backend configured, a locked key store fails every command,
  `jj status` included, and neither `--ignore-working-copy` nor `jj workspace update-stale`
  gets past it. `jj sign` with no arguments took `reachable(@, mutable())` and rewrote each
  commit it signed. GitHub's protected-branch rule rejected an unsigned push with
  `protected branch hook declined`, verified against a throwaway branch.
- **`jj git push` does not run Git's `pre-push` hook.** Measured once: the same hook blocked
  `git push` and was ignored by `jj git push`. Whether any other Git hook runs under
  Jujutsu is untested.

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
- Not covered, judged low frequency for this audience: sparse checkouts, `jj fix`,
  `jj simplify-parents`, colocated-repo Git index interactions.
