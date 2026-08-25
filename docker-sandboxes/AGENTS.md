# Docker Sandbox Kit Instructions

Changes under this directory must be validated against a real Docker Sandbox,
not only with static YAML or shell checks.

For every changed kit:

1. Run `sbx kit validate docker-sandboxes/kits/<agent>`.
2. Create a disposable sandbox with the changed local kit and the dotfiles
   repository mounted as a workspace.
3. Use `sbx exec <sandbox> -- ...` to verify the installed files, symlink
   targets, environment variables, and agent-visible configuration.
4. Verify that the sandbox has no sibling `AGENTS.md` and that the generated
   context was renamed to sibling `IGNORE_ME.md` before the agent attaches.
5. For Codex, verify that `~/.codex/config.toml` exists and is not a symlink,
   that `~/.codex/dotfiles.config.toml` points to `codex/config.toml`, and that
   `codex --profile dotfiles mcp get mcp-gateway` succeeds.
6. For OpenCode, verify that `OPENCODE_CONFIG` points outside the
   sandbox-managed `~/.config/opencode/opencode.json` path and that the custom
   configuration and plugin links resolve to the mounted dotfiles.

Report the exact container checks and their results. Remove disposable
validation sandboxes after the checks when it is safe to do so.
