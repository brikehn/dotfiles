---
name: datadog-audit
description: Audit Datadog errors and error logs for a set of services: surface what is failing (volume, spikes, top issues), group by recurrence, and judge attribution (ours vs downstream/client/noise). Use whenever you ask what is failing in Datadog, to audit/triage service errors, check error volume or spikes, or review Datadog error-tracking ("what's erroring in prod", "audit extend-api errors", "any spikes today"), with or without a slash command. Read-only via `pup`; fans out debugging subagents in parallel to root-cause errors whose cause is in doubt, and feeds jira-ticket (a separate, you-triggered step) for a recurring, attributable error.
---

# Datadog Error Audit

Reads Datadog error-tracking and error logs for a set of services through the
`pup` CLI, analyzes the errors (group repeats, judge whether each is our failure
or an external one), and reports a diagnosis per service. Verify never assume,
read-only for external systems unless asked, concise.

This skill surfaces, groups, and attributes what's failing, then stops. It
diagnoses only; it never writes a fix (that's implementation, out of scope).
Two chains out of it:

- **Root cause, fanned out during the audit (not yours to trigger):** when an
  error's cause is genuinely in doubt after the attribution pass (the logs and a
  quick local code read still don't settle whether it's ours), that error gets a
  `debugging` subagent. These are independent judgment per error type, so fan
  them out in parallel, one subagent per in-doubt error type, dispatched in a
  single message once the attribution pass has flagged them, and let them run
  while you finish attributing the rest. `debugging` owns the reproduce ->
  isolate -> hypothesis+verify method; don't restate or re-derive it here. Each
  returns a validated cause (or a most-supported hypothesis with what it still
  needs); that's a claim to verify against the source yourself before it lands in
  the report, never a fact to repeat. This skill still doesn't fix, it folds the
  verified cause into the attribution.
- **Ticket, yours to trigger:** for a recurring error judged attributable to us,
  the report marks it a ticket candidate and, at the end, offers to open the
  ticket. On your yes, chain to `jira-ticket` (which produces the ticket; the
  actual create still prompts separately). Don't draft the ticket inside this
  skill and don't file one without that yes. Errors judged external (a
  downstream/partner 500 we merely surface, expected client noise) are reported
  as such, not ticketed.

## Tool: `pup` (read-only)

Queries run through `pup`, Datadog's CLI. It emits JSON by default; parse with
`jq`. Only its read subcommands are used. If the tool isn't on PATH, fall back to
`mise exec -- pup ...`.

If `pup auth status` reports not authenticated, stop and say to run
`pup auth login` (an interactive browser OAuth flow you run yourself); don't
attempt the audit against an unauthenticated CLI.

Follow `pup`'s own usage guidance: always pass `--from` on a query; count with
`logs aggregate --compute=count`, never by fetching raw logs to count them; start
with a small `--limit` and refine; APM durations are in nanoseconds. When the
report cites a `pup` command to rerun yourself, append `--no-agent` (outside this
session `pup` emits raw JSON, not the agent envelope, so the citation matches
what you'll see).

Command shapes verified against `pup` 1.6.0 (the `--help` JSON is wrong on some
of these; these are what the CLI actually enforces):

- **Time format** is bare relative (`1h`, `30m`, `7d`), an RFC3339 stamp, or a
  Unix timestamp. `now-7d` is rejected.
- **`error-tracking issues search`** requires `--state`, `--from`, `--limit`, and
  exactly one of `--track` (`trace`|`logs`|`rum`) or `--persona` (mutually
  exclusive; passing both errors). Use `--track trace` for backend services. It
  returns only issue `id` + `total_count`; there's no title in the search result.
- **`error-tracking issues get <id>`** resolves an id to its attributes:
  `error_type`, `error_message`, `service`, `file_path`, `function_name`,
  `state`, `first_seen`/`last_seen`. No `title` field; identify an issue by
  `error_type` + `error_message`.
- **`logs aggregate`** output is at `.data.buckets[].computes.c0` (the compute is
  keyed `c0`), with the group value under `.by`. A `--group-by <facet>` only
  returns buckets when that facet is actually emitted by the service: many
  backend services log plain `msg`/`stacktrace` and have no `@error.type`, so
  grouping on it yields zero buckets. Confirm the facet exists (probe with a
  small query) before relying on a group-by; don't report "no exceptions" when
  the facet simply isn't populated.
- **An empty result is data, not an error.** A `count` aggregate returns
  `.data.buckets: []` (no `[0]`) when nothing matches, e.g. a service that
  emitted only `info`/`warn` in the window. Read that as 0 errors (the service
  isn't failing), not as a failed query. The `-status:(...)` exclusion and quoted
  parentheses pass through the shell inside `--query "..."` as-is.
- **`monitors search`** takes a monitor-search `--query` (NOT a log query) and
  returns `.metadata.total_count` plus `.monitors[]` (each with `name`, `status`,
  `tags`). Firing = `status:alert`. Scope by tag with
  `tag:(service:<svc> OR ... OR team:<team>)`; a monitor carries whatever tags it
  was given, so a tag you assume may match nothing (confirm before trusting a
  zero, see the pre-pass).
- **`slos list`** takes a free-text `--query` (matches the SLO name/description)
  and returns `.data[]` with `id`, `name`, `type` (`metric`|`monitor`);
  `.metadata.total_count` is null, count `.data` yourself. **`slos get <id>`**
  returns `.data.thresholds[]` (target + timeframe). **`slos status <id> --from
  <t> --to now`** returns the attainment for the window but errors
  `400 "overall denominator (total events) is 0"` when the SLO saw no events in
  it, that's "no traffic", not a broken query, and often means the SLO is scoped
  to a different env than you're auditing.

## Service set

The services to audit are a personal choice, like bot-triage's repo list. There's
NO default in the repo: the list lives only in memory (see [[datadog-services]]),
and only once you've chosen to save one. It is not project config.

1. Resolve the list, in order: services named in this invocation win for this
   run; else the saved memory list if one exists; else ask, because nothing is
   seeded by default. Never guess service names.
2. Persist only on request: if you ask to remember the list, write/update the
   `[[datadog-services]]` memory file. Don't create it unprompted.

## Procedure

Work over a time window that defaults to the **last 24h** unless you specify a
date/range (state the window you used). The services are independent, so run the
per-service gather concurrently (issue the `pup` reads for all services together
and collect the results); then analyze and attribute each yourself.

**The error filter (the base query):**
`env:production -status:(info OR warn OR notice OR debug OR ok) service:<svc>`.
Exclude the non-error levels rather than matching `status:error`, so any error
severity is caught, not only the literal `error` label. The ONLY part that
changes per service is `service:<svc>`; keep the rest verbatim. Pass it to `pup`
as `--query "<that>"`. Add `env:<other>` only if you audit a non-production env.

### Firing monitors (a domain-level pre-pass)

Error logs aren't the only signal that something's failing: a service can be
quiet in logs while a monitor the team already tuned is firing (an SLO burn, a
latency threshold, a Temporal/Kafka backlog that emits no error line). So before
the per-service log gather, run one monitors read across the whole service set
and let it inform priority and attribution. Don't report a service as healthy on
a log count of 0 when a monitor for it is in `alert`.

Build the filter from the **service list you already resolved**, OR-ing their
`service:` tags:
`pup monitors search --query "tag:(service:<svc1> OR service:<svc2> OR ...) status:alert" --per-page 20`,
reading `.metadata.total_count` and `.monitors[]` (`name`, `status`). This is one
read for the run, not per service. A firing monitor names, in the team's own
words, what they consider broken and at what threshold, carry it into the report
and raise the priority of the service it points at.

A `team:<team>` tag can widen the net to monitors not tagged by service, but the
team is NOT a default and is NOT hardcoded, resolve it exactly like the service
list (this invocation wins, else the saved `[[datadog-services]]` memory if it
records one, else ask; persist only on request). Whatever tag you use, confirm it
actually matches before trusting a zero: probe once without `status:alert`, since
a team's tag is often not the label you'd guess. If no team is resolved, the
`service:`-only filter above is enough on its own.

### Gather (per service)

- **Error volume:** `pup logs aggregate --query "<base query>" --from "24h" --compute "count"`,
  reading `.data.buckets[0].computes.c0`. Count via aggregate, not by listing
  logs. A count of 0 is a real, reportable "not failing", not an error.
- **By HTTP status (the default breakdown):** `pup logs aggregate --query "<base query>" --from "24h" --compute "count" --group-by "@httpResponse.status" --sort count --limit 10`.
  500s vs 4xx tells attribution apart at a glance. Only relied on when the facet
  returns buckets.
- **Then by operation (the drill-down that localizes it):** when the status
  breakdown shows a real error class, re-run the aggregate on that narrowed
  status grouped by operation: `pup logs aggregate --query "<base query> @httpResponse.status:500" --from "24h" --compute "count" --group-by "@operationID" --sort count --limit 10`.
  One operation usually owns almost all of it, which both names the endpoint to
  attribute and is itself the recurrence count. Only when the service emits
  `@operationID`; skip if the facet returns no buckets.
- **Open error issues (the exception view):** `pup error-tracking issues search --state OPEN --from "24h" --limit 10 --track trace --query "service:<svc>" --order-by TOTAL_COUNT`,
  then resolve the top few ids with `pup error-tracking issues get <id>` for
  `error_type` + `error_message`. Already grouped by exception, useful when raw
  logs lack an `@error.type` facet.
- **Spikes:** compare the window's count against a prior equal window (last 24h
  vs the 24h before, via `--from "48h" --to "24h"`), or an obvious jump in a
  status/issue count. State it as a comparison you actually ran, not an
  impression.
- **A specific slice** (an endpoint, a client, an operation): use your own log
  query verbatim in `--query`, grouping by a facet that slice emits.
- **The actual error logs to analyze:** pull the recurring error's own log lines
  (`pup logs search --query "<base query> <narrowing>" --from "24h" --limit 20 --sort desc`)
  and read their `msg`, `stacktrace`, `@error`, and any `@http*` fields.
  Attribution is judged from these, so you need the real lines, not just the
  count. Keep `--limit` small; don't dump the whole set.
- **SLO burn (only when a service has an SLO and its logs look clean or a monitor
  points at it):** an error burning an error budget is worth acting on even at a
  low raw count. Discover the SLO with `pup slos list --query "<service name>"`,
  read its target with `pup slos get <id>`, and check the window with
  `pup slos status <id> --from "7d" --to now`. A `400 "denominator ... 0"` means
  the SLO saw no events in the window (no traffic, or it's scoped to a different
  env than you're auditing). Optional depth, not a required per-service read.

Verify, don't assume: every count, spike, and top issue you report comes from a
`pup` result you actually ran this session, not from memory or inference. If a
service returns nothing (no errors, or no access), say so for that service rather
than omitting it.

### Analyze (per service): recurrence, then attribution

The raw count isn't the finding. For each service, two questions decide what (if
anything) is worth acting on:

1. **Is it the same error, or many?** Group before concluding: N occurrences of
   one identical error (same `error_type` + `error_message`, or one
   error-tracking issue with a high `total_count`) is ONE problem, not N. Say
   "one recurring error, X times" rather than "X errors". Attribute only the
   recurring ones; a one-off is noise unless you ask.
2. **Is it ours, or an external service's?** Judge from the actual error lines,
   and say which and why. A stack in our code, a validation we raise, a panic we
   own points to us; a non-2xx from a downstream or partner call, a client
   sending malformed input, a dependency timeout points elsewhere. When the log
   is opaque (no stacktrace, no `@error`, just a generic "500 Server Error"), the
   log alone doesn't settle it: confirm which code path emits it by reading the
   owning service's repo **locally**.
   - Prefer the local clones under [[projects-root]] (`~/repos/dailypay`),
     grepping the message/endpoint there, over more `pup`/API calls: the goal is
     to attribute without hammering the API, and the same service often spans
     multiple repos. If the repo isn't cloned, note that rather than guessing.
   - This is a light attribution read (which side raises the error), not a
     root-cause investigation. If a local read still doesn't settle it, hand that
     error to a `debugging` subagent (fanned out in parallel, per the intro)
     rather than doing the deep reproduce/isolate here; its verified cause, once
     you confirm it against the source, upgrades the tag from UNESTABLISHED to
     OURS/EXTERNAL. An error still unsettled after debugging stays UNESTABLISHED,
     carrying debugging's most-supported hypothesis.
   - Never assert a cause the evidence doesn't support. "Ours" and "external" are
     both claims you must be able to point at (a stack frame, a downstream
     status, a repo line).

A ticket candidate is an error that's both **recurring** and **attributable to
us** (or otherwise needs our action). A firing monitor or a burning SLO on a
service is itself "needs our action" even when the raw log count is low, treat it
as a candidate on the same footing, attributing it the same way. Mark those;
external and unestablished errors are reported with their tag but aren't
candidates.

## Output

Chat response, voiced via `writing` for any prose. Lead with substance. If any
monitor is firing, open with a one-line **Firing monitors:** roll-up
(`<name> (<service>)`, or "none") so the team's own alarms lead; then the
per-service sections. Order services worst-first (a firing monitor or a real
spike at the top, then highest volume). Shape per service:

```text
**<service>**  <- firing: <monitor name> | (no line if none)
Volume: <count> errors over <window><, spiking vs <baseline> | , flat>

- <error_type>: <short error_message>, one recurring error x<count> [OURS: <the stack frame / repo line, or the cause debugging confirmed> | EXTERNAL: <the downstream status / client cause> | UNESTABLISHED: still unsettled after a debugging pass, with its most-supported hypothesis]
- <next issue...>

Ticket candidates: <error_type> (recurring + ours) | <monitor/SLO> (firing) | none
```

Keep it scannable: counts, issue identifiers, and the attribution tag with its
one-line evidence, no per-line prose. If a service returned nothing or was
inaccessible, keep its header with that one line so the gap is obvious. End with
one line stating the window audited. If nothing's failing across all services (no
errors and no firing monitor), say that plainly.

After the report, if there's at least one ticket candidate, offer to open a
ticket for it. Only on your yes, chain to `jira-ticket` (a separate turn/skill);
don't draft or file it otherwise. Debugging isn't a post-report offer here, it
already ran in-audit as a fanned-out subagent, and its result is folded into the
tags above.

## Scope and safety

Read-only on Datadog, always. Never create a case, submit a metric, or run any
`pup` write; those are remote mutations and aren't part of this audit. The local
repo reads for attribution are read-only greps of existing clones, not clones or
writes. Filing a ticket is a separate step via `jira-ticket` on your yes (and the
create still prompts on its own); this skill produces the report and the offer,
not the ticket.

## Before delivering

Confirm every service in the resolved list was audited (or its no-data / access
error reported), the firing-monitors pre-pass ran once for the set built from the
resolved services (and, if a team tag was used, it was confirmed to match so a
zero is real), the window is stated, every count, spike, and firing state came
from a `pup` result run this session (not memory), and each recurring error
carries a recurrence count and an attribution tag whose one-line evidence you can
point at. Confirm every in-doubt error got a fanned-out `debugging` subagent and
that any cause it returned was verified against the source before you tagged it.
Then stop; don't root-cause an error yourself outside that subagent, don't write
a fix, and don't draft or file the ticket without your yes.
