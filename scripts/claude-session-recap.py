#!/usr/bin/env python3
"""Summarize recent Claude Code sessions from their transcripts.

Enumerates local session transcripts under ~/.claude/projects, keeps the ones
with real conversation activity inside a time window (default: today, local
time), and prints a compact per-session recap: title, git branch, a resume
command, turn count and duration, files touched, edit count, and the last
user prompt / agent reply.

Usage:
    recap.py                 # today
    recap.py yesterday       # just yesterday
    recap.py 2026-08-20      # a specific local date
    recap.py 3d              # a rolling window of the last 3 days (incl. today)
    recap.py 2026-08-18..2026-08-20   # an inclusive local date range
"""

import glob
import json
import os
import re
import sys
from datetime import datetime, timedelta, date

PROJECTS_DIR = os.path.expanduser("~/.claude/projects")

# Tools that represent a code change, for the "edits" count.
EDIT_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}

# A last agent reply equal to one of these is a background/no-op line; when we
# hit it we walk back to the preceding substantive reply instead.
NON_REPLY_LINES = {"No response requested.", "(no content)"}


def parse_window(arg):
    """Return (start_date, end_date) inclusive local dates, or None for all."""
    today = datetime.now().astimezone().date()
    if not arg or arg.strip().lower() == "today":
        return today, today
    a = arg.strip().lower()
    if a == "yesterday":
        y = today - timedelta(days=1)
        return y, y
    m = re.fullmatch(r"(\d{4}-\d{2}-\d{2})", a)
    if m:
        d = date.fromisoformat(m.group(1))
        return d, d
    m = re.fullmatch(r"(\d{4}-\d{2}-\d{2})\.\.(\d{4}-\d{2}-\d{2})", a)
    if m:
        return date.fromisoformat(m.group(1)), date.fromisoformat(m.group(2))
    m = re.fullmatch(r"(\d+)d?", a)
    if m:
        n = max(1, int(m.group(1)))
        return today - timedelta(days=n - 1), today
    raise ValueError(
        f"Unrecognized window '{arg}'. Use: today | yesterday | YYYY-MM-DD | Nd | YYYY-MM-DD..YYYY-MM-DD"
    )


def to_local(ts):
    """Parse an ISO timestamp (…Z or with offset) to an aware local datetime."""
    if not ts:
        return None
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except ValueError:
        return None
    return dt.astimezone()


def block_text(content):
    """Extract concatenated text blocks from a message content field."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(
            b.get("text", "")
            for b in content
            if isinstance(b, dict) and b.get("type") == "text"
        )
    return ""


def is_tool_result_only(content):
    return isinstance(content, list) and content and all(
        isinstance(b, dict) and b.get("type") == "tool_result" for b in content
    )


def strip_wrappers(text):
    """Remove system-reminder / slash-command wrapper noise from user text."""
    for tag in (
        "system-reminder",
        "command-name",
        "command-message",
        "command-args",
        "local-command-stdout",
    ):
        text = re.sub(rf"<{tag}>.*?</{tag}>", "", text, flags=re.DOTALL)
    return text.strip()


def preview(text, limit=300):
    """Collapse whitespace and tail long text to its last segment."""
    if not text:
        return ""
    flat = re.sub(r"\s+", " ", text).strip()
    if len(flat) <= limit:
        return flat
    return "…" + flat[-limit:]


def analyze(path, start_date, end_date):
    """Parse one transcript; return a summary dict or None if not in window."""
    session_id = os.path.basename(path).replace(".jsonl", "")
    cwd = None
    branch = None
    ai_title = None
    custom_title = None
    turns = 0
    edits = 0
    files = []
    seen_files = set()
    last_user = None
    assistant_texts = []  # (local_dt, text) for substantive replies
    first_dt = None
    last_dt = None
    in_window = False

    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            kind = obj.get("type")

            if kind == "ai-title":
                ai_title = obj.get("aiTitle") or ai_title
                continue
            if kind == "custom-title":
                custom_title = obj.get("customTitle") or custom_title
                continue
            if kind == "file-history-delta":
                fp = obj.get("trackingPath")
                if fp and fp not in seen_files:
                    seen_files.add(fp)
                    files.append(fp)
                continue

            if kind not in ("user", "assistant"):
                continue

            if obj.get("cwd") and not cwd:
                cwd = obj.get("cwd")
            if obj.get("gitBranch") and not branch:
                branch = obj.get("gitBranch")

            dt = to_local(obj.get("timestamp"))
            if dt is None:
                continue
            msg = obj.get("message")
            if not isinstance(msg, dict):
                continue
            content = msg.get("content")

            entry_in_window = start_date <= dt.date() <= end_date

            if kind == "user":
                if obj.get("isMeta") or is_tool_result_only(content):
                    continue
                text = strip_wrappers(block_text(content))
                if not text:
                    continue
                if entry_in_window:
                    in_window = True
                    turns += 1
                    last_user = text
                    first_dt = first_dt or dt
                    last_dt = dt

            elif kind == "assistant":
                for block in (content or []):
                    if isinstance(block, dict) and block.get("type") == "tool_use":
                        if block.get("name") in EDIT_TOOLS and entry_in_window:
                            edits += 1
                text = block_text(content).strip()
                if text and entry_in_window:
                    in_window = True
                    assistant_texts.append((dt, text))
                    first_dt = first_dt or dt
                    last_dt = dt

    if not in_window:
        return None

    # Last substantive agent reply, skipping background/no-op lines.
    last_agent = None
    for _, text in reversed(assistant_texts):
        if text not in NON_REPLY_LINES:
            last_agent = text
            break

    # Skip empty shells (e.g. a session opened and immediately /clear'd): no
    # human prompt and no substantive reply means we weren't really active in it.
    if turns == 0 and last_agent is None:
        return None

    title = custom_title or ai_title
    return {
        "session_id": session_id,
        "project": os.path.basename(os.path.dirname(path)),
        "cwd": cwd,
        "branch": branch,
        "title": title,
        "title_source": "custom" if custom_title else ("ai" if ai_title else None),
        "turns": turns,
        "edits": edits,
        "files": files,
        "last_user": last_user,
        "last_agent": last_agent,
        "first_dt": first_dt,
        "last_dt": last_dt,
        "size_bytes": os.path.getsize(path),
    }


def human_size(num_bytes):
    """Human-readable transcript size matching the /resume picker (e.g. 929K)."""
    size = float(num_bytes)
    for unit in ("B", "K", "M", "G"):
        if size < 1024 or unit == "G":
            if unit == "B":
                return f"{int(size)}B"
            return f"{size:.0f}{unit}"
        size /= 1024
    return f"{size:.0f}G"


def cell(text):
    """Make text safe for a markdown table cell (flatten, escape pipes)."""
    return re.sub(r"\s+", " ", str(text)).replace("|", "\\|").strip()


def files_label(files):
    """Comma-joined file basenames, disambiguating and collapsing collisions."""
    shown = files[:5]
    extra = len(files) - len(shown)
    # Prefix the immediate parent for colliding basenames, then collapse any
    # labels still identical (distinct paths sharing a name and parent) with a count.
    basenames = [os.path.basename(f) for f in shown]
    labels = []
    for path, base in zip(shown, basenames):
        if basenames.count(base) > 1:
            labels.append(os.path.join(os.path.basename(os.path.dirname(path)), base))
        else:
            labels.append(base)
    parts, seen = [], set()
    for label in labels:
        if label in seen:
            continue
        seen.add(label)
        count = labels.count(label)
        parts.append(f"{label} (×{count})" if count > 1 else label)
    listed = ", ".join(parts)
    if extra > 0:
        listed += f", +{extra} more"
    return listed


def format_session(s):
    title = s["title"] or "(untitled)"
    if s["branch"]:
        title = f"{title} ({s['branch']})"

    span = "—"
    if s["first_dt"] and s["last_dt"]:
        start = s["first_dt"].strftime("%H:%M")
        end = s["last_dt"].strftime("%H:%M")
        mins = int((s["last_dt"] - s["first_dt"]).total_seconds() // 60)
        dur = f"{mins}m" if mins < 60 else f"{mins // 60}h{mins % 60:02d}m"
        span = f"{start} → {end} ({dur})"
    turn_word = "turn" if s["turns"] == 1 else "turns"
    edit_word = "edit" if s["edits"] == 1 else "edits"
    duration = f"{span} / {s['turns']} {turn_word} / {s['edits']} {edit_word}"

    rows = [
        ("Size", human_size(s["size_bytes"])),
        ("Duration", cell(duration)),
    ]
    if s["files"]:
        rows.append(("Files", cell(files_label(s["files"]))))
    if s["last_user"]:
        rows.append(("Last user", cell(preview(s["last_user"], 220))))
    if s["last_agent"]:
        rows.append(("Last agent", cell(preview(s["last_agent"], 220))))
    cwd = s["cwd"] or "."
    rows.append(("Resume", f"`cd {cwd} && claude --resume {s['session_id']}`"))

    # The required header row carries the session title in the value column; a
    # placeholder "-" fills the key column so both columns align down the table.
    lines = [f"| - | {cell(title)} |", "|---|---|"]
    for label, value in rows:
        lines.append(f"| **{label}** | {value} |")
    return "\n".join(lines)


def main(argv):
    arg = argv[1] if len(argv) > 1 else None
    try:
        start_date, end_date = parse_window(arg)
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 2

    if not os.path.isdir(PROJECTS_DIR):
        print(f"No projects directory at {PROJECTS_DIR}", file=sys.stderr)
        return 1

    transcripts = [
        p
        for p in glob.glob(os.path.join(PROJECTS_DIR, "*", "*.jsonl"))
        if os.sep + "subagents" + os.sep not in p
    ]

    sessions = []
    for path in transcripts:
        try:
            summary = analyze(path, start_date, end_date)
        except (OSError, ValueError):
            continue
        if summary:
            sessions.append(summary)

    sessions.sort(key=lambda s: s["last_dt"] or datetime.min.astimezone())

    if start_date == end_date:
        window_label = start_date.isoformat()
    else:
        window_label = f"{start_date.isoformat()} .. {end_date.isoformat()}"

    if not sessions:
        print(f"No sessions with activity in window: {window_label}")
        return 0

    print(f"# Sessions active in {window_label} ({len(sessions)})\n")
    print("\n\n".join(format_session(s) for s in sessions))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
