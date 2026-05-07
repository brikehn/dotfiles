#!/bin/sh
# One-time machine bootstrap. Installs package managers and core infrastructure.
set -e

log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m    ✓ %s\033[0m\n' "$*"; }

if [ "$(id -u)" -eq 0 ]; then
	SUDO=""
elif command -v sudo >/dev/null 2>&1; then
	SUDO="sudo"
else
	echo "error: linux bootstrap requires root or sudo" >&2
	exit 1
fi

log "Installing mise"
if command -v mise >/dev/null 2>&1; then
	ok "mise already installed"
else
	curl https://mise.run | sh
	ok "mise installed"
fi

case "$(uname -s)" in
Darwin)
	log "Installing Homebrew"
	if command -v brew >/dev/null 2>&1; then
		ok "brew already installed"
	else
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		ok "brew installed"
	fi
	;;
Linux)
	log "Installing Linux prereqs"
	$SUDO apt-get update -q
	$SUDO apt-get install -y \
		build-essential \
		ca-certificates \
		curl \
		git \
		zsh
	$SUDO chsh -s "$(command -v zsh)" "$USER"
	ok "Linux prereqs installed, shell set to zsh"
	;;
esac
