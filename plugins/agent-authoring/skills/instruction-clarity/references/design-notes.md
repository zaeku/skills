# Design notes

Read this before extending or editing this skill. It records what was left out
of ASD-STE100 on purpose, so the exclusions are not reversed by mistake.

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

These are a coherent second skill, not additions to this one. Keeping this skill
scoped to STE-derived clarity is what makes its rules mechanically checkable.
