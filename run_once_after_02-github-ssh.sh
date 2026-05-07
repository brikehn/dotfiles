#!/bin/sh
# One-time GitHub auth setup
set -e

log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
ok()  { printf '\033[1;32m    ✓ %s\033[0m\n' "$*"; }

export PATH="$HOME/.local/share/mise/shims:$PATH"

if [ "$(uname -s)" = "Darwin" ]; then
	log "GitHub auth (macOS)"
	if gh auth status >/dev/null 2>&1; then
		ok "already authenticated"
	else
		gh auth login --git-protocol ssh
		ok "authenticated"
	fi
	exit 0
fi

log "GitHub SSH key setup (Linux)"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
	mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
	ssh-keygen -t ed25519 -C "$(hostname)" -f "$HOME/.ssh/id_ed25519"
	ok "SSH key generated"
else
	ok "SSH key already exists"
fi

eval "$(ssh-agent -s)" >/dev/null
ssh-add "$HOME/.ssh/id_ed25519"

log "GitHub auth (Linux)"
if gh auth status >/dev/null 2>&1; then
	ok "already authenticated"
else
	gh auth login --git-protocol ssh
	ok "authenticated"
fi
