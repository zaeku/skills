---
name: instruction-clarity
description: Rules for writing or reviewing instructions that a model will read — SKILL.md and other skill files, system prompts, AGENTS.md, CLAUDE.md, GEMINI.md and other agent instruction files, tool and subagent descriptions, task briefs, and workflow docs. Use this whenever the user is drafting, editing, or auditing text meant to be followed by a model rather than a person, even if they don't mention STE, controlled language, or clarity by name. Use it again as a revision pass after any edit to one of those files, including an edit made inside a task about something else — the topic of the task does not change what the file is. Also use it when the user says a model "ignored", "misread", "skipped", or "half-followed" an instruction, or did the thing the file argued against — this skill diagnoses each of those from the instruction text.
---

# Agent Instruction Clarity

ASD-STE100 is a controlled-language standard written so that non-native aircraft
mechanics cannot misread a maintenance procedure. Its failure model overlaps
heavily with the way a model misreads text: ambiguous parse trees, unresolved
referents, and instructions that get partially executed.

Eight of its rules transfer directly. The rules are listed below in the order
that finds the most defects per pass.

## The nine rules

| # | Rule | Why it matters here | Scan for |
|---|---|---|---|
| 1 | One term per concept, one verb per action | A model has no way to know `task` and `work item` are the same thing, and may infer they are not | Two words for one concept, or one word for two |
| 2 | One instruction per sentence, imperative | Compound sentences get partially executed, and the omission is hard to spot afterward | `and` / `then` / `;` between two verbs in a procedural sentence |
| 3 | Constraints before the step, with the consequence stated | A late constraint is read after the model has started acting. A stated reason lets the model apply the rule to cases the author did not anticipate | Caveats or "note that" after the step; prohibitions with no consequence |
| 4 | Conditional logic as a vertical list | Nested prose conditions force a truth table into working memory, and branches get dropped | Two or more of `if` / `unless` / `except` / `otherwise` in one sentence |
| 5 | Name the actor | An action with no actor becomes a guess: do I do this, or is it already done, or does the user? | `is/are/was/were` + participle with no `by <actor>` |
| 6 | Noun clusters of three words maximum | Stacked nouns have several valid parses and English gives no signal which is meant | Four or more stacked nouns with no preposition between them |
| 7 | No telegraphic compression | Stripping articles and prepositions to save tokens removes exactly the cues that fix structure | Missing articles, dropped prepositions, dashes standing in for verbs |
| 8 | Long sentences are a smell, not a limit | A long sentence has usually accumulated a second instruction or a hidden condition | Sentences past ~20 words in procedures, ~25 in prose |
| 9 | Instructions in the file, reasons outside it | A defended choice describes the draft, not the current state, and an alternative the reader never considered stays in context as text | "this is intentional", "the reason", a clause that defends how the file is written, a negation of an alternative nothing points the reader at, an absence explained in the document rather than in the world. Never the consequence of ignoring the instruction, which rule 3 requires |

Rules 1, 2, and 3 account for most real defects. If a pass has to be short, do
those three.

`[rules.md](references/rules.md)` carries the full treatment of each rule with worked
before/after examples. Read it in either of these cases:

- You are rewriting rather than only flagging.
- A scan signal fired and the fix is not obvious.

## Writing

Draft normally first. Then run the rules as a revision pass. Applying them while
drafting produces stilted text and slows the draft down.

### Schedule the revision pass

A draft written inside another task carries no cue to come back to it. Name the
moment instead. Run the pass at whichever of these arrives first:

- You are about to report the edit as finished.
- You are about to commit the file, or to push it.
- Another session, subagent, or user is about to read the file.

A covered file is any file whose reader is a model: a skill, a system prompt,
`AGENTS.md`, `CLAUDE.md`, a tool or subagent description, a task brief, or a
workflow doc.

Apply these cases:

- You edited a covered file inside a task about something else: Run the pass. The subject of the task does not change what the file is.
- You edited a covered file several times in one session: Run one pass over every edit.
- You only read the file: Do not run the pass.
- Your own new text is part of what you review: Scan it under the same rules. Text that explains a measurement is where rules 7 and 8 fail most often.

## Reviewing a document

Scan and report in different orders. They serve different people.

**Scan by rule.** Go rule by rule through the whole document rather than reading
it once for general quality. Apply the scan signal mechanically, one rule at a
time.

**Report by document position.** Someone fixing the document works top to
bottom. Sort the findings by location before you present them.

Report each finding as three things:

- Location
- Rule number
- The proposed rewrite

Give concrete rewrites, not abstract advice. "Line 40 uses both `task` and
`work item`; pick one" is useful. "Improve terminology consistency" is not.

Rule 1 is the exception to position sorting: inconsistent terms are a
document-wide finding, so report them once at the top rather than at every
occurrence.

## Diagnosing from a symptom

Users often arrive with a behavior complaint and no document in hand — a model
skipped a step, ignored a constraint, or handled one case wrongly. Ask for the
instruction text, then start from the rule the symptom points at.

| Symptom | Start with |
|---|---|
| Skips a step in the middle of a procedure | 2 — it is probably not a separate step yet |
| Skips the last step | 2, then 8 — check whether it is fused to the step before it |
| Violates a constraint it clearly read | 3 — check whether the constraint comes after the step, and whether it says why |
| Treats one thing as two, or two as one | 1 |
| Correct on most inputs, wrong on one case | 4 — write out the branches and look for the one that was never specified |
| Does nothing, or asks who should act | 5 |
| Interprets a phrase in an unintended sense | 6, then 7 |
| Does the thing the document argued against | 9 — the rejected alternative is in the file as text |

If the instruction text is clean under every rule, say so and stop. The cause is
then outside this skill's scope — see the Scope section.

## Scope

This skill covers the clarity defects in the table above. Agent instructions
have other failure modes — instruction precedence, worked examples, trigger
conditions, positive alternatives to bare prohibitions — that these nine rules
do not cover. Do not treat a clean pass here as a complete review.

`[design-notes.md](references/design-notes.md)` records what was left out of the standard, and
where the skill goes past it. Read it before extending or editing this skill.
