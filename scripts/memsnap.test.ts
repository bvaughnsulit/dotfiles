// Tests for memsnap. Unit tests cover the pure parsing/formatting helpers;
// the integration test runs the whole script against faked system tools placed
// earlier on PATH, so no real `top`/`ps`/`lsof` is invoked.

import { test } from "node:test"
import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"

import { flattenDescendants, formatCmd, parseSnapshot, tomb } from "./memsnap.ts"

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

test("flattenDescendants: transitive children, sorted by footprint desc", () => {
    const kids = new Map([
        ["100", ["200", "250", "700"]],
        ["200", ["300"]], // grandchild, reached transitively
    ])
    const mem = new Map([
        ["100", 1200], ["200", 300], ["250", 40], ["300", 500],
    ])

    // root excluded; the grandchild is pulled in; rows sorted by MB descending;
    // a pid absent from `mem` (700) contributes 0.
    assert.deepEqual(flattenDescendants("100", kids, mem), [
        ["300", 500],
        ["200", 300],
        ["250", 40],
        ["700", 0],
    ])

    // a leaf has no descendants; an unknown pid yields nothing
    assert.deepEqual(flattenDescendants("250", kids, mem), [])
    assert.deepEqual(flattenDescendants("999", new Map(), new Map()), [])
})

test("integration: renders every section from faked system tools", () => {
    const dir = mkdtempSync(join(tmpdir(), "memsnap-"))
    try {
        const fake = (name: string, body: string) => {
            const binPath = join(dir, name)
            writeFileSync(binPath, body)
            chmodSync(binPath, 0o755)
        }

        // A small process world exercising both nvim instances and truncation:
        //   300  big consumer, ppid 1
        //   100  nvim (1200M) @ project, with children 200 (600M) and 250 (40M)
        //   500  nvim (400M)  @ other-project, with child 600 (50M)
        //   400  copilot server (80M), reparented to launchd (ppid 1)
        // Instance 100 totals 1840M (kept under --compact); instance 500 totals
        // 450M (dropped under --compact). Under --compact's 500M proc cutoff, 200
        // stays while 250 is hidden. Only 300 and 100 clear the 1000M top cutoff.
        fake("top", [
            "#!/bin/sh",
            "cat <<'EOF'",
            "Processes: 7 total",
            "PhysMem: 15G used (4073M wired), 134M unused.",
            "VM: 264T vsize, 6144M framework vsize.",
            "PID    MEM    COMMAND",
            "300    6000M  /opt/big/process",
            "100    1200M  /home/test/.local/nvim",
            "200    600M   node some-lsp",
            "500    400M   /home/test/.local/nvim",
            "400    80M    node copilot-language-server",
            "600    50M    node small-lsp",
            "250    40M    node tiny-helper",
            "EOF",
            "",
        ].join("\n"))

        fake("pgrep", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'case "$last" in',
            "  nvim) printf '100\\n500\\n' ;;",
            "  node) printf '200\\n250\\n400\\n600\\n' ;;",
            "esac",
            "",
        ].join("\n"))

        fake("ps", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'case "$*" in',
            "  *pid=,ppid=*)",
            "    printf '  100     1\\n  200   100\\n  250   100\\n  300     1\\n  400     1\\n  500     1\\n  600   500\\n' ;;",
            "  *ppid=*)",
            '    case "$last" in 200|250) echo 100 ;; 600) echo 500 ;; *) echo 1 ;; esac ;;',
            "  *command=*)",
            '    case "$last" in',
            "      100|500) echo /home/test/.local/nvim ;;",
            "      200) echo node some-lsp ;;",
            "      250) echo node tiny-helper ;;",
            `      300) echo ${LONG_CMD} ;;`,
            "      400) echo node copilot-language-server ;;",
            "      600) echo node small-lsp ;;",
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
            '  500) echo "nvim $last user cwd DIR 1,2 3 4 /home/test/other-project" ;;',
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

        // memory-pressure section is gone
        assert.ok(!out.includes("memory pressure"), "expected no memory-pressure section")
        assert.ok(!out.includes("PhysMem"), "expected no PhysMem passthrough")

        // top by footprint: only consumers >= 1000M (300, 100); each row tagged with
        // its cwd. 200/500/etc are below the cutoff and absent from this section.
        assert.match(out, /== top by footprint \(≥ 1,000 MB\) ==/)
        assert.match(out, /6,000 MB[^\n]*300[^\n]*⟨other⟩[^\n]*\/opt\/big\/process/)

        // nvim instance: directory subheader carries the total + proc count; procs
        // (root nvim folded in) are flattened to one level, sorted by footprint desc.
        assert.match(out, /project[^\n]*\(1,840 MB · 3 procs\)/)
        assert.match(out, /1,200 MB[^\n]*100[^\n]*\.local\/nvim/)
        assert.match(out, /600 MB[^\n]*200[^\n]*node some-lsp/)
        assert.match(out, /40 MB[^\n]*250[^\n]*node tiny-helper/)
        // no tree connectors, and the divider/subtotal footer is replaced by the subheader
        assert.ok(!out.includes("└─"), "expected flat listing, not a tree")
        assert.ok(!out.includes("subtotal"), "expected the subtotal footer to be gone")
        assert.ok(!out.includes("─────────"), "expected the divider line to be gone")

        // instances ordered by subtotal desc (1840 before 450); within an instance,
        // procs ordered by footprint desc (some-lsp 600M before tiny-helper 40M)
        assert.ok(out.indexOf("some-lsp") < out.indexOf("small-lsp"), "instances not sorted by subtotal")
        assert.ok(out.indexOf("some-lsp") < out.indexOf("tiny-helper"), "procs not sorted by footprint")

        // the smaller nvim instance and its child are still fully shown by default
        assert.match(out, /other-project[^\n]*\(450 MB · 2 procs\)/)
        assert.match(out, /400 MB[^\n]*500[^\n]*\.local\/nvim/)
        assert.match(out, /50 MB[^\n]*600[^\n]*node small-lsp/)

        // orphan section lists the reparented copilot (ppid 1)...
        assert.match(out, /orphaned LSP\/copilot[\s\S]*80 MB[^\n]*400[^\n]*node copilot-language-server/)
        // ...but each proc is only shown once, under its nvim
        assert.equal((out.match(/node some-lsp/g) ?? []).length, 1)

        // long command is truncated by default, printed in full under --full
        assert.ok(!out.includes(LONG_CMD), "expected default run to truncate")
        const full = execFileSync("node", [script, "3", "--full"], { encoding: "utf-8", env })
        assert.ok(full.includes(LONG_CMD), "expected --full run to keep the whole command")

        // --compact drops the sub-1000MB instance (500) and the sub-500MB proc (250),
        // each replaced by a count. The kept proc (200, 600M) stays, and the subheader
        // total/count still reflect the hidden proc (display-only hiding).
        const cmpct = execFileSync("node", [script, "3", "--compact"], { encoding: "utf-8", env })
        assert.match(cmpct, /600 MB[^\n]*200[^\n]*node some-lsp/) // above the 500M cutoff, kept
        assert.match(cmpct, /project[^\n]*\(1,840 MB · 3 procs\)/) // hidden proc still counted
        assert.match(cmpct, /… 1 process below 500 MB/)
        assert.match(cmpct, /… 1 more nvim instance under 1000 MB/)
        assert.ok(!cmpct.includes("tiny-helper"), "expected the sub-500MB proc hidden")
        assert.ok(!cmpct.includes("small-lsp"), "expected the sub-1000MB instance dropped")
    } finally {
        rmSync(dir, { recursive: true, force: true })
    }
})

test("integration: omits the orphan section when nothing has reparented", () => {
    const dir = mkdtempSync(join(tmpdir(), "memsnap-"))
    try {
        const fake = (name: string, body: string) => {
            const binPath = join(dir, name)
            writeFileSync(binPath, body)
            chmodSync(binPath, 0o755)
        }

        // A world with a big consumer and one nvim whose lsp (200) is still a child
        // of nvim (ppid 100) — nothing has reparented to launchd, so the orphan
        // section has nothing to show.
        fake("top", [
            "#!/bin/sh",
            "cat <<'EOF'",
            "Processes: 3 total",
            "PhysMem: 15G used (4073M wired), 134M unused.",
            "PID    MEM    COMMAND",
            "300    6000M  /opt/big/process",
            "100    1200M  /home/test/.local/nvim",
            "200    300M   node some-lsp",
            "EOF",
            "",
        ].join("\n"))

        fake("pgrep", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'case "$last" in',
            "  nvim) echo 100 ;;",
            "  node) echo 200 ;;",
            "esac",
            "",
        ].join("\n"))

        fake("ps", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'case "$*" in',
            "  *pid=,ppid=*)",
            "    printf '  100     1\\n  200   100\\n  300     1\\n' ;;",
            "  *ppid=*)",
            '    case "$last" in 200) echo 100 ;; *) echo 1 ;; esac ;;',
            "  *command=*)",
            '    case "$last" in',
            "      100) echo /home/test/.local/nvim ;;",
            "      200) echo node some-lsp ;;",
            "      300) echo /opt/big/process ;;",
            "    esac ;;",
            "esac",
            "",
        ].join("\n"))

        fake("lsof", [
            "#!/bin/sh",
            'for last in "$@"; do :; done',
            'echo "COMMAND PID USER FD TYPE DEVICE SIZE NODE NAME"',
            'echo "proc $last user cwd DIR 1,2 3 4 /home/test/project"',
            "",
        ].join("\n"))

        const script = join(import.meta.dirname, "memsnap.ts")
        const env = { ...process.env, HOME: "/home/test", PATH: `${dir}:${process.env.PATH}` }
        const out = execFileSync("node", [script], { encoding: "utf-8", env })

        assert.ok(!out.includes("orphaned"), "expected the orphan section omitted when empty")
        assert.match(out, /project[^\n]*\(1,500 MB · 2 procs\)/) // nvim section still renders
    } finally {
        rmSync(dir, { recursive: true, force: true })
    }
})
