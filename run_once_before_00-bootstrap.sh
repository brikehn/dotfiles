#!/bin/sh
# One-time machine bootstrap. Installs package managers and core infrastructure.
set -e

if [ "$(id -u)" -eq 0 ]; then
	SUDO=""
elif command -v sudo >/dev/null 2>&1; then
	SUDO="sudo"
else
	echo "error: linux bootstrap requires root or sudo" >&2
	exit 1
fi

command -v mise >/dev/null 2>&1 || curl https://mise.run | sh

case "$(uname -s)" in
Darwin)
	if ! command -v brew >/dev/null 2>&1; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	;;
Linux)
	$SUDO apt-get update
	$SUDO apt-get install -y \
		build-essential \
		ca-certificates \
		curl \
		git \
		zsh
	$SUDO chsh -s "$(command -v zsh)" "$USER"
	;;
esac
