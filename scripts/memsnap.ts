// memsnap — quick memory snapshot (true footprint) with an nvim drill-down.
//
// Why not ps/RSS: under memory pressure macOS compresses and swaps pages, so a
// process actually holding gigabytes can report only a few MB of RSS. top's MEM
// column counts the real physical footprint (resident + compressed + dirty), so
// that is what we read here.
//
// usage: node scripts/memsnap.ts [N] [--full]
//   N       number of overall consumers to list (default 15)
//   --full  print full command names instead of truncating them to 72 columns

import { execSync } from "node:child_process"

const HOME = process.env.HOME ?? ""
const DEFAULT_CMD_LEN = 72 // command-name truncation width; --full lifts it

const BOLD = "\x1b[1m"
const DIM = "\x1b[2m"
const RED = "\x1b[1;31m"
const RESET = "\x1b[0m"
const header = (s: string) => console.log(`${BOLD}${s}${RESET}`)

// Run a command, returning stdout as text. Many of our probes race against
// processes that may exit mid-snapshot, so a non-zero exit just yields "".
function sh(cmd: string): string {
    try {
        return execSync(cmd, {
            encoding: "utf-8",
            stdio: ["ignore", "pipe", "ignore"],
            // lsof can block indefinitely on a stale mount; cap every probe so a
            // hung command degrades to "" (a timeout throws) instead of wedging.
            timeout: 5000,
            killSignal: "SIGKILL",
        })
    } catch {
        return ""
    }
}

// Normalise top's MEM units (K/M/G/B) to integer megabytes.
export function tomb(v: string): number {
    const num = parseFloat(v.replace(/[^0-9.]/g, "")) || 0
    if (/G/.test(v)) return Math.trunc(num * 1024)
    if (/K/.test(v)) return Math.trunc(num / 1024)
    if (/B/.test(v)) return 0
    return Math.trunc(num)
}

// A fixed-width megabyte column: thousands-separated, unit-suffixed, right-
// aligned so every row's size lines up for vertical scanning, and tinted by
// magnitude so heavy consumers stand out (red ≥1G) and trivial ones recede.
export function sizeCell(mb: number): string {
    const text = `${mb.toLocaleString("en-US")} MB`.padStart(9)
    const tint = mb >= 1024 ? RED : mb < 64 ? DIM : ""
    return tint ? `${tint}${text}${RESET}` : text
}

// Present a raw `ps command=` string with the $HOME prefix stripped, clamped to
// `maxLen` columns (pass Infinity to keep the full command). "<gone>" if empty.
export function formatCmd(raw: string, home: string, maxLen = DEFAULT_CMD_LEN): string {
    return (raw.split(home + "/").join("") || "<gone>").slice(0, maxLen)
}

// A process's command with $HOME stripped, clamped to `maxLen`. "<gone>" if gone.
function shortCmd(pid: string, maxLen: number): string {
    return formatCmd(sh(`ps -o command= -p ${pid}`).trim(), HOME, maxLen)
}

// A process's working directory with $HOME stripped, or "" if lsof can't read
// it (common for processes we don't own). lsof prints one line per fd; the cwd
// path is the last whitespace-separated field of the last line.
function cwdOf(pid: string): string {
    return sh(`lsof -a -d cwd -p ${pid}`)
        .trim().split("\n").pop()!.split(/\s+/).pop()!
        .split(HOME + "/").join("")
}

// Parse top's table into [pid, footprintMB] pairs (already sorted desc).
// Rows begin after the "PID ..." header line; a row's first field is the pid
// and its second is the MEM column.
export function parseSnapshot(snap: string): Array<[string, number]> {
    const parsed: Array<[string, number]> = []
    let started = false
    for (const line of snap.split("\n")) {
        if (/^PID/.test(line)) { started = true; continue }
        if (!started) continue
        const cols = line.trim().split(/\s+/)
        if (/^[0-9]+$/.test(cols[0])) parsed.push([cols[0], tomb(cols[1])])
    }
    return parsed
}

function main(): void {
    const argv = process.argv.slice(2)
    const noTruncate = argv.some((arg) => arg === "--full" || arg === "--no-truncate")
    const n = Number(argv.find((arg) => /^[0-9]+$/.test(arg))) || 15
    const cmdLen = noTruncate ? Infinity : DEFAULT_CMD_LEN

    // One snapshot of every process, ordered by footprint. Reused for every section.
    const snap = sh("top -l 1 -o mem -stats pid,mem,command")

    header("== memory pressure ==")
    for (const line of snap.split("\n")) {
        if (/^(PhysMem|VM):/.test(line)) console.log(line)
    }

    const parsed = parseSnapshot(snap)

    // pid -> footprint(MB) lookup, populated from the single snapshot above.
    const MEM = new Map<string, number>(parsed)

    console.log("")
    header(`== top ${n} by footprint ==`)
    // Dir goes ahead of the command here (unlike the nvim tree's trailing tag):
    // top-N commands run long, so a leading dir stays visible while the command
    // trails off the right edge.
    for (const [pid, mb] of parsed.slice(0, n)) {
        const cwd = cwdOf(pid)
        const dir = cwd ? `${DIM}⟨${cwd}⟩${RESET} ` : ""
        console.log(`${sizeCell(mb)}  ${pid.padStart(6)}  ${dir}${shortCmd(pid, cmdLen)}`)
    }

    // ppid -> [child, ...] map, so we can walk each nvim's descendants.
    const KIDS = new Map<string, string[]>()
    for (const line of sh("ps -axo pid=,ppid=").split("\n")) {
        const [p, pp] = line.trim().split(/\s+/)
        if (!p || !pp) continue
        ;(KIDS.get(pp) ?? KIDS.set(pp, []).get(pp)!).push(p)
    }

    const ISNVIM = new Set<string>(
        sh("pgrep -x nvim").split("\n").map((s) => s.trim()).filter(Boolean),
    )

    // walk pid depth — print a process, then recurse into its children with
    // box-drawing connectors. `prefix` carries the ancestors' vertical bars so
    // the tree lives entirely in the command column, leaving the size/pid
    // columns aligned. Accumulates footprint/count into the caller's tallies.
    let subtotal = 0
    let subCount = 0
    function walk(wp: string, prefix: string, isLast: boolean, isRoot: boolean): void {
        const cmd = shortCmd(wp, cmdLen)
        if (cmd === "<gone>") return
        const mb = MEM.get(wp) ?? 0
        subtotal += mb
        subCount += 1

        let extra = ""
        if (ISNVIM.has(wp)) {
            const cwd = cwdOf(wp)
            extra = ` ${DIM}⟨${cwd || "?"}⟩${RESET}`
        }

        const branch = isRoot ? "" : isLast ? "└─ " : "├─ "
        console.log(`${sizeCell(mb)}  ${wp.padStart(6)}  ${prefix}${branch}${cmd}${extra}`)

        const kids = KIDS.get(wp) ?? []
        const childPrefix = isRoot ? "" : prefix + (isLast ? "   " : "│  ")
        kids.forEach((c, i) => walk(c, childPrefix, i === kids.length - 1, false))
    }

    console.log("")
    header("== nvim sessions (each with its child procs) ==")
    if (ISNVIM.size === 0) {
        console.log(`  ${DIM}(none running)${RESET}`)
    } else {
        for (const p of ISNVIM) {
            const pp = sh(`ps -o ppid= -p ${p}`).trim()
            if (ISNVIM.has(pp)) continue // nested nvim: shown under its parent
            subtotal = 0
            subCount = 0
            walk(p, "", true, true)
            console.log(`  ${DIM}${"─".repeat(9)}${RESET}`)
            const total = `${subtotal.toLocaleString("en-US")} MB`.padStart(9)
            console.log(`${BOLD}${total}${RESET}  ${DIM}subtotal · ${subCount} proc${subCount === 1 ? "" : "s"}${RESET}\n`)
        }
    }

    // Copilot/LSP servers daemonize and reparent to launchd (ppid 1), so they never
    // show up under an nvim above even though they belong to one. List them so their
    // footprint is not invisible.
    console.log("")
    header("== orphaned LSP/copilot (reparented, not under any nvim) ==")
    let any = false
    for (const p of sh("pgrep node").split("\n").map((s) => s.trim()).filter(Boolean)) {
        if (sh(`ps -o ppid= -p ${p}`).trim() !== "1") continue
        const cmd = sh(`ps -o command= -p ${p}`)
        if (/copilot|language-server|langserver|lsp/.test(cmd)) {
            any = true
            console.log(`${sizeCell(MEM.get(p) ?? 0)}  ${p.padStart(6)}  ${shortCmd(p, cmdLen)}`)
        }
    }
    if (!any) console.log(`  ${DIM}(none)${RESET}`)
}

if (import.meta.main) main()
