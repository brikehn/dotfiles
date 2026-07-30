#!/bin/sh
# Emits agent state for every live window, for session_switcher.sh's fzf
# picker to key off of. Output, one line per window, tab-delimited:
#   <session_name>\t<window_index>\t<state>
# <state> is blocked/working/waiting/done, or "-" if the window has no
# tracked agent pane. Always "-", never truly empty — a line ending in an
# empty field (trailing tab immediately before the newline) loses that
# field when read by `read`, which strips trailing IFS characters.

set -eu

. "$(dirname "$0")/agent_status_lib.sh"

command -v tmux >/dev/null 2>&1 || exit 0

tmux list-windows -a -F '#{session_name}	#{window_index}	#{window_id}' 2>/dev/null | while IFS="$(printf '\t')" read -r session index window_id; do
  worst="$(tmux list-panes -t "$window_id" -F '#{pane_id}' 2>/dev/null | agent_status_worst_of_panes)"
  printf '%s\t%s\t%s\n' "$session" "$index" "${worst:--}"
done
