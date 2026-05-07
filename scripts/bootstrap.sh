#!/bin/sh
# Bootstrap a new machine before running chezmoi.
# Usage: sh -c "$(curl -fsLS https://raw.githubusercontent.com/brikehn/dotfiles/main/bootstrap.sh)"
set -e

SELF_URL="https://raw.githubusercontent.com/brikehn/dotfiles/main/bootstrap.sh"

# --- Linux: sudo setup ---
# On Debian server installs, sudo may not be pre-configured.
# Install it via su and re-exec this script in a new login session.
if [ "$(uname -s)" = "Linux" ] && [ "$(id -u)" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
	echo "sudo not found. Enter root password to install it:"
	if ! su -c "apt-get update && apt-get install -y sudo && usermod -aG sudo $(id -un)"; then
		echo "error: authentication failed. Re-run this script to try again." >&2
		exit 1
	fi
	echo "sudo configured. Continuing in new session..."
	exec su - "$(id -un)" -c "wget -qO- $SELF_URL | sh"
fi

if [ "$(id -u)" -eq 0 ]; then
	SUDO=""
elif command -v sudo >/dev/null 2>&1; then
	SUDO="sudo"
fi

# --- macOS: Xcode Command Line Tools ---
if [ "$(uname -s)" = "Darwin" ]; then
	if ! xcode-select -p >/dev/null 2>&1; then
		echo "Installing Xcode Command Line Tools..."
		touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
		CLT=$(softwareupdate -l 2>/dev/null | grep -B 1 -E 'Command Line Tools' | awk -F'*' '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -1)
		$SUDO softwareupdate -i "$CLT" --verbose
		$SUDO xcode-select --switch /Library/Developer/CommandLineTools
		rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
	fi
fi

# --- Linux: prereqs for chezmoi (curl, git) ---
if [ "$(uname -s)" = "Linux" ]; then
	$SUDO apt-get update
	$SUDO apt-get install -y curl git
fi

# --- chezmoi init + apply ---
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply brikehn
