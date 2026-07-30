---
name: debugging
description: Find and validate, with evidence, the root cause of a specific failure (a failing test, error, stack trace, crash, wrong output). Use when something is broken and the cause is NOT yet known, or when another skill needs a cause validated before a fix. Diagnoses only, does not write the fix. Trigger on "why is this failing", "find the root cause", "figure out what's breaking this", a pasted stack trace or error with "what's causing this". NOT for when the cause is already known and you just need to write the change (that is implementation via pick-up-work), nor for producing a design/analysis doc.
---

# Debugging

Procedure for finding why a specific thing fails and proving it. This is the
"verify, never assume" instinct turned on a failure: no cause is stated without
evidence that confirms it.

Two ways it runs, same procedure:

- **On its own:** you hand me a failure ("this is broken, find out why").
- **As a called capability:** another skill needs a cause validated before
  acting. `responding-to-ci` calls it to validate a CI failure's cause;
  `datadog-audit` fans it out to root-cause an error whose attribution is in
  doubt; `pick-up-work` reaches for it when a change's failure needs root-cause
  work before the fix. This skill owns the root-cause method in one place;
  callers reuse it rather than re-deriving it.

The boundary is the same either way: **this skill validates the cause and stops.
It does not write the fix.** Implementation (`pick-up-work`) applies fixes; the
caller or the user takes the validated cause from here and fixes from there.

When NOT to use this skill: if the cause is already known and the work is just
to write the change, that is implementation directly (`pick-up-work`), not this.
Debugging earns its place only when the cause is in doubt; reach for it to
*establish* the cause, not to fix a failure you already understand.

## Step 0 — tools on PATH

Non-interactive shells here often don't have the mise-managed tools on PATH, and
`jira`/`dp` live in the `work` profile. Try `gh`/`pup`/`bun` directly; fall back
to `mise exec -- <tool>`, and `MISE_ENV=work mise exec -- jira ...` for JIRA.

## Procedure

1. **Reproduce first.** Get the failure to happen on demand (the failing test,
   command, input, or steps). If it cannot be reproduced, that is the first
   finding: report it and stop, don't proceed blind on a failure you cannot
   trigger.
2. **Isolate.** Narrow *where* it happens before theorizing: read the actual
   error/stack, add or read logs, bisect the diff or commits (`git log -S`,
   `git bisect`, `git blame`), shrink the input. Reduce the surface until the
   failure points somewhere specific.
3. **Hypothesis then verify.** Form one candidate cause at a time and confirm it
   with evidence (a log line, a value observed, the test passing when the
   suspected input changes), never "this should be it". A hypothesis you didn't
   confirm is not the cause. For a prod failure, the evidence often lives in
   Datadog: query it with `pup` (`pup logs search`, `pup logs aggregate`,
   `pup error-tracking issues get`) rather than reasoning from the symptom.
4. **Root cause, not symptom.** Distinguish the underlying cause from where it
   surfaced. If the evidence only supports a surface patch and not the true
   cause, say so explicitly rather than dressing a symptom as the cause.

## Output

Chat response, in the register the `writing` skill defines when the narration is
attributed to you (hedging is fine here, this is investigation). Lead with the
root cause in one line, then the evidence that proves it, then the context a
fixer needs:

- **Root cause:** the one-line cause, stated plainly.
- **Evidence:** what you observed that confirms it (the reproduction, the
  log/value, the bisect result), each something you actually checked, not
  inferred.
- **Where:** the file/function/line and the failing path.
- **Fix direction (not the fix):** what would have to change, enough for the
  caller or `pick-up-work` to act. Do not apply it here.

If you couldn't reproduce or couldn't confirm a single cause, say so plainly and
give the most-supported hypotheses with what evidence each still needs. Don't
present an unconfirmed guess as the cause.

## Before delivering

Confirm the root cause is backed by evidence you actually observed, not
reasoning alone. Re-check that the cause, if removed, would actually stop the
failure. Don't claim a cause you didn't reproduce or confirm; an honest
"narrowed to X, not yet confirmed" beats a confident wrong cause. This skill does
not write or apply the fix; hand the validated cause to the caller.
