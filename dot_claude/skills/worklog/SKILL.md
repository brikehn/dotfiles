---
name: worklog
description: Use when the user asks to generate, update, or run their daily worklog / track record (e.g. "/worklog", "run worklog", "generate my worklog for today", "catch up my worklog"). Gathers GitHub (dailypay org) PR/review/commit activity, JIRA ticket activity, Confluence page activity, Slack (channels+DMs) messages, and Datadog on-call/incident activity for Brian Kwon, correlates related items into connected bodies of work (Slack thread -> JIRA ticket -> PR -> doc), and writes one markdown file per day to ~/worklog/YYYY-MM-DD.md for later self-assessment writeups.
---

# Daily worklog

Builds a per-day track record of Brian's work by pulling from GitHub, JIRA, Confluence, Slack, and Datadog, then correlating related items into connected "bodies of work" rather than five flat lists. Output feeds future self-assessments — bias toward capturing what happened and why it mattered, not just raw event counts.

## Identity / scope
- GitHub: user `brikehn`, scoped to `org:dailypay` only (skip personal repos/orgs)
- JIRA: everything under `brian.kwon@dailypay.com` counts as work-related, no extra filtering
- Confluence: same account, cloudId `dailypay.atlassian.net`, pages created or contributed to
- Slack: channels + DMs, messages from Brian and threads he's active in
- Datadog: incidents/monitors/alerts Brian acked or was paged for (via `pup`)

## Date range
1. List `~/worklog/*.md` and find the most recent filename (`YYYY-MM-DD.md`).
2. If a date/range was passed as an argument, use that instead.
3. Otherwise, range = (day after last file) through today. If no prior files exist, default to just today.
4. If the resulting range spans more than ~10 days, tell Brian the range before pulling — that's a lot of API calls across five sources.

## Gather (parallel — independent tool calls in one message)

**GitHub** (via `gh`, scoped `org:dailypay`, date filters as `updated:>=YYYY-MM-DD`):
- Authored PRs: `gh search prs --owner dailypay --author brikehn --updated ">=<start>" --json number,title,repository,url,state,updatedAt`
- Reviewed PRs: `gh search prs --owner dailypay --reviewed-by brikehn --updated ">=<start>" --json number,title,repository,url,state,updatedAt`
- Issues involved in: `gh search issues --owner dailypay --involves brikehn --updated ">=<start>" --json number,title,repository,url,state,updatedAt`
- Commits (only if not already covered by the PRs above): `gh search commits --owner dailypay --author brikehn --author-date ">=<start>" --json sha,commit,repository,url`

**JIRA** (via `jira`):
- If unsure of current flags, run `jira issue list --help` first rather than guessing.
- Issues assigned to, reported by, or touched by Brian, updated in range, e.g.:
  `jira issue list -q "(assignee = currentUser() OR reporter = currentUser()) AND updated >= '<start>'" --plain`
- For tickets that look load-bearing (tied to a PR or Slack thread found elsewhere), `jira issue view <KEY>` to pull the actual comment/transition narrative, not just the title.

**Confluence** (via `mcp__plugin_atlassian_atlassian__*` tools, `cloudId: "dailypay.atlassian.net"`):
- `searchConfluenceUsingCql` with `contributor = currentUser() AND type = page AND lastmodified >= "<start>"` (contributor catches edits, not just creation — pass CQL unescaped, no `&gt;=` HTML entities).
- For pages that look load-bearing (tied to a ticket/PR found elsewhere), `getConfluencePage` for the actual content, not just the title.

**Slack** (via `mcp__plugin_slack_slack__*` tools):
- Search Brian's messages and active threads in range, channels + DMs: `slack_search_public_and_private` with a query like `from:me after:<start>` (fall back to `slack_search_public` if private search errors).
- For any thread that references a PR/ticket found above, `slack_read_thread` for full context — this is what makes body-of-work correlation possible, not just a list of messages.

**Datadog** (via `pup`):
- If unsure of subcommands, run `pup --help` first. Look for incidents/alerts/on-call events involving Brian in range (e.g. incident list filtered by responder).
- Skip cleanly with a note if no relevant subcommand exists — don't guess at flags that might not exist.

## Correlate
This is the actual point of the tool — don't just concatenate four lists.

- Group items referencing the same JIRA key, PR number, or clearly the same piece of work (a Slack thread discussing a ticket that has a linked PR, a PR that closes an issue, an incident that spawned a follow-up ticket, a Confluence doc written up for a ticket or incident).
- For each connected group, write a short narrative: what started it (often a Slack ask or a ticket), what was done (PR, review, doc, incident response), and the outcome (merged, resolved, deployed, published).
- Items with no clear connection to anything else still get listed individually under their own source section — don't force false links.

## Write
One file per day at `~/worklog/YYYY-MM-DD.md`. If the range covers multiple days, split items by the date they actually happened (PR/issue updated date, Slack message timestamp, incident date), not by when the tool ran, and write one file per day.

Structure per file:

```markdown
# YYYY-MM-DD

## Bodies of work
- **<short title>**: <2-4 sentence narrative linking the Slack/JIRA/PR/incident items>
  - Refs: <PR links, JIRA keys, incident IDs>

## GitHub
- <PRs authored/reviewed, issues, not already covered above>

## JIRA
- <tickets touched, not already covered above>

## Confluence
- <pages created/edited, not already covered above>

## Slack
- <notable standalone messages/threads, not already covered above>

## Datadog / on-call
- <incidents/alerts, not already covered above>
```

If a section has nothing for that day, drop it rather than writing "None."

Keep prose plain and factual — follow the `writing` skill's voice rules for any narrative sentences (no em-dash, no arrow-chains, short and unpadded, don't oversell). This file is raw material for a future self-assessment, not the self-assessment itself.

## After writing
Report the file path(s) written and a one-line count (e.g. "3 bodies of work, 5 solo items"). Don't dump full file contents unless asked.
