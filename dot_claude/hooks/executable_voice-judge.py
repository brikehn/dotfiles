#!/usr/bin/env python3
"""Stop hook: judge prose written in Brian's voice against the `writing` skill.

Why this exists: default Claude prose reaches for em-dashes, arrow-chains, and
"Root cause is X, not Y" framing that Brian never uses. The `writing` skill
forbids them, but a rule that depends on Claude recalling it mid-turn fails
across a long session. This hook is the mechanical backstop: when a turn
produced prose meant to read as Brian's, it checks the output against the
writing rules and blocks once if it violates them.

Two cheap gates run before any model call, so the judge costs nothing on a
normal turn:

  1. SCOPE: a voice-relevant skill was invoked this turn (`writing`, or a skill
     that defers to it: `review-pr`, `create-pr`, `jira-ticket`, `pick-up-work`).
     No such skill => the turn is not producing Brian-voiced prose, exit silent.
  2. PRE-FILTER: the turn's assistant text contains a hard tell outside code
     fences (an em-dash, an arrow glyph, or a known formula phrase). No tell =>
     nothing the hard rules catch, exit silent.

Only when both fire does it call a cheap model (`dp ai claude -p --bare --model
sonnet`) to confirm the tell is a genuine voice violation in Brian-attributed
prose (not, say, an em-dash inside a quoted error string or a code sample). The
model reads the deployed `writing` skill as the rubric.

Bounded and fail-open like a good gate: honors stop_hook_active (one block per
turn, no loops), and any failure talking to the judge (missing CLI, timeout,
unparseable output) exits silent so a flaky judge never wedges the turn.
"""
import json
import os
import re
import shutil
import subprocess
import sys

# Skills whose output is (or contains) prose written as Brian. `writing` is the
# voice layer itself; the other four deliver PR/ticket/comment/Slack prose that
# routes through it. If any fired this turn, the turn is in voice scope.
VOICE_SKILLS = {"writing", "review-pr", "create-pr", "jira-ticket", "pick-up-work"}

WRITING_SKILL = os.path.expanduser("~/.claude/skills/writing/SKILL.md")

# Hard tells the writing skill names explicitly. Presence outside a code fence is
# necessary (not sufficient) for a violation; the model confirms. The em-dash and
# arrow are literal; the formulas are the Claude investigation-writing patterns
# the skill calls out by name.
EM_DASH = re.compile(r"—")     # em-dash (not hyphen, not en dash)
ARROW = re.compile(r"→|->|=>")  # arrow glyph or ascii arrow chains
FORMULA = re.compile(
    r"root cause is\b|takeaway:|\bsurfaced as\b|a symptom \w+ hops", re.I)


def _records(tpath):
    try:
        lines = open(tpath, encoding="utf-8").read().splitlines()
    except OSError:
        return []
    out = []
    for ln in lines:
        ln = ln.strip()
        if not ln:
            continue
        try:
            out.append(json.loads(ln))
        except ValueError:
            continue
    return out


def _turn_slice(records):
    """Records from the last genuine user prompt to end of file (this turn)."""
    last_user = None
    for i, r in enumerate(records):
        if r.get("type") != "user" or r.get("isMeta"):
            continue
        content = (r.get("message") or {}).get("content")
        has_text = False
        if isinstance(content, str) and content.strip():
            has_text = True
        elif isinstance(content, list):
            has_text = any(isinstance(c, dict) and c.get("type") == "text"
                           and c.get("text", "").strip() for c in content)
        if has_text:
            last_user = i
    return records[last_user:] if last_user is not None else records


def _skills_invoked(turn):
    """Canonical skill names invoked via the Skill tool this turn, plus any
    invoked through a slash command in the user prompt."""
    names = set()
    for r in turn:
        if r.get("type") == "assistant":
            for c in (r.get("message") or {}).get("content", []) or []:
                if isinstance(c, dict) and c.get("type") == "tool_use" \
                        and c.get("name") == "Skill":
                    s = (c.get("input") or {}).get("skill", "")
                    if s:
                        names.add(re.split(r"[/:]", s)[-1])
        elif r.get("type") == "user" and not r.get("isMeta"):
            content = (r.get("message") or {}).get("content")
            text = content if isinstance(content, str) else " ".join(
                c.get("text", "") for c in (content or [])
                if isinstance(c, dict) and c.get("type") == "text")
            for m in re.findall(r"<command-name>\s*/?([a-z-]+)", text, re.I):
                names.add(m)
            for m in re.findall(r"(?m)^\s*/([a-z-]+)\b", text):
                names.add(m)
    return names


def _assistant_text(turn):
    """Concatenated assistant text emitted this turn (the prose to inspect)."""
    parts = []
    for r in turn:
        if r.get("type") != "assistant":
            continue
        for c in (r.get("message") or {}).get("content", []) or []:
            if isinstance(c, dict) and c.get("type") == "text":
                parts.append(c.get("text", ""))
    return "\n".join(parts)


def _strip_code(text):
    """Remove fenced and inline code so a tell inside a code/error sample does
    not pre-trip the filter (the model would rule it out anyway, but this keeps
    the cheap gate cheap)."""
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"`[^`]*`", " ", text)
    return text


def _dp_bin():
    found = shutil.which("dp")
    if found:
        return found
    base = os.path.expanduser("~/.local/share/mise/installs/dailypay-dp")
    if os.path.isdir(base):
        for ver in sorted(os.listdir(base), reverse=True):
            cand = os.path.join(base, ver, "bin", "dp")
            if os.path.isfile(cand) and os.access(cand, os.X_OK):
                return cand
    return None


JUDGE_PROMPT = """You check whether prose written to read as if a specific person (Brian) wrote it follows his voice rules. You did NOT write it. Judge ONLY against the rules below, and only flag a CLEAR violation in prose that is genuinely meant to be his (a PR/review comment, a ticket body or comment, a Slack message, a doc, an email). Text that is Claude's own narration to the user, a tool result, a quoted error string, a file path, or code is NOT in scope: do not flag a tell that appears only there.

## The writing rules (rubric)

%s

## The assistant's output this turn

<<<OUTPUT
%s
OUTPUT

Return ONLY this JSON: {"violation": true|false, "detail": "<one sentence naming the specific tell and where, or empty>"}"""


def _ask(dp, prompt):
    try:
        proc = subprocess.run(
            [dp, "ai", "claude", "-p", "--bare", "--model", "sonnet",
             "--no-session-persistence", prompt],
            capture_output=True, text=True, timeout=40)
    except Exception:
        return None
    out = (proc.stdout or "").strip()
    m = re.search(r"\{.*\}", out, re.S)
    if not m:
        return None
    try:
        return json.loads(m.group(0))
    except ValueError:
        return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    if data.get("stop_hook_active"):
        return  # never block twice in a row
    tpath = data.get("transcript_path")
    if not tpath:
        return
    records = _records(tpath)
    if not records:
        return
    turn = _turn_slice(records)
    # Gate 1: was a voice-relevant skill in play this turn?
    if not (_skills_invoked(turn) & VOICE_SKILLS):
        return
    text = _assistant_text(turn)
    if not text.strip():
        return
    # Gate 2: any hard tell present outside code?
    clean = _strip_code(text)
    if not (EM_DASH.search(clean) or ARROW.search(clean) or FORMULA.search(clean)):
        return
    try:
        skill_body = open(WRITING_SKILL, encoding="utf-8").read()
    except OSError:
        return  # no rubric to judge against: fail-open
    dp = _dp_bin()
    if not dp:
        return
    verdict = _ask(dp, JUDGE_PROMPT % (skill_body, text))
    if not verdict or verdict.get("violation") is not True:
        return  # complies, or judge unavailable/unsure: fail-open
    detail = (verdict.get("detail") or "").strip() or \
        "an em-dash, arrow-chain, or a formulaic phrasing the writing skill forbids"
    print(json.dumps({
        "decision": "block",
        "reason": (
            "The prose you wrote as Brian violates the `writing` skill: %s "
            "Re-read the writing skill and rewrite that text in his voice (plain "
            "connectives instead of em-dashes/arrows, no \"root cause is X\" "
            "framing). If you judge this a false positive (the tell is only in "
            "code or a quote), say briefly why and proceed; you will not be "
            "blocked again this turn." % detail
        ),
    }))


if __name__ == "__main__":
    main()
