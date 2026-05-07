#!/bin/sh
# Install dependencies: packages, fonts, plugins, mise tools.
set -e

if [ "$(id -u)" -eq 0 ]; then
	SUDO=""
elif command -v sudo >/dev/null 2>&1; then
	SUDO="sudo"
else
	SUDO=""
fi

brew_install() {
	command -v "$1" >/dev/null 2>&1 || brew install "$1"
}

# Packages
case "$(uname -s)" in
Darwin)
	case "$(uname -m)" in
	arm64) eval "$(/opt/homebrew/bin/brew shellenv)" ;;
	x86_64) eval "$(/usr/local/bin/brew shellenv)" ;;
	esac
	brew_install jq
	command -v op >/dev/null 2>&1 || brew install 1password-cli
	brew_install tmux
	brew_install luarocks
	ls "$HOME/Library/Fonts/IosevkaTermNerdFont"* >/dev/null 2>&1 || brew install --cask font-iosevka-term-nerd-font
	;;
Linux)
	$SUDO apt-get update
	$SUDO apt-get install -y \
		jq \
		libssl-dev \
		luarocks \
		pkg-config \
		tmux \
		unzip \
		xz-utils
	;;
esac

# Mise tools (go, node, neovim, etc.)
MISE=$(command -v mise 2>/dev/null || echo "${HOME}/.local/bin/mise")
"$MISE" install

# Remove bootstrap chezmoi binary — mise manages it now
rm -f "$HOME/.local/bin/chezmoi"
