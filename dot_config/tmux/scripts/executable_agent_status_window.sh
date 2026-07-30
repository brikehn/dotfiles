#!/bin/sh
# Renders one window's agent-state label for window-status-format /
# window-status-current-format. Takes the window id (e.g. "@3") as $1 so
# rose-pine's tmux.conf can pass #{window_id}.
# Usage: agent_status_window.sh #{window_id}

set -eu

. "$(dirname "$0")/agent_status_lib.sh"

window_id="${1:-}"
[ -n "$window_id" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

worst="$(tmux list-panes -t "$window_id" -F '#{pane_id}' 2>/dev/null | agent_status_worst_of_panes)"
[ -n "$worst" ] && printf ' %s' "$(agent_status_label_for "$worst")"
