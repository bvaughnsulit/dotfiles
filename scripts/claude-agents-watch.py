#!/usr/bin/env python3
"""Live view of interactive `claude agents --json` sessions.

Runs `claude agents --json`, keeps only kind == "interactive", groups the
sessions by working directory, and lists each group ordered by status then
start time. Clears and redraws on a 30s timer, or immediately when any key
is pressed; press 'q' to quit.

Usage:
    claude-agents-watch.py
"""

import json
import os
import select
import subprocess
import sys
import termios
import tty
from datetime import datetime

REFRESH_SECONDS = 30
HOME = os.path.expanduser("~")


def fetch_agents():
    """Run `claude agents --json` and return the parsed list, or an error string."""
    try:
        proc = subprocess.run(
            ["claude", "agents", "--json"],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        return f"Failed to run `claude agents --json`: {exc}"
    if proc.returncode != 0:
        return f"`claude agents --json` exited {proc.returncode}: {proc.stderr.strip()}"
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        return f"Could not parse agents JSON: {exc}"


def short_cwd(cwd):
    if cwd and cwd.startswith(HOME):
        return "~" + cwd[len(HOME):]
    return cwd or "(unknown cwd)"


def human_started(started_at_ms):
    """Format an epoch-ms timestamp as a human-readable local time."""
    if not started_at_ms:
        return "?"
    dt = datetime.fromtimestamp(started_at_ms / 1000).astimezone()
    today = datetime.now().astimezone().date()
    if dt.date() == today:
        return dt.strftime("%H:%M:%S")
    return dt.strftime("%Y-%m-%d %H:%M")


def group_and_sort(agents):
    """Group interactive agents by cwd; sort groups by cwd, entries by status then startedAt."""
    interactive = [a for a in agents if a.get("kind") == "interactive"]

    groups = {}
    for agent in interactive:
        groups.setdefault(agent.get("cwd") or "", []).append(agent)

    for entries in groups.values():
        entries.sort(key=lambda a: (a.get("status") or "", a.get("startedAt") or 0))

    return sorted(groups.items(), key=lambda kv: kv[0])


USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def _c(code):
    return code if USE_COLOR else ""


RESET = _c("\033[0m")
BOLD = _c("\033[1m")
DIM = _c("\033[2m")
CYAN = _c("\033[36m")
RED = _c("\033[31m")

# Distinguished by shape/emoji rather than color, since color alone isn't
# a reliable signal (colorblindness, no-color terminals).
STATUS_EMOJI = {
    "running": "🏃",
    "active": "🏃",
    "busy": "🏃",
    "idle": "💤",
    "waiting": "⏳",
    "pending": "⏳",
    "stopped": "🛑",
    "done": "✅",
    "completed": "✅",
    "error": "❌",
    "failed": "❌",
    "crashed": "❌",
}
DEFAULT_STATUS_EMOJI = "❓"


def status_badge(status):
    """Return (plain_text, styled_text) for a status, so callers can pad by
    the visible width without counting embedded ANSI escape codes."""
    key = (status or "").lower()
    emoji = STATUS_EMOJI.get(key, DEFAULT_STATUS_EMOJI)
    plain = f"{emoji} {status or '?'}"
    return plain, plain


def render(agents_or_error):
    if isinstance(agents_or_error, str):
        print(f"{RED}{agents_or_error}{RESET}")
        return

    groups = group_and_sort(agents_or_error)
    total = sum(len(entries) for _, entries in groups)

    print(f"{BOLD}Interactive Claude agents ({total}){RESET}")
    print(f"{DIM}as of {datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S')}{RESET}")

    if not groups:
        print(f"\n{DIM}(none){RESET}")
        return

    all_entries = [e for _, entries in groups for e in entries]
    name_w = max(len(e.get("name") or e.get("sessionId", "")) for e in all_entries)
    status_w = max(len(status_badge(e.get("status"))[0]) for e in all_entries)

    for cwd, entries in groups:
        print(f"\n{BOLD}{CYAN}{short_cwd(cwd)}{RESET}")
        for e in entries:
            name = e.get("name") or e.get("sessionId", "")
            plain_status, badge = status_badge(e.get("status"))
            pad = " " * (status_w - len(plain_status))
            started = human_started(e.get("startedAt"))
            pid = e.get("pid", "?")
            print(
                f"  {badge}{pad}  {BOLD}{name:<{name_w}}{RESET}  "
                f"{DIM}started {started}  pid {pid}{RESET}"
            )


def clear_screen():
    print("\033[2J\033[H", end="")


def wait_for_key(timeout):
    """Block up to `timeout` seconds for a keypress; return the key or None on timeout."""
    if not sys.stdin.isatty():
        return None
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        rlist, _, _ = select.select([sys.stdin], [], [], timeout)
        if rlist:
            return sys.stdin.read(1)
        return None
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def main():
    while True:
        clear_screen()
        render(fetch_agents())
        print(f"\n{DIM}[any key to refresh now, q to quit — auto-refresh in {REFRESH_SECONDS}s]{RESET}")
        key = wait_for_key(REFRESH_SECONDS)
        if key and key.lower() == "q":
            break


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
