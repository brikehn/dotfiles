#!/usr/bin/env bash
# Read-only triage of dependency/security bot PRs and Dependabot security alerts
# for one repo. Emits a single JSON object the bot-triage skill consumes and
# turns into a report. Does only authenticated GETs via `gh` (pr list, repo
# view, dependabot/alerts); no writes, no merges, no comments. Keep it read-only:
# the skill relies on that to run it without a state-change prompt.
#
# Deployed by chezmoi to ~/.claude/skills/bot-triage/bot-triage.sh; the skill
# calls it by that absolute path.
#
# Usage: bot-triage.sh <owner/repo>
#
# Bots are recognized by author.is_bot plus title pattern, because one bot
# author (github-actions) opens very different PRs (Frogbot security, SDK gen,
# release, mise) and Frogbot has no identity of its own (its PRs are opened by
# github-actions and identified only by the "[Frogbot]" title).
set -euo pipefail

REPO="${1:-}"
if [ -z "$REPO" ]; then
  echo "usage: bot-triage.sh <owner/repo>" >&2
  exit 2
fi
# owner/repo only: no flags, URLs, or shell metacharacters reaching gh.
if ! printf '%s' "$REPO" | grep -qE '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$'; then
  echo "error: '$REPO' is not a valid <owner/repo>" >&2
  exit 2
fi
command -v gh >/dev/null 2>&1 || { echo "error: gh CLI not found" >&2; exit 1; }

# Validate the repo exists and is readable before doing anything else.
if ! gh repo view "$REPO" >/dev/null 2>&1; then
  echo "error: cannot access repo '$REPO' (typo or no permission)" >&2
  exit 3
fi

# --- pull requests -----------------------------------------------------------
# One call gets author, is_bot, draft, and the check rollup. Classify each bot
# PR into a section and flag the security ones.
prs="$(gh pr list --repo "$REPO" --state open --limit 100 \
  --json number,title,author,isDraft,url,statusCheckRollup 2>/dev/null \
  | jq '
    def section:
      (.author.login // "") as $a | (.title // "") as $t |
      if   ($a | test("dependabot"))      then "dependabot"
      elif ($t | test("frogbot"; "i"))    then "frogbot"
      elif ($a | test("renovate"))        then "renovate"
      elif ($t | test("update sdk"; "i")) then "sdk-gen"
      elif ($t | test("release"; "i"))    then "release"
      elif ($t | test("mise"; "i"))       then "mise"
      else "other-bot" end;
    def is_security:
      (.title // "" | test("\\[security\\]"; "i")) or (.title // "" | test("frogbot"; "i"));
    def checkstate:
      [ .statusCheckRollup[]? | ((.conclusion // .state // "") | ascii_upcase) ] as $c |
      { total:   ($c | length),
        failure: ([ $c[] | select(. == "FAILURE" or . == "ERROR" or . == "CANCELLED" or . == "TIMED_OUT" or . == "ACTION_REQUIRED") ] | length),
        pending: ([ $c[] | select(. == "PENDING" or . == "IN_PROGRESS" or . == "QUEUED" or . == "EXPECTED" or . == "") ] | length),
        success: ([ $c[] | select(. == "SUCCESS") ] | length),
        skipped: ([ $c[] | select(. == "SKIPPED" or . == "NEUTRAL" or . == "STALE") ] | length) }
      | . + { state: ( if .total == 0 then "none"
                       elif .failure > 0 then "failing"
                       elif .pending > 0 then "pending"
                       else "passing" end ) };
    [ .[]
      | select((.author.is_bot == true) or (.title // "" | test("frogbot"; "i")))
      | { number, title, url, author: (.author.login // ""), draft: .isDraft,
          section: section, is_security: is_security, checks: checkstate } ]
  ')"

# --- security alerts ---------------------------------------------------------
# Dependabot alerts may be disabled (403/404) or empty; treat that as
# "unavailable" rather than failing the whole triage.
alerts="null"
if alert_raw="$(gh api --paginate "repos/$REPO/dependabot/alerts?state=open&per_page=100" --jq '.[]' 2>/dev/null)"; then
  alerts="$(printf '%s' "$alert_raw" | jq -s '
    { total: length,
      by_severity: ( [ .[].security_advisory.severity ] | group_by(.)
                     | map({ key: .[0], value: length }) | from_entries ),
      items: [ .[] | {
        number, severity: .security_advisory.severity,
        package: .dependency.package.name, manifest: .dependency.manifest_path,
        ghsa: .security_advisory.ghsa_id, url: .html_url,
        fixed_in: (.security_vulnerability.first_patched_version.identifier // null) } ] }
  ')"
fi

# Page where the alerts are viewed, so the report can link to it.
security_url="https://github.com/$REPO/security/dependabot"

jq -n --arg repo "$REPO" --arg security_url "$security_url" \
  --argjson prs "${prs:-[]}" --argjson alerts "$alerts" \
  '{ repo: $repo, security_url: $security_url, pull_requests: $prs, alerts: $alerts }'
