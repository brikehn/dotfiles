#!/usr/bin/env python3
"""SessionStart hook: warn when the deployed ~/.claude differs from chezmoi source.

Brian edits the chezmoi source (~/.local/share/chezmoi/dot_claude) and activates
a change by running `chezmoi apply`. Edit the source and forget to apply, and the
running Claude Code silently uses the old deployed copy of a skill, hook, or
settings block. Nothing built in catches this.

So at session start this checks whether `chezmoi status` reports any pending
change under the claude target (~/.claude) and, if so, prints a one-line notice
naming the drifted paths. Silent when in sync. Fail-open and bounded: chezmoi
missing, a slow status, or any error just prints nothing (the session proceeds),
because a drift warning must never wedge startup.

The reverse direction (source behind git origin) is not checked here: this is a
personal dotfiles repo, not a multi-machine install with copied helpers, so "did
I apply my own edits" is the failure that actually happens.
"""
import json
import os
import shutil
import subprocess
import sys

TARGET = os.path.expanduser("~/.claude")


def _chezmoi_bin():
    """Locate chezmoi; it is mise-managed and may be off a bare hook's PATH."""
    found = shutil.which("chezmoi")
    if found:
        return found
    base = os.path.expanduser("~/.local/share/mise/installs/chezmoi")
    if os.path.isdir(base):
        for ver in sorted(os.listdir(base), reverse=True):
            cand = os.path.join(base, ver, "bin", "chezmoi")
            if os.path.isfile(cand) and os.access(cand, os.X_OK):
                return cand
    for cand in ("/opt/homebrew/bin/chezmoi", "/usr/local/bin/chezmoi"):
        if os.path.isfile(cand):
            return cand
    return None


def main():
    try:
        json.load(sys.stdin)  # consume the event payload; contents unused
    except Exception:
        pass
    cm = _chezmoi_bin()
    if not cm:
        return
    try:
        # `chezmoi status <target>` is cheaper than a full diff: one status line
        # per pending path, empty when in sync. Bounded well under any hook cap.
        proc = subprocess.run(
            [cm, "status", TARGET],
            capture_output=True, text=True, timeout=8)
    except Exception:
        return
    out = (proc.stdout or "").strip()
    if not out:
        return  # in sync, nothing to say
    # Each line is "<codes> <path>"; collect the drifted paths, relative to home.
    paths = []
    for ln in out.splitlines():
        parts = ln.split(None, 1)
        if len(parts) == 2:
            paths.append(parts[1])
    if not paths:
        return
    shown = ", ".join(paths[:6]) + (" ..." if len(paths) > 6 else "")
    notice = ("chezmoi drift: %d path(s) under ~/.claude differ from source "
              "(edited but not applied): %s. Run `chezmoi apply` to activate, or "
              "`chezmoi diff` to review." % (len(paths), shown))
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": notice,
        }
    }))


if __name__ == "__main__":
    main()
