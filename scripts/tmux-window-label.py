#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# ///
"""Print the tmux status label for one window.

Windows inside a worktree of the session's repo show their branch; others show
their directory name. Labels share the total width: labels shorter than an even
share keep their full length, and the longer ones split what is left.

Usage:
    tmux-window-label.py <session path> <total width> <window index> [<window index> <window path>]...
"""

import os
import subprocess
import sys

MIN_LENGTH = 5


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
    refs = worktree_refs(session_path)
    labels = {
        window_index: label_for(window_path, refs)
        for window_index, window_path in zip(window_args[::2], window_args[1::2])
    }
    max_length = max(MIN_LENGTH, max_label_length([len(label) for label in labels.values()], int(total_width)))
    print(truncate(labels[own_window_index], max_length))


if __name__ == "__main__":
    main()
