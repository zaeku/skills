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

Do not substitute a Git worktree for a Jujutsu workspace: Jujutsu does not manage one as a workspace, and `jj workspace list` does not show it.

## Snapshot every other workspace before you rewrite anything

**The invariant.** After you rewrite the operation log, or rewrite a change another workspace has checked out, the next `jj` command inside that other workspace can remove files from its disk. It removes at least the files Jujutsu never snapshotted there, and can remove a snapshotted one too. A file is unsnapshotted when a process wrote it into a workspace and no `jj` command has run there since.

These operations were each measured removing another workspace's unsnapshotted files on jj 0.44.0:

- `jj op restore <old>`
- `jj op abandon ..<op>`
- `jj undo`
- `jj rebase -r <that workspace's @>`
- `jj abandon -r <that workspace's @>`

Treat any other operation-log rewrite as belonging to this list. One operation measured as safe on 0.44.0: `jj describe -r <that workspace's @>`, which snapshots normally and leaves the files.

**The loss is silent.** The removing command exits 0 and prints no warning. Its only signal is one line of ordinary output:

```
Added 0 files, modified 0 files, removed 3 files
```

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

If you own a workspace, run `jj util snapshot` in it at the end of your turn.

Do not snapshot another agent's workspace on its behalf during normal work. That snapshot races the agent still writing into the workspace, and it covers only the files that existed at that instant.

**One exception.** Before any operation in the list above, snapshot every other workspace, even the ones you do not own. Tell the other agents first where you can. `recovering.md` gives the same instruction for the same case.

**`jj edit` of a revision another workspace has checked out.** It succeeds silently, with no warning, and leaves two workspaces on one change ID with different commit IDs. Do not run it against another workspace's `@`.

**The stale-workspace procedure.** One report describes a workspace refusing every `jj` command:

```
Error: The working copy is stale (not updated since operation <id>).
```

No trigger reproduced that state on jj 0.44.0. If it does occur and the workspace holds unsnapshotted files:

1. Copy the files out with `cp`.
2. Run `jj workspace update-stale`.
3. Copy the files back.
4. Confirm that each file returned.

## Divergent changes are normal here, and they are a trap

Rewriting a change that a workspace has checked out produces two commits with the same change ID. Jujutsu marks them `(divergent)` and refuses a bare change-ID reference:

```
Error: Change ID `abcdefgh` is divergent
```

Both copies usually hold identical content, so picking by inspection tells you nothing. **Pick by which one a workspace is sitting on**, because abandoning that one strands the workspace:

```sh
cd <workspace> && jj log -r @ --no-graph -T 'commit_id.short()'
```

First compare the copies with `jj diff -r <id>`. If they differ in content, abandon nothing and ask the user. If they hold the same content, apply these cases:

- One copy is a workspace's working copy: Keep it. Abandon the others by commit ID.
- No copy is any workspace's working copy: Keep the one whose diff you want, abandon the rest.

Then describe or rebase the survivor — and resolve its ID again afterwards, because the rebase changes it.

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
