import json
import os
import unittest
from pathlib import Path
from unittest.mock import ANY, call, patch

from codex.hooks import notification


class TestAbbreviateHome(unittest.TestCase):
    def test_abbreviates_path_beneath_home(self) -> None:
        self.assertEqual(
            notification.abbreviate_home(
                "/Users/vaughn/project", home=Path("/Users/vaughn")
            ),
            "~/project",
        )

    def test_does_not_abbreviate_path_with_only_a_shared_prefix(self) -> None:
        self.assertEqual(
            notification.abbreviate_home(
                "/Users/vaughn-other/project", home=Path("/Users/vaughn")
            ),
            "/Users/vaughn-other/project",
        )


class TestTruncateMessage(unittest.TestCase):
    def test_leaves_message_at_maximum_length_unchanged(self) -> None:
        message = "a" * notification.MAX_MESSAGE_LENGTH

        self.assertEqual(notification.truncate_message(message), message)

    def test_truncates_long_message_with_ellipsis(self) -> None:
        message = "a" * (notification.MAX_MESSAGE_LENGTH + 1)

        truncated_message = notification.truncate_message(message)

        self.assertEqual(
            truncated_message,
            f"{'a' * (notification.MAX_MESSAGE_LENGTH - 1)}…",
        )
        self.assertEqual(len(truncated_message), notification.MAX_MESSAGE_LENGTH)


class TestNotifications(unittest.TestCase):
    @patch("codex.hooks.notification.subprocess.run")
    @patch("codex.hooks.notification.shutil.which", return_value="/usr/bin/nvim")
    def test_sends_message_to_neovim(self, _which, run) -> None:
        notification.notify_neovim("It's <done>\nnow", {"NVIM": "/tmp/nvim.sock"})

        run.assert_called_once_with(
            [
                "nvim",
                "--server",
                "/tmp/nvim.sock",
                "--remote-expr",
                'luaeval("print(_A)", "It\'s <done>\\nnow")',
            ],
            capture_output=True,
            check=False,
        )

    @patch("codex.hooks.notification.subprocess.run")
    @patch("codex.hooks.notification.shutil.which", return_value="/usr/bin/osascript")
    @patch("codex.hooks.notification.platform.system", return_value="Darwin")
    def test_sends_macos_notification(self, _system, _which, run) -> None:
        notification.notify_macos('Finished "cleanly"', "~/project")

        run.assert_called_once_with(
            [
                "osascript",
                "-e",
                "on run argv",
                "-e",
                'display notification (item 1 of argv) with title "Codex" '
                'subtitle (item 2 of argv) sound name "Blow"',
                "-e",
                "end run",
                'Finished "cleanly"',
                "~/project",
            ],
            capture_output=True,
            check=False,
        )

    @patch("codex.hooks.notification.notify_macos")
    @patch("codex.hooks.notification.notify_neovim")
    def test_main_uses_codex_notification_fields(self, notify_neovim, notify_macos) -> None:
        notification_payload = {
            "type": "agent-turn-complete",
            "last-assistant-message": "Work complete.",
            "cwd": "/Users/vaughn/project",
        }

        with (
            patch("sys.argv", ["notification.py", json.dumps(notification_payload)]),
            patch.dict(os.environ, {}, clear=True),
            patch("codex.hooks.notification.Path.home", return_value=Path("/Users/vaughn")),
        ):
            notification.main()

        self.assertEqual(
            [
                call("Work complete.", ANY),
                call("Work complete.", "~/project"),
            ],
            [notify_neovim.call_args, notify_macos.call_args],
        )

    @patch("codex.hooks.notification.notify_macos")
    @patch("codex.hooks.notification.notify_neovim")
    def test_main_truncates_long_message(self, notify_neovim, notify_macos) -> None:
        notification_payload = {
            "last-assistant-message": "a" * (notification.MAX_MESSAGE_LENGTH + 1),
        }
        expected_message = f"{'a' * (notification.MAX_MESSAGE_LENGTH - 1)}…"

        with (
            patch("sys.argv", ["notification.py", json.dumps(notification_payload)]),
            patch.dict(os.environ, {}, clear=True),
        ):
            notification.main()

        self.assertEqual(
            [call(expected_message, ANY), call(expected_message, "")],
            [notify_neovim.call_args, notify_macos.call_args],
        )


if __name__ == "__main__":
    unittest.main()
