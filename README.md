# skills

Agent skills written and revised alongside the agents that read them. Each is a
plugin of its own, so you install the one you want and leave the rest.

```
/plugin marketplace add zaeku/skills
/plugin install version-control@zaeku
/plugin install agent-authoring@zaeku
```

| Plugin | Skill | What it is for | Verified against |
| --- | --- | --- | --- |
| [version-control](plugins/version-control) | `use-jujutsu-safely` | Working inside a Jujutsu repository without losing anyone's files — inspection, changes, history edits, conflicts, recovery, bookmarks, Git remotes | jj 0.44.0, two independent audits |
| [agent-authoring](plugins/agent-authoring) | `instruction-clarity` | Writing and reviewing instructions an agent will read: skills, system prompts, `AGENTS.md`, tool descriptions | ASD-STE100, applied as eight rules |

Without a plugin loader, copy the skill directory itself into wherever your
agent scans for skills:

```sh
git clone https://github.com/zaeku/skills /tmp/zaeku-skills
cp -R /tmp/zaeku-skills/plugins/version-control/skills/use-jujutsu-safely ~/.claude/skills/
```

Each skill states what it was verified against and when. A skill about a tool's
failure modes goes stale when the tool changes, so check that line before you
trust a detail on a newer version.

## License

MIT. See [LICENSE](LICENSE).
