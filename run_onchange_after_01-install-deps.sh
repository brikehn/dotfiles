#!/bin/sh
# Install dependencies: packages, fonts, plugins, mise tools.
set -e

log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m    ✓ %s\033[0m\n' "$*"; }

if [ "$(id -u)" -eq 0 ]; then
	SUDO=""
elif command -v sudo >/dev/null 2>&1; then
	SUDO="sudo"
else
	SUDO=""
fi

brew_install() {
	if command -v "$1" >/dev/null 2>&1; then
		ok "$1 already installed"
	else
		brew install "$2"
		ok "$1 installed"
	fi
}

case "$(uname -s)" in
Darwin)
	case "$(uname -m)" in
	arm64) eval "$(/opt/homebrew/bin/brew shellenv)" ;;
	x86_64) eval "$(/usr/local/bin/brew shellenv)" ;;
	esac

	log "Installing brew packages"
	brew_install jq jq
	brew_install op 1password-cli
	brew_install tmux tmux
	brew_install luarocks luarocks

	log "Installing fonts"
	if ls "$HOME/Library/Fonts/IosevkaTermNerdFont"* >/dev/null 2>&1; then
		ok "IosevkaTermNerdFont already installed"
	else
		brew install --cask font-iosevka-term-nerd-font
		ok "IosevkaTermNerdFont installed"
	fi
	;;
Linux)
	log "Installing apt packages"
	$SUDO apt-get update -q
	$SUDO apt-get install -y \
		jq \
		libssl-dev \
		luarocks \
		pkg-config \
		tmux \
		unzip \
		xz-utils
	ok "apt packages installed"
	;;
esac

log "Installing mise tools"
MISE=$(command -v mise 2>/dev/null || echo "${HOME}/.local/bin/mise")
"$MISE" install
ok "mise tools installed"

log "Cleaning up bootstrap chezmoi binary"
rm -f "$HOME/.local/bin/chezmoi"
ok "done"
