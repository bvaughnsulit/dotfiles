// memsnap — quick memory snapshot (true footprint) with an nvim drill-down.
//
// Why not ps/RSS: under memory pressure macOS compresses and swaps pages, so a
// process actually holding gigabytes can report only a few MB of RSS. top's MEM
// column counts the real physical footprint (resident + compressed + dirty), so
// that is what we read here.
//
// usage: node scripts/memsnap.ts [N] [--full] [--compact]
//   N          max number of top consumers to list (default 15; those ≥1000 MB)
//   --full     print full command names instead of truncating them to 72 columns
//   --compact  hide nvim instances under 1000 MB and child procs under 500 MB,
//              replacing each hidden group with a trailing count

import { execSync } from "node:child_process"

const HOME = process.env.HOME ?? ""
const DEFAULT_CMD_LEN = 72 // command-name truncation width; --full lifts it
const TOP_MIN_MB = 1000 // top-consumers section: always hide anything below this
const NVIM_MIN_MB = 1000 // --compact: hide nvim instances whose subtotal is below this
const PROC_MIN_MB = 500 // --compact: hide a nvim's procs below this

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

// Collect a pid's transitive descendants as [pid, footprintMB] pairs, sorted by
// footprint descending. The root is excluded — it stays the anchor line of its
// nvim instance. `mem` supplies footprints (0 for any pid it doesn't list).
export function flattenDescendants(
    root: string,
    kids: Map<string, string[]>,
    mem: Map<string, number>,
): Array<[string, number]> {
    const out: Array<[string, number]> = []
    const stack = [...(kids.get(root) ?? [])]
    while (stack.length) {
        const pid = stack.pop()!
        out.push([pid, mem.get(pid) ?? 0])
        const grandkids = kids.get(pid)
        if (grandkids) stack.push(...grandkids)
    }
    return out.sort((a, b) => b[1] - a[1])
}

function main(): void {
    const argv = process.argv.slice(2)
    const noTruncate = argv.some((arg) => arg === "--full" || arg === "--no-truncate")
    const compact = argv.some((arg) => arg === "--compact")
    const n = Number(argv.find((arg) => /^[0-9]+$/.test(arg))) || 15
    const cmdLen = noTruncate ? Infinity : DEFAULT_CMD_LEN

    // One snapshot of every process, ordered by footprint. Reused for every section.
    const snap = sh("top -l 1 -o mem -stats pid,mem,command")

    const parsed = parseSnapshot(snap)

    // pid -> footprint(MB) lookup, populated from the single snapshot above.
    const MEM = new Map<string, number>(parsed)

    // Heavy hitters only: the largest consumers at or above TOP_MIN_MB, capped at n.
    const heavy = parsed.filter(([, mb]) => mb >= TOP_MIN_MB).slice(0, n)
    header(`== top by footprint (≥ ${TOP_MIN_MB.toLocaleString("en-US")} MB) ==`)
    if (heavy.length === 0) {
        console.log(`  ${DIM}(none)${RESET}`)
    }
    // Dir goes ahead of the command here (unlike the nvim section's trailing tag):
    // top commands run long, so a leading dir stays visible while the command
    // trails off the right edge.
    for (const [pid, mb] of heavy) {
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

    console.log("")
    header("== nvim sessions (each with its child procs) ==")
    if (ISNVIM.size === 0) {
        console.log(`  ${DIM}(none running)${RESET}`)
    } else {
        // Build each nvim instance up front: the root nvim plus every descendant,
        // flattened to one level and sorted by footprint. Nested nvims fold into
        // their parent's list rather than starting a new instance. Collecting
        // first lets us order instances by subtotal.
        type Proc = { pid: string; mb: number; cmd: string }
        const instances: Array<{ dir: string; procs: Proc[]; subtotal: number }> = []
        for (const root of ISNVIM) {
            const parent = sh(`ps -o ppid= -p ${root}`).trim()
            if (ISNVIM.has(parent)) continue // nested nvim: folded into its parent below
            const rootCmd = shortCmd(root, cmdLen)
            if (rootCmd === "<gone>") continue
            const procs: Proc[] = [{ pid: root, mb: MEM.get(root) ?? 0, cmd: rootCmd }]
            for (const [pid, mb] of flattenDescendants(root, KIDS, MEM)) {
                const cmd = shortCmd(pid, cmdLen)
                if (cmd !== "<gone>") procs.push({ pid, mb, cmd })
            }
            procs.sort((a, b) => b.mb - a.mb)
            const subtotal = procs.reduce((sum, proc) => sum + proc.mb, 0)
            instances.push({ dir: cwdOf(root) || "?", procs, subtotal })
        }
        instances.sort((a, b) => b.subtotal - a.subtotal)

        let hiddenInstances = 0
        for (const inst of instances) {
            if (compact && inst.subtotal < NVIM_MIN_MB) { hiddenInstances += 1; continue }

            // The directory subheader carries the instance's total and proc count,
            // so no divider/subtotal footer is needed. Any hiding below is
            // display-only — the total and count still include every proc.
            const total = inst.subtotal.toLocaleString("en-US")
            const count = inst.procs.length
            console.log(`${BOLD}${inst.dir}${RESET}  ${DIM}(${total} MB · ${count} proc${count === 1 ? "" : "s"})${RESET}`)

            let hiddenProcs = 0
            for (const proc of inst.procs) {
                if (compact && proc.mb < PROC_MIN_MB) { hiddenProcs += 1; continue }
                console.log(`${sizeCell(proc.mb)}  ${proc.pid.padStart(6)}  ${proc.cmd}`)
            }
            if (hiddenProcs > 0) {
                console.log(`  ${DIM}… ${hiddenProcs} process${hiddenProcs === 1 ? "" : "es"} below ${PROC_MIN_MB} MB${RESET}`)
            }
            console.log("")
        }

        if (hiddenInstances > 0) {
            console.log(`  ${DIM}… ${hiddenInstances} more nvim instance${hiddenInstances === 1 ? "" : "s"} under ${NVIM_MIN_MB} MB${RESET}`)
        }
    }

    // Copilot/LSP servers daemonize and reparent to launchd (ppid 1), so they never
    // show up under an nvim above even though they belong to one. Collect them so
    // their footprint is not invisible; the whole section is omitted when none exist.
    const orphans: string[] = []
    for (const pid of sh("pgrep node").split("\n").map((s) => s.trim()).filter(Boolean)) {
        if (sh(`ps -o ppid= -p ${pid}`).trim() !== "1") continue
        if (/copilot|language-server|langserver|lsp/.test(sh(`ps -o command= -p ${pid}`))) orphans.push(pid)
    }
    if (orphans.length > 0) {
        console.log("")
        header("== orphaned LSP/copilot (reparented, not under any nvim) ==")
        for (const pid of orphans) {
            console.log(`${sizeCell(MEM.get(pid) ?? 0)}  ${pid.padStart(6)}  ${shortCmd(pid, cmdLen)}`)
        }
    }
}

if (import.meta.main) main()
