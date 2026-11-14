#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# ///
"""Print the tmux status label for one window.

Windows running ssh show the destination host; windows inside a worktree of the
session's repo show their branch; others show their directory name. Labels
share the total width: labels shorter than an even share keep their full
length, and the longer ones split what is left.

Usage:
    tmux-window-label.py <session path> <total width> <window index>
        [<window index> <window path> <window command> <window tty>]...
"""

import os
import subprocess
import sys

MIN_LENGTH = 5
# ssh options that take a value, from ssh(1)
SSH_VALUE_OPTIONS = set("BbcDEeFIiJLlmOoPpQRSWw")


def ssh_destination(args):
    """Host from an ssh command line, without the user or port."""
    destination = None
    args = iter(args[1:])
    for arg in args:
        if arg == "--":
            destination = next(args, None)
            break
        if not arg.startswith("-") or arg == "-":
            destination = arg
            break
        for position, flag in enumerate(arg[1:], start=1):
            if flag in SSH_VALUE_OPTIONS:
                # the value is either attached (`-p22`) or the next argument
                if position == len(arg) - 1:
                    next(args, None)
                break
    if destination is None:
        return None

    is_uri = destination.startswith("ssh://")
    host = destination.removeprefix("ssh://").rpartition("@")[2]
    # only the URI form carries a port; otherwise a colon may be part of an IPv6 address
    return host.rsplit(":", 1)[0] if is_uri else host


def ssh_hosts(ttys):
    """Map each tty to the host its ssh process is connected to."""
    if not ttys:
        return {}
    try:
        proc = subprocess.run(
            ["ps", "-o", "pid=,tty=,args=", "-t", ",".join(tty.removeprefix("/dev/") for tty in ttys)],
            capture_output=True,
            text=True,
        )
    except OSError:
        return {}

    hosts = {}
    rows = sorted((line.split() for line in proc.stdout.splitlines()), key=lambda row: int(row[0]))
    for _, tty, *args in rows:
        tty = f"/dev/{tty}"
        # the lowest pid is the ssh the user ran, not a ProxyJump child
        if tty in hosts or os.path.basename(args[0]) != "ssh":
            continue
        host = ssh_destination(args)
        if host:
            hosts[tty] = host
    return hosts


def worktree_refs(session_path):
    """Map each worktree of the session's repo to its branch, or short hash when detached."""
    try:
        proc = subprocess.run(
            ["git", "-C", session_path, "worktree", "list", "--porcelain"],
            capture_output=True,
            text=True,
        )
    except OSError:
        return {}

    refs = {}
    worktree = None
    for line in proc.stdout.splitlines():
        key, _, value = line.partition(" ")
        if key == "worktree":
            worktree = value
        elif key == "HEAD":
            refs[worktree] = value[:7]
        elif key == "branch":
            refs[worktree] = value.removeprefix("refs/heads/")
    return refs


def label_for(window_path, refs):
    real_path = os.path.realpath(window_path)
    directory_name = os.path.basename(window_path)
    matches = [w for w in refs if real_path == w or real_path.startswith(w + os.sep)]
    if not matches:
        return directory_name

    # the longest match wins so a worktree nested inside another is attributed correctly
    ref = refs[max(matches, key=len)]
    # numbered worktree directories carry no meaning beyond their branch
    if directory_name.isdigit():
        return ref
    return f"{directory_name}/{ref}"


def max_label_length(lengths, total_width):
    """Largest length every label can have while all labels fit in `total_width`."""
    remaining_width = total_width
    remaining_count = len(lengths)
    for length in sorted(lengths):
        share = remaining_width // remaining_count
        if length > share:
            return share
        remaining_width -= length
        remaining_count -= 1
    return total_width


def truncate(label, max_length):
    if len(label) <= max_length:
        return label
    head_length = (max_length - 1) * 3 // 4
    tail_length = max_length - 1 - head_length
    return f"{label[:head_length]}…{label[-tail_length:]}"


def main():
    session_path, total_width, own_window_index, *window_args = sys.argv[1:]
    windows = list(zip(window_args[::4], window_args[1::4], window_args[2::4], window_args[3::4]))
    refs = worktree_refs(session_path)
    hosts = ssh_hosts([tty for _, _, command, tty in windows if command == "ssh"])
    labels = {
        window_index: f"ssh:{hosts[tty]}" if tty in hosts else label_for(window_path, refs)
        for window_index, window_path, _, tty in windows
    }
    max_length = max(MIN_LENGTH, max_label_length([len(label) for label in labels.values()], int(total_width)))
    print(truncate(labels[own_window_index], max_length))


if __name__ == "__main__":
    main()
