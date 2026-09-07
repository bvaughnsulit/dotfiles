import io
import json
import unittest
from unittest.mock import patch

from codex.hooks import block_auto_compaction


class TestCompactionResponse(unittest.TestCase):
    def test_blocks_automatic_compaction(self) -> None:
        self.assertEqual(
            block_auto_compaction.compaction_response({"trigger": "auto"}),
            {
                "continue": False,
                "stopReason": block_auto_compaction.BLOCK_REASON,
            },
        )

    def test_allows_manual_compaction(self) -> None:
        self.assertEqual(
            block_auto_compaction.compaction_response({"trigger": "manual"}),
            {"continue": True},
        )


class TestMain(unittest.TestCase):
    def test_writes_codex_hook_response(self) -> None:
        hook_input = {
            "hook_event_name": "PreCompact",
            "trigger": "auto",
        }
        stdout = io.StringIO()

        with (
            patch("sys.stdin", io.StringIO(json.dumps(hook_input))),
            patch("sys.stdout", stdout),
        ):
            block_auto_compaction.main()

        self.assertEqual(
            json.loads(stdout.getvalue()),
            {
                "continue": False,
                "stopReason": block_auto_compaction.BLOCK_REASON,
            },
        )


if __name__ == "__main__":
    unittest.main()
