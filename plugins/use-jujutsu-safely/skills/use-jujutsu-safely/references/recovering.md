# Recover from an incorrect operation

Read when a command produced a result you did not expect, or when content appears to be missing. Read it at the first sign — each additional command makes diagnosis harder.

Stop history edits first.

## Collect evidence

```sh
jj status
jj op log -n 20
jj log -n 10
jj evolog -p -r <change-id>
```

If you are not certain which operation or revision is the correct recovery target, stop and ask the user. Do not run `jj undo` or `jj op restore` to find out.

## Apply these cases

- Only one change needs inspection: Use `jj evolog`.
- One file needs content from an earlier version: Use `jj restore --from <revision>` with an explicit path.
- The latest operation must be reversed: Inspect the latest operation before you use `jj undo`. If any other workspace exists, run `jj util snapshot` in each one first. `jj undo` is an operation-log rewrite.
- The repository must return to an earlier operation: Identify the exact operation before you use `jj op restore`. If any other workspace exists, run `jj util snapshot` in each one first. This is the one case where you snapshot a workspace you do not own — see [concurrent-agents.md](concurrent-agents.md).
- A commit is no longer visible in `jj log`: Reference it by ID. `jj file show -r <commit-id> <path>` and `jj diff -r <commit-id>` read an abandoned commit, and `jj workspace add <destination> -r <commit-id>` checks one out whole.
- The content was in the working copy at a known moment: Read the repository as of that operation. `jj --at-op <op-id> log -r @` gives the commit that held it, and `jj --at-op <op-id> file show -r <commit> <path>` reads the file.

## Content is rarely lost

Jujutsu snapshots the working copy at the start of most commands, so snapshotted content survives a rewrite, an `abandon`, and a stale workspace. `jj log` hiding a commit does not remove it from the store; the ID still reads.

**Search `jj op log` before you report anything as lost.** Treat a report that a file was never snapshotted as a claim to verify, not a fact to act on. The usual next step after such a report is an `abandon`, and that is how content becomes genuinely hard to find.

The one real exposure is an unsnapshotted file: a file another process wrote into a workspace where no `jj` command has run since.

**A recovery command removes those files from another workspace's disk.** `jj undo`, `jj op restore` and `jj op abandon` each do it, and they print no warning. The content survives; the disk state does not. Read the content back by commit ID, or through `jj --at-op` when the plain ID no longer resolves. A prior snapshot guarantees the content, never the disk state: a previously snapshotted file can be removed from that workspace's disk too.

So run `jj util snapshot` in each other workspace before an operation-log rewrite. [concurrent-agents.md](concurrent-agents.md) has the full operation list, the measurements, and why `jj status` is not a substitute.

## Recovering is not always the cheapest answer

Ask what the missing content is before you reconstruct it. Generated output — a build artifact, a container dump, a sweep's log — is usually cheaper to regenerate by re-running the command that made it than to recover from the operation log. Recovery is for work that cannot be reproduced.

## Never repair with Git

Do not use `git reset`, `git checkout --`, or force push to recover Jujutsu state. These commands can make the Git view and the Jujutsu view disagree.
