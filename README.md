# Dotfiles

Managed by [chezmoi](https://www.chezmoi.io/). Tools via [mise](https://mise.jdx.dev/) and brew (macOS).

---

## New machine

Runs bootstrap script — installs prereqs, then chezmoi.

```sh
# macOS
sh -c "$(curl -fsLS https://raw.githubusercontent.com/brikehn/dotfiles/main/scripts/bootstrap.sh)"

# Linux (Debian/Ubuntu)
wget -qO- https://raw.githubusercontent.com/brikehn/dotfiles/main/scripts/bootstrap.sh | sh
```

Sets zsh as default shell — takes effect on next login.

> **Linux:** if sudo is not configured, prompts for root password to set it up, then continues automatically.

### What bootstrap does

1. **macOS:** installs Xcode Command Line Tools (silent), then Homebrew
2. **Linux:** installs curl + git via apt; configures sudo if missing
3. Runs `chezmoi init --apply brikehn` — clones dotfiles, applies config
4. Installs mise tools (go, node, neovim, etc.), tmux plugins, zsh plugins, fonts

### Interactive steps

- **macOS:** Homebrew install prompts for password and confirmation — unavoidable

After bootstrap completes, reload the shell:

```sh
exec zsh
```

---

## Existing machine (first-time setup)

Prereqs already installed (curl, git, brew/apt). Just install chezmoi and apply:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io/lb)" -- init --apply brikehn
exec zsh
```

## Maintenance

Edit source files in `~/.local/share/chezmoi/`, then apply. Never edit live files directly — overwritten on next apply.

`chezmoi` aliased to `dotf`

```sh
# Apply scoped (preferred)
dotf apply --force ~/.config/nvim

# Apply everything
dotf apply --force

# Preview before applying
dotf diff

# Open source file for editing
dotf edit ~/.zshrc
```

### Neovim

`<leader>df` — Telescope fuzzy finder scoped to the dotfiles repo (`$DOTFILES`). Find and open source files without navigating manually.
