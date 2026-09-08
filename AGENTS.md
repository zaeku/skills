# Agent Guidelines

Guidelines for an agent working on this repository. It holds rules, verified
facts, and the boundaries this project defends. It is not the product
description — read `README.md` for that, and read it first if you have not.

Invoke the `use-jujutsu-safely` skill before an unfamiliar command. If your
harness does not carry that skill, read the
[copy in this marketplace](https://github.com/zaeku/skills/tree/main/plugins/version-control/skills/use-jujutsu-safely)
or run `jj help <command>`. The rules that cost something here:

- **Record finished work with `jj commit -m`, not `jj describe`.** `jj commit`
  describes `@` and opens a new empty change, so your next edit lands somewhere
  new. `jj describe` leaves `@` described, and the next edit amends the change
  you just described. Use `jj describe -r <id>` to correct a description, or to
  describe a change that is not `@`.
- **Pass `-r` to `jj new` every time.** `@` is per workspace, and the default
  parent is wrong as soon as a second workspace exists.
- **`jj describe` on a change that already has a description replaces it
  silently.** Read `jj log` first. Resolve a revset to a commit id before you
  pass it to `-r`.
- **Run `jj util snapshot` when a session in a workspace ends.** It records the
  working copy and does nothing else; `jj status` also snapshots, but as a side
  effect of a command that may reset the working copy in the same breath.
- Do not discard existing changes. The user loses work that no commit holds.
  Existing changes belong to the user unless a task identifies them as agent
  changes.
- **Sign before you push.** GitHub rejects an unsigned push to `main`.

  1. Run `jj sign`. It takes the `revsets.sign` revset, set here to
     `reachable(@-, mutable())`. That revset reaches in both directions, so it
     includes `@` as a descendant of `@-` whenever anything is signed at all.
  2. Run `jj unsign -r @`. Add `--ignore-working-copy` when the repository will
     no longer open; that flag skips the snapshot and not the revset, so it
     prevents nothing else here.
  3. Push.

  Do not leave `@` signed. `behavior = "keep"` preserves a signature through a
  rewrite, every jj command rewrites `@`, and a signed `@` asks 1Password on
  `jj status`. Nothing is signed as it is made, because jj signs the
  working-copy commit on every snapshot and each signature is a prompt.
  Unsigning after the push is safe, since `@` is neither pushed nor a parent of
  anything.

## Language

Write documentation, project artifacts, code comments, and change descriptions
in English. Reply to the user in the language of their prompt.
