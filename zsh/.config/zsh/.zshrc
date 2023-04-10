#!/bin/zsh

### ZSH
setopt menucomplete
setopt interactive_comments
stty stop undef # Disable ctrl-s to freeze terminal
zle_highlight=('paste:none')

unsetopt BEEP

### Completions
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

### Functions
source "${ZDOTDIR}/zsh-functions"

### Plugins
zsh_add_plugin "zsh-completions"
zsh_add_plugin "zsh-autosuggestions"
zsh_add_plugin "zsh-syntax-highlighting"

### Aliases
alias vim="nvim"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ls="ls -FG"
else
  alias ls="ls -F --color=auto"
fi

alias awsps='export AWS_PROFILE=$( aws configure list-profiles | fzf )'

### Keybinds
bindkey -v
bindkey "^p" up-line-or-beginning-search # Up
bindkey "^n" down-line-or-beginning-search # Down
bindkey "^k" up-line-or-beginning-search # Down
bindkey "^j" down-line-or-beginning-search # Down
bindkey -r "^u"
bindkey -r "^d"
bindkey "^ " autosuggest-accept
bindkey "^[[Z" reverse-menu-complete

export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^l' vi-forward-char
bindkey -M menuselect '^j' vi-down-line-or-history

test -f "${ZDOTDIR}/secrets" && source "${ZDOTDIR}/secrets"

if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
    ssh-add
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
path+=("$HOME/.rvm/bin")

path+=("$HOME/.local/bin")

path+="$(yarn global bin)"

export PATH

. "$HOME/.cargo/env"

# bun completions
[ -s "/Users/thebriankwon/.bun/_bun" ] && source "/Users/thebriankwon/.bun/_bun"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

eval "$(starship init zsh)"
