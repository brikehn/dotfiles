#!/usr/bin/env python3
"""PreToolUse hook: deny inline-interpreter one-liners, point to the right tool.

Reads the tool-call JSON on stdin. If a Bash command runs code inline via
`python3 -c`, `node -e`, `ruby -e`, `perl -e` (and common variants), it returns
a "deny" decision telling Claude to use the dedicated tool instead: `yq` for
YAML, `jq` for JSON, `actionlint` for GitHub workflows, a CLI's own flags
otherwise. Inline interpreters are arbitrary code and the wrong tool for
parsing/validation, which is what CLAUDE.md's tool-preference rules ask for.

Running a script file (`python3 foo.py`, `node app.js`) is NOT blocked: only
the inline-code flags (-c / -e) are. Fail-open: on any doubt, prints nothing
and exits 0, deferring to the normal flow. It never approves.
"""
import json
import sys

# interpreter -> the flag that means "run this inline code string".
INLINE = {
    "python": "-c", "python3": "-c", "py": "-c",
    "node": "-e", "nodejs": "-e", "deno": "-e", "bun": "-e",
    "ruby": "-e", "perl": "-e",
}


def offending_interpreter(command):
    # Look for `<interp> ... -c/-e` as a command word followed (anywhere in its
    # args) by the inline flag. Token scan keeps it simple and quote-agnostic
    # enough for detection (we only need to decide deny vs defer).
    toks = command.replace("|", " | ").split()
    for idx, tok in enumerate(toks):
        base = tok.split("/")[-1]
        flag = INLINE.get(base)
        if not flag:
            continue
        # scan this interpreter's args (until a shell operator) for the flag.
        for t in toks[idx + 1:]:
            if t in ("|", "&&", "||", ";", "&", ">", ">>", "<"):
                break
            if t == flag or t.startswith(flag):
                return base
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    if data.get("tool_name") != "Bash":
        return
    command = (data.get("tool_input") or {}).get("command", "")
    if not isinstance(command, str) or not command:
        return
    interp = offending_interpreter(command)
    if not interp:
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "Do not run inline code with %s -c/-e for parsing or validation. "
                "Use the dedicated tool: yq for YAML, jq for JSON, actionlint for "
                "GitHub workflows, or a CLI's own flags. Run a script file if you "
                "genuinely need %s." % (interp, interp)
            ),
        }
    }))


if __name__ == "__main__":
    main()
