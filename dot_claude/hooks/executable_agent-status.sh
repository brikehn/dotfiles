#!/bin/sh
# Writes this pane's agent state for the tmux status bar to read.
# Usage: agent-status.sh <working|blocked|done|ready|clear|track-start|track-stop>
# Keyed by TMUX_PANE so the tmux script can look state up per pane.
# "clear" removes the state file (call on SessionEnd) so a closed session
# doesn't leave a stale label until the next tmux status-bar cleanup pass.
#
# "track-start"/"track-stop" (called from SubagentStart/SubagentStop) add or
# remove a per-agent marker file under a pane-keyed tracking directory, so a
# top-level Stop that fires while a backgrounded subagent is still running
# doesn't get reported as plain "done". The marker's presence is only ever
# read, never cross-checked-then-written by another process — the derived
# "waiting" state itself is computed at read time in agent_status_lib.sh
# (agent_status_effective_state_for), not stored here. That avoids a race
# where a Stop and a same-instant track-stop could each check the other's
# stale value and leave the label stuck. agent_id comes from the hook's JSON
# stdin payload (jq '.agent_id'); see herdr-agent-state.sh for the same field
# used to detect subagent context.
#
# working/done skip the write if stdin carries an agent_id — PostToolUse
# (working) and Stop-adjacent events fire for a subagent's own tool calls too,
# and a subagent's tool call finishing shouldn't flip the pane back to
# "working" out from under a real "blocked"/"waiting" state on the interactive
# thread. "blocked" is the exception: a subagent's permission_prompt is a real
# wait-on-user, so it writes through even with an agent_id present, and the
# reader (agent_status_effective_state_for) ages it out by transcript mtime.

set -eu

state="${1:-}"
[ -n "${TMUX_PANE:-}" ] || exit 0

state_dir="$HOME/.cache/tmux-agent-status"
pane="${TMUX_PANE#%}"
tracking_dir="$state_dir/tracking-$pane"

case "$state" in
  working|blocked|done)
    # Read agent_id and (for blocked) transcript_path in one jq pass — stdin is
    # a stream, readable only once.
    fields="$(jq -r '[.agent_id // "", .transcript_path // ""] | @tsv' 2>/dev/null || true)"
    agent_id="${fields%%	*}"
    transcript_path="${fields#*	}"
    # Suppress subagent-scoped working/done (see header), but let a subagent's
    # blocked write through — it's a genuine permission_prompt wait, and the
    # transcript sidecar below lets the reader age it out once answered.
    [ -z "$agent_id" ] || [ "$state" = "blocked" ] || exit 0
    ;;
  ready)
    # Fresh-session label, written from SessionStart. SessionStart also fires
    # on compact (mid-turn) and on subagent sessions — neither should stomp a
    # real working/blocked state. Allow-list the genuinely-fresh sources
    # (startup/resume/clear) rather than deny-listing compact, so a jq failure
    # (empty fields) safely writes nothing instead of stomping a live state.
    fields="$(jq -r '[.agent_id // "", .source // ""] | @tsv' 2>/dev/null || true)"
    agent_id="${fields%%	*}"
    source="${fields#*	}"
    [ -z "$agent_id" ] || exit 0
    case "$source" in
      startup|resume|clear) ;;
      *) exit 0 ;;
    esac
    # A fresh process (startup/resume) has claimed this pane. Any tracking
    # markers still here belong to a dead predecessor session that reused the
    # same pane_id — its SubagentStop/SessionEnd never fired (crash, kill, or
    # detach). Left behind, those orphans keep the tracking dir non-empty
    # forever, which pins the read-time label to waiting/working
    # (agent_status_effective_state_for) even after all real agents finish.
    # Wipe them; the new session re-populates via its own track-start. Guarded
    # by the no-agent_id + startup|resume|clear check above, so a compact or a
    # subagent SessionStart never clears a live session's markers.
    rm -rf "$tracking_dir"
    ;;
  clear)
    rm -f "$state_dir/$pane" "$state_dir/$pane.transcript"
    rm -rf "$tracking_dir"
    exit 0
    ;;
  track-start|track-stop)
    agent_id="$(jq -r '.agent_id // empty' 2>/dev/null || true)"
    [ -n "$agent_id" ] || exit 0
    if [ "$state" = "track-start" ]; then
      mkdir -p "$tracking_dir"
      : > "$tracking_dir/$agent_id"
    else
      rm -f "$tracking_dir/$agent_id"
    fi
    exit 0
    ;;
  *) exit 0 ;;
esac

mkdir -p "$state_dir"

# Push the new state onto the tmux status line immediately instead of waiting
# up to status-interval (5s) for the next passive #() refresh — but only when
# it actually changed, so a burst of same-state writes (e.g. PostToolUse
# firing "working" on every tool call) doesn't storm the server with redraws.
prev="$(cat "$state_dir/$pane" 2>/dev/null || true)"
printf '%s' "$state" > "$state_dir/$pane"

# On "blocked", record which transcript this block belongs to so the reader
# (agent_status_effective_state_for) can tell a live block from a stale one:
# if that transcript is later written past this state file's mtime, the thread
# progressed past the prompt and the block is stale. Written after the state
# file so the transcript's mtime is compared against a freshly-stamped marker.
# On any non-blocked write, drop the sidecar so a prior block's marker can't
# linger and mis-classify a future block.
if [ "$state" = "blocked" ] && [ -n "${transcript_path:-}" ]; then
  printf '%s' "$transcript_path" > "$state_dir/$pane.transcript"
else
  rm -f "$state_dir/$pane.transcript"
fi

if [ "$state" != "$prev" ] && command -v tmux >/dev/null 2>&1; then
  tmux refresh-client -S 2>/dev/null || true
fi
