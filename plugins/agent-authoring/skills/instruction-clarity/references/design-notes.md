# Design notes

Read this before extending or editing this skill. It records what was left out
of ASD-STE100 on purpose, so the exclusions are not reversed by mistake, and
where the skill goes past the standard.

## Excluded: the approved vocabulary list

STE's approved-word list (roughly 900 words) is about half the standard. It is
omitted here.

It exists because non-native human readers have a limited vocabulary. A model
does not, and constraining vocabulary costs precision without buying clarity.
Rule 1 carries over the useful principle — consistency of terms — without the
list.

## Excluded: human-readability rules

Also omitted: avoiding `-ing` forms, restrictions on tense, the six-sentence
paragraph cap, and STE's descriptive-text style rules.

These serve visual scanning by a human reader. They buy nothing when the reader
is a model.

## Added: rule 9, which is not from the standard

Rule 9 came from a habit that survives a clean pass under rules 1 to 8. A model
writing an instruction tends to write the reason for the instruction next to it:
the alternative it rejected, the objection it answered, the choice it defended.

STE cannot catch this, because STE governs the sentence. A defended choice is
often a perfect sentence — one action, imperative, short, actor named. The defect
sits a layer up, in whether the sentence belongs in the file at all.

Three effects made it worth a rule rather than a design note:

- The rejected alternative stays in context as text that describes the wrong behavior.
- The clause records the state of a draft, so it goes stale first and silently.
- A model that reads instructions written this way writes its next instruction the same way.

Rule 9 has a mechanical test, which is what qualifies it for the table. An
earlier framing — "a clause that carries no information for a reader without
prior knowledge" — was rejected as the test. It deletes worked examples and the
consequence that rule 3 requires, and it invites an argument about whether a
defense informs. The deletion test asks about behavior instead.

Two rounds of use revised the scan column three times.

The column led with `not X but Y`. It fired three times in one file and was
wrong three times: every hit was a negation naming a habit the reader arrives
with, which makes the rejected term the working part of the instruction. The
form cannot separate that from a defense of the draft, so each item now names
the target of the clause instead of its punctuation.

The column also read "any clause that defends a choice or explains an absence",
which caught the consequence that rule 3 requires and pointed two rules in one
table opposite ways. An absence now counts only when the document is what lacks
the thing, and the exclusion for rule 3 sits in the why column, where the
judgment belongs.

The last revision widened one item. The column said "defends how the file is
written" while the why column said "a defended choice", so a defended tool
choice passed the scan. A bare "the reason" went out at the same time, because
the phrase appears in any sentence about reasons, including the rule that
governs them.

## Not covered: agent-specific failure modes

Several properties that matter a great deal in agent instructions have no STE
equivalent, because they are not failure modes for human readers. This skill
does not address them:

- **Positive alternatives over bare prohibitions.** "Do Y instead" outperforms
  "do not X". A prohibition with no substitute behavior is fragile.
- **Instruction precedence.** What wins when two instructions conflict. STE does
  not contemplate a document contradicting itself.
- **Worked examples.** STE discourages redundancy. Few-shot examples are among
  the strongest levers available in agent instructions, so this is a case where
  the standard should be deliberately inverted.
- **Trigger conditions.** A maintenance manual is found by a human using a table
  of contents. A skill has to select itself.
- **Position effects.** Instructions at the start and end of a document carry
  more weight than those in the middle, which is a constraint on document
  structure that has no print-era analogue.

These are a coherent second skill, not additions to this one. Every rule in the
table has a mechanical scan signal, and these five have none.
