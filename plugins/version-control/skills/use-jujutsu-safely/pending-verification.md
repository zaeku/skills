# Verification record

Not part of the skill. `SKILL.md` does not link this file, and no reference does. It is the
worklist for whoever maintains the skill next.

The skill is stamped at **jj 0.45.1**. Every claim in it was reproduced in a throwaway repository
under jj's default config, except the four items under "Still open" below. How each claim came to
be worded the way it is lives in the commit log; `git log v0.2.0..v0.3.0` is the audit trail.

## Still open

- **Signing with a locked key store.** The claim in `recovering.md` — that a signing failure
  fails every command, reads included — was measured once on 0.44.0 against 1Password's
  op-ssh-sign, and re-measured on 0.45.1 only through an emulated always-failing signer
  (`program = /usr/bin/false`). The two disagree about `--ignore-working-copy`: the emulated
  signer let it through, the locked store did not. 0.45.1 also changed where signatures are
  stored for SHA-256 Git repositories.
- **The `git filter-repo` recovery.** One run, on 0.44.0, with `git filter-repo` a40bce5.
  `filter-branch` and BFG are named in `rewriting-history.md` by inference from that same repack,
  not by measurement.
- **Git hooks other than `pre-push`.** `pre-push` is measured twice: `git push` runs it and
  `jj git push` ignores it. No other hook is tested.
- **The GitHub protected-branch rejection.** One observation, on 0.44.0. A local bare remote
  cannot produce `protected branch hook declined`, so re-running it needs a real remote that
  carries protection rules.

Untried rather than open, and lower value: `jj --at-op <old> new` (files survived, no divergence
appeared, and the behavior is documented nowhere), a genuinely concurrent second `jj` process,
sparse checkouts, and network filesystems.

## Do not reintroduce these

- That an operation-log rewrite removes another workspace's files. `jj undo`, and `jj op restore`
  to a later operation, left them on disk under both values of `snapshot.auto-update-stale`. It is
  rewriting a workspace's own `@` that costs it files, by way of the stale state.
- That the removal happens without `jj workspace update-stale`. That command is the removal,
  whether a person runs it or `snapshot.auto-update-stale = true` runs it for them.
- That the operation log holds no copy of a removed unsnapshotted file. Jujutsu snapshots before
  it resets, so the content stays readable by commit ID, sometimes only through `jj --at-op`.
- That a large-file refusal blocks the whole snapshot. It is per file.
- That a per-command table of workspace outcomes stands on its own. Two audits built one and both
  got it wrong, because the deciding variable was a config value neither recorded.

## Judgment calls, deliberately settled

- The workspace section names one mechanism first — the stale working copy, cleared by
  `jj workspace update-stale` — and only then lists what each command does. The list is
  defensible now because the mechanism explains every row. It was not before.
- The snapshot-first precaution still covers `jj undo` and `jj op restore`, which measured as
  harmless. Cost is one `jj util snapshot` per workspace, against a class of operation whose
  behavior has been misread twice.
- `jj op integrate` is in the skill now, as the recovery for the sibling-operation error that
  `jj op abandon` leaves in another workspace. Both earlier passes left it out for want of a
  measured trigger.
- The skill states jj's built-in defaults and tells the reader to check the value in force. It
  carries no second set of numbers for what any particular machine configures.
- Not covered, judged low frequency for this audience: sparse checkouts, `jj fix`,
  `jj simplify-parents`, and colocated-repo Git index interactions beyond the `git fsck` note in
  `recovering.md`.

## Where the measurements live

- `git log v0.2.0..v0.3.0` — everything the 0.44.0 to 0.45.1 pass changed, and why.
- Commit `Attribute the workspace file loss to the setting that decides it` — the
  `snapshot.auto-update-stale` finding, the two puzzles it closed, and the corrections that
  followed.
- Commit `Re-run the remaining 0.44.0 claims and stamp the skill at 0.45.1` — the claims
  re-measured unchanged on 0.45.1, listed one by one.
