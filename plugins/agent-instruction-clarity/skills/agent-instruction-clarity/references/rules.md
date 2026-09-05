# The eight rules in full

Numbering matches the table in SKILL.md.

## 1 — One term for one concept, one verb for one action

The highest-value rule. Human readers silently unify synonyms; models frequently
do not. If a document calls the same thing `task` in one place and `job` or
`work item` in another, a model may reasonably infer these are different things.

The rule runs both directions: do not use two words for one concept, and do not
use one word for two concepts.

**Instead of:** "Create a task. Each job must have an owner. Assign the work item to a reviewer."

**Write:** "Create a task. Each task must have an owner. Assign the task to a reviewer."

Apply it to verbs too. If `validate`, `check`, and `verify` name the same
operation, pick one and use it everywhere. If they name different operations,
define each one.

**Method:** list every domain noun and verb in the document. Any two that could
be the same thing are a defect until proven otherwise.

## 2 — One instruction per sentence, in the imperative

A sentence carrying three actions gets partially executed. Models drop middle
items in long contexts, and the omission is hard to detect afterward because the
sentence "was addressed."

**Instead of:** "Validate the input and write the result to the output directory and notify the user of any errors."

**Write:**

```
1. Validate the input.
2. Write the result to the output directory.
3. Tell the user about any errors.
```

Numbered steps also give the model and the user a shared vocabulary for
referring to one specific part of the procedure.

## 3 — Constraints before the step, with the consequence attached

STE requires warnings and cautions to appear ahead of the procedure they govern,
in the imperative, and to state what happens if ignored. All three parts matter.

A constraint placed after the step is read after the model has already started
acting on it. And a bare prohibition is weaker than one with a stated reason — a
model that knows why a rule exists can apply it to cases the author did not
anticipate.

**Instead of:**

```
Run the migration script. Note that this must not be run against production.
```

**Write:**

```
Do not run the migration script against production. It drops and recreates
every table, and there is no rollback.

Run the migration script against the staging database.
```

## 4 — Break conditional logic into a vertical list

Nested conditions written as prose force the reader to hold a truth table in
working memory. Models drop branches under that load. A vertical list makes each
case separately visible — and makes a missing case obvious to the author too.

**Instead of:** "If the file exists and is not empty, parse it, unless it's in the legacy format, in which case convert it first, but only if the user has write access."

**Write:**

```
Check the file before you parse it:

- File does not exist, or is empty -> stop and tell the user.
- Current format -> parse it.
- Legacy format, user has write access -> convert it, then parse it.
- Legacy format, user has no write access -> stop and tell the user.
```

Writing the cases out often reveals a branch the prose version never specified.
That is the main reason to do it.

## 5 — Name the actor

Passive voice hides who performs the action. In an agent instruction that gap
becomes a decision the model has to guess at.

**Instead of:** "The configuration is validated before deployment."

**Write:** "Validate the configuration before you deploy." (agent acts)

**Or:** "The user validates the configuration before you deploy." (user acts)

The point is not a stylistic preference for the active voice. Every action needs
a named actor. Keep the passive where the actor is stated and the sentence reads
better that way.

## 6 — Limit noun clusters to three words

Stacked nouns have more than one valid parse and English gives no signal about
which one is meant. Insert prepositions to fix the structure.

**Instead of:** "agent skill instruction file format validation"

**Write:** "validation of the file format for agent skill instructions"

This costs tokens and is worth it.

## 7 — Do not compress by deleting structure

STE forbids telegraphic style. Instruction authors often strip articles,
prepositions, and connectives to save tokens, which removes exactly the cues
that disambiguate structure.

**Instead of:** "On error, retry — max 3, backoff exp, then escalate user"

**Write:** "If the operation fails, retry it up to three times with exponential backoff. If it still fails, escalate to the user."

Being brief and being compressed are different things. Cut whole sentences that
carry no instruction. Do not cut the words that hold a sentence together.

## 8 — Treat long sentences as a smell, not a hard limit

STE caps procedural sentences at 20 words and descriptive sentences at 25. Use
the number as a signal rather than a rule: a sentence that runs long has almost
always accumulated a second instruction or a hidden condition.

When a sentence goes long, ask what is buried in it. The fix is usually rule 2
or rule 4, not trimming words.
