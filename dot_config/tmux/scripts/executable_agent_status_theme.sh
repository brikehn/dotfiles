#!/bin/sh
# Loads the rose-pine theme, then appends the agent-status label onto
# whatever window-status-format/window-status-current-format it set.
#
# rose-pine's own tmux.conf line is `run-shell rose-pine.tmux`, which tmux
# schedules asynchronously — it does NOT block config parsing. That means a
# plain `setw window-status-format ...` placed after it in tmux.conf would
# run first and then get silently overwritten once rose-pine's background
# job finishes. Running rose-pine synchronously here (not via run-shell)
# and reading its result back afterward avoids that race entirely.

set -eu

rose_pine_dir="$HOME/.config/tmux/plugins/rose-pine"
scripts_dir="$(dirname "$0")"

"$rose_pine_dir/rose-pine.tmux"

suffix="#($scripts_dir/agent_status_window.sh #{window_id})"

for opt in window-status-format window-status-current-format; do
  current="$(tmux show-window-options -gv "$opt" 2>/dev/null || true)"
  tmux set-window-option -g "$opt" "${current}${suffix}"
done
