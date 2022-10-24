#!/bin/zsh

# Default programs:
export EDITOR="nvim"

# Environment variables:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

HISTFILE="${XDG_CACHE_HOME}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

export DOTFILES="$HOME/.dotfiles"

# UTF-8 encoding
export LC_CTYPE=en_US.UTF-8

# Zsh
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

if [ ! -d "$HOME/.cache/zsh" ]; then
  mkdir -p "$HOME/.cache/zsh"
fi

# For colorful completions
export CLICOLOR=1 
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
export LS_COLORS='no=00;37:fi=00:di=00;33:ln=04;36:pi=40;33:so=01;35:bd=40;33;01:'

# GnuPG
export GPG_TTY=$(tty)

# Starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export STARSHIP_CACHE=~/.cache/starship

# NPM
if [ -f "${XDG_CONFIG_HOME}/npm/token" ]; then
  source "${XDG_CONFIG_HOME}/npm/token"
fi

export BUN_INSTALL="/Users/thebriankwon/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"
