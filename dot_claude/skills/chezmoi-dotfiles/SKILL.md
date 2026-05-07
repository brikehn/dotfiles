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

- **Never edit `~` directly.** Edit `~/.local/share/chezmoi/` source, then apply.
- **Always apply after editing.** Scope to changed path: `chezmoi apply --force <path>`.
- **Use `chezmoi add` to bring live changes back to source.**
- **Auto-commit/push on personal machines only.** Work machines: commit manually.
- **chezmoi aliased to `dotf` in shell.** Use full command in docs/scripts.

## Source Naming

| Source                       | Target            | Meaning                         |
| ---------------------------- | ----------------- | ------------------------------- |
| `dot_zprofile`               | `~/.zprofile`     | `dot_` → leading dot            |
| `executable_myscript.sh`     | `myscript.sh`     | sets executable bit             |
| `file.tmpl`                  | `file`            | Go template (rendered on apply) |
| `run_once_before_00-foo.sh`  | (script)          | runs once, never again          |
| `run_onchange_before_bar.sh` | (script)          | re-runs when content changes    |

Doc: https://www.chezmoi.io/reference/source-state-attributes/

## Machine-Local Variables

`.chezmoi.toml.tmpl` prompts on `init`, stores in `~/.config/chezmoi/chezmoi.toml` under `[data]`. Use in `.tmpl` files as `{{ .variableName }}`.

Example: `{{- if .isWork -}} ... {{- end -}}` (the `-` trims whitespace).

Doc: https://www.chezmoi.io/reference/special-files/chezmoi-format-tmpl/

## Scripts

| Prefix             | Re-runs when          | Use for               |
| ------------------ | --------------------- | --------------------- |
| `run_once_`        | Never (hash-keyed)    | Bootstrap (brew once) |
| `run_onchange_`    | Content changes       | Deps (propagates)     |
| Numbers: `00-`,... | Controls exec order   | Alphabetical sort     |

Doc: https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/

## Script Idempotency

Must be safe to re-run. Pitfalls:

**`set -e` + `&&`**: Use `if` not `[ ! -d "$d" ] && git clone` (short-circuit exits 1).

**Package state ≠ reality**: Check real state, not `brew list` (fails for manual installs).

```sh
command -v tmux >/dev/null 2>&1 || brew install tmux
ls ~/Library/Fonts/IosevkaTermNerdFont* >/dev/null 2>&1 || brew install --cask font-iosevka-term-nerd-font
```

## Auto Commit / Push

Personal: `autoCommit = true` and `autoPush = true` (apply commits+pushes automatically).
Work: disabled. Commit manually.

## Workflow

**Edit source first (preferred):**
1. Edit `~/.local/share/chezmoi/`
2. `chezmoi apply --force <path>`
3. Personal: done (auto-committed). Work: commit manually.

**Edited live file:**
1. `chezmoi add <path>` (copies live → source, preserves attributes)
2. `chezmoi apply --force <path>` (verify)
3. Personal: done. Work: commit manually.

Use `chezmoi add` for: new files, bringing live changes back, executable scripts.

## Commands

```sh
chezmoi add <path>           # Live → source (auto-detects attributes)
chezmoi apply --force <path> # Source → live (scoped, preferred)
chezmoi diff                 # Preview changes
chezmoi source-path <path>   # Find source for target
chezmoi update               # Pull remote + apply
```

## Bootstrap

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply brikehn
```

Prompts "Work machine?" on init.
