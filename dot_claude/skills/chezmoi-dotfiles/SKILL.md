---
name: chezmoi-dotfiles
description: Use when reading, editing, or applying any dotfile managed by chezmoi — including zsh config, git config, mise config, nvim config, Claude Code settings, or any file under ~/.local/share/chezmoi/. Also use when adding new dotfiles, writing chezmoi scripts, working with chezmoi templates, or bootstrapping a new machine. If the user asks to change any config file that lives in their home directory, check whether it's chezmoi-managed before editing it directly.
---

# Chezmoi Dotfiles

Dotfiles are managed by chezmoi. The source of truth is `~/.local/share/chezmoi/` — not the live files in `~`. Editing live files directly means changes will be overwritten on the next `chezmoi apply`.

## Docs — read these before guessing

| Topic                                              | URL                                                                      |
| -------------------------------------------------- | ------------------------------------------------------------------------ |
| Source state attributes (prefixes/suffixes)        | https://www.chezmoi.io/reference/source-state-attributes/                |
| Special files (.chezmoidata, .chezmoiignore, etc.) | https://www.chezmoi.io/reference/special-files/                          |
| Templates                                          | https://www.chezmoi.io/reference/templates/                              |
| Scripts (run_once, run_onchange)                   | https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/        |
| Daily operations                                   | https://www.chezmoi.io/user-guide/daily-operations/                      |
| Machine differences                                | https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/ |
| Commands reference                                 | https://www.chezmoi.io/reference/commands/                               |

When unsure about chezmoi behavior, fetch the relevant doc above rather than guessing.

## Hard Rules

- **Never edit `~` config files directly.** Always edit `~/.local/share/chezmoi/` source, then apply.
- **Always apply after editing.** Scope `chezmoi apply --force` to only the changed target path.
- **chezmoi runs via mise.** Use `mise exec chezmoi -- chezmoi <cmd>` — bare `chezmoi` is not in PATH.

## Source Naming

Chezmoi encodes metadata in source filenames via prefixes and suffixes. Key ones:

| Source name                              | Target            | Why                                        |
| ---------------------------------------- | ----------------- | ------------------------------------------ |
| `dot_zprofile`                           | `~/.zprofile`     | `dot_` → leading dot                       |
| `dot_config/nvim/`                       | `~/.config/nvim/` | directory, same rule                       |
| `settings.json.tmpl`                     | `settings.json`   | `.tmpl` → processed as Go template         |
| `run_once_before_00-bootstrap.sh`        | (script)          | runs once, before apply, ordered by name   |
| `run_onchange_before_01-install-deps.sh` | (script)          | re-runs when content changes, before apply |
| `executable_myscript.sh`                 | `myscript.sh`     | sets executable bit                        |

Full attribute reference: https://www.chezmoi.io/reference/source-state-attributes/

## Machine-Local Variables

`.chezmoi.toml.tmpl` in the repo root prompts during `chezmoi init` and writes values into `~/.config/chezmoi/chezmoi.toml` under `[data]`:

```toml
[data]
    isWork = {{ promptBool "Work machine?" false }}
```

Values are available in all `.tmpl` files as `.variableName`. Template usage: `{{- if .isWork -}} ... {{- end -}}`. The `-` trims surrounding whitespace.

Reference: https://www.chezmoi.io/reference/special-files/chezmoi-format-tmpl/

## Claude Code Settings Split

`dot_claude/settings.json.tmpl` dispatches to `.chezmoitemplates/`:

```
{{- if .isWork -}}
{{-   template "claude_settings_work.tmpl" . -}}
{{- else -}}
{{-   template "claude_settings_personal.tmpl" . -}}
{{- end -}}
```

- `claude_settings_personal.tmpl` — model/effortLevel/advisorModel; caveman plugin; extraKnownMarketplaces
- `claude_settings_work.tmpl` — none of the above; no third-party marketplaces

## Scripts

Two script prefixes, with different re-run semantics:

| Prefix                 | Re-runs when                                 | Use for                                                      |
| ---------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| `run_once_before_`     | Never again (content-hash keyed per machine) | Bootstrap: install brew once                                 |
| `run_onchange_before_` | Script content changes                       | Dep list: add a package, commit, apply — all machines get it |

Numbers in filenames (`00-`, `01-`) control execution order (alphabetical sort).

Reference: https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/

## Script Idempotency

Scripts must be safe to re-run. Two pitfalls:

**`set -e` + `&&` short-circuit**: `[ ! -d "$dir" ] && git clone ...` — when dir exists, the test exits 1, `set -e` kills the script. Use `if`:

```sh
clone_if_missing() {
  if [ ! -d "$2" ]; then
    git clone --depth=1 "$1" "$2"
  fi
}
```

**Package manager state ≠ actual state**: `brew list` returns non-zero for manually installed tools. Check real state instead:

```sh
# CLI tools
command -v tmux >/dev/null 2>&1 || brew install tmux

# Fonts (macOS) — check ~/Library/Fonts/ directly
font_installed() {
  ls "$HOME/Library/Fonts/${1}"* >/dev/null 2>&1
}
font_installed IosevkaTermNerdFont || brew install --cask font-iosevka-term-nerd-font
```

## Workflow for Any Change

1. Edit source in `~/.local/share/chezmoi/`.
2. `mise exec chezmoi -- chezmoi apply --force <target-path>` (scope to changed file/dir).
3. Confirm live file updated.
4. Commit in `~/.local/share/chezmoi/`.

## Common Commands

```sh
# Apply all
mise exec chezmoi -- chezmoi apply --force

# Apply scoped (prefer this)
mise exec chezmoi -- chezmoi apply --force ~/.config/nvim

# Preview changes without applying
mise exec chezmoi -- chezmoi diff

# Find source file for a target
mise exec chezmoi -- chezmoi source-path ~/.zprofile

# Verify installation
mise exec chezmoi -- chezmoi doctor
```

## Bootstrap (new machine)

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply brikehn
```

Prompts "Work machine?" during init — no manual config needed.

Full guide: https://www.chezmoi.io/user-guide/daily-operations/#install-chezmoi-and-your-dotfiles-on-a-new-machine-with-a-single-command

## mise.toml Organization

`dot_config/mise/config.toml` tools grouped with comments:
`# languages` / `# shell` / `# cli tools` / `# editors` / `# ai` / `# dotfiles`
