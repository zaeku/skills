# Handle conflicts

Read when Jujutsu reports a conflict. A conflict is commit state inside Jujutsu, not a working-copy condition to clear before continuing.

**The conflict is often not in `@`.** `jj rebase` leaves it in the commit it moved, and that
commit is not the working copy. `jj status` then reports **no conflict**, whatever else it
reports — it still lists your own working-copy changes. A bare `jj resolve --list` exits with
`Error: No conflicts found at this revision`, while the file on disk holds one side and no
markers. A reader who stops there concludes that no conflict exists. When the conflicted
commit happens to be an ancestor of `@`, `jj status` does print the conflict and a bare
`jj resolve --list` does succeed, so neither output proves the conflict is gone.

1. Read the commit the previous command named. Jujutsu prints `New conflicts appeared in <n> commits` and lists them.
2. Decide where to resolve, by these cases:
   - `@` is the conflicted commit: Resolve in the working copy.
   - The conflicted commit is not `@`: Run `jj new <conflicted-commit>`. Resolve there. Then run `jj squash` to move the resolution into that commit. Jujutsu prints these three steps itself when the rebase creates the conflict.
3. Run `jj resolve --list -r <commit>` for the conflicted commit.
4. Resolve each conflicted file. Apply the per-file cases below.
5. Run `jj status`.
6. Run the project check.

If the user selected a merge tool, run `jj resolve <path>` with that tool and skip the cases below. Otherwise apply these cases to each file:

- One complete side is correct, and you have evidence for it: Run `jj resolve --tool :ours` or `jj resolve --tool :theirs`. `:ours` is side #1 of the conflict and `:theirs` is side #2. In a rebase, `:ours` is the destination's content and `:theirs` is the rebased commit's content. Neither one means "the branch you are on". Confirm which side is which with `jj diff -r <commit>` before you choose.
- Neither side is correct on its own: Edit the conflict markers in the working copy directly. The next Jujutsu command snapshots the file. The conflict clears when the markers are gone.

Do not select `:ours` or `:theirs` without evidence. A side selector discards the whole other side, including valid modifications.

Do not assume that a conflicted commit can be pushed to a Git remote. A Git remote cannot represent every Jujutsu conflict state. Resolve conflicts before `jj git push`. `jj git push --allow-conflicts` exists; use it only when the user asked for a conflicted commit on the remote.
