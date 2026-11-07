"""Launch the sandbox declared for the current worktree directory."""

import os
from pathlib import Path
import sys


def main() -> None:
    workspace = Path.cwd()
    configuration_directory = workspace.parent / ".sbxenv"
    configurations = [
        configuration_directory / "base.sbxenv.yaml",
        configuration_directory / f"{workspace.name}.sbxenv.yaml",
    ]
    for configuration in configurations:
        if not configuration.is_file():
            sys.exit(f"Missing sandbox configuration: {configuration}")

    command = ["sbx", "env", "run", *map(str, configurations), *sys.argv[1:]]
    try:
        os.execvp(command[0], command)
    except OSError as error:
        sys.exit(f"Could not launch sbx: {error}")


if __name__ == "__main__":
    main()
