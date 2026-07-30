#!/bin/sh
# macOS desktop notification for agent state changes, distinct per state so
# blocked and done are tellable apart without looking at the screen.
# Usage: agent-notify.sh <blocked|done> ["<message>"]
# If no message is given, builds one naming the session:window the event came
# from. Reads the hook's JSON stdin for `cwd` so a backgrounded/auto-mode fork
# — which runs with no TMUX_PANE in its env — can still be located: its pane is
# found by matching a live claude pane whose current path equals that cwd.

set -eu

state="${1:-}"
message="${2:-}"
command -v osascript >/dev/null 2>&1 || exit 0

# Hook stdin is a one-shot stream; read it once. Always piped (possibly empty),
# so cat sees EOF immediately and never blocks.
input="$(cat 2>/dev/null || true)"
cwd=""
if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"
fi

# Resolve the pane this event belongs to: the interactive thread exports
# TMUX_PANE; a backgrounded fork doesn't, so fall back to the (first) claude
# pane whose current path matches the event's cwd. Sets pane_id and pane_where
# ("session:index") when found.
pane_id="${TMUX_PANE:-}"
pane_where=""
if command -v tmux >/dev/null 2>&1; then
  if [ -n "$pane_id" ]; then
    pane_where="$(tmux display-message -p -t "$pane_id" '#S:#I' 2>/dev/null || true)"
  elif [ -n "$cwd" ]; then
    # tab-delimited: path<TAB>command<TAB>pane_id<TAB>session:index. Pick the
    # first claude pane whose path equals cwd exactly.
    match="$(tmux list-panes -a -F '#{pane_current_path}	#{pane_current_command}	#{pane_id}	#{session_name}:#{window_index}' 2>/dev/null \
      | awk -F'\t' -v c="$cwd" '$1==c && $2=="claude" {print $3"\t"$4; exit}' || true)"
    if [ -n "$match" ]; then
      pane_id="${match%%	*}"
      pane_where="${match#*	}"
    fi
  fi
fi

# Skip the notification if the resolved pane's window is the one on screen right
# now: window_active_clients > 0 means a client is currently viewing it.
if [ -n "$pane_id" ] && command -v tmux >/dev/null 2>&1; then
  viewers="$(tmux display-message -p -t "$pane_id" '#{window_active_clients}' 2>/dev/null || true)"
  [ -n "$viewers" ] && [ "$viewers" != "0" ] && exit 0
fi

# Build the message from the resolved location; fall back to the cwd's basename
# ("in worklog") when tmux can't place it, so the notification still says which
# work it came from instead of a bare title echo.
if [ -z "$message" ]; then
  if [ -n "$pane_where" ]; then
    message="in $pane_where"
  elif [ -n "$cwd" ]; then
    message="in ${cwd##*/}"
  fi
fi

case "$state" in
  blocked)
    title="Claude Code — needs you"
    sound="Sosumi"
    ;;
  done)
    title="Claude Code — done"
    sound="Pop"
    ;;
  *)
    exit 0
    ;;
esac

[ -n "$message" ] || message="$title"

osascript -e "display notification \"$(printf '%s' "$message" | sed 's/"/\\"/g')\" with title \"$title\" sound name \"$sound\"" >/dev/null 2>&1 || true
