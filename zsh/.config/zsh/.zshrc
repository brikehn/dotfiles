# ----- Zsh Configuration -----

bindkey -e # Use emacs-style bindings

# Options
setopt MENU_COMPLETE # Enable menu completion
setopt INTERACTIVE_COMMENTS # Allow comments in shell
setopt HIST_IGNORE_ALL_DUPS # Remove duplicates in history

# Completion configuration
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# ----- Aliases -----

alias vim="nvim"

# Pretty `ls`
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ls="ls -FG"
else
  alias ls="ls -F --color=auto"
fi

# ----- Initialization -----

# Load secrets if present
test -f "${ZDOTDIR}/secrets" && source "${ZDOTDIR}/secrets"

# Load `starship` shell prompt
eval "$(starship init zsh)"

# Load helper functions
source "${ZDOTDIR}/zsh-functions"

# ----- Plugins -----

# zsh-completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    zmodload zsh/complist # Load zsh completion module

    # Completion menu keybinds
    bindkey -M menuselect '^h' vi-backward-char
    bindkey -M menuselect '^k' vi-up-line-or-history
    bindkey -M menuselect '^l' vi-forward-char
    bindkey -M menuselect '^j' vi-down-line-or-history
    bindkey "^ " autosuggest-accept # Trigger completion

    autoload -Uz compinit; compinit # Initialize completion
    _comp_options+=(globdots) # Include hidden files
fi

# zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)

# zsh-history-substring-search
bindkey '^p' history-substring-search-up
bindkey '^n' history-substring-search-down

zsh_add_plugin "zsh-autosuggestions"
zsh_add_plugin "zsh-syntax-highlighting" # must load last
zsh_add_plugin "zsh-history-substring-search" # must load after zsh-syntax-highlighting

eval "$(~/.local/bin/mise activate zsh)"
