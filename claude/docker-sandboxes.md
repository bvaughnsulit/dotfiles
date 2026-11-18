# Claude Code in Docker Sandboxes

This doc covers running Claude Code in a Docker Sandbox (`sbx`) with the same behaviour as running it locally. It does three things:

1. It lists every part of the current Claude setup in this repo and in `~/dev/local-config`, and says how each part can be supported in a sandbox (§3–§4).
2. It proposes workarounds for the parts the sandbox does not support (§5).
3. It describes common Claude workflows that change inside a sandbox even though nothing in the config refers to them (§6).

Support levels:

- **Native**: a built-in `sbx` command, setting, or kit capability does it.
- **Workaround**: possible, but only with your own setup: a personal mixin kit, extra mounts, a startup hook, a host bridge (§5.1), or a config change.
- **Not supported**: no reasonable way to do it from inside the sandbox.

**Sources:** `sbx` v0.53.0 `--help` on this machine; docs.docker.com/ai/sandboxes; the kit spec at github.com/docker/sandbox-kit-spec; and two throwaway sandboxes created on 2026-11-14 and then removed. The first was `sbx create claude`, which resolved to kit `docker.io/sbx/claude:latest` running Claude Code 2.1.325 on Debian 13 (Docker Hardened Images). The second was `sbx create shell`. Anything marked _(verify)_ has not been tested. Everything else was either seen in a probe or is stated in the `sbx` help or docs.

The northspyre items come from the local-config `northspyre/` files and its `setup.sh`. No northspyre checkout on this machine currently has those symlinks applied.

---

## 1. Sandbox facts that drive everything below

| Fact                                                                                                                                                                                                                                                                                                                                                                                                                                   | Evidence                                   | Consequence                                                                                                                                                                       |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Each sandbox is a microVM with its own Debian userland. The agent runs as `agent` (uid 1000) with home `/home/agent`, in the `sudo` and `docker` groups, and passwordless `sudo` works.                                                                                                                                                                                                                                                | probe                                      | Nothing from your Mac's home is present: `~/.claude*`, `~/.gitconfig`, `~/.gitignore_global`, Keychain, zsh config, mise, Homebrew. Kit install hooks can `sudo apt-get install`. |
| "Sandboxes don't pick up user-level configuration from your host, such as `~/.claude`." Project-level config in the workspace *is* read. Shared skills are the one exception.                                                                                                                                                                                                                                                          | docs                                       | User settings, `CLAUDE.md`, keybindings, hooks, statusline, plugins, and user-scope MCP servers all have to be provided some other way.                                           |
| A workspace mounts at the **same absolute path** as on the host. Extra workspaces (`sbx run claude . /path[:ro]`) also keep their host path unless you give a target.                                                                                                                                                                                                                                                                  | docs                                       | Absolute symlinks into `~/dotfiles` and `~/dev/local-config` resolve **if those directories are mounted too**. Claude's per-project transcript directory names match the host's.  |
| "Don't use symlinks to host paths because a sandboxed agent can't follow them outside the sandbox."                                                                                                                                                                                                                                                                                                                                    | docs FAQ                                   | Without the extra mounts, every symlink that `setup.sh` creates inside a project dangles.                                                                                         |
| The Claude kit launches `claude --dangerously-skip-permissions`. Arguments after `--` are appended to that.                                                                                                                                                                                                                                                                                                                            | docs, `sbx kit inspect`                    | Permission prompts are replaced by the sandbox boundary (§4.6).                                                                                                                   |
| The kit **owns `~/.claude/settings.json`**. It writes `Stop`/`StopFailure`/`UserPromptSubmit`/`Notification` hooks and a `statusLine`, all calling `/usr/local/bin/sbx-claude-hook`. It also writes `permissions.defaultMode: bypassPermissions`, `skipDangerousModePermissionPrompt`, `alwaysThinkingEnabled: true`, and `themeId`. Kit args `model` / `reasoningEffort` set the `CLAUDE_MODEL` / `CLAUDE_REASONING_EFFORT` env vars. | probe                                      | Your settings must be **merged** into the kit's file, not swapped in (§4.1).                                                                                                      |
| The kit owns `~/.claude/CLAUDE.md`, which holds about 20 KB of sbx guidance between `<!-- sbx:guidance -->` markers. This includes an env-persistence file, `/etc/sandbox-persistent.sh` (`CLAUDE_ENV_FILE`).                                                                                                                                                                                                                          | probe                                      | Your user `CLAUDE.md` has to be appended or imported, not swapped in (§4.2).                                                                                                      |
| Tools **present:** `uv`, `python3`, `jq`, `gh`, `git`, `rg`, `curl`, `socat`, `xdg-open`, plus clipboard shims (`pbcopy`, `xclip`, `wl-copy`). Tools **missing:** `node`/`npm`, `zsh`, `just`, `fd`, `vi`/`vim`/`nvim`, `nc`, `psql`, `redis-cli`.                                                                                                                                                                                     | probe                                      | Several items below need a kit install hook (§4.20).                                                                                                                              |
| Git global config has `core.excludesfile=/home/agent/.gitignore_template`, which contains an sbx-managed block. **No `user.name`/`user.email` is set.**                                                                                                                                                                                                                                                                                | probe                                      | §4.13 and §4.14.                                                                                                                                                                  |
| All egress goes through a host proxy at `gateway.docker.internal:3128`. The proxy CA is trusted through `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE`, and `NODE_EXTRA_CA_CERTS`. Policy is deny-by-default but ships with broad default allows (see `sbx policy ls`). UDP and ICMP are blocked. Host `localhost` is unreachable unless granted.                                                                                               | probe, docs                                | `uv pip install` worked through the proxy. SSH to `github.com:22` was **refused**. Host services need `host-port@1` (§4.17).                                                      |
| Credentials are injected by the proxy, and the agent only sees sentinels: `GH_TOKEN=gho_sbxproxymanaged…`, and `MCP_SENTINEL_TOKEN_NAME=proxy-managed` for MCP.                                                                                                                                                                                                                                                                        | probe, docs                                | Real tokens never enter the VM.                                                                                                                                                   |
| Claude's `~/.claude.json` in the sandbox has one MCP server, `mcp-gateway`. The sandbox has `MCP_GATEWAY_URL=http://mcp-gateway.docker.internal/mcp`. Host stdio servers registered with `sbx mcp add --command` run **on the Mac** and are reached through this gateway.                                                                                                                                                              | probe                                      | This is the host bridge used in §5.1 (tested end to end).                                                                                                                         |
| Timezone is **UTC**. The default shell is **bash**. Defaults were 8 CPUs, about 7 GB RAM (50% of host memory, clamped 512 MiB–32 GiB), a 20 GB root disk, and a 10 GB Docker volume.                                                                                                                                                                                                                                                   | probe, `sbx run --help`, `sbx settings ls` | §6.7 and §6.4.                                                                                                                                                                    |
| Each sandbox has its **own isolated dockerd**. The host's containers are invisible.                                                                                                                                                                                                                                                                                                                                                    | docs                                       | §6.2.                                                                                                                                                                             |
| VM files survive `sbx stop`/start and are deleted by `sbx rm`. `volume@1` storage survives re-creation under the same sandbox name. `host-mount@1` storage is shared across sandboxes of the same kit, is visible on the host, and can be bound to a chosen host dir with `--mount HOST:SANDBOX_PATH` at create time.                                                                                                                  | docs, kit spec                             | §5.7 and §4.8.                                                                                                                                                                    |
| Per the kit spec, a local sandbox stops once its last session disconnects, unless a kit declares `long-running@1`.                                                                                                                                                                                                                                                                                                                     | kit spec                                   | §6.5.                                                                                                                                                                             |

Current `sbx` state on this machine:
- **Secrets:** a global `github` service secret is stored, and `openai` OAuth is configured.
- **MCP servers and skills:** none registered.
- **Existing sandboxes:** `codex-dotfiles` and `codex-worktree-probe`. The second mounts `/Users/vaughn/worktrees/dotfiles` plus `/Users/vaughn/dotfiles/.git`, which is the worktree pattern from §4.15.

---

## 2. Summary: configured pieces

| §    | Piece                                                                                                         | Where it lives today                                                  | Support                                                                     |
| ---- | ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| 4.1  | User `settings.json`                                                                                          | `claude/settings.json`, symlinked to `~/.claude/` and `~/.claude-ns/` | Workaround: merge at boot                                                   |
| 4.2  | User `CLAUDE.md`                                                                                              | `claude/.claude/CLAUDE.md`                                            | Workaround: `@import`                                                       |
| 4.3  | `keybindings.json`                                                                                            | `claude/keybindings.json`                                             | Workaround: symlink                                                         |
| 4.4  | `model: opus`, `effortLevel: high`, `env.CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD`, other scalar settings | settings.json                                                         | Native once 4.1 is done, or kit args                                        |
| 4.5  | Hooks: Notification (`osascript`), PostToolUse (`nvim checktime`), PreToolUse (`on_pre_tool_use.ts`)          | `claude/hooks/`, settings.json                                        | Not supported as written → Workarounds §5.2, §5.3; drop the PreToolUse hook |
| 4.6  | Permissions (`allow`, `deny`, `defaultMode: auto`)                                                            | settings.json, project `settings.local.json`                          | Partial → §5.6                                                              |
| 4.7  | Statusline (`statusline.py`)                                                                                  | `claude/statusline.py`                                                | Workaround: wrapper that keeps the kit's statusline                         |
| 4.8  | Plugins (10 enabled) including LSP plugins                                                                    | `~/.claude/plugins`                                                   | Workaround                                                                  |
| 4.9  | Skills                                                                                                        | `~/dev/local-config/agents/skills`                                    | Native (copy or git) or Workaround (live)                                   |
| 4.10 | Two config dirs / two accounts                                                                                | mise `CLAUDE_CONFIG_DIR`                                              | Workaround: per-sandbox login                                               |
| 4.11 | MCP servers (`northspyre-local`, project `.mcp.json`)                                                         | `~/.claude-ns/.claude.json`, repo                                     | Native                                                                      |
| 4.12 | Project files symlinked from local-config                                                                     | `local-config/{northspyre,dotfiles}/…`                                | Workaround: read-only mount                                                 |
| 4.13 | Global gitignore                                                                                              | `.gitignore_global`                                                   | Workaround                                                                  |
| 4.14 | Git identity, other `.gitconfig`                                                                              | `.gitconfig`                                                          | Native (`git-identity@1`)                                                   |
| 4.15 | Git worktrees                                                                                                 | `~/worktrees/*`                                                       | Workaround: mount the main `.git`                                           |
| 4.16 | GitHub auth, SSH                                                                                              | gh keyring, `~/.ssh`                                                  | Native                                                                      |
| 4.17 | Local Postgres and other host services                                                                        | host docker compose                                                   | Native (`host-port@1`)                                                      |
| 4.18 | `.venv` / `node_modules` in the workspace                                                                     | northspyre                                                            | Workaround                                                                  |
| 4.19 | WebFetch domain allowlist                                                                                     | settings files                                                        | Native (`sbx policy allow network`)                                         |
| 4.20 | Tooling (`node`, `zsh`, `just`, `fd`, an editor, DB clients)                                                  | Homebrew / mise                                                       | Workaround: kit install hook or template                                    |
| 4.21 | Launching from nvim (`toggle_ai_cli`), `CLAUDE_CODE_TASK_LIST_ID`, Ctrl+G `EDITOR`                            | `nvim/lua/plugins/ai.lua`, `scripts/neovim-remote`                    | Workaround; Ctrl+G → §5.4                                                   |
| 4.22 | Session history, `/resume`, `claude-session-recap.py`                                                         | `~/.claude/projects`                                                  | Workaround → §5.7                                                           |
| 4.23 | Image paste, text copy, opening URLs, Claude in Chrome, Remote Control                                        |                                                                       | Native (sbx settings)                                                       |
| 4.24 | IDE integration (`/ide`)                                                                                      | not used                                                              | Not supported → possible workaround §5.5                                    |
| 4.25 | Codex / opencode config                                                                                       | `codex/`, `opencode/`, `agents/AGENTS.md`                             | Out of scope (same model applies with `sbx run codex`)                      |

---

## 3. Mounts every Claude sandbox needs

Most workarounds below assume these two extra read-only workspaces:

```sh
sbx run claude . ~/dotfiles:ro ~/dev/local-config:ro -e DOTFILES_DIR=/Users/vaughn/dotfiles
```

- `~/dotfiles:ro` provides your settings, `CLAUDE.md`, keybindings, statusline, the bridge scripts, and `.gitignore_global`.
- `~/dev/local-config:ro` makes the project symlinks and the skills directory resolve.
- **Read-only** means the agent cannot edit its own settings, hooks, or the host-side scripts. Keep it that way.

`sbxenv.yaml` and anything executed **on the host** (bridge server, `sbx env` lifecycle commands, secret helpers) must live outside *writable* mounts.

---

## 4. Configured pieces in detail

### 4.1 User `settings.json`

The kit writes its own settings file with hooks you want to keep, so don't symlink yours over it. Instead, a mixin `lifecycle@1` **startup** hook (proposed `claude/sandbox/merge_settings.py`, run with the image's `python3`) builds the final file on every boot:
- Start from the kit's file and deep-merge `/Users/vaughn/dotfiles/claude/settings.json` over it.
- **Concatenate** `hooks.<Event>` arrays instead of replacing them, so sbx's hooks and yours both run.
- Replace your host-only hooks with sandbox versions (§4.5).
- `statusLine`: replace it with the wrapper described in §4.7.
- `permissions`: keep the kit's `defaultMode` unless you choose §5.6 option B, and merge in your `deny` list.

Changes you make *inside* the sandbox (`/config`, `/model` defaults, `/permissions`) are written to the VM's copy. They never reach `~/dotfiles`, and the next merge may overwrite them, so edit dotfiles instead.

### 4.2 User `CLAUDE.md`

The startup hook appends `@/Users/vaughn/dotfiles/claude/.claude/CLAUDE.md` to the kit's `~/.claude/CLAUDE.md` if the line is missing. The import reads live from the read-only mount. An alternative is a mixin with `agent-context@2` `content:`, but that copy is static and needs a kit rebuild whenever the text changes.

`#` memory shortcuts and `/memory` edits to the user file land in the VM copy only.

### 4.3 `keybindings.json`

The kit doesn't write this file. A startup hook runs `ln -sf /Users/vaughn/dotfiles/claude/keybindings.json /home/agent/.claude/keybindings.json`.

### 4.4 Model, effort, env, scalar settings

These come along with the merge in §4.1. Alternatively pass `--kit-arg model=opus --kit-arg reasoningEffort=high`.

### 4.5 Hooks

- **Notification (`claude/hooks/notification_hook.sh`):** this calls `osascript` and `nvim --server $NVIM`, and neither exists in the VM. Drop it from the merged settings and use the bridge hook in §5.2. Your `preferredNotifChannel: terminal_bell` still rings the host terminal through the TTY.
- **PostToolUse `nvim checktime`:** guarded by `[ -n "$NVIM" ]`, so it is a silent no-op in the sandbox. See §5.3.
- **PreToolUse `on_pre_tool_use.ts`:** needs `node`, which is not in the image, and does nothing today (`if (false)`). Drop it from the merged settings, or port it to Python if it ever does something.

### 4.6 Permissions

The kit runs `--dangerously-skip-permissions` and sets `defaultMode: bypassPermissions`. Your `allow` list and `defaultMode: auto` have no effect. The `deny` rules (`Bash(npx:*)`, `Bash(yarn:*)`) should still be enforced _(verify)_. Arguments after `--` are only appended, so they can't remove the flag. Options are in §5.6.

"Always allow" writes to the project `.claude/settings.local.json` will fail, because that file is a symlink into the read-only local-config mount. Under bypass mode you'll rarely see prompts anyway.

### 4.7 Statusline

`statusline.py` runs because `uv` and `python3` are present. The kit's own statusline (`sbx-claude-hook claude-status`) prints nothing; it forwards session info to Docker's desktop app. Use a wrapper that sends stdin to `sbx-claude-hook claude-status` in the background and prints `statusline.py`'s output, so both keep working.

The account segment reads `oauthAccount` from `.claude.json`. With OAuth held on the host it may be missing, in which case the segment shows `account:error(...)` _(verify after `/login`)_.

### 4.8 Plugins (including LSP)

`enabledPlugins` comes along with the merge, but the installed marketplace and cache (`~/.claude/plugins`) do not.
- **Install:** a mixin `lifecycle@1` **install** hook runs `claude plugin marketplace add anthropics/claude-plugins-official` and `claude plugin install <name>@claude-plugins-official` for each enabled plugin. It needs a matching `network-policy@1` `install.allow` (`github.com`, `codeload.github.com`, …).
- **Install once:** a `host-mount@1` at `/home/agent/.claude/plugins` shares installs across sandboxes and survives `sbx rm`.
- **LSP binaries:** `pyright-lsp` and `typescript-lsp` also need their binaries. Install node first (§4.20), then `npm i -g pyright typescript-language-server typescript`.

### 4.9 Skills

`~/.claude/skills` is a symlink to `~/dev/local-config/agents/skills`. Options:
- **Native, copy:** `sbx skills import` reads `~/.claude/skills` and follows top-level symlinks. Edits need a re-import, and new skills appear on the next sandbox start.
- **Native, git:** `sbx skills add bvaughnsulit/local-config`, then `sbx skills update` after you push.
- **Workaround, live (recommended):** create the sandbox with `--skills off`, rely on the local-config mount (§3), and add a startup hook that runs `ln -sfn /Users/vaughn/dev/local-config/agents/skills /home/agent/.claude/skills`. This matches how the setup works locally today.

### 4.10 Accounts (`~/.claude` personal vs `~/.claude-ns` work)

Locally, mise switches `CLAUDE_CONFIG_DIR` per directory. A sandbox has one config dir.
- Run `/login` inside each sandbox. The OAuth flow runs on the host, and the token never enters the VM.
- To pin an account per sandbox, use a sandbox-scoped secret: `sbx secret set anthropic --sandbox <name>`. The docs don't say whether one OAuth login is shared across sandboxes _(verify)_.
- Don't let mise activate inside the sandbox. If it did, `northspyre/mise.toml` would point `CLAUDE_CONFIG_DIR` at an empty `/home/agent/.claude-ns`. The kit launches `claude` directly, so this is only a risk if you install mise yourself.

### 4.11 MCP servers

- **`northspyre-local`** is a user-scope stdio server in `~/.claude-ns/.claude.json`, so the sandbox won't see it. Register it with sbx. It then runs **on the host**, so its paths and DB access stay as they are:
  ```sh
  sbx mcp add northspyre-local --command uv \
    --args run,--directory,/Users/vaughn/dev/northspyre/mcp-server,python,-m,mcp_server.run_stdio,--org-id,1,--user-id,4050
  sbx run claude … --static-mcp northspyre-local      # fixed at create; or `sbx mcp load NAME --sandbox SANDBOX`
  ```
- **Project `.mcp.json`** is read from the workspace, and those servers run **inside** the sandbox, so they need network grants. `disabledMcpjsonServers: ["figma"]` carries over through the `settings.local.json` symlink.

### 4.12 Project files symlinked from local-config

`agents/setup.sh`, `northspyre/._vaughn/setup.sh`, and `dotfiles/._vaughn/setup.sh` create **absolute** symlinks into `~/dev/local-config/…`. The northspyre set covers:
- `.claude/CLAUDE.md`, `.claude/settings.local.json`, and `.claude/rules/.vaughn`
- `.vaughn/`, `justfile`, `mise.toml`, and `.vscode/`
- `.git/info/exclude`

The local-config mount (§3) makes all of these resolve without changes. Related settings:
- `claudeMdExcludes` and `disabledMcpjsonServers` work as they do today.
- `additionalDirectories`: `/Users/vaughn/dotfiles/claude` resolves via the dotfiles mount. `/Users/vaughn/dev/local-config/claude` no longer exists, so remove it.
- `justfile` recipes need `zsh` and `just` (missing), plus `uv` (present) and the repo's `profile_utils.sh`.

### 4.13 Global gitignore

The sandbox's git can't see `~/.gitignore_global`, which lists `.vaughn/`, `.vaughn`, `CLAUDE.local.md`, and `.__bvs__*`. It would show them as untracked, and the agent might `git add` them. Keep sbx's `core.excludesfile` (`/home/agent/.gitignore_template`, which has an sbx-managed block). Add a startup hook that appends your patterns from the dotfiles mount outside that block, if they're missing.

### 4.14 Git identity and other `.gitconfig`

There's no identity in the sandbox, so declare `git-identity@1` in the mixin; it copies `user.name`/`user.email` from the host. `delta` as pager, `nvim` as editor, and `colorMoved` don't matter for the agent. Copy `merge.conflictstyle = diff3` with a startup `git config --global` if you want consistent conflict output.

### 4.15 Git worktrees

A worktree like `~/worktrees/northspyre-deal` has a `.git` *file* pointing into `/Users/vaughn/northspyre-deal/.git/worktrees/…`. Mount that main `.git` as a writable extra workspace, the way the existing `codex-worktree-probe` sandbox does. Clone mode (`--clone`) is the alternative, but it is refused from a non-main worktree.

Worktrees Claude creates itself (`claude -w`, subagent `isolation: worktree`) work if they live inside the mounted repo. They are visible on the host too.

### 4.16 GitHub auth and SSH

- **Native:**
  - `sbx secret set github --command 'gh auth token'` is already stored, and the sandbox sees `GH_TOKEN` as a sentinel.
  - `gh` works, including `gh pr create`/`view` and the `review-pr-comments` skill.
  - HTTPS git push and pull work through the same injected token.
- **SSH remotes / signing:** SSH to `github.com:22` was refused in the probe. Use HTTPS remotes (your current setup), or add `ssh-agent@1` to the mixin plus a network allow for `github.com:22`. `ssh.agentForwardingEnabled` is on. The signing key must be loaded in the host agent.

### 4.17 Host services (Postgres `localhost:5432`, Redis, and others)

`host-port@1` in a northspyre mixin forwards a host loopback port to sandbox `127.0.0.1:<port>`, so the CLAUDE.md connection details stay correct. Add one entry per service you need (5432, the Redis port, and any backend port; see §6.2). The alternative is `just ns datastores up` inside the sandbox's own dockerd, which gives isolated, empty data per sandbox.

### 4.18 `.venv` / `node_modules` in the workspace

These were built for macOS and won't run in the Linux VM. Reinstalling over them would break the host copies.
- **Python:** use `UV_PROJECT_ENVIRONMENT=/home/agent/.venv-ns` so the sandbox gets its own venv.
- **Node:** a `volume@1` at the absolute `…/NorthSpyre/front_end/react/node_modules` path could shadow the host directory _(verify that a volume can overlay a path inside a workspace mount)_.
- Tell the agent, through a project rule or the merged `CLAUDE.md`, never to `npm install` or `uv sync` into the host paths.

### 4.19 WebFetch domain allowlist

WebFetch requests come from inside the VM, so egress policy applies. Allow the domains your settings already trust: `sbx policy allow network circleci.com,support.circleci.com,pdfbox.apache.org,javadoc.io` (global, or `--sandbox NAME`). `sbx policy log` shows refused connections. WebSearch runs on Anthropic's side and isn't affected.

### 4.20 Tooling

A mixin **install** hook runs `sudo apt-get install -y nodejs npm zsh just fd-find postgresql-client redis-tools` plus an editor (§5.4). Check package names on DHI Debian 13. To pay the install cost once, save a configured sandbox with `sbx template save` and create new ones from it (`-t`). Templates don't include mounted workspaces or the Docker store.

### 4.21 Launching from nvim

`nvim/lua/plugins/ai.lua` `toggle_ai_cli` runs `claude` in a terminal, setting `CLAUDE_CODE_TASK_LIST_ID` and `EDITOR` (`scripts/neovim-remote`, which needs `$NVIM`). For the sandbox, the command becomes something like:

```lua
{ "sbx", "run", "claude", "--name", <name>, "-e", "CLAUDE_CODE_TASK_LIST_ID=" .. cwd, "-e", "HOST_NVIM=" .. vim.v.servername }
```

`-e` applies on re-attach too. The passthrough keymaps keep working because it's the same TTY. `scripts/neovim-remote` cannot work inside the VM: see §5.4 for Ctrl+G.

### 4.22 Session history and `/resume`

Transcripts and `history.jsonl` live in the VM. They survive stop/start and are lost on `sbx rm`. Host sessions aren't visible inside, and `scripts/claude-session-recap.py` (which reads `~/.claude/projects`) can't see sandbox sessions. The fix is in §5.7.

### 4.23 Clipboard, browser, Chrome, Remote Control

All of these are sbx settings and are off by default unless noted:
- **Image paste:** `sbx settings set clipboard.imagePaste true`.
- **Copying text out** (`/copy`; the image has `pbcopy`/`xclip` shims): `clipboard.textCopy true`.
- **Opening URLs** (`/login`, links): `browser.enabled`, which is already on.
- **Claude in Chrome:** `claude.chrome true`. It needs subscription OAuth, not an API key.
- **Remote Control:** `claude.remoteControl true`.

### 4.24 IDE integration

Not used today: there's no `claudecode.nvim`. See §5.5 if that changes.

---

## 5. Workarounds for unsupported and partial items

### 5.1 Foundation: host bridge through the sbx MCP gateway

Most gaps come down to one thing: something in the sandbox needs to reach a host-only resource, such as `osascript`, the nvim RPC socket, or host files. A stdio MCP server registered with `sbx mcp add --command` runs **on the Mac**, and sandbox processes can call it through `MCP_GATEWAY_URL`.

**Tested on 2026-11-14:**
- I registered a throwaway Python stdio server and loaded it into a sandbox (`sbx mcp load probe-bridge --sandbox probe-parity`).
- A `curl` inside the sandbox ran `initialize` and then `tools/call` against the gateway.
- The host process wrote a marker file on the Mac.
- The tool did **not** appear in the gateway's `tools/list`, which showed only `mcp-find`/`mcp-exec`/`mcp-config-set`, but a direct `tools/call` worked.

Proposal:
- **Host side:** `claude/sandbox/host_bridge.py`, a uv script and stdio MCP server. Register it once with `sbx mcp add host-bridge --command uv --args run,--script,/Users/vaughn/dotfiles/claude/sandbox/host_bridge.py` and attach it with `--static-mcp host-bridge`. It exposes only narrow tools that take data and never commands: `notify`, `nvim_checktime`, and `nvim_edit`.
- **Sandbox side:** `claude/sandbox/bridge_call.py`, a small `python3` client for initialize plus `tools/call`, read from the read-only dotfiles mount. Hooks and `EDITOR` use it.
- **Which nvim:** pass the host socket with `-e HOST_NVIM=…`. The bridge accepts it only if it's an existing socket owned by you.
- **Caveats:**
  - The agent can call these tools too, because they're on its gateway, so keep them harmless. `nvim_edit` must only accept paths under a mounted workspace or the edit-exchange dir.
  - Gateway timeouts for long-blocking calls are unknown _(verify)_.
  - The tools aren't in `tools/list`, so hooks call them by name.

### 5.2 Notifications

| Option | Works when Claude runs… | Effort |
|---|---|---|
| **A. Bridge `notify` (recommended):** the merged settings carry a `Notification` hook that calls `bridge_call.py notify`, which runs `osascript` on the host, and also prints in nvim when `HOST_NVIM` is set. This matches today's behaviour. | anywhere | Bridge (§5.1) |
| B. `preferredNotifChannel: "ghostty"`: Claude emits OSC 777 over the TTY, and ghostty has `desktop-notifications = true`. | Directly in ghostty only. **Not** inside the nvim terminal, which consumes the escape sequence. **Not** in tmux either: Claude only wraps passthrough when `$TMUX` is set, which it isn't in the VM, and `tmux/tmux.conf` has no `allow-passthrough`. | Config only |
| C. Docker's built-in path: `sbx-claude-hook` sends `agent_notify` to a Docker sandbox desktop app. | Only while that app is running _(not tested; Docker Desktop here is 4.41)_ | None |

`terminal_bell` already works as a no-effort fallback.

### 5.3 nvim reload after edits

- **Mostly covered already:** `nvim/lua/config/autocmds.lua:47` runs `checktime` on `FocusGained`/`TermClose`/`TermLeave`, and agent edits land on the host filesystem directly. Leaving the Claude terminal reloads changed buffers.
- **Buffers visible in a split during edits:** the PostToolUse `Write|Edit` hook calls bridge `nvim_checktime(HOST_NVIM)`, and the host runs `nvim --server <sock> --remote-send '<cmd>checktime<cr>'`, the same command you use today. A host-only alternative is a timer in nvim that runs `checktime` while an `ai_cli` terminal job is alive.

### 5.4 Ctrl+G external editor

| Option | Notes |
|---|---|
| **A. Edit in host nvim through the bridge.** Sandbox `EDITOR=/Users/vaughn/dotfiles/claude/sandbox/editor.py`. It copies Claude's temp file into an exchange dir: a mixin `host-mount@1` at `/home/agent/.sbx-edit`, bound with `--mount ~/.cache/sbx-edit:/home/agent/.sbx-edit` so the host path is known. It then calls `nvim_edit(HOST_NVIM, path)` and copies the result back when the call returns. | nvim 0.12.6 has no `--remote-wait`, so the bridge opens the file with `--remote-tab` and polls `--remote-expr "bufloaded(…)"` until you close it. This depends on the gateway allowing a long call _(verify)_. You get your real nvim. |
| B. Install nvim in the sandbox and set `EDITOR=nvim`. Optionally use `NVIM_APPNAME=minimal-nvim` or symlink a config from the dotfiles mount. | Simple, but you get nvim nested inside the nvim terminal. A full config needs lazy.nvim installs per sandbox (network allow for github). |
| C. Install `vim` and set `EDITOR=vim`. | Lowest effort. |

The image has **no** editor at all today, so pick one of these or Ctrl+G fails.

### 5.5 IDE integration (`/ide`)

Not tested; I recommend skipping it unless you adopt an IDE plugin. The approach would be:
- The IDE plugin listens on `127.0.0.1:<port>` and writes `~/.claude/ide/<port>.lock` with an auth token.
- Pin that port in the plugin and add `host-port@1 {host: <port>}` to the mixin.
- Copy the lock file into `/home/agent/.claude/ide/` with a startup hook from a mounted dir.

Another route is an IDE connecting *into* the sandbox: `sbx setup ssh` configures SSH access to sandboxes, which could allow VS Code Remote-SSH _(verify)_.

### 5.6 Permission mode `auto` instead of bypass

- **A. Accept bypass (recommended).** The sandbox is the boundary: microVM, deny-by-default egress, and read-only config mounts. Keep your `deny` rules in the merge _(verify they're still enforced under bypass)_.
- **B. Personal workload kit:** a kit that `extends` the sbx Claude kit and overrides the launch command to `--permission-mode auto`. Make it the default with `sbx settings set kit.shortcuts.claude <ref>`. The merge would then also set `defaultMode: auto` and remove `skipDangerousModePermissionPrompt` _(verify that `extends` can override the command; check with `sbx kit inspect --resolved`)_.

### 5.7 Share sessions between host and sandbox

Workspace paths are identical, so per-project transcript directories (`~/.claude/projects/-Users-vaughn-…`) match. A mixin declares `host-mount@1 {path: /home/agent/.claude/projects}`, and you bind it to the real host dir at create time:

```sh
sbx run claude . --mount ~/.claude/projects:/home/agent/.claude/projects   # ~/.claude-ns/projects for work
```

`claude --resume` would then work in both directions, and `scripts/claude-session-recap.py` would see sandbox sessions unchanged _(verify that `--mount` accepts an existing, populated dir)_.

**Do not mount all of `~/.claude` or `~/.claude-ns`.** `.claude.json` holds stdio `mcpServers` commands that **host** Claude executes. A sandboxed agent with write access could plant one and escape the next time you run Claude on the host. The same applies to settings hooks, which is why those come from the read-only dotfiles mount.

---

## 6. Common workflows that change inside a sandbox

These aren't spelled out in your config, but they change because of the facts in §1.

### 6.1 Showing Claude files and screenshots
- **Dragging a screenshot from Finder, or typing a path like `~/Desktop/…png` / `~/Downloads/…`, fails.** The path refers to the Mac. Enable image paste (§4.23), or mount a screenshots folder read-only as an extra workspace.
- **"Look at the log in /tmp/…" fails.** Host `/tmp` isn't the VM's `/tmp`. The northspyre allow rule `Read(//tmp/**)` now refers to the VM's `/tmp`.
- **Any file outside the mounted workspaces is invisible**, including other repos, `~/Library` logs, and `~/.aws` and similar config.

### 6.2 Running and testing the app (northspyre)
- **Servers running on the Mac** (Flask, React dev server) can't be reached with `curl localhost:<port>`. That affects the `curl-api-testing` skill, the `._vaughn/scripts` seed scripts, and anything that checks a running endpoint. Either grant `host-port@1` per port (§4.17) or run the whole stack inside the sandbox.
- **Servers started inside the sandbox** need `sbx ports <sandbox> --publish <port>` (or `-p` at create) before your Mac browser can see them. Bind them to `0.0.0.0` to be safe _(verify whether loopback-bound servers are reachable through a published port)_.
- **Docker commands see only the sandbox's daemon.** `just redisflush` (`docker exec ns-redis …`), "check the container logs", and `docker ps` don't see host containers. If datastores run in the sandbox, each sandbox gets its own empty volumes, and images are pulled again per sandbox.
- **Cloud and cluster tools** (`just utils kshell …`, `kubectl`, `aws`) have no credentials or config. That's probably desirable for QA environments. If needed, use per-service secrets plus network allows.
- **DB clients** (`psql`, `redis-cli`) aren't installed (§4.20).

### 6.3 Git and GitHub day to day
- **Works:** HTTPS push/pull, `gh pr create`/`view`, PR comment review, CI log fetches through `gh`.
- **Breaks:** SSH remotes and SSH signing (§4.16), and commits before git identity is set (§4.14).
- **Worktrees:** see §4.15. Claude's own worktree features work only inside the mounted repo.

### 6.4 Parallel sessions (tmux and worktrees)
- **Each sandbox is a full VM.** By default that's about 7 GB of RAM and every CPU, so three or four parallel worktree agents can starve the Mac. Use `--memory` / `--cpus`, or run several sessions in one sandbox (`sbx exec -it <sandbox> claude`).
- **`sbx run claude` in a directory that already has a sandbox asks you to reuse it.** A second agent in the same worktree needs a distinct `--name` or `sbx exec`.
- **Per-sandbox state is not shared** (plugins, login, transcripts) unless you set up the host mounts above.

### 6.5 Detaching and background work
- **A local sandbox stops once its last session disconnects**, unless a kit declares `long-running@1`. When it stops, Claude's background shells, `/loop` and session-only cron jobs, `run_in_background` processes, and dev servers Claude started all die.
- **Re-attach with `sbx run --name <sandbox>`**, and use `claude --continue`/`--resume` inside it.
- **Remote Control** (continuing from phone or claude.ai) needs `claude.remoteControl` (§4.23).

### 6.6 Shell environment Claude assumes from your Mac
- **The shell is bash.** None of your zsh setup loads: no `.zshrc` aliases, no mise, no `ns` function from `profile_utils.sh`. The justfile's `#!/usr/bin/env zsh` recipes need zsh installed.
- **Env changes across bash calls** persist through `/etc/sandbox-persistent.sh` (the kit's `CLAUDE_ENV_FILE`), not through your profile.
- **Linux tool differences:** macOS-specific commands Claude has used in your sessions behave differently or are missing, such as `sed -i ''`, `open`, `pbpaste`, BSD `find`/`date`/`stat` flags, and `osascript`.

### 6.7 Time and locale
- **The VM runs in UTC.** That affects "what did I do today", log and commit timestamps, date-sensitive tests, and the recap script's day boundaries. Pass `-e TZ=America/…` if that matters.

### 6.8 Network-dependent work
- **Package installs** from public npm and PyPI work through the proxy (the CA is trusted). **Private registries** need custom secrets: `npm.pkg.github.com` isn't covered by the `github` secret, and neither is CodeArtifact.
- **Downloading from a new domain** may be blocked, whether by `WebFetch` on docs sites or `curl` of release binaries. Check `sbx policy log`. `WebSearch` is unaffected.
- **Non-HTTP protocols** are limited: UDP and ICMP are blocked, so `ping` and some database or cloud protocols that use them won't work.

### 6.9 Performance
- **Mounted repos may be slower.** Workspaces are shared into the VM, so `rg`, `git status`, `tsc`, `jest`, and `pytest` on a large repo may be slower than on the Mac _(not measured)_.
- **The sandbox's Docker disk** is a separate 10 GB volume (`sandbox.disk.dockerVolume`).

### 6.10 Versions and other Claude surfaces
- **Claude Code's version is pinned by the kit image.** It was 2.1.325 on both host and sandbox at probe time, but the two can drift. New features or fixes may not match, and `claude update` inside the VM is lost on re-creation.
- **Other surfaces run on the host,** not in the sandbox: the VS Code extension, the desktop app, and scripts or editor plugins that call `claude -p`.
- **Browser automation** needs browsers inside the sandbox (for example the `docker.io/sbx/playwright` kit), or Claude in Chrome (§4.23).

### 6.11 Things that keep working unchanged
- **Inside a session:** subagents, agent teams, skills (once §4.9 is set up), slash commands, `/compact`, plan mode, task lists, and project-level hooks and CLAUDE.md.
- **The workspace itself:** edits land on the host immediately.
- **Your terminal, nvim, and tmux setup on the Mac**, because only the agent process moves.

---

## 7. Suggested shape

Use a personal **mixin kit** for user-level parity, plus one **`sbxenv.yaml`** per project:

```
dotfiles/claude/sandbox/
  spec.yaml              # mixin: git-identity@1, open-url@1 (optional),
                         #   lifecycle@1 install: apt tools, node + LSP binaries, plugins
                         #   lifecycle@1 startup: merge_settings.py, CLAUDE.md @import, keybindings
                         #     + skills symlinks, gitignore append
                         #   network-policy@1 (install phase: apt, npm, github)
                         #   host-mount@1: /home/agent/.claude/plugins, /home/agent/.claude/projects,
                         #     /home/agent/.sbx-edit
  merge_settings.py      # §4.1
  host_bridge.py         # §5.1 host side (runs on the Mac)
  bridge_call.py         # §5.1 sandbox side
  editor.py              # §5.4 option A
local-config/northspyre/sandbox/
  kit.yaml               # mixin: host-port@1 5432 (+ redis, backend ports), psql/redis clients
  sbxenv.yaml            # agent: claude; workspace; additionalWorkspaces: ~/dotfiles:ro,
                         #   ~/dev/local-config:ro (+ main .git for worktrees); kits: both mixins;
                         #   env: DOTFILES_DIR, UV_PROJECT_ENVIRONMENT, TZ; mounts: projects → ~/.claude-ns/projects;
                         #   mcp: northspyre-local, host-bridge; sandboxOptions: skills: off, memory
```

`sbxenv.yaml` must sit outside writable mounts. Inside local-config is fine, because local-config is mounted read-only. With this in place, `sbx env run <dir>` replaces `claude` as the launch command, including in `toggle_ai_cli`.

One-time host setup:

```sh
sbx login
sbx secret set github --command 'gh auth token'          # already done
sbx mcp add northspyre-local --command uv --args …       # §4.11
sbx mcp add host-bridge --command uv --args …            # §5.1
sbx settings set clipboard.imagePaste true
sbx settings set clipboard.textCopy true
sbx policy allow network circleci.com,support.circleci.com,pdfbox.apache.org,javadoc.io
```

Other changes outside the sandbox:
- Remove `/Users/vaughn/dev/local-config/claude` from northspyre `settings.local.json` `additionalDirectories` (§4.12).
- Make `scripts/claude-session-recap.py` accept a projects dir if you don't use the direct bind in §5.7.

---

## 8. Open questions

Questions 4–9 were probed on 2026-11-14 with throwaway sandboxes, which were then removed. The §7 mixin is prototyped in `claude/sandbox/`. sbx requires the descriptor to be named `spec.yaml`, not `kit.yaml`.

1. Are `deny` permission rules enforced under `--dangerously-skip-permissions`? (§4.6) **Open:** needs `/login` in a sandbox.
2. Does `oauthAccount` exist in the sandbox's `.claude.json` after `/login`? (§4.7) **Open:** before login, the statusline shows `account:error(missing oauthAccount)`.
3. Are OAuth logins per sandbox or shared? (§4.10) **Open:** needs `/login`.
4. Can a `volume@1` overlay a path inside a workspace mount, such as `node_modules`? (§4.18) **Yes.** The sandbox sees an empty ext4 volume at that path, and the host directory is untouched.
5. Does `--mount` accept an existing, populated host dir for a `host-mount@1` path? (§5.7, §5.4) **Yes.** Existing files are visible before hooks run.
6. How long can a gateway `tools/call` block before it times out? (§5.1, §5.4) **No timeout was seen up to 310 s.** `editor.py` still avoids long calls: `nvim_edit` returns at once, and the editor polls `nvim_edit_status`.
7. Can a kit that `extends` the Claude kit override its launch command? (§5.6) **Partly answered.** A mixin's `lifecycle@1` `interactive` tail is ignored; the launch stayed `claude --dangerously-skip-permissions`. A workload kit that uses `extends` couldn't be built here, because building it needs Docker Desktop's containerd image store (`OCI exporter is not supported for the docker driver`).
8. Can a published port reach a server bound to loopback inside the VM? (§6.2) **No.** The connection is reset. Servers must bind `0.0.0.0`.
9. Do the mixin's startup hooks run after the kit writes `settings.json` and `CLAUDE.md` on every boot, or only at create? (§4.1) **The kit writes both files once, at create, before install hooks.** It doesn't rewrite them on restart. Startup hooks run on every boot. `merge_settings.py` therefore keeps the kit's original file as `settings.sbx-base.json` and re-merges from it.
10. How much slower is a large repo over the workspace mount than on the Mac? (§6.9) **Open.**
