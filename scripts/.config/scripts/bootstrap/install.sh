#!/bin/sh

### OPTIONS AND VARIABLES ###
OS=$(uname -s)

# Colors
BLUE="$(tput setaf 4)"
NONE="$(tput sgr0)"

### FUNCTIONS ###

print_msg() {
  printf "${BLUE}::${NONE} %s\n" "${@}" >&1
}

welcome() {
  printf "${BLUE}%s${NONE}\n" "
        __       __    ___ __ __             
    .--|  .-----|  |_.'  _|__|  .-----.-----.
  __|  _  |  _  |   _|   _|  |  |  -__|__ --|
 |__|_____|_____|____|__| |__|__|_____|_____|
"
}

setup() {
  read -rp "${BLUE}::${NONE} Would you like to start the setup process? (y/N): " yn
  case $yn in
    [Yy]*) find_os ;;
    *)
      print_msg "Exiting setup..."
      exit
      ;;
  esac
  unset yn
}

find_os() {
  case "${OS}" in
    "Linux")
      DISTRO=$(sed -n 's/^NAME=\(.*\)/\1/p' </etc/os-release)
      case "${DISTRO}" in
        *Arch*) sh "${HOME}/.dotfiles/scripts/.config/scripts/bootstrap/os/arch.sh" ;;
        *)
          print_msg "Sorry, your Linux distribution is not supported."
          exit 1
          ;;
      esac
      ;;
    "Darwin") sh "${HOME}/.dotfiles/scripts/.config/scripts/bootstrap/os/macos.sh" ;;
    *)
      print_msg "Operating system not supported, exiting..."
      exit 1
      ;;
  esac
}

### MAIN ###

welcome
setup
