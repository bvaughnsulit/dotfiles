from __future__ import annotations

import json
import os
import platform
import shutil
import subprocess
import sys
from collections.abc import Mapping
from pathlib import Path
from typing import Any, Optional


DEFAULT_MESSAGE = "Codex finished its turn."
MAX_MESSAGE_LENGTH = 200


def truncate_message(message: str) -> str:
    if len(message) <= MAX_MESSAGE_LENGTH:
        return message

    return f"{message[: MAX_MESSAGE_LENGTH - 1]}…"


def abbreviate_home(path: str, home: Optional[Path] = None) -> str:
    home_path = home or Path.home()
    try:
        relative_path = Path(path).relative_to(home_path)
    except ValueError:
        return path

    return "~" if relative_path == Path(".") else f"~/{relative_path}"


def notify_neovim(message: str, environment: Mapping[str, str]) -> None:
    server_address = environment.get("NVIM")
    if not server_address or shutil.which("nvim") is None:
        return

    expression = f'luaeval("print(_A)", {json.dumps(message)})'
    subprocess.run(
        ["nvim", "--server", server_address, "--remote-expr", expression],
        capture_output=True,
        check=False,
    )


def notify_macos(message: str, cwd: str) -> None:
    if platform.system() != "Darwin" or shutil.which("osascript") is None:
        return

    subprocess.run(
        [
            "osascript",
            "-e",
            "on run argv",
            "-e",
            'display notification (item 1 of argv) with title "Codex" '
            'subtitle (item 2 of argv) sound name "Blow"',
            "-e",
            "end run",
            message,
            cwd,
        ],
        capture_output=True,
        check=False,
    )


def main() -> None:
    notification: Any = json.loads(sys.argv[1])
    if not isinstance(notification, dict):
        raise TypeError("Codex notification must be a JSON object")

    message = truncate_message(
        notification.get("last-assistant-message") or DEFAULT_MESSAGE
    )
    cwd = abbreviate_home(notification.get("cwd", ""))

    notify_neovim(message, os.environ)
    notify_macos(message, cwd)


if __name__ == "__main__":
    main()
