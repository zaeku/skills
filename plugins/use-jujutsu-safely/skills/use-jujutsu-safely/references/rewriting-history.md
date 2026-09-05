# Rewrite history with explicit targets

Read before you run `jj squash`, `jj split`, `jj rebase`, or `jj absorb`. These commands rewrite descendants and move bookmarks. Read it also before you rewrite history with an external Git tool, which breaks a colocated repository unless you remove `.jj` first.

## Before the rewrite

1. Run `jj workspace list`. If a workspace other than yours exists, read [concurrent-agents.md](concurrent-agents.md) before you continue, and run `cd <workspace> && jj util snapshot` in each of those workspaces first. A rewrite of a change another workspace has checked out removes that workspace's unsnapshotted files.
2. Run `jj status`.
3. Run a focused `jj log` that shows every affected commit.
4. Resolve the source revision **to an ID**, not to a revset that means "the head".
5. Resolve the destination revision the same way.
6. Run `jj op log -n 5` when the rewrite touches a change you cannot reproduce.

Do not guess a revision range. An incorrect range can rewrite unrelated descendants.

**A rewrite can exit 0 and still leave a conflict.** `jj rebase` reporting success does not mean the result is clean; the conflict is commit state. Check `jj status` afterwards rather than reading the exit code.

## After the rewrite

1. Run the same focused `jj log`.
2. Run `jj diff` for each important rewritten change.
3. Run the project check.
4. Verify each affected bookmark.
5. **Resolve every commit ID you are still holding.** A rebase gives the rewritten change a new commit ID, so an ID captured before the rewrite now points at the pre-rewrite commit or at nothing.

Step 5 is the one that gets skipped. An ID resolved before a rebase and reused after it lands the description on the wrong commit, and the error surfaces only when the remote rejects a push for a missing description.

## Rewriting while workspaces exist

A rebase or an `abandon` of a change that another workspace has checked out does two things.
It usually leaves the change divergent — two commits sharing one change ID. It also removes
that workspace's unsnapshotted files at the next `jj` command there, measured on jj 0.44.0.
Snapshot every other workspace before the rewrite; step 1 above is where you find out whether
this applies. [concurrent-agents.md](concurrent-agents.md) has the full list of operations
that do this, and the divergence resolution procedure.

## Rewriting with an external Git tool

`git filter-repo`, `git filter-branch` and BFG rewrite the Git commits, then repack the object store. The repack deletes Jujutsu's working-copy commit, because no Git ref points at it. Every later `jj` command in that repository then fails with `Object <id> of type commit not found`. `--ignore-working-copy` and `jj workspace update-stale` fail at the same point, so the repository does not open at all.

Remove `.jj` before you run such a tool, and create it again afterwards:

1. Create a bookmark at the commit you want rewritten. `git filter-repo` rewrites refs, and a colocated repository usually has a detached Git `HEAD` and no branch.
2. Copy `.git` and `.jj` to a backup outside the repository.
3. Run `rm -rf .jj`.
4. Run the external tool.
5. Run `jj git init --colocate` in the same directory.

Step 5 gives you back a repository whose history is the rewritten one. You lose the operation log and the empty working-copy commit. You lose no project history, because the commits, their descriptions and their diffs are Git objects that the tool rewrote in place.

**Do not restore the deleted working-copy commit from the backup.** Its ancestors are the commits you just rewrote, so restoring it returns the content you removed to the object store.

Measured once on jj 0.44.0, with `git filter-repo` a40bce5, on 2026-09-05.

## `jj absorb`

`jj absorb` moves each modification in the source revision to the closest mutable ancestor that last modified those lines. It leaves a modification in the source revision when it cannot determine one ancestor.

After `jj absorb`, review the result with `jj op show -p`. Then inspect the remaining source revision with `jj diff`.

## Immutable commits

Jujutsu refuses to rewrite a commit that is immutable — typically one already pushed. The command fails with exit 1 and `Error: Commit <id> is immutable`. This includes `jj describe -r`, `jj rebase -r` and `jj edit`. Do not expect the rewrite to land on a child instead; nothing was written.

A separate behaviour has a separate trigger. When `@` *becomes* immutable during some other command — a bookmark move, a fetch — Jujutsu creates a new commit on top of it and warns `Warning: The working-copy commit became immutable; a new commit has been created on top of it.` Read that message: the change you were editing is not the change you are now on.
