---
name: use-jujutsu-safely
description: Use Jujutsu safely for repository inspection, code changes, history edits, conflict handling, recovery, bookmarks, and Git remote operations. Use when a repository contains a .jj directory, when the user mentions jj or Jujutsu, or when Git commands could change a Jujutsu-managed repository.
---

# Use Jujutsu Safely

Treat Jujutsu as the source of truth in a Jujutsu-managed repository. Follow this file instead of translating Git commands mechanically.

This file holds what applies before you know which task you are in. Everything else is in a linked reference, and the table at the end says when to read each one. **Read the reference before you act, not after a command surprises you.**

## Establish the repository mode

1. Check for a `.jj` directory at the repository root.
2. Run `jj root` to confirm the repository root.
3. Run `jj version` when command compatibility can affect the task.

Apply these cases:

- `.jj` exists and `.git` does not: Use `jj` to inspect and change repository state.
- `.jj` does not exist: Do not initialize Jujutsu unless the user requests initialization.
- `.jj` and `.git` exist: Treat the repository as colocated. Use `jj` for commits and history edits.

## Four rules that hold whatever you are doing

These have no natural trigger point, because they apply to every action. The rest of this skill assumes them.

**1. There is no staging area, and every `jj` command snapshots first.** `@` is the working-copy commit and every file edit is already part of it. A generated file or a build output enters `@` as soon as it exists. A command you think of as read-only — `jj status`, `jj log` — snapshots the working copy before it runs. A file above the snapshot size limit is the one thing that does not enter `@`: Jujutsu refuses that file alone, exits 0, leaves it untracked, and records every other file normally. Add its pattern to `.gitignore`.

**The exception to rule 1: in a workspace that is not yours, the next `jj` command can delete files instead of snapshotting them.** That happens after any other workspace rewrote the operation log — `jj undo`, `jj op restore`, `jj op abandon` — or rewrote the change this workspace has checked out — `jj rebase -r`, `jj abandon`. The command removes at least every file Jujutsu never snapshotted there, and can remove a snapshotted one too. Run `jj util snapshot` in every other workspace **before** you run such a command. After the command the files are already off that disk, and `jj util snapshot` cannot bring them back. See [concurrent-agents.md](references/concurrent-agents.md).

**2. Name revisions by ID. Never by position.** Each of these names whatever sits there at that instant: `heads(...)`, `@-`, "the tip", and any shell substitution that resolves one of them. A rebase, another workspace or a snapshot changes what they resolve to. The next command then acts on a different commit, and it reports nothing.

This matters most for `jj describe`, which overwrites a description without asking. It also takes its revisions positionally, so one `jj describe -r <revset> -m "<message>"` overwrites the description of every commit the revset resolves to.

**Record finished work with `jj commit -m`, not `jj describe`.** `jj commit` has no `-r` option and always acts on `@`, so it cannot describe a commit you did not mean. It also leaves `@` empty and undescribed, so your next edit starts a new change instead of amending the one you just described. Use `jj describe` for what `jj commit` does not cover: a change that is not `@`, or one you are still working on. [making-changes.md](references/making-changes.md) has the cases.

When you do name a revision:

1. Resolve the revision to a change ID.
2. Confirm the change ID with `jj diff -r <id> --name-only`.
3. Act on that change ID.
4. Resolve any commit ID again after anything rewrites history. A change ID survives the rewrite; a commit ID names one version and goes stale.

**3. Do not alter unrelated changes.** They can belong to the user or to another agent. This includes describing a change you did not create and rebasing a change someone else is working on.

**4. Never repair Jujutsu state with Git.** `git reset`, `git checkout --` and force pushes make the Git view and the Jujutsu view disagree. Recovery is in [recovering.md](references/recovering.md).

## Inspect before you change state

```sh
jj status
jj log -n 5
jj bookmark list
```

Increase the log range only when the task requires it.

**The project check.** Several references end a procedure with "Run the project check". That means the test or build command this repository uses — the one named in its contributor documentation, its agent instructions, or by the user. Skip the step when the repository names no such command.

## What to read, and when

| Read | Before you |
| --- | --- |
| [making-changes.md](references/making-changes.md) | edit files, commit, describe, split, or abandon |
| [rewriting-history.md](references/rewriting-history.md) | run `jj squash`, `jj split`, `jj rebase`, or `jj absorb`, or rewrite history with an external Git tool such as `git filter-repo` |
| [bookmarks-and-remotes.md](references/bookmarks-and-remotes.md) | create, move, delete, fetch, or push a bookmark |
| [concurrent-agents.md](references/concurrent-agents.md) | create or repair a workspace, run `jj undo`, `jj op restore` or `jj op abandon`, rewrite a change another workspace has checked out, or when more than one agent shares the repository |
| [ids-and-templates.md](references/ids-and-templates.md) | read repository state at scale, or resolve an ambiguous ID |
| [conflicts.md](references/conflicts.md) | act on a conflict Jujutsu reports |
| [recovering.md](references/recovering.md) | act after a command produced a result you did not expect, or when content appears to be missing |

[conflicts.md](references/conflicts.md) and [recovering.md](references/recovering.md) are the ones agents reach for late. Read them at the first sign, not after a second command has made the state harder to diagnose.

## Report the result

Report these facts:

- Each commit or bookmark that you created or moved.
- Each conflict or recovery action that you performed.
- Each repository state that still requires user action.

Do not claim success from command exit status alone. A Jujutsu command can exit successfully and still leave a conflict in a commit. Confirm the final state with `jj status` and a focused `jj log`.
