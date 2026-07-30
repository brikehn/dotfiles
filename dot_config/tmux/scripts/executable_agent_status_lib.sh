#!/bin/sh
# Shared helpers for reading per-pane agent state, sourced by agent_status.sh
# (status-right rollup) and agent_status_window.sh (per-window tab label).
# States are written by ~/.claude/hooks/agent-status.sh keyed by pane_id
# into $HOME/.cache/tmux-agent-status/.

agent_status_state_dir="$HOME/.cache/tmux-agent-status"

# Kept as a named function (not inlined into a pipeline) because a `case`
# nested inside a `while ... done | ...` command substitution trips a parser
# bug in bash 3.2 (macOS's default /bin/bash).
agent_status_rank_for() {
  case "$1" in
    blocked) printf '5' ;;
    working) printf '4' ;;
    waiting) printf '3' ;;
    done) printf '2' ;;
    ready) printf '1' ;;
    *) printf '0' ;;
  esac
}

# rose-pine dawn palette (thm_love / thm_gold / thm_pine) so labels match the theme.
# For tmux format strings (status-right, window-status-format) — uses tmux's
# own #[fg=...] styling syntax.
agent_status_label_for() {
  case "$1" in
    blocked) printf '#[fg=#b4637a,bold]BLOCKED#[default]' ;;
    working) printf '#[fg=#ea9d34,bold]WORKING#[default]' ;;
    waiting) printf '#[fg=#907aa9,bold]WAITING#[default]' ;;
    done)    printf '#[fg=#286983]DONE#[default]' ;;
    ready)   printf '#[fg=#56949f]READY#[default]' ;;
  esac
}

# Same palette, raw ANSI escapes instead of tmux #[] syntax — for output that
# tmux itself won't re-parse, e.g. text fed straight into fzf via popup.
agent_status_ansi_label_for() {
  case "$1" in
    blocked) printf '\033[1;38;2;180;99;122mBLOCKED\033[0m' ;;
    working) printf '\033[1;38;2;234;157;52mWORKING\033[0m' ;;
    waiting) printf '\033[1;38;2;144;122;169mWAITING\033[0m' ;;
    done)    printf '\033[38;2;40;105;131mDONE\033[0m' ;;
    ready)   printf '\033[38;2;86;148;159mREADY\033[0m' ;;
  esac
}

# Returns success if the pane is (still) running an agent as its foreground
# command. An agent that exits ungracefully — crash, kill, or a closed tab
# that skipped SessionEnd — leaves its last state file behind while the pane
# drops back to a shell, so readers would otherwise show a stale label
# forever. Detected by deny-listing shells rather than allow-listing agent
# names: fail-open on anything non-shell (including tmux/query failures) so a
# genuinely-running agent is never wrongly blanked, even if it ever reports a
# command other than "claude". A running agent keeps "claude" as its
# foreground command even while it shells out for a tool, so mid-tool reads
# don't false-negative.
agent_status_pane_has_agent() {
  command -v tmux >/dev/null 2>&1 || return 0
  cmd="$(tmux display-message -p -t "%$1" '#{pane_current_command}' 2>/dev/null || true)"
  [ -n "$cmd" ] || return 0
  case "$cmd" in
    zsh|bash|sh|fish|dash|tcsh|ksh) return 1 ;;
    *) return 0 ;;
  esac
}

# Reads a pane's raw stored state, then reclassifies it if that pane still
# has outstanding tracked background agents (see agent-status.sh's
# track-start/track-stop). Computed at read time — never stored — so a Stop
# and a same-instant SubagentStop can't race each other into a stuck label;
# whichever writer runs last, the next read reflects the true
# outstanding-agent count.
#
# One stale-label case collapses to the true "orchestrating agents" state:
#   done -> waiting  top-level turn ended, background agents still cooking.
#
# "blocked" is deliberately NOT downgraded on outstanding agents. A subagent's
# permission_prompt is a real wait-on-user, and its blocked write now reaches
# this pane (agent-status.sh no longer suppresses subagent blocks) — collapsing
# it to "working" whenever the tracking dir is non-empty would re-hide exactly
# the subagent block we want to surface. Stale main-thread blocks (prompt
# approved, thread moved on) are instead aged out precisely by transcript mtime
# below, which fires whether or not agents are outstanding.
agent_status_effective_state_for() {
  pane="$1"
  state="$(cat "$agent_status_state_dir/$pane" 2>/dev/null || true)"
  [ -n "$state" ] || return 0
  # Ignore a leftover file whose agent has already exited (pane is a shell).
  agent_status_pane_has_agent "$pane" || return 0
  tracking_dir="$agent_status_state_dir/tracking-$pane"
  if [ -d "$tracking_dir" ] && [ -n "$(ls -A "$tracking_dir" 2>/dev/null)" ]; then
    case "$state" in
      done) state="waiting" ;;
    esac
  fi
  # A "blocked" with no live agents can still be stale: a permission_prompt
  # latched it, then the thread moved on (auto-mode auto-answered, or the user
  # answered) but the only hooks that fired afterward were subagent-scoped
  # tool events, which agent-status.sh suppresses — so nothing rewrote the
  # pane. Detect forward progress by mtime: agent-status.sh drops a sidecar
  # naming this pane's transcript when it writes "blocked", and the state file
  # itself is stamped at block time. If the transcript has been written *since*
  # the block, Claude progressed past the prompt and isn't waiting on the user
  # — downgrade to working. A genuine block (default mode, thread parked on the
  # prompt) leaves the transcript untouched, so its mtime stays <= the marker's
  # and the label correctly stays blocked. Self-heals on the next Stop -> done.
  if [ "$state" = "blocked" ]; then
    tfile="$agent_status_state_dir/$pane.transcript"
    if [ -f "$tfile" ]; then
      tpath="$(cat "$tfile" 2>/dev/null || true)"
      if [ -n "$tpath" ] && [ -f "$tpath" ] && [ "$tpath" -nt "$agent_status_state_dir/$pane" ]; then
        state="working"
      fi
    fi
  fi
  printf '%s' "$state"
}

# Worst state (blocked > working > waiting > done > ready) among a set of pane ids
# read on stdin, one pane_id (with leading % stripped by the caller, or not)
# per line.
agent_status_worst_of_panes() {
  while IFS= read -r pane_id; do
    pane="${pane_id#%}"
    [ -f "$agent_status_state_dir/$pane" ] || continue
    state="$(agent_status_effective_state_for "$pane")"
    [ -n "$state" ] || continue
    printf '%s %s\n' "$(agent_status_rank_for "$state")" "$state"
  done | sort -rn | head -1 | cut -d' ' -f2
}
