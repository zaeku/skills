# Change IDs and log templates

Use this reference to read repository state with less output. Verified against jj 0.44.0.

## Shortest unique prefix

`change_id` and `commit_id` both accept the shortest prefix that is currently unique in the repository.

```sh
jj show p           # resolves change ID "p..."
jj describe -r abc  # resolves commit ID "abc..."
```

`jj log` renders the unique prefix bright and the remaining characters dim. Copy the bright part only.

Apply these cases:

- The prefix is unique: Jujutsu resolves the revision.
- The prefix became ambiguous after new commits: Jujutsu reports `Error: Change ID prefix '<prefix>' is ambiguous`. Jujutsu does not select a revision silently. Add one more character to the prefix. Then run the command again.
- The change must survive a rewrite: Use the change ID. A commit ID changes on every rewrite.

## Resolving a target safely

[SKILL.md](../SKILL.md) rule 2 says to name revisions by ID rather than by position. These are the cases:

- The target is known: Use its change ID.
- The target was found by a positional revset: Resolve it to a change ID, confirm it with `jj diff -r <id> --name-only`, then act on that change ID.
- Anything rewrote history since you resolved it: Resolve it again. A commit ID from before a rebase is stale.

## Compact log output

A default `jj log` prints a graph and full metadata. This output consumes context quickly. Use `--no-graph` with an explicit template.

```sh
jj log --no-graph -T 'change_id.shortest() ++ " " ++ description.first_line() ++ "\n"'
```

Verified template expressions:

- `change_id.shortest()` — the shortest unique change-ID prefix.
- `commit_id.shortest()` — the shortest unique commit-ID prefix.
- `change_id.short(8)` — a fixed-width prefix.
- `description.first_line()` — the description summary.
- `bookmarks` — the bookmarks on the commit. Empty when the commit has none.
- `author.email()` — the author email.

Combine a template with `-r <revset>` to read one field from one revision:

```sh
jj log --no-graph -r @ -T 'change_id.shortest() ++ "\n"'
```

Use the plain `jj log` graph when the task requires commit relationships. Use a template when the task requires specific fields.
