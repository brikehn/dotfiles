# Dotfiles

Managed by [chezmoi](https://www.chezmoi.io/). Tools via [mise](https://mise.jdx.dev/).

See [SETUP.md](SETUP.md) for new machine bootstrap and first-time installation.

## Quick Start

### Bootstrap

```sh
curl -fsLS https://raw.githubusercontent.com/brikehn/dotfiles/main/scripts/bootstrap.sh | sh
exec zsh -l
```

### Existing machine

Prerequisites: `curl`, `git`, `brew` (macOS)

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply brikehn
exec zsh -l
```

See [SETUP.md](SETUP.md) for details.

## Daily Usage

### Editing Dotfiles

Edit source files in `~/.local/share/chezmoi/`, then apply. Never edit live files directly — changes overwritten on next apply.

`chezmoi` aliased to `dotf`.

```sh
# Add new/changed files from live → source
dotf add ~/.config/nvim/init.lua

# Apply scoped (preferred)
dotf apply --force ~/.config/nvim

# Apply everything
dotf apply --force

# Preview before applying
dotf diff

# Find source file for a target
dotf source-path ~/.zshrc
```

**Neovim:** `<leader>df` opens Telescope fuzzy finder scoped to `$DOTFILES`.

### Machine-local overrides

This repo only holds config that's identical on every machine. Anything that differs per machine lives in an unmanaged local file that the shared config picks up if present:

| Shared (this repo)          | Machine-local (never committed)          |
| --------------------------- | ---------------------------------------- |
| `~/.config/zsh/.zshrc`      | `~/.config/zsh/work`, `~/.config/zsh/secrets` |
| `~/.config/mise/config.toml` | `~/.config/mise/config.work.toml` (loaded via `MISE_ENV=work`) |

Claude Code config (`~/.claude`) is not managed here.

### tmux Session Switcher

Unified session + git worktree picker. Open with `prefix+f`.

| Key      | Action                                               |
| -------- | ---------------------------------------------------- |
| `Enter`  | Switch to session/worktree or pick branch            |
| `ctrl-x` | Kill session (keeps worktree)                        |
| `ctrl-d` | Delete worktree (smart: deletes branch if on remote) |

More info: [SESSION_SWITCHER.md](dot_config/tmux/SESSION_SWITCHER.md)
