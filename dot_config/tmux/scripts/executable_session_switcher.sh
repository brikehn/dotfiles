#!/usr/bin/env zsh
# session_switcher.sh — unified tmux session + git worktree picker
#
# USAGE:
#   Bound to prefix+f in tmux.conf. Opens fzf popup with sessions/worktrees.
#
# KEYBINDS:
#   Enter       Switch to session/worktree or pick branch for repos
#   ctrl-r      Refresh GitHub repo cache
#   ctrl-x      Kill selected session (keeps worktree)
#   ctrl-d      Delete selected worktree (checks for uncommitted changes)
#
# SETUP:
#   See ~/.config/tmux/SESSION_SWITCHER.md for full documentation.

set -eu
setopt pipefail
setopt null_glob

SESSION_SWITCHER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/session_switcher"
SESSION_SWITCHER_REPO_CACHE="$SESSION_SWITCHER_CACHE_DIR/gh_repos"

# tmux popups + fzf reload subprocesses don't inherit the interactive shell's
# PATH, so make mise-installed tools (gh) reachable explicitly.
export PATH="$HOME/.local/share/mise/shims:/opt/homebrew/bin:$PATH"

# Note: avoid naming local variables `path` — in zsh it is tied to $PATH.

list_worktrees() {
  # Format: path<TAB>label (where label = "<repo>@<branch>" or "<repo>@<short-sha>")
  # Using `@` — tmux reserves `:` in session names, and `/` reads as a repo path.
  #
  # Reads git worktree metadata directly from <bare>/worktrees/<name>/{HEAD,gitdir}
  # instead of invoking `git worktree list` per repo — ~100x faster at 25+ repos.
  local bare repo wt head gitdir wtpath label
  for bare in "$HOME"/repos/*/*.git; do
    [[ -d "$bare/worktrees" ]] || continue
    repo=${bare:t:r}
    for wt in "$bare"/worktrees/*/; do
      [[ -f "$wt/HEAD" && -f "$wt/gitdir" ]] || continue
      head=$(< "$wt/HEAD")
      gitdir=$(< "$wt/gitdir")
      wtpath=${gitdir%/.git}
      if [[ "$head" == "ref: refs/heads/"* ]]; then
        label=${head#ref: refs/heads/}
      else
        label=${head:0:7}
      fi
      printf '%s\t%s@%s\n' "$wtpath" "$repo" "$label"
    done
  done
}

list_sessions() {
  # Format: name<TAB>path<TAB>activity_epoch
  tmux list-sessions -F '#{session_name}	#{session_path}	#{session_activity}' 2>/dev/null || true
}

list_gh_repos() {
  # Emits one "org/repo" per line from the cache. Silent if cache is absent.
  [[ -f "$SESSION_SWITCHER_REPO_CACHE" ]] || return 0
  cat "$SESSION_SWITCHER_REPO_CACHE"
}

list_local_repos() {
  # Emits one "org/repo\tbare_path" per line for each bare repo under ~/repos.
  local bare owner repo
  for bare in "$HOME"/repos/*/*.git; do
    [[ -d "$bare/worktrees" ]] || continue
    owner=${bare:h:t}
    repo=${bare:t:r}
    printf '%s/%s\t%s\n' "$owner" "$repo" "$bare"
  done
}

build_entries() {
  # Emits tab-delimited lines: "<visible_label>\t<kind>\t<payload>"
  # Ordering: sessions (MRU), then repos + worktrees + gh_repos merged alpha.

  local sessions worktrees local_repos gh_repos
  sessions=$(list_sessions)
  worktrees=$(list_worktrees)
  local_repos=$(list_local_repos)
  gh_repos=$(list_gh_repos)

  # Index worktree labels by path so linked sessions show the "repo@branch" label.
  # NOTE: zsh stores literal quotes in keys when subscript is double-quoted —
  # e.g. `x["$k"]=v` keys become `"path"`. Use unquoted subscripts: `x[$k]=v`.
  typeset -A worktree_label_by_path
  local wpath wlabel
  while IFS=$'\t' read -r wpath wlabel; do
    [[ -z "$wpath" ]] && continue
    worktree_label_by_path[$wpath]="$wlabel"
  done <<< "$worktrees"

  # Index local repos by "org/repo" for dedup against gh_repos.
  typeset -A local_repo_bare_by_orgrepo
  local orgrepo bare
  while IFS=$'\t' read -r orgrepo bare; do
    [[ -z "$orgrepo" ]] && continue
    local_repo_bare_by_orgrepo[$orgrepo]="$bare"
  done <<< "$local_repos"

  # Pass 1: all sessions, MRU at top. Label prefers worktree label when available.
  # Track which worktree paths already have a session so Pass 2 can skip them.
  typeset -A linked_worktree_paths
  local session_lines=""
  local name s_path activity display
  while IFS=$'\t' read -r name s_path activity; do
    [[ -z "$name" ]] && continue
    if [[ -n "${worktree_label_by_path[$s_path]:-}" ]]; then
      display="${worktree_label_by_path[$s_path]}"
      linked_worktree_paths[$s_path]=1
    else
      display="$name"
    fi
    session_lines+="${activity}"$'\t'$'\x1b[1m'"${display}"$'\x1b[0m'$'\t'"session"$'\t'"${name}"$'\n'
  done <<< "$sessions"

  # Pass 2: mixed alpha block — local repos, worktrees (without a session),
  # gh_repos (dimmed).
  local mixed_lines=""

  # Local repos.
  while IFS=$'\t' read -r orgrepo bare; do
    [[ -z "$orgrepo" ]] && continue
    mixed_lines+="${orgrepo}"$'\t'"repo"$'\t'"${bare}"$'\n'
  done <<< "$local_repos"

  # Worktrees without an attached session.
  while IFS=$'\t' read -r wpath wlabel; do
    [[ -z "$wpath" ]] && continue
    [[ -n "${linked_worktree_paths[$wpath]:-}" ]] && continue
    mixed_lines+="${wlabel}"$'\t'"worktree"$'\t'"${wpath}"$'\n'
  done <<< "$worktrees"

  # GH repos — dim via ANSI; skip any that are already local.
  local gh_line
  while IFS= read -r gh_line; do
    [[ -z "$gh_line" ]] && continue
    [[ -n "${local_repo_bare_by_orgrepo[$gh_line]:-}" ]] && continue
    mixed_lines+=$'\x1b[2m'"${gh_line}"$'\x1b[0m'$'\t'"gh_repo"$'\t'"${gh_line}"$'\n'
  done <<< "$gh_repos"

  # Emit: sessions MRU (sort desc on activity), mixed alpha (sort asc on label).
  printf '%s' "$session_lines" | sort -t$'\t' -k1,1rn | cut -f2-
  # NOTE: ANSI escapes sort before printable chars so gh_repos may cluster at
  # the top of the mixed block. Acceptable — dim styling still distinguishes.
  printf '%s' "$mixed_lines" | sort -t$'\t' -k1,1
}

refresh_gh_repos() {
  # Rebuilds $SESSION_SWITCHER_REPO_CACHE from `gh` CLI.
  # Silent on success. On failure, writes a hint to stderr and leaves any
  # existing cache file in place.
  command -v gh >/dev/null 2>&1 || {
    echo "session_switcher: 'gh' not installed" >&2
    return 1
  }

  mkdir -p "$SESSION_SWITCHER_CACHE_DIR"
  local tmp
  tmp=$(mktemp "$SESSION_SWITCHER_CACHE_DIR/gh_repos.XXXXXX") || return 1

  local orgs
  orgs=$(gh api user/orgs --jq '.[].login' 2>/dev/null) || {
    echo "session_switcher: 'gh api user/orgs' failed (not authenticated?)" >&2
    rm -f "$tmp"
    return 1
  }

  local org
  while IFS= read -r org; do
    [[ -z "$org" ]] && continue
    gh repo list "$org" --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' 2>/dev/null >> "$tmp" || true
  done <<< "$orgs"

  sort -u "$tmp" -o "$tmp"
  mv "$tmp" "$SESSION_SWITCHER_REPO_CACHE"
}

# Use the terminal's ANSI "red" slot for fzf match highlights — maps through
# the active terminal theme. In Rose Pine Dawn that's "love" (saturated rose).
SESSION_SWITCHER_FZF_COLOR='hl:yellow:bold,hl+:yellow:bold'

kill_session() {
  # Kills a tmux session (ctrl-x). Works on session and worktree entries.
  local kind="$1" payload="$2"

  if [[ "$kind" == "session" ]]; then
    # Direct session entry — payload is session name.
    tmux kill-session -t "$payload" 2>/dev/null || true
    tmux display-message "killed session: $payload"
  elif [[ "$kind" == "worktree" ]]; then
    # Worktree entry — derive session name from label (repo@branch).
    # Payload is the worktree path, but we need the session name.
    # The session name should be in {1} (label), so we'll pass it separately.
    local label="$3"
    tmux kill-session -t "$label" 2>/dev/null || true
    tmux display-message "killed session: $label"
  fi

  # Brief sleep to let tmux update its session list before picker restarts.
  sleep 0.1
}

delete_worktree() {
  # Deletes a worktree after checking for uncommitted changes (ctrl-d).
  local label="$1" kind="$2" payload="$3"

  if [[ "$kind" != "worktree" ]]; then
    tmux display-message "not a worktree: $label"
    return 0
  fi

  # Worktree path: ~/repos/<org>/<repo>/<branch>
  # Bare path: ~/repos/<org>/<repo>.git
  local bare="${payload%/*}.git"

  if [[ ! -d "$payload" ]]; then
    # Directory is gone but metadata exists — force remove or prune it.
    local err
    if ! err=$(git -C "$bare" worktree remove --force "$payload" 2>&1); then
      # Force remove failed, try pruning all orphaned worktrees.
      if ! err=$(git -C "$bare" worktree prune 2>&1); then
        tmux display-message -d 5000 "prune failed: ${err##*$'\n'}"
        return 1
      fi
    fi
    tmux display-message "pruned orphaned worktree: $label"
    return 0
  fi

  # Check for uncommitted changes or untracked files.
  if ! git -C "$payload" diff-index --quiet HEAD -- 2>/dev/null || \
     [[ -n $(git -C "$payload" ls-files --others --exclude-standard 2>/dev/null) ]]; then
    tmux display-message -d 5000 "worktree has uncommitted changes: $label"
    return 1
  fi

  # Safe to delete — remove worktree.
  if ! git -C "$bare" worktree remove "$payload" 2>/dev/null; then
    tmux display-message -d 5000 "worktree remove failed: $label"
    return 1
  fi
  tmux display-message "deleted worktree: $label"
}

branch_picker() {
  local identifier="$1"
  local bare org repo

  if [[ "$identifier" == /* ]]; then
    # Local bare repo path.
    bare="$identifier"
    repo=${bare:t:r}
    org=${bare:h:t}
  else
    # org/repo from a gh_repo entry.
    org="${identifier%%/*}"
    repo="${identifier##*/}"
    bare="$HOME/repos/$org/$repo.git"
  fi

  # Fetch branches.
  local branches
  if [[ -d "$bare" ]]; then
    # Use the bare repo's remote for already-cloned repos.
    branches=$(git -C "$bare" ls-remote --heads origin 2>/dev/null | sed 's|.*refs/heads/||')
  else
    # No bare yet: use gh.
    branches=$(gh api "repos/$org/$repo/branches" --paginate --jq '.[].name' 2>/dev/null)
  fi

  # Popup with branches.
  local selection retval query picked
  set +e
  selection=$(printf '%s\n' "$branches" | fzf \
    --exit-0 \
    --print-query \
    --reverse \
    --color="$SESSION_SWITCHER_FZF_COLOR" \
    --style=minimal \
    --prompt "" \
    --pointer "" \
    --marker "" \
    --padding "0,0,0,1" \
    --no-info)
  retval=$?
  set -e

  query=$(printf '%s\n' "$selection" | sed -n '1p')
  picked=$(printf '%s\n' "$selection" | sed -n '2p')

  local branch=""
  if [[ $retval -eq 0 && -n "$picked" ]]; then
    branch="$picked"
  elif [[ $retval -eq 1 && -n "$query" ]]; then
    branch="$query"
  else
    return 0
  fi

  # Clone bare repo if missing.
  if [[ ! -d "$bare" ]]; then
    mkdir -p "$HOME/repos/$org"
    if ! git clone --bare "git@github.com:$org/$repo.git" "$bare" 2>/dev/null; then
      tmux display-message "clone failed: $org/$repo"
      return 1
    fi
    git -C "$bare" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git -C "$bare" fetch origin 2>/dev/null
  fi

  # Create worktree if missing.
  local wt_path="$HOME/repos/$org/$repo/$branch"
  if [[ ! -d "$wt_path" ]]; then
    # The branch list came from `ls-remote`, so the picked branch may not yet
    # have a local ref — fetch it explicitly before `worktree add`.
    local err branch_exists_remotely=1
    if ! err=$(git -C "$bare" fetch origin "$branch" 2>&1); then
      # If branch doesn't exist on remote, we'll create it locally from origin/HEAD.
      # Other fetch failures (network, auth) should still abort.
      if [[ "$err" == *"couldn't find remote ref"* ]]; then
        branch_exists_remotely=0
      else
        tmux display-message -d 5000 "fetch failed: ${err##*$'\n'}"
        return 1
      fi
    fi

    if [[ $branch_exists_remotely -eq 1 ]]; then
      # Branch exists remotely — check it out.
      if ! err=$(git -C "$bare" worktree add "$wt_path" "$branch" 2>&1); then
        tmux display-message -d 5000 "worktree add failed: ${err##*$'\n'}"
        return 1
      fi
    else
      # Branch doesn't exist — create it from the default branch.
      # Determine the default branch by trying common names.
      local base_ref=""
      for candidate in origin/main origin/master origin/develop main master; do
        if git -C "$bare" rev-parse --verify "$candidate" >/dev/null 2>&1; then
          base_ref="$candidate"
          break
        fi
      done
      if [[ -z "$base_ref" ]]; then
        tmux display-message -d 5000 "no default branch found (tried main, master, develop)"
        return 1
      fi
      if ! err=$(git -C "$bare" worktree add -b "$branch" "$wt_path" "$base_ref" 2>&1); then
        tmux display-message -d 5000 "worktree add -b failed: ${err##*$'\n'}"
        return 1
      fi
    fi
  fi

  # Create session + switch.
  local name="$repo@$branch"
  tmux new-session -d -s "$name" -c "$wt_path" 2>/dev/null || true
  tmux switch-client -t "$name"
}

main() {
  # Bootstrap the GH repo cache on first use so the primary picker shows
  # gh_repo entries immediately. Silent failure is OK — picker still works.
  if [[ ! -f "$SESSION_SWITCHER_REPO_CACHE" ]] && command -v gh >/dev/null 2>&1; then
    refresh_gh_repos 2>/dev/null || true
  fi

  if [[ "${1:-}" == "--emit-entries" ]]; then
    build_entries
    return 0
  fi

  if [[ "${1:-}" == "--refresh-repos" ]]; then
    refresh_gh_repos
    shift
    # Allow "--refresh-repos --emit-entries" in one call (used by fzf reload).
    if [[ "${1:-}" == "--emit-entries" ]]; then
      build_entries
    fi
    return 0
  fi

  if [[ "${1:-}" == "--branch-picker" ]]; then
    shift
    branch_picker "${1:-}"
    return $?
  fi

  if [[ "${1:-}" == "--kill-session" ]]; then
    shift
    kill_session "$@"
    return $?
  fi

  if [[ "${1:-}" == "--delete-worktree" ]]; then
    shift
    delete_worktree "$@"
    return $?
  fi

  local entries
  entries=$("$ZSH_ARGZERO" --emit-entries)

  local selection retval
  set +e
  selection=$(printf '%s' "$entries" | fzf \
    --exit-0 \
    --print-query \
    --reverse \
    --ansi \
    --with-nth=1 \
    --delimiter=$'\t' \
    --color="$SESSION_SWITCHER_FZF_COLOR" \
    --prompt "" \
    --pointer "" \
    --marker "" \
    --padding "0,0,0,1" \
    --info-command "true" \
    --info=right \
    --no-scrollbar \
    --bind "ctrl-r:reload($ZSH_ARGZERO --refresh-repos --emit-entries 2>/dev/null)" \
    --bind "ctrl-x:execute-silent($ZSH_ARGZERO --kill-session {2} {3} {1})+abort" \
    --bind "ctrl-d:execute-silent($ZSH_ARGZERO --delete-worktree {1} {2} {3})+abort")
  retval=$?
  set -e

  local query picked
  query=$(printf '%s\n' "$selection" | sed -n '1p')
  picked=$(printf '%s\n' "$selection" | sed -n '2p')

  if [[ $retval -eq 0 && -n "$picked" ]]; then
    local _label kind payload
    IFS=$'\t' read -r _label kind payload <<< "$picked"
    case "$kind" in
      session)
        tmux switch-client -t "$payload"
        ;;
      worktree)
        tmux new-session -d -s "$_label" -c "$payload" 2>/dev/null || true
        tmux switch-client -t "$_label"
        ;;
      repo|gh_repo)
        # Run the branch picker in the current popup (nested display-popup is
        # unreliable). branch_picker handles the final switch-client itself.
        branch_picker "$payload"
        ;;
    esac
  elif [[ $retval -eq 1 && -n "$query" ]]; then
    tmux new-session -d -s "$query" 2>/dev/null || true
    tmux switch-client -t "$query"
  fi
}

main "$@"
