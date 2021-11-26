#!/bin/zsh

### VARIABLES & CONSTANTS ###
USER=$(id -u -n)
DOTFILES_REPO="https://github.com/brikehn/dotfiles.git"
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

setup_pacman() {
  print_msg "Updating repositories..."
  sudo pacman -Syyu --noconfirm >/dev/null 2>&1
  # Remove 'fakeroot-tcp' if running in WSL
  if grep -q WSL /proc/version; then
    print_msg "Removing fakeroot-tcp..."
    sudo pacman -Qq | grep -qw fakeroot-tcp && pacman --noconfirm -Rsc fakeroot-tcp >/dev/null 2>&1
  fi
  print_msg "Installing necessary dependencies..."
  sudo pacman -S --needed --noconfirm base-devel pacman-contrib >/dev/null 2>&1
}

packages=(
  "zsh"
  "zsh-completions"
  "zsh-syntax-highlighting"
  "zsh-autosuggestions"
  "starship"
  "stow"
  "tmux"
  "neovim"
  "nodejs"
  "npm"
  "yarn"
  "unzip"
  "ripgrep"
  "openssh"
  "docker"
  "docker-compose"
  "gnupg"
  "fzy"
)

install_packages() {
  print_msg "Installing packages..."
  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

install_aur_helper() {
  [ -f "/usr/bin/yay" ] || (
    cd /tmp
    print_msg "Installing yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg --noconfirm -si >/dev/null 2>&1
  )
}

aur_packages=()

install_aur_packages() {
  print_msg "Installing AUR packages..."
  yay -S --needed --noconfirm "${aur_packages[@]}"
}

install_dotfiles() {
  rm -rf "${DOTFILES}"
  print_msg "Installing dotfiles..."
  git clone "${DOTFILES_REPO}" "${DOTFILES}"
}

configs=(
  "alacritty"
  "fonts"
  "git"
  "nvim"
  "scripts"
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
    [ -e "${HOME}/${file}" ] && rm -rf "${HOME:?}/${file}"
  done
  sudo chsh -s /bin/zsh "${USER}"
}

setup_neovim() {
  print_msg "Setting up Neovim..."
  [ ! -d "${XDG_DATA_HOME}/nvim/site/pack/packer/start/packer.nvim" ] \
    && git clone https://github.com/wbthomason/packer.nvim \
      "${XDG_DATA_HOME}/nvim/site/pack/packer/start/packer.nvim"
  nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
  curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
  unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
  chmod +x /tmp/win32yank.exe
  sudo mv /tmp/win32yank.exe /usr/local/bin/
}

### MAIN ###

setup_pacman
install_packages
install_aur_helper
install_aur_packages
install_dotfiles
setup_dotfiles
setup_zsh
setup_neovim
print_msg "Setup complete!"
