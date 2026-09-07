from __future__ import annotations

import json
import sys
from typing import Any


BLOCK_REASON = "Automatic compaction is disabled. Use /compact to compact manually."


def compaction_response(hook_input: dict[str, Any]) -> dict[str, Any]:
    if hook_input.get("trigger") != "auto":
        return {"continue": True}

    return {
        "continue": False,
        "stopReason": BLOCK_REASON,
    }


def main() -> None:
    hook_input: Any = json.load(sys.stdin)
    if not isinstance(hook_input, dict):
        raise TypeError("Codex hook input must be a JSON object")

    json.dump(compaction_response(hook_input), sys.stdout)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
