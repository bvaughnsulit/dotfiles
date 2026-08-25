`sh scripts/setup.sh`

## Agent sandboxes

The shell configuration provides commands for creating Docker Sandboxes with
the matching shared dotfiles kit. Their implementation lives in
`docker-sandboxes/sandboxes.py`:

```sh
sbx-opencode /path/to/project
sbx-codex /path/to/project
```

The project path defaults to the current directory when omitted. Any remaining
arguments are passed to `sbx run`, so agent arguments can follow `--`:

```sh
sbx-codex . -- --help
```

Both commands pass `DOTFILES_DIR` into the sandbox. The project is the primary
workspace and the dotfiles repository is an additional read-write workspace.
Later invocations reconnect to the sandbox created for that agent and project.

The OpenCode kit loads `opencode/opencode.jsonc` through `OPENCODE_CONFIG`, plus
`opencode/plugins` and the shared root-level `AGENTS.md`. The Codex kit loads
`codex/config.toml` as the separate `dotfiles` profile, leaving Docker's managed
base configuration intact, and loads the shared `AGENTS.md`. Before attaching,
the wrapper renames Docker's generated sibling `AGENTS.md` to `IGNORE_ME.md`,
which the agents ignore. Kits are applied only when a sandbox is created, so
remove and recreate an existing sandbox before adding or changing a kit.
