#!/bin/zsh

### VARIABLES & CONSTANTS ###
USER=$(id -u -n)
DOTFILES_REPO="git@github.com:brikehn/dotfiles"
DOTFILES=${HOME}/.dotfiles

# Colors
BLUE="$(tput setaf 4)"
NONE="$(tput sgr0)"

# Set XDG directories.
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

### FUNCTIONS ###

print_msg() {
  printf "${BLUE}::${NONE} %s\n" "${@}" >&1
}

install_homebrew() {
  [ -f "/usr/local/bin/brew" ] || (
    print_msg "Installing Homebrew..."
    /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  )
}

packages=(
  "git"
  "zsh-completions"
  "zsh-syntax-highlighting"
  "zsh-autosuggestions"
  "starship"
  "stow"
  "tmux"
  "neovim"
  "node"
  "yarn"
  "unzip"
  "ripgrep"
  "fzy"
  "gnupg"
)

install_packages() {
  print_msg "Installing packages..."
  brew install "${packages[@]}"
}

install_dotfiles() {
  rm -rf "${DOTFILES}"
  print_msg "Installing dotfiles..."
  git clone "${DOTFILES_REPO}" "${DOTFILES}"
}

configs=(
  "git"
  "nvim"
  "starship"
  "tmux"
  "zsh"
)

setup_dotfiles() {
  print_msg "Setting up dotfiles..."
  cd "${DOTFILES}"
  stow -D "${configs[@]}"
  stow "${configs[@]}"
}

setup_zsh() {
  print_msg "Setting up zsh..."
  zsh_dotfiles=(".zsh" ".zlogin" ".zlogout" ".zshenv" ".zshrc")
  # Delete default Zsh configuration files if present.
  for file in "${zsh_dotfiles[@]}"; do
    [ -e "${HOME}/${file}" ] && rm -rf "${HOME:?}/${file}" >/dev/null 2>&1
  done
  print_msg "Setting Zsh as default shell..."
  chsh -s /bin/zsh "${USER}"
}

setup_neovim() {
  print_msg "Setting up Neovim..."
  [ ! -d "${XDG_DATA_HOME}/nvim/site/pack/packer/start/packer.nvim" ] \
    && git clone https://github.com/wbthomason/packer.nvim \
      "${XDG_DATA_HOME}/nvim/site/pack/packer/start/packer.nvim"
  nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

fix_tmux() {
  print_msg "Fixing tmux encoding issue..."
  /usr/local/opt/ncurses/bin/infocmp tmux-256color > ~/tmux-256color.info
  tic -xe tmux-256color tmux-256color.info
  infocmp tmux-256color | head
}

### MAIN ###

install_homebrew
install_packages
install_dotfiles
setup_dotfiles
setup_zsh
setup_neovim
fix_tmux
print_msg "Setup complete!"
