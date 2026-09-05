# Make code changes

Read before you edit files, commit, describe, split, or abandon.

## The model these cases assume

- `@` is the working-copy commit; `@-` is its parent.
- A change ID identifies a change across rewrites. A commit ID identifies one version of it.
- A bookmark points to a commit and does not advance like a Git branch.
- Jujutsu has no current branch.
- A rewrite can rewrite descendant commits automatically.

## Decide where your next edit lands

**`jj new` and `jj edit` move the working copy.** Jujutsu first snapshots your uncommitted edits into the change that was current. After the move, those edits are no longer in the files. That is not loss — see [recovering.md](recovering.md). Run `jj status` after either command rather than assuming that the edits followed you. This applies to both branches below.

If the task must modify an existing commit in place, run `jj edit <revision>` and skip the cases below. Otherwise apply these cases before you edit files:

- `@` holds modifications that are the work you are continuing: Edit the files directly, whether or not `@` has a description.
- `@` holds modifications unrelated to your task: Run `jj new <parent>`.
- `@` has no modifications and no description: Edit the files directly.
- `@` has no modifications and has a description: Run `jj new <parent>`.

## After you edit files

1. Run `jj diff` to inspect the resulting modifications.
2. Run `jj status` to detect conflicts and unrelated files.

**Record finished work with `jj commit -m "<message>"`.** Run step 1 first and confirm that
`jj diff` reports modifications: `jj commit` on an empty `@` creates an empty commit that
carries a description, and prints no warning. This is the default. Do not wait for the user
to ask for a commit. You decide when a piece of work is finished and named.

`jj commit` describes `@`. Then it creates a new empty child. Three properties follow from
that, and each one prevents a mistake:

- **`@` is empty and undescribed afterwards.** The section above lets you edit that state directly, so your next edit lands in a new change.
- **`jj describe` alone leaves a described `@`.** Your next edit then amends the change you just described.
- **`jj commit` has no `-r` option.** It always acts on `@`, so it cannot describe a commit you did not mean. Rule 2 of `SKILL.md` describes that mistake. `jj commit` can still be mis-scoped: it takes `[FILESETS]...`, and `jj commit -m "<message>" <path>` commits only that path, exits 0, and leaves every other modification in the new `@`. Pass no path unless the task requires a partial commit.

**`jj describe` overwrites silently.** It replaces any existing description with no
confirmation. The output shows the new description, never the one it replaced, so a wrong
target leaves no trace. It also takes its revisions positionally, so a revset that resolves
to several commits replaces every one of their descriptions in one command and reports only
`Updated <n> commits.` Confirm the target with `jj diff -r <id> --name-only` before you run
it, and never pass a revset that means "the head".

Apply these cases:

- You did not reach this commit with `jj edit`, the work is finished, and you have a message: Run `jj commit -m "<message>"`.
- The work is unfinished: Leave the working-copy commit unchanged.
- A description is wrong, or a named revision needs one: Run `jj describe -r <id> -m "<message>"`.
- You are editing an existing commit in place after `jj edit`: Run `jj describe -m "<message>"`.
- The task requires selected changes in separate commits: Use `jj split` after you inspect its help for the installed version.
- The working-copy commit must be discarded: Run `jj abandon -r <revision>` on that explicit revision. `jj abandon` of a working-copy commit also removes that commit's files from disk and prints only `removed <n> files`. The content stays readable through the abandoned commit ID, so record that ID before you run the command.

By default a bookmark does not follow `jj commit`, and one setting changes that. See [bookmarks-and-remotes.md](bookmarks-and-remotes.md).

**`jj rebase` does not move the working copy.** After a rebase, `@` is still wherever it was, so a bare `jj describe` lands on that change rather than the one you just moved. Pass `-r <change-id>` — this is the common way a description ends up on the wrong commit.

## Removing a tracked file

A `.gitignore` entry alone does not remove a tracked file from `@`. `jj file untrack` rejects a path that is not ignored. Run these steps in this order:

1. Add the pattern to `.gitignore`. A directory pattern does not match a symlink: `.venv/` ignores a directory, and `.venv` also ignores a symlink of that name.
2. Run `jj file untrack <path>`. The file stays on disk.
3. Run `jj status` to confirm that the file left `@`.

## Large files

Jujutsu refuses to snapshot a file above its size limit and prints the path and the limit. The refusal is per file: the command exits 0, records every other file normally, and leaves the refused file under `Untracked paths:`. It never entered `@`, so do not try to remove it with `jj file untrack` — that command rejects a path that is not ignored. Add the pattern to `.gitignore` rather than raising the limit.
