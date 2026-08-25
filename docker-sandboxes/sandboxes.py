#!/usr/bin/env python3
"""Run an agent in its project-specific Docker Sandbox."""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys


def run_sandbox(agent: str, arguments: list[str]) -> None:
    """Create or reconnect to the sandbox for an agent and project."""
    project_arg = arguments[0] if arguments else os.getcwd()
    remaining = arguments[1:] if arguments else []
    project = Path(project_arg).expanduser().resolve()
    sandbox_name = f"{agent}-{project.name}"

    if "--" in remaining:
        separator = remaining.index("--")
        create_args = remaining[:separator]
        agent_args = remaining[separator + 1 :]
    else:
        create_args = remaining
        agent_args = []

    if agent == "codex":
        agent_args = ["--profile", "dotfiles", *agent_args]

    dotfiles_dir = os.environ.get("DOTFILES_DIR")
    if not dotfiles_dir:
        raise SystemExit("DOTFILES_DIR is not set")

    sandboxes = subprocess.run(
        ["sbx", "ls", "-q"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout.splitlines()

    generated_context = project.parent / "AGENTS.md"
    ignored_context = project.parent / "IGNORE_ME.md"

    if sandbox_name in sandboxes:
        subprocess.run(
            [
                "sbx",
                "exec",
                sandbox_name,
                "--",
                "sh",
                "-c",
                'if [ -f "$1" ]; then mv -f "$1" "$2"; fi',
                "sh",
                str(generated_context),
                str(ignored_context),
            ],
            check=True,
        )
    else:
        subprocess.run(
            [
                "sbx",
                "create",
                "-e",
                "DOTFILES_DIR",
                "--name",
                sandbox_name,
                agent,
                str(project),
                dotfiles_dir,
                "--kit",
                f"{dotfiles_dir}/docker-sandboxes/kits/{agent}",
                *create_args,
            ],
            check=True,
        )
        subprocess.run(
            [
                "sbx",
                "exec",
                sandbox_name,
                "--",
                "mv",
                "-f",
                str(generated_context),
                str(ignored_context),
            ],
            check=True,
        )

    run_args = ["--", *agent_args] if agent_args else []
    subprocess.run(
        [
            "sbx",
            "run",
            "-e",
            "DOTFILES_DIR",
            "--name",
            sandbox_name,
            agent,
            *run_args,
        ],
        check=True,
    )


def main() -> None:
    if len(sys.argv) < 2 or sys.argv[1] not in {"codex", "opencode"}:
        raise SystemExit(f"usage: {Path(sys.argv[0]).name} {{codex,opencode}} [project] [args ...]")

    run_sandbox(sys.argv[1], sys.argv[2:])


if __name__ == "__main__":
    main()
