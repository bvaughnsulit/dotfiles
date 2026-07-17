// Tests for memsnap. Unit tests cover the pure parsing/formatting helpers;
// the integration test runs the whole script against faked system tools placed
// earlier on PATH, so no real `top`/`ps`/`lsof` is invoked.

import { test } from "node:test"
import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"

import { formatCmd, parseSnapshot, tomb } from "./memsnap.ts"

// A command well past the 72-col truncation width, with no $HOME prefix to strip.
const LONG_CMD = "/opt/big/process/" + "deep/".repeat(20) + "leaf"

test("tomb: normalises top's MEM units to integer megabytes", () => {
    assert.equal(tomb("6000M"), 6000)
    assert.equal(tomb("500M"), 500)
    assert.equal(tomb("2.5G"), 2560)
    assert.equal(tomb("2048K"), 2)
    assert.equal(tomb("512K"), 0) // sub-MB truncates to 0
    assert.equal(tomb("0B"), 0)
    assert.equal(tomb("42"), 42) // bare number is already MB
    assert.equal(tomb("1.9M"), 1) // truncates, never rounds up
    assert.equal(tomb(""), 0)
    assert.equal(tomb("garbage"), 0)
})

test("formatCmd: strips the $HOME prefix and truncates to maxLen", () => {
    assert.equal(formatCmd("/home/test/foo/bar", "/home/test"), "foo/bar")
    assert.equal(formatCmd("/usr/bin/node", "/home/test"), "/usr/bin/node") // no home to strip
    assert.equal(formatCmd("/home/test/a /home/test/b", "/home/test"), "a b") // every occurrence
    assert.equal(formatCmd("", "/home/test"), "<gone>") // exited mid-snapshot
    assert.equal(formatCmd("x".repeat(100), "/home/test").length, 72) // truncates by default
    assert.equal(formatCmd("x".repeat(100), "/home/test", Infinity), "x".repeat(100)) // --full keeps it
})

test("parseSnapshot: pairs pid with footprint, in order, skipping noise", () => {
    const snap = [
        "Processes: 5 total",
        "PhysMem: 15G used, 134M unused.", // pre-header lines ignored
        "PID    MEM    COMMAND",
        "300    6000M  /opt/big/process",
        "100    500M   /home/test/.local/nvim",
        "garbage line", // non-numeric first field skipped
        "200    50M    node some-lsp with spaces", // trailing cols ignored
    ].join("\n")

    assert.deepEqual(parseSnapshot(snap), [
        ["300", 6000],
        ["100", 500],
        ["200", 50],
    ])
})

test("parseSnapshot: empty input yields no rows", () => {
    assert.deepEqual(parseSnapshot(""), [])
})

test("integration: renders every section from faked system tools", () => {
    const dir = mkdtempSync(join(tmpdir(), "memsnap-"))
    try {
        const fake = (name: string, body: string) => {
            const binPath = join(dir, name)
            writeFileSync(binPath, body)
            chmodSync(binPath, 0o755)
        }

        // A tiny process world: one big consumer (300), an nvim (100) with a
        // child lsp (200), and a copilot server (400) reparented to launchd.
        fake("top", [
            "#!/bin/sh",
            "cat <<'EOF'",
            "Processes: 4 total",
            "PhysMem: 15G used (4073M wired), 134M unused.",
            "VM: 264T vsize, 6144M framework vsize.",
            "PID    MEM    COMMAND",
            "300    6000M  /opt/big/process",
            "100    500M   /home/test/.local/nvim",
            "400    80M    node copilot-language-server",
            "200    50M    node some-lsp",
            "EOF",
            "",
        ].join("\n"))

        fake("pgrep", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'case "$last" in',
            "  nvim) echo 100 ;;",
            "  node) printf '200\\n400\\n' ;;",
            "esac",
            "",
        ].join("\n"))

        fake("ps", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'case "$*" in',
            "  *pid=,ppid=*)",
            "    printf '  100     1\\n  200   100\\n  300     1\\n  400     1\\n' ;;",
            "  *ppid=*)",
            '    case "$last" in 100|300|400) echo 1 ;; 200) echo 100 ;; *) echo 1 ;; esac ;;',
            "  *command=*)",
            '    case "$last" in',
            "      100) echo /home/test/.local/nvim ;;",
            "      200) echo node some-lsp ;;",
            `      300) echo ${LONG_CMD} ;;`,
            "      400) echo node copilot-language-server ;;",
            "    esac ;;",
            "esac",
            "",
        ].join("\n"))

        fake("lsof", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'echo "COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME"',
            'case "$last" in',
            '  100) echo "nvim $last user cwd DIR 1,2 3 4 /home/test/project" ;;',
            '  *) echo "proc $last user cwd DIR 1,2 3 4 /home/test/other" ;;',
            "esac",
            "",
        ].join("\n"))

        const script = join(import.meta.dirname, "memsnap.ts")
        const env = { ...process.env, HOME: "/home/test", PATH: `${dir}:${process.env.PATH}` }
        const out = execFileSync("node", [script, "3"], { encoding: "utf-8", env })

        // Columns are size-then-pid-then-command; sizes carry thousands
        // separators and magnitude tint, so match on same-line ([^\n]*) spans
        // that tolerate the interleaved ANSI codes.

        // memory-pressure passthrough
        assert.match(out, /== memory pressure ==/)
        assert.match(out, /PhysMem: 15G used/)
        assert.match(out, /VM: 264T vsize/)

        // top-N, biggest first, honouring the argv N=3, each row tagged with its cwd
        assert.match(out, /== top 3 by footprint ==/)
        assert.match(out, /6,000 MB[^\n]*300[^\n]*⟨other⟩[^\n]*\/opt\/big\/process/)

        // nvim tree: $HOME stripped from cmd + cwd, child under a connector, subtotal summed
        assert.match(out, /500 MB[^\n]*100[^\n]*\.local\/nvim[^\n]*⟨project⟩/)
        assert.match(out, /50 MB[^\n]*200[^\n]*└─ node some-lsp/)
        assert.match(out, /550 MB[^\n]*subtotal · 2 procs/)

        // orphan section lists the reparented copilot (ppid 1)...
        assert.match(out, /orphaned LSP\/copilot[\s\S]*80 MB[^\n]*400[^\n]*node copilot-language-server/)
        // ...but the child lsp (ppid 100) is only shown once, under its nvim
        assert.equal((out.match(/node some-lsp/g) ?? []).length, 1)

        // long command is truncated by default, printed in full under --full
        assert.ok(!out.includes(LONG_CMD), "expected default run to truncate")
        const full = execFileSync("node", [script, "3", "--full"], { encoding: "utf-8", env })
        assert.ok(full.includes(LONG_CMD), "expected --full run to keep the whole command")
    } finally {
        rmSync(dir, { recursive: true, force: true })
    }
})
