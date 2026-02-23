# Default programs
export EDITOR="nvim"

# Environment variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Zsh config location
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Load `brew`
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load `mise`
eval "$(~/.local/bin/mise activate zsh)"

# Load `starship` shell prompt
eval "$(starship init zsh)"

# For colorful completions
export CLICOLOR=1 
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
export LS_COLORS='no=00;37:fi=00:di=00;33:ln=04;36:pi=40;33:so=01;35:bd=40;33;01:'

export DOTFILES="$HOME/.dotfiles"
