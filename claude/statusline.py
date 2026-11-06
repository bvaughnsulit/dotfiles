#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# ///
"""Print the Claude Code status line.

Reads the status line JSON that Claude Code sends on stdin and prints up to
three lines:

    <model> (<effort>) | ctx <n>% | $<cost> | cache <state> <hit ratio>% (exp <HH:MM>) · last miss: <causes>
    <session name>
    <account email> | <limits>

Segments whose data is absent from the input are omitted, and the session name
line is omitted until the session has a name. The account email is
not part of the input, so it is read from the `oauthAccount` object in Claude Code's config file (`$CLAUDE_CONFIG_DIR/.claude.json`, or
`~/.claude.json`). That format is internal to Claude Code; if it cannot be
read, the account segment shows `account:error(<reason>)` instead.

Usage:
    statusline.py < status.json
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path

RESET = "\033[0m"
DIM = "\033[2m"
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"

SEPARATOR = f" {DIM}|{RESET} "
SUB_SEPARATOR = f" {DIM}·{RESET} "


def style(text: str, color: str) -> str:
    return f"{color}{text}{RESET}"


def config_path() -> Path:
    config_dir = os.environ.get("CLAUDE_CONFIG_DIR")
    if config_dir:
        return Path(config_dir) / ".claude.json"
    return Path.home() / ".claude.json"


def account_segment() -> str:
    path = config_path()
    try:
        config = json.loads(path.read_text())
    except FileNotFoundError:
        return style(f"account:error(not found: {path})", RED)
    except (OSError, json.JSONDecodeError) as error:
        return style(f"account:error(unreadable: {type(error).__name__})", RED)

    account = config.get("oauthAccount")
    if not isinstance(account, dict):
        return style("account:error(missing oauthAccount)", RED)
    email = account.get("emailAddress")
    if not isinstance(email, str) or not email:
        return style("account:error(missing oauthAccount.emailAddress)", RED)
    return style(email, CYAN)


def format_clock(epoch_seconds: float) -> str:
    """Format a time as HH:MM, prefixed with the weekday when it is not today."""
    moment = datetime.fromtimestamp(epoch_seconds)
    if moment.date() == datetime.now().date():
        return moment.strftime("%H:%M")
    return moment.strftime("%a %H:%M")


def limits_segment(rate_limits: dict) -> str | None:
    parts = []
    for key, label in (("five_hour", "5h"), ("seven_day", "7d"), ("spend_limit", "spend")):
        window = rate_limits.get(key)
        if not window:
            continue
        used = style(f"{window['used_percentage']:.0f}%", YELLOW)
        resets = style(f"(resets {format_clock(window['resets_at'])})", DIM)
        parts.append(f"{style(label, DIM)} {used} {resets}")
    return SUB_SEPARATOR.join(parts) or None


def cache_segment(prompt_cache: dict) -> str:
    state = style("cache", DIM) + " " + style("warm" if prompt_cache.get("warm") else "cold", BLUE)
    if prompt_cache.get("hit_ratio") is not None:
        state += f" {prompt_cache['hit_ratio'] * 100:.0f}%"
    if prompt_cache.get("expires_at") is not None:
        state += " " + style(f"(exp {format_clock(prompt_cache['expires_at'])})", DIM)
    parts = [state]
    last_miss_cause = prompt_cache.get("last_miss_cause")
    if last_miss_cause and last_miss_cause.get("causes"):
        parts.append(style("last miss:", DIM) + " " + style(",".join(last_miss_cause["causes"]), YELLOW))
    return SUB_SEPARATOR.join(parts)


def model_usage_line(data: dict) -> str:
    model = style(data["model"]["display_name"], MAGENTA)
    effort = data.get("effort")
    if effort and effort.get("level"):
        model += " " + style(f"({effort['level']})", DIM)
    used_percentage = data["context_window"].get("used_percentage") or 0
    segments = [
        model,
        f"{style('ctx', DIM)} {used_percentage:.0f}%",
        style(f"${data['cost']['total_cost_usd']:.2f}", GREEN),
    ]
    if data.get("prompt_cache"):
        segments.append(cache_segment(data["prompt_cache"]))
    return SEPARATOR.join(segments)


def account_limits_line(data: dict) -> str:
    segments = [account_segment()]
    if data.get("rate_limits"):
        limits = limits_segment(data["rate_limits"])
        if limits:
            segments.append(limits)
    return SEPARATOR.join(segments)


def main() -> None:
    data = json.load(sys.stdin)
    print(model_usage_line(data))
    if data.get("session_name"):
        print(style(data["session_name"], BLUE))
    print(account_limits_line(data))


if __name__ == "__main__":
    main()
