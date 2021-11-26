#!/bin/zsh

### VARIABLES & CONSTANTS ###
USER=$(id -u -n)
AUR_HELPER="yay"
DOTFILES_REPO="https://github.com/brikehn/dotfiles.git"
DOTFILES=${HOME}/.dotfiles

# Colors
BLUE="$(tput setaf 4)"
NONE="$(tput sgr0)"

# Set XDG directories.
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

# Set Zsh configuration directory.
export ZDOTDIR="${HOME}/.config/zsh"

### FUNCTIONS ###

print_msg() {
  printf "%s\r" "${@}" >&1
}

setup_pacman() {
  sudo pacman -Syyu --noconfirm >/dev/null 2>&1
  print_msg "[....................] [  0%]"
  # Remove 'fakeroot-tcp' if running in WSL
  print_msg "[####................] [ 20%]"
  if grep -q WSL /proc/version; then
    print_msg "[#####...............] [ 25%]"
    sudo pacman -Qq | grep -qw fakeroot-tcp && pacman --noconfirm -Rsc fakeroot-tcp >/dev/null 2>&1
  fi
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
  "shfmt"
  "shellcheck"
  "python"
  "python-pip"
  "flake8"
  "python-black"
  "yamllint"
)

install_packages() {
  print_msg "[#####...............] [ 25%]"
  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

install_aur_helper() {
  [ -f "/usr/bin/yay" ] || (
    cd /tmp
    print_msg "[##########..........] [ 50%]"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg --noconfirm -si >/dev/null 2>&1
  )
}

aur_packages=(
  "stylua"
)

install_aur_packages() {
  print_msg "[###########.........] [ 55%]"
  yay -S --needed --noconfirm "${aur_packages[@]}"
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
  print_msg "[#############.......] [ 65%]"
  cd "${DOTFILES}"
  stow -D "${configs[@]}"
  stow "${configs[@]}"
}

setup_zsh() {
  print_msg "[################....] [ 80%]"
  zsh_dotfiles=(".zsh" ".zlogin" ".zlogout" ".zshenv" ".zshrc")
  # Delete default Zsh configuration files if present.
  for file in "${zsh_dotfiles[@]}"; do
    [ -e "${HOME}/${file}" ] && rm -rf "${HOME:?}/${file}"
  done
  sudo chsh -s /bin/zsh "${USER}"
}

setup_neovim() {
  print_msg "[#################...] [ 85%]"
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
setup_dotfiles
setup_zsh
setup_neovim
printf "%s" "[####################] [100%] Setup is now complete!"
