# Session Switcher

Unified tmux session + git worktree picker with fzf.

## Features

- **Browse sessions and worktrees** in a single fuzzy-searchable popup
- **Create sessions** from existing worktrees or new branches
- **Kill sessions or windows** without deleting worktrees (ctrl-x)
- **Delete worktrees** with safety checks for uncommitted changes (ctrl-d)
- **MRU session ordering** with bold highlighting for active sessions
- **Worktree/dotfiles context**, shown dim and right-aligned, for any session
  or window that's actually sitting in one

## Setup

### Prerequisites

- **fzf** (fuzzy finder) — `brew install fzf` or `mise use fzf`
- **git worktree-based repo structure** (see Directory Structure below)

### tmux.conf

Add to `~/.config/tmux/tmux.conf`:

```tmux
bind f display-popup -w 60 -h 20 -y 15 -E '~/.config/tmux/scripts/session_switcher.sh'
```

Reload tmux config: `tmux source-file ~/.config/tmux/tmux.conf`

### Directory Structure

The picker expects bare repos with worktrees:

```
~/repos/
  <org>/
    <repo>.git/              # bare repo
    <repo>/                  # worktrees directory
      <branch>/
      <another-branch>/
```

**Example:**
```
~/repos/
  acme/
    widgets.git/             # bare repo (all git metadata)
    widgets/                 # worktrees
      main/
      feature-branch/
      bugfix-123/
```

**Converting an existing clone to this structure:**

```bash
cd ~/repos/acme
git clone --bare git@github.com:acme/widgets.git
cd widgets.git
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch origin
git worktree add ../widgets/main main
```

## Usage

### Keybinds

| Key | Action |
|-----|--------|
| `prefix+f` | Open the picker |
| `Enter` | Switch to selected entry (or pick branch for repos) |
| `ctrl-x` | Kill selected session or window (does not delete worktree) |
| `ctrl-d` | Delete worktree (also deletes branch if it's local-only) |
| `Esc` / `ctrl-c` | Close picker |

### Picker Entries

The picker shows four types of entries:

1. **Sessions** (top, bold, MRU sorted)
   - Active tmux sessions, always labeled by their actual tmux session name
   - If the session has exactly one window and that window's current
     directory is a worktree or the dotfiles dir, that's shown as dim,
     right-aligned context on the same row (e.g. `mysession    widgets@main`)
   - A session with more than one window shows just its name, with each
     window listed indented below it (own context per window — see below)
   - Selecting a session (or a window row) switches to it immediately

   **Windows** (indented under a session with 2+ windows)
   - One row per window: `  <index>:<window name>`, with its own dim,
     right-aligned context if that window's directory is a worktree or
     the dotfiles dir — since different windows in the same session can
     be sitting in different places
   - Selecting switches straight to that window

2. **Worktrees** (middle, alpha sorted)
   - Git worktrees without attached sessions
   - Label format: `<repo>@<branch>`
   - Selecting creates a session and switches to it

3. **Local repos** (middle, alpha sorted)
   - Bare repos under `~/repos/`
   - Label format: `<org>/<repo>`
   - Selecting opens branch picker

4. **Dotfiles** (middle, alpha sorted)
   - Chezmoi source directory (`~/.local/share/chezmoi`)
   - Only shows if directory exists
   - Selecting creates/switches to "dotfiles" session
   - Cannot be deleted via ctrl-d

### Branch Picker

When you select a repo, a second fzf popup shows branches:

- **Pick existing branch**: Checks out the branch and creates a worktree
- **Type new branch name**: Creates a new branch from the default branch (main/master/develop)

The picker fetches branches from the remote if they don't exist locally yet.

### Creating Sessions

**From existing worktree:**
1. Open picker (`prefix+f`)
2. Select worktree entry
3. Session created with name `<repo>@<branch>`

**From new branch:**
1. Open picker (`prefix+f`)
2. Select repo entry
3. Type branch name in branch picker
4. Worktree created, session starts

**Ad-hoc session:**
1. Open picker (`prefix+f`)
2. Type a name that doesn't match any entry
3. Press Enter
4. New session created with that name (not linked to a worktree)

### Deleting

**Kill session or window (ctrl-x):**
- Kills the tmux session, or just the selected window if it's a window row
- Worktree remains intact
- Picker closes (reopen with `prefix+f` to see updated list)
- Works on session, window, and worktree entries

**Delete worktree (ctrl-d):**
- Checks for uncommitted changes first (staged, unstaged, untracked)
- Shows 5-second error if changes exist
- Runs `git worktree remove` if clean
- **Smart branch cleanup**: Also deletes the local branch if it exists on remote (safe, can fetch back)
  - Branch on remote → deletes both worktree and local branch (can fetch back anytime)
  - Local-only branch → deletes worktree only, keeps branch (would lose it forever)
- Picker closes (reopen with `prefix+f` to see updated list)
- Only works on worktree entries (shows "not a worktree" for others, "cannot delete dotfiles" for dotfiles entry)

**Orphaned worktrees:**
If you manually delete a worktree directory, the git metadata remains. `ctrl-d` on an orphaned entry will clean up the metadata automatically.

## Troubleshooting

### "fetch failed: couldn't find remote ref"

The branch doesn't exist on the remote. This happens when:
- You typed a new branch name → worktree will be created from default branch
- A branch was deleted remotely but still shows in the list

### "worktree has uncommitted changes"

The worktree has uncommitted work (staged, unstaged, or untracked files). Options:
- Commit the changes: `git commit -am "wip"`
- Stash the changes: `git stash`
- Discard the changes: `git reset --hard` (destructive!)

### "pruned orphaned worktree"

The worktree directory was deleted manually (e.g., `rm -rf`) but git metadata remained. The picker cleaned it up.

### "no default branch found (tried main, master, develop)"

The bare repo has no branches checked out. This shouldn't happen with properly cloned bare repos. Fix:

```bash
cd ~/repos/<org>/<repo>.git
git fetch origin
git branch -a  # verify branches exist
```

## Tips

- **Session names**: Use `<repo>@<branch>` pattern for clarity
- **Prefix+w**: Native tmux window picker, an alternative to the indented window rows here
- **Prefix+s**: Native tmux session picker (alternative for just sessions)
- **Worktree cleanup**: Periodically run `git worktree prune` in bare repos to clean up stale metadata

## Advanced

### Using with chezmoi

If managing tmux config with chezmoi, track both files:

```bash
chezmoi add ~/.config/tmux/tmux.conf
chezmoi add ~/.config/tmux/scripts/session_switcher.sh
```

### Customizing fzf colors

Edit `SESSION_SWITCHER_FZF_COLOR` in the script to match your theme:

```bash
SESSION_SWITCHER_FZF_COLOR='hl:yellow:bold,hl+:yellow:bold'
```

### Popup dimensions

Adjust in `tmux.conf`:

```tmux
# Default is 60x20. Larger popup, e.g. for sessions with lots of windows:
bind f display-popup -w 80 -h 30 -y 10 -E '~/.config/tmux/scripts/session_switcher.sh'
```

## Related Tools

- **tmux-resurrect** + **tmux-continuum**: Save/restore sessions automatically
- **git worktree**: Native git support for multiple working directories
- **fzf-git**: Similar picker for git operations
