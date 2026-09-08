# Isolate concurrent agents

Do not let two agents edit the same working copy. Concurrent edits can mix unrelated changes in `@`.

Use a separate Jujutsu workspace for each concurrent agent:

```sh
jj workspace list
jj workspace add <destination> --name <name>
```

Apply these cases:

- The user or orchestrator already supplied an isolated workspace: Use that workspace.
- Multiple agents will edit the repository: Create one workspace for each agent.
- One agent will edit the repository: Use the current workspace.
- A workspace reports that its working copy is stale: Follow the stale-workspace procedure at the end of the next section. Do not run `jj workspace update-stale` before that procedure.

Each workspace has its own working-copy commit. Rewriting a change that another workspace has checked out usually leaves that workspace **divergent**: see "Divergent changes are normal here" below.

Do not substitute a Git worktree for a Jujutsu workspace. Jujutsu does not manage one as a workspace, and `jj workspace list` does not show it. Worse, a `jj` command run from inside a Git worktree of a colocated repository acts on the main workspace: `jj root` prints the main repository root and `jj status` reports the main workspace's `@`, so an agent working in the worktree edits one tree and commits another. Measured on jj 0.45.1.

## Snapshot every other workspace before you rewrite anything

**The invariant.** After you rewrite a change another workspace has checked out, that workspace loses files from its disk. It loses at least the files Jujutsu never snapshotted there, and it loses snapshotted ones too. A file is unsnapshotted when a process wrote it into a workspace and no `jj` command has run there since.

`jj workspace update-stale` is the command that removes them. It prints one line of ordinary output:

```
Added 0 files, modified 0 files, removed 3 files
```

**One setting decides whether anyone sees it happen.** `snapshot.auto-update-stale` is `false` by default. Measured on jj 0.45.1, with `jj rebase -r` and `jj abandon -r` against another workspace's `@`:

- `false`: the next `jj` command in that workspace fails with `Error: The working copy is stale (not updated since operation <id>)`, exit 1. Every later command there fails the same way. The files are still on disk. They go when someone runs the `jj workspace update-stale` that the error hints at.
- `true`: the next `jj` command runs `jj workspace update-stale` for you. It exits 0, prints the `removed <n> files` line among its ordinary output, and the files are already gone.

Read the value before you rely on either behavior:

```sh
jj config list --include-defaults snapshot.auto-update-stale
```

**Other rewrites, measured on jj 0.45.1 under both values of the setting.** These rows differ in whether the other workspace went stale at all:

- `jj op abandon ..<op>`: that workspace fails with `Internal error: The repo was loaded at operation <a>, which seems to be a sibling of the working copy's operation <b>` and exit 255. Its files stay. Run the `jj op integrate <b>` that Jujutsu hints, in that workspace: it exits 0, prints `The specified operation has been integrated with other existing operations.`, and the workspace works again with its files intact.
- `jj op restore <op>`, to an operation that predates the workspace: that workspace prints `No working copy.` and keeps its files. `jj workspace update-stale` there fails with `Error: Nothing checked out in this workspace`.
- `jj op restore <op>` to a later operation, and `jj undo`: the files stayed on disk in every run, snapshotted and unsnapshotted alike.
- `jj describe -r <that workspace's @>`: snapshots normally and leaves the files.

Snapshot the other workspaces before any of these anyway. The list describes one version's behavior, and it is not a promise about the next one.

**The content survives; the disk state does not.** Jujutsu inserts a snapshot operation before it resets, so the removed content is still readable afterwards by commit ID, sometimes only through the operation log:

```sh
jj op log
jj file show -r <commit-id> <path>
jj --at-op <op-id> file show -r <commit-id> <path>
```

So `jj util snapshot` is a content-durability measure, not a disk-state measure. Files can leave the disk even when the workspace was snapshotted first. Snapshot anyway: it puts the content in a commit you can name.

**Snapshot with `jj util snapshot`, not with `jj status`.** `jj status` snapshots, but only as a side effect of a command that can also reset the files in that workspace. Use the command that only snapshots:

```sh
cd <workspace> && jj util snapshot
```

It prints `Snapshot complete.`, or `No snapshot needed.` when the workspace is clean.

**Snapshot before the rewrite, because afterwards the command is gone.** A workspace whose working copy has gone stale refuses `jj util snapshot` with the same stale error it gives every other command, exit 1, measured on jj 0.45.1. A workspace that got `No working copy.` instead answers `No snapshot needed.` and protects nothing. Neither state has a snapshot you can still take.

Apply these cases:

- Your own workspace, at the end of your turn: Run `jj util snapshot`.
- Another agent's workspace, during normal work: Do not snapshot it. That snapshot races the agent still writing into the workspace, and it covers only the files that existed at that instant.
- Another agent's workspace, before you rewrite a change it has checked out or run any operation listed above: Run `jj util snapshot` there too, and tell that agent first where you can. `recovering.md` gives the same instruction for the same case.

**`jj edit` of a revision another workspace has checked out.** It succeeds silently, with no warning, and leaves two workspaces on one change ID with different commit IDs. Do not run it against another workspace's `@`.

**The stale-workspace procedure.** A stale workspace refuses every `jj` command:

```
Error: The working copy is stale (not updated since operation <id>).
```

With `snapshot.auto-update-stale = false`, which is the default, this is what a workspace shows after someone rewrote the change it had checked out. Its files are still there, and the `jj workspace update-stale` in the hint is what removes them. So when the workspace holds files you need:

1. Copy the files out with `cp`. `jj util snapshot` is not available here.
2. Run `jj workspace update-stale`.
3. Copy the files back.
4. Confirm that each file returned.

Reproduced on jj 0.45.1 with `jj rebase -r` and with `jj abandon -r` against the workspace's `@`.

## Divergent changes are normal here, and they are a trap

Rewriting a change that a workspace has checked out produces two commits with the same change ID. Jujutsu marks them `(divergent)` and refuses a bare change-ID reference:

```
Error: Change ID `abcdefgh` is divergent
Hint: Use change offset to select single revision: abcdefgh/0, abcdefgh/1
Hint: Use `change_id(abcdefgh)` to select all revisions
```

Name one copy as `<change-id>/0` or `<change-id>/1`, and both as `change_id(<change-id>)`. A commit ID also names one copy, and it is the safer handle when you are about to abandon something.

Compare the copies with `jj diff -r <id>` first. If they differ in content, abandon nothing and ask the user.

Both copies usually hold identical content, so picking by inspection tells you nothing. **Pick by which one a workspace is sitting on**, because abandoning that one strands the workspace:

```sh
cd <workspace> && jj log -r @ --no-graph -T 'commit_id.short()'
```

When the copies hold the same content, apply these cases:

- One copy is a workspace's working copy: Keep it. Abandon the others by commit ID.
- No copy is any workspace's working copy: Keep the one whose diff you want, abandon the rest.

Then describe or rebase the survivor — and resolve its ID again afterwards, because the rebase changes it.

**`jj converge` does the same job in one command, from jj 0.45.0.** It replaces the copies with one new commit, rebases their descendants onto it, and moves the local bookmarks that pointed at them. With no `-r` it takes its revisions from the `revsets.converge` setting, whose default is `mutable() & divergent()`.

It prompts, and a prompt stops an agent that cannot answer it. It asks:

- Which change to converge, when the revset holds more than one.
- Which description, which parents, or which author to keep, when its heuristics do not settle them.

Pass `--no-interactive`. The command then fails instead of asking:

```
Error: Could not converge change
```

That is exit 1, and Jujutsu rewrites nothing. Measured on jj 0.45.1, with two copies whose descriptions differed.

Apply these cases:

- `jj converge --no-interactive` exited 1: Use the manual procedure above.
- It converged: Confirm the survivor with `jj log`. Then check each bookmark it moved with `jj bookmark list`.

## A rewritten or stale workspace is not lost work

A rewrite elsewhere changes which commit a workspace sits on. It does not delete snapshotted content. That content stays in the operation log and in the commit store.

Find it before you conclude anything is gone:

```sh
jj op log                       # every operation, including each snapshot
jj log -r 'all()'
jj evolog -p -r <change-id>
```

Apply these cases:

- The content is in a commit that is no longer visible: Reference the commit by id. `jj log` hides an abandoned commit, but `jj file show -r <commit-id> <path>` and `jj diff -r <commit-id>` still read it.
- Whole files must come back: Use `jj workspace add <destination> -r <commit-id>`, or copy each path out with `jj file show`.
- The repository must return to an earlier state: Identify the exact operation in `jj op log`. Run `jj util snapshot` in every other workspace first. The restore removes the unsnapshotted files in those workspaces. Then run `jj op restore <operation-id>`.

Report content as lost only after `jj op log` shows no snapshot that contains it. An agent's statement that content was never snapshotted is a claim to verify, not a fact to act on.
