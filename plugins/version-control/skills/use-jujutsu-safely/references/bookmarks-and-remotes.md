# Bookmarks and Git remotes

Read before you create, move, delete, fetch, or push a bookmark.

## Bookmarks

Inspect a bookmark before you change it. Pass an explicit revision to each command. `@` is per workspace, so `-r @` is correct only when `@` is provably the commit you mean. A wrong revision moves the bookmark to the wrong commit, and the next push publishes it.

```sh
jj bookmark list
jj bookmark create <name> -r <revision>
jj bookmark set <name> -r <revision>
```

Change a bookmark only when the user requested the change. Then apply these cases:

- The bookmark already points to the required commit: Do not move it.
- The bookmark must move forward: Use `jj bookmark set <name> -r <revision>`.
- The bookmark must move backward or sideways: Add `--allow-backwards`. `jj bookmark set` moves a bookmark forward only without it.

## Whether a bookmark follows `jj commit`

By default it does not. `jj commit` describes `@`. Then it moves `@` to a new empty child. The bookmark stays where
it was, and the commit you described is `@-`. Set the bookmark to the change ID that
`jj commit` printed for `@-`. `-r @` now names the empty child.

One setting changes this. `jj commit` advances a bookmark when both of these hold:

- `experimental-advance-branches.enabled-branches` lists the bookmark. A name and a pattern both work, so `["glob:*"]` enables every bookmark. The setting name still says `branches`; it means bookmarks.
- The bookmark points at `@-` before you run the command. It then advances onto the commit that `jj commit` describes. A bookmark already on `@` does not move.

Confirm the result with `jj bookmark list`. Four limits apply:

- A bookmark advances from `@-` only. A bookmark that sits further back does not catch up.
- `jj new` advances the bookmark as well. It can leave the bookmark on an empty commit with no description. The Git remotes section below covers what a push does with a commit that has no description.
- Two revsets decide which bookmark advances: `revsets.bookmark-advance-from` and `revsets.bookmark-advance-to`. Read both with `jj config list --include-defaults revsets`.
- The setting carries an `experimental-` prefix, so its name can change between versions. Read `jj config list --include-defaults experimental-advance-branches` before you rely on it. Without `--include-defaults` an unset setting prints `Warning: No matching config key for: <name>`, which does not mean that the setting is gone.

## Git remotes

Do not push unless the user authorized a change to the remote. A push changes shared state.

Fetch only when the task requires current remote state.

For an update that the user authorized:

1. Run `jj git fetch`.
2. Inspect the local bookmark and its remote bookmark.
3. Rebase onto the remote bookmark only when the task requires integration.
4. Run the project check.
5. Run `jj status`.
6. Run a focused `jj log`.
7. Run `jj bookmark list`.
8. Sign what you are about to push, in a repository that signs: `jj sign`. With no arguments it takes `reachable(@, mutable())`, which is the work that has not been published.
9. Push the explicit bookmark with `jj git push -b <name>`.

Apply these cases:

- The bookmark does not yet exist on the remote: Run `jj git push -b <name>`. Jujutsu tracks the new remote bookmark automatically. Do not add `--allow-new`. That flag no longer exists.
- The commit has no description: Write a description with `jj describe -r <id> -m "<message>"`. When the user requires an undescribed commit on the remote, pass `--allow-empty-description` to `jj git push` instead.
- The task needs one commit on the remote without a named bookmark: Run `jj git push -c <revision>`. Jujutsu creates and tracks a `push-<change-id>` bookmark.
- The remote moved ahead: Run `jj git fetch`. Then rebase onto the remote bookmark. Then push again. Do not force push.
- The remote rejects the push with `protected branch hook declined`: the branch requires signed commits and one of yours is unsigned. Run `jj sign`, then push again. Do not force push.
- A `pre-push` hook does not run. `jj git push` does not execute Git's hooks and `git push` does, measured on jj 0.44.0. A repository that guards its pushes with a hook has no guard when the push comes from Jujutsu.

Do not invent a remote name or bookmark name. Read both names from repository state.

A rejected push is diagnostic. Read the commit ID in the `Hint: Rejected commit:` line and act on that commit, not on the one you pushed. When a push is rejected for a missing description, the named commit is one of these:

- An ancestor of the pushed bookmark that you never chose — commonly the empty `@` that an earlier `jj commit` plus `jj new` left behind. Describe it, or move the bookmark so it is no longer an ancestor.
- One you never described. Describe it.
- One whose description you put on a different commit. Move the description to it.

Check which commit the bookmark points at, and what its ancestors are, before you add a description.
