# Dotfiles

## Tools I use:

### Package manager
* brew (macOS)

### Utilities
* stow
* unzip
* ripgrep
* fzy
* gnupg

### Terminal/Shell
* zsh
    * zsh-syntax-highlighting
    * zsh-completions
    * zsh-autosuggestions
* starship

### Dev Toolbox
* git
* neovim
* node
* tmux
* yarn
* docker

## Manual Installation

```sh
git clone https://github.com/brikehn/dotfiles.git ~/.dotfiles
```

```sh
cd ~/.dotfiles

# Add config
stow <dir_name>

# Delete config
stow -D <dir_name>
```

## Fix tmux

```sh
/usr/local/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
tic -xe tmux-256color tmux-256color.info
infocmp tmux-256color | head
```
