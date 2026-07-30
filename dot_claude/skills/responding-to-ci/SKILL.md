---
name: responding-to-ci
description: Get a PR's failing CI green. Use when a PR has red checks and you want them fixed ("CI is red", "fix the failing checks", "the build is broken on this PR", a failing GitHub Actions run URL). Triages each failing check, then drives the fix. Read-only on CI; never reruns or pushes on its own. This is the procedure `pick-up-work` routes into for its ci-fix arc; it does NOT open your own PR (that's create-pr) or review someone else's (review-pr).
---

# Responding to CI

Procedure for "a PR has red CI, get it green". Its sole job is CI failures,
nothing broader: it doesn't refactor, add features, or touch code unrelated to a
failing check. It is an orchestrator: it triages the checks, then calls the
skills that own each part.

- **`debugging`** validates the cause of a failure when the cause is in doubt
  (a real test/build failure whose reason isn't obvious).
- **`writing-code`** applies the fix once the cause is known (the edit and its
  pre-delivery verify gate). The commit/push around it stays with
  **`pick-up-work`**'s conventions and safety gates.

This skill itself does neither the root-cause validation nor the fix; it decides
which failures are worth fixing, routes each to the right skill, and reports.
The input is the PR. `pick-up-work`'s ci-fix arc invokes this skill for the
triage; when the fix is ready it hands back to `pick-up-work` for the commit.

## Step 0 — tools on PATH

Non-interactive shells here often lack the mise tools; `jira`/`dp` need the
`work` profile. Try `gh`/`pup` directly, fall back to `mise exec -- <tool>`.

## Procedure

1. **Get the failing checks.** `gh pr checks <pr>` to list the red ones. The cwd
   usually already sits on the PR's branch, so no number is needed; confirm with
   `git branch --show-current`. Reading CI (checks, runs, logs) is allowed and
   prompts nothing.
2. **Pull the failure detail.** For each failing check, read the failing logs:
   `gh run view <run-id> --log-failed`. The checks are independent, so read
   their logs concurrently; if the count is high or a cause isn't obvious, fan
   the triage out to a subagent per failing check (each reads its own logs and
   returns a classification with the one-line reason). That per-check triage is
   mechanical (read logs, bucket the failure), so run it on a cheaper model
   (`model: 'haiku'` on the Agent call); the judgment that follows
   (root-causing an in-doubt failure via `debugging`, writing the fix via
   `pick-up-work`) keeps the strong model. The fixing in step 3 stays serial:
   it mutates the shared working tree, so apply changes one at a time.
3. **Triage each failure into one of:**
   - **flaky / infra** (timeout, runner died, network blip, transient registry
     error): mark it as such and STOP on that check. Don't touch code.
     Re-running is your decision (`gh run rerun` prompts), so surface it, don't
     run it.
   - **cause obvious** (lint, format, an explicit type error, a missing import):
     the cause is known, so skip debugging and go straight to the fix via
     `writing-code`.
   - **cause in doubt** (a real test failure or build break whose reason isn't
     clear): call `debugging` to validate the root cause first, then hand the
     validated cause to `writing-code`.
4. **Verify locally before claiming.** After a fix, re-run the same check
   locally that failed (the lint, the test, the build) and confirm it passes. A
   fix you didn't re-run is not done.

## Output

Chat response, voiced via `writing` for any prose. Lead with the verdict per
failing check, grouped so you see at a glance what was fixed, what is flaky, and
what still needs you. For each check:

- **check name** -> classification (flaky/infra | fixed | needs decision), and
  the one-line reason.
- For a fix: what changed and that the check passes locally now.
- For flaky/infra: say so and note that a rerun is your call (it wasn't
  triggered).

Close with anything left for you: checks to rerun, a fix that needs a decision,
or the push (which is yours). Say "all green locally" plainly only if you re-ran
and confirmed it.

## Scope and safety

Read-only on CI: inspecting checks, runs, and logs prompts nothing. State
changes stay with you: `gh run rerun` is human-gated (never rerun
automatically), and `git push` is too (the fix is delivered locally; the push is
yours). Never merge. If getting a check green needs a change beyond the failing
check's scope, stop and surface it rather than widening the work.

## Before delivering

Confirm each failing check was triaged and each fix was actually re-run locally
and passed, not assumed. Don't claim CI is green from a local run alone if the
failure could be environment-specific; say what you verified and how. Don't
rerun CI or push; those are yours.
