---
name: writing-code
description: Implement a code change well, and adversarially self-review it before calling it done. Use when the task is to build, implement, fix, refactor, or change code, with or without a slash command; trigger on "implement X", "fix this", "add Y", a ticket asking for a code change. Owns the code-writing discipline (match patterns, reuse, tests) and the pre-delivery review gate (fan out fresh reviewers over the full body of every touched function, verify each finding against the source, resolve confirmed ones before delivering). pick-up-work's implement arc and responding-to-ci route into it; it does NOT own the worktree/commit/PR arc (that's pick-up-work) or reviewing someone else's PR (review-pr).
---

# Writing code

Procedure for writing a code change and proving it's sound before it leaves your
hands. This skill owns two things: writing the change to match the codebase, and
the adversarial self-review gate before delivery. It does NOT own the arc around
that: getting the ticket and context (`gather-context`), the worktree, commit
conventions, push gating, and the PR (`pick-up-work` and `create-pr`). Those
call into this skill for the edit-and-review, then resume.

## Step 0 — tools on PATH

Non-interactive shells here often lack the mise tools; `jira`/`dp` need the
`work` profile. Try `gh`/`pup`/`bun` directly, fall back to `mise exec -- <tool>`.

## Before coding

1. **Get the ticket and its context first.** Invoke `gather-context` for the
   ticket and its full chain (linked issues, parent/epic, and, if the ticket
   came from an investigation, that investigation's ticket AND its PR/document).
   Don't start coding until its gate passes; scope and acceptance criteria come
   from it.
2. **Read the surrounding code and existing patterns before writing**, so the
   change matches what's there. Reuse what exists instead of adding new.

## Code-specific rules

- **No comments unless the "why" is non-obvious.** A comment that restates what
  the code already shows is noise. Match the neighbors' comment density and
  length; don't pair a doc comment with inline comments that repeat it. The bar
  is the non-obvious why, nothing else.
- **Reuse existing packages, helpers, utilities.** If one exists for what you
  need, use it; don't write a parallel implementation.
- **Follow the reference code's reusable shape.** When you model new code on
  existing code, match how that reference is structured. If it lives in a
  shared/reusable package, write yours the same way, not as an inline copy
  buried in one caller.
- **Match the file's naming, style, idioms, and declaration order** (read a
  neighbor before writing). Don't impose an order the file doesn't have.
- **Tests for non-trivial new logic.** When you add logic with branches, edge
  cases, parsing, or anything whose failure only surfaces at runtime, add unit
  tests in the same change, following the repo's existing test pattern, and say
  you did and why. Two limits: only if the repo already tests that kind of code
  (don't introduce a framework where there's none), and not for trivial changes
  (config, rename, wiring). If Brian says no tests, skip them.
- **Don't silently drop existing behavior.** Removing or changing behavior
  something may depend on (a retry, an error path, a fallback, a default) is a
  serious change, not a cleanup: call it out and confirm it's intended.
- **Human-facing text says what the code observes, not the cause it presumes.**
  When authoring an alert, log, error message, or comment, separate what is
  measured from what may have caused it. A symptom-based check (running-vs-
  desired tasks, healthy-host count) must not claim to detect the root cause;
  describe the symptom and list possible causes.

## Before delivering: the verify gate

Two layers, both required, before the change is done.

### 1. Run the repo's own checks, not a proxy for them

Your verify gate is the exact checks the repo and its CI enforce, discovered
from source (`Makefile` targets, `.golangci.yml`, the CI workflow), and actually
run: e.g. `make lint-local` / `golangci-lint run`, not `go vet` alone (`go vet`
doesn't run staticcheck, so it misses rules like ST1005). A hand-picked subset
you assume is equivalent is not the gate; read the config to know what actually
runs, then run that. Confirm the change satisfies the acceptance criteria and
nothing beyond them.

### 2. Adversarial review (non-trivial changes)

For any change with real logic, infra, or CI (not a rename/config one-liner),
don't rely on your own re-read alone — you're blind to your own decisions. Fan
out fresh subagent reviewers over the diff, no stake in how you wrote it, to
hunt for what authors miss and Copilot catches. Scope each reviewer to the
**full body of every function the diff touches, not just the changed hunk**: a
pre-existing defect (an ignored `err`, a missing escape) inside a function you
edited is in scope the moment you touch it, and a hunk-scoped read walks past
it. Dispatch them in one message, each owning one dimension, returning
`file:line` plus why:

- **Correctness / runtime bugs:** ask two separate questions of every path —
  *can it crash* (nil, panic, deref) and *can it return a wrong-but-valid
  answer* (a truncated page returned as complete, a partial result treated as
  the full set, an opaque server value fed back unescaped). "Breaks safely" is
  not "returns the right result"; hunt the second as hard as the first. Also:
  dead code left beside an edit, checks that don't actually cover their case
  (`git diff --exit-code` missing untracked files), behavior silently dropped,
  config parsed at runtime.
- **Test quality:** flaky tests, assertions that depend on timing, real
  `sleep`/wall-clock, or goroutine scheduling rather than a deterministic signal
  (the kind that pass locally and fail in CI).
- **References and external refs:** mutable or inconsistent refs (a `@main` ref
  where the repo pins versions); a path, URL, or runbook link the change emits
  that doesn't exist on the base branch, with the cross-PR merge-order
  dependency not flagged.
- **Human-facing text:** an alert, log, or error message (or comment) that
  overstates behavior, asserting a cause the code doesn't observe.

Then **validate each finding against the real code before acting on it.** When
the agents return, open the file and confirm each issue is actually present;
don't accept or dismiss a finding from assumption. Apply the confirmed ones and
re-review.

### The two triage traps (both banned)

- **"Pre-existing pattern / consistent with the neighbors" is not a dismissal.**
  That discount is only valid when your change doesn't alter reachability. If
  your edit makes a latent issue newly reachable (a new pagination loop feeding
  a server-controlled cursor back into a URL, a new caller-controlled value into
  an unescaped param), it's in scope and yours to fix, no matter how many
  neighbors share the pattern. *Where* a bug's code lives is not *when* it
  became reachable. Any change of cardinality on something concurrent or shared
  (1→N workers on one `WaitGroup`, 1→N writers, 1→N callers of a partial-failure
  path) is a reachability change until you've traced the failure modes and shown
  otherwise.
- **Weight an independent reviewer's severity above your own authorship bias.**
  When a fresh reviewer rates something and you want to downgrade it, the burden
  is on you to refute their argument *at the code*, not to invoke consistency or
  intent. If you can't refute it, their severity stands.

**A confirmed finding is a blocker to resolve, not a note to ship with.**
Flagging a risk in a comment or PR note is not resolving it: "keep this below X"
next to a value that isn't below X is still a bug. If the review confirms a
value is wrong (a timeout exceeding the pod's grace window), verify the real
constraint at its source (that's `gather-context`'s infra step) and set a safe
value before delivering. The value leaves your hands correct, or it doesn't
leave. If you consciously choose not to fix a confirmed finding, that's an
explicit, argued exception, and it appears at minimum in the PR description;
silently dropping it isn't allowed.

## Handing off

Once the change passes the gate, hand back to the caller: `pick-up-work` owns
the commit (conventional-commit, one line, no body, no Co-Authored-By), the
push gating (human-triggered, never on your own), and the PR via `create-pr`.
Don't offer to commit or push from here.
