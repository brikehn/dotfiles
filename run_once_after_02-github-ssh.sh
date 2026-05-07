#!/bin/sh
# One-time GitHub auth setup
set -e

if [ "$(uname -s)" = "Darwin" ]; then
    if ! gh auth status >/dev/null 2>&1; then
        gh auth login --git-protocol ssh
    fi
    exit 0
fi

# Linux: generate key, load agent, auth gh
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$(hostname)" -f "$HOME/.ssh/id_ed25519"
fi

eval "$(ssh-agent -s)" >/dev/null
ssh-add "$HOME/.ssh/id_ed25519"

if ! gh auth status >/dev/null 2>&1; then
    gh auth login --git-protocol ssh
fi
