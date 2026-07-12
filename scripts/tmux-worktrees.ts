import { execSync } from "node:child_process"

interface Worktree {
    path: string;
    branch: string;
    session_name?: string;
    window_index?: number;
    pane_index?: number;
    command?: string;
}

(function _() {
    const panes = execSync(
        "tmux list-panes -a -F '#{session_name} #{window_index} #{pane_index} #{pane_current_path} #{pane_current_command}'",
        { encoding: "utf-8" }
    )
    const worktrees = execSync(
        "git worktree list",
        { encoding: "utf-8" }
    )

    const worktreeMap: Map<string, Worktree> = new Map()

    worktrees.split("\n").forEach((line: string) => {
        if (line.trim() === "") return
            const [path, _hash , branch] = line.split(/\s+/) // TODO: need to handle the case where the path or branch contains spaces (detached HEAD)
        worktreeMap.set(path, {
            path,
            branch: branch.slice(1, -1)
        })
    })

    panes.split("\n").forEach((line: string) => {
        if (line.trim() === "") return
        const [session_name, window_index, pane_index, pane_current_path, pane_current_command] = line.split(" ")
        const worktree = worktreeMap.get(pane_current_path)
        if (!worktree) { return }
        if (!worktree.command && worktree.command === 'nvim') { return }
        if (worktree.window_index !== undefined && worktree.window_index < Number(window_index)) { return }
        if (worktree.pane_index !== undefined && worktree.pane_index < Number(pane_index)) { return }

        worktree.session_name = session_name
        worktree.window_index = Number(window_index)
        worktree.pane_index = Number(pane_index)
        worktree.command = pane_current_command
    })

    Array.from(worktreeMap.values()).sort((a, b) => {
        if (a.session_name !== b.session_name) {
            return (a.session_name ?? "").localeCompare(b.session_name ?? "")
        }
        if (a.window_index !== b.window_index) {
            return (a.window_index ?? 0) - (b.window_index ?? 0)
        }
        return a.path.localeCompare(b.path)
    }).forEach((worktree: Worktree) => {
            process.stdout.write(`${worktree.branch} ${worktree.path} ${worktree.session_name} ${worktree.window_index} ${worktree.pane_index} ${worktree.command}\n`)
        })
})()
