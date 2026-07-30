#!/bin/sh
# Gives each flagged session its own full-width status line instead of
# packing them horizontally into status-right, where long repo/branch names
# would overextend. Excludes the session currently shown on screen (its own
# tabs already carry per-window labels — no need to repeat it in the rollup).
# States are written by ~/.claude/hooks/agent-status.sh (or codex's equivalent)
# keyed by pane_id into $HOME/.cache/tmux-agent-status/.
# Worst state per session wins: blocked > working > waiting > done.
#
# Runs every status-interval via status-right's #() (same as before). The
# single worst-ranked session is printed to stdout so it lands inline on the
# existing status-right line (no extra row consumed) — the rest are pushed
# onto their own full-width rows below via status-format[1..4] as a side
# effect. Tmux's `status` option maxes out at 5 rows total, so beyond
# 1 (inline) + 4 (stacked) = 5 flagged sessions, the last stacked row
# collapses into a "+N more" summary.
# Usage: agent_status.sh [current_session_name]

set -eu

. "$(dirname "$0")/agent_status_lib.sh"

current_session="${1:-}"
max_rows=4

[ -d "$agent_status_state_dir" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

live_panes_file="$(mktemp)"
rows_file="$(mktemp)"
trap 'rm -f "$live_panes_file" "$rows_file"' EXIT
tmux list-panes -a -F '#{pane_id}' 2>/dev/null | sed 's/^%//' > "$live_panes_file"

# Drop state files (and tracking-<pane> dirs) for panes that no longer
# exist, so the dir doesn't grow forever. Under `set -eu`, `rm -f` on a
# directory would abort the script, so tracking dirs need `rm -rf`.
for f in "$agent_status_state_dir"/*; do
  [ -e "$f" ] || continue
  pane="$(basename "$f")"
  case "$pane" in
    tracking-*) pane="${pane#tracking-}" ;;
    # "<pane>.transcript" sidecar (see agent-status.sh's blocked write): map it
    # back to its pane id so a live pane's sidecar isn't GC'd every pass — its
    # basename would otherwise never match a bare pane id and get deleted 5s
    # after being written, defeating the stale-blocked detection.
    *.transcript) pane="${pane%.transcript}" ;;
  esac
  if ! grep -qx "$pane" "$live_panes_file"; then
    if [ -d "$f" ]; then
      rm -rf "$f"
    else
      rm -f "$f"
    fi
  fi
done

tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
  [ "$session" = "$current_session" ] && continue
  worst="$(tmux list-panes -t "$session" -F '#{pane_id}' 2>/dev/null | agent_status_worst_of_panes)"
  [ -n "$worst" ] && printf '%s %s:%s\n' "$(agent_status_rank_for "$worst")" "$session" "$worst"
done | sort -rn | cut -d' ' -f2- > "$rows_file"

total=$(wc -l < "$rows_file" | tr -d ' ')

clear_stacked_rows() {
  i=1
  while [ "$i" -le "$max_rows" ]; do
    # An empty string, not unset: unsetting falls back to tmux's built-in
    # per-index default format (e.g. index 2 renders a stray "S: <session>"
    # line), which isn't blank.
    tmux set-option -g "status-format[$i]" ""
    i=$((i + 1))
  done
}

if [ "$total" -eq 0 ]; then
  tmux set-option -g status on
  clear_stacked_rows
  exit 0
fi

# First (worst-ranked) entry goes inline on the existing status-right line
# via stdout, so it costs no extra row.
head="$(sed -n '1p' "$rows_file")"
head_session="${head%%:*}"
head_state="${head#*:}"
printf '%s: %s' "$head_session" "$(agent_status_label_for "$head_state")"

rest=$((total - 1))
shown=$rest
[ "$shown" -gt "$max_rows" ] && shown=$max_rows

i=1
while [ "$i" -le "$shown" ]; do
  entry="$(sed -n "$((i + 1))p" "$rows_file")"
  session="${entry%%:*}"
  state="${entry#*:}"
  if [ "$i" -eq "$max_rows" ] && [ "$rest" -gt "$max_rows" ]; then
    hidden=$((rest - max_rows + 1))
    tmux set-option -g "status-format[$i]" "#[align=right]#[fg=#575279](+$hidden more) "
  else
    # Trailing space matches the inline (row 0) entry: rose-pine's template
    # always joins prepend_section + ' ' + right_column, even when
    # right_column is empty, so row 0's label sits 1 col short of the true
    # right edge. Without this space, #[align=right] here flushes stacked
    # rows all the way to the edge — 1 col further right than row 0.
    tmux set-option -g "status-format[$i]" "#[align=right]#[fg=#575279]${session}#[default]: $(agent_status_label_for "$state") "
  fi
  i=$((i + 1))
done

# Clear any previously-populated rows beyond what we need this pass.
i=$((shown + 1))
while [ "$i" -le "$max_rows" ]; do
  tmux set-option -g "status-format[$i]" ""
  i=$((i + 1))
done

tmux set-option -g status $((shown + 1))
