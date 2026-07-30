#!/usr/bin/env python3
"""PreToolUse hook: deny WebFetch to systems that have a dedicated tool.

Brian's CLAUDE.md mandates the right tool per system: the Atlassian MCP tools
for Jira/Confluence, the `gh` CLI for GitHub, and `pup` for Datadog. WebFetch on
any of those hits authenticated content it cannot read anyway, so this hook
denies the fetch and points at the correct tool. Any other URL (upstream release
notes, a provider upgrade guide, a blog) is left alone: WebFetch is the right
tool there.

Reads the tool-call JSON on stdin. Fail-open on anything unparseable.
"""
import json
import re
import sys

# host substring -> (label, what to use instead)
ROUTES = [
    ("atlassian.net", "Jira/Confluence",
     "the Atlassian MCP tools (mcp__plugin_atlassian_atlassian__getJiraIssue / "
     "search / getConfluencePage). cloudId is dailypay.atlassian.net. Extract the "
     "key or id from the URL and call the MCP tool."),
    ("jira.", "Jira",
     "the Atlassian MCP tools (mcp__plugin_atlassian_atlassian__getJiraIssue). "
     "Extract the key from the URL."),
    ("github.com", "GitHub",
     "the gh CLI (gh pr view / gh api repos/...). Extract the id from the URL and "
     "run the command."),
    ("datadoghq.com", "Datadog",
     "the pup CLI (pup logs search / pup metrics query / pup monitors get). "
     "Datadog content is authenticated and unreadable via WebFetch."),
]


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    if data.get("tool_name") != "WebFetch":
        return
    url = (data.get("tool_input") or {}).get("url", "")
    if not isinstance(url, str) or not url:
        return
    host = re.sub(r"^[a-z]+://", "", url, flags=re.I).split("/")[0].split("?")[0].lower()
    for needle, label, guidance in ROUTES:
        if needle in host:
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": (
                        "Do not WebFetch %s (%s); it is authenticated and unreadable "
                        "that way. Use %s" % (host, label, guidance)
                    ),
                }
            }))
            return


if __name__ == "__main__":
    main()
