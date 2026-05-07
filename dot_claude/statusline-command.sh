#!/bin/sh
input=$(cat)

# Context window usage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limits
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

SEP=$(printf '\033[2m · \033[0m')

color_pct() {
  label="$1"
  val="$2"
  n=$(printf '%.0f' "$val")
  if [ "$n" -ge 80 ]; then
    printf '\033[31m%s:%s%%\033[0m' "$label" "$n"
  elif [ "$n" -ge 60 ]; then
    printf '\033[33m%s:%s%%\033[0m' "$label" "$n"
  else
    printf '\033[2m%s:%s%%\033[0m' "$label" "$n"
  fi
}

parts=""
append() {
  if [ -z "$parts" ]; then
    parts="$1"
  else
    parts="$parts$SEP$1"
  fi
}

[ -n "$used" ]   && append "$(color_pct ctx "$used")"
[ -n "$five_h" ] && append "$(color_pct 5h "$five_h")"
[ -n "$seven_d" ] && append "$(color_pct 7d "$seven_d")"

printf '%s' "$parts"
