# agent-authoring

The `instruction-clarity` skill: a revision pass for text an agent will read.

```
/plugin marketplace add zaeku/skills
/plugin install agent-authoring@zaeku
```

Without a plugin loader, copy `skills/instruction-clarity/` into wherever your
agent scans for skills.

ASD-STE100 is a controlled-language standard written so that non-native aircraft
mechanics cannot misread a maintenance procedure. Its failure model overlaps an
LLM's: ambiguous parse trees, unresolved referents, and instructions that get
half-executed. Eight of its rules transfer directly, and this skill applies them
to skills, system prompts, `AGENTS.md`, `CLAUDE.md`, tool and subagent
descriptions, and task briefs.

It works in two directions. Given a document, it reports findings sorted by
position, each with a concrete rewrite. Given a symptom — an agent skipped a
step, ignored a constraint it clearly read, treated one thing as two — it starts
from the rule that symptom points at.

`references/rules.md` carries each rule with before and after examples.
`references/design-notes.md` records which parts of the standard were left out,
and why.

The scope is narrow on purpose. Instruction precedence, worked examples, and
trigger conditions are real failure modes that STE has nothing to say about, so
a clean pass here is not a complete review.

## Trademark

ASD-STE100 and Simplified Technical English are trademarks of ASD, Brussels.
This skill is not affiliated with, endorsed by, or certified by ASD or the
STEMG. It adapts a subset of the standard for a different reader, and it does
not make a document STE-compliant.
