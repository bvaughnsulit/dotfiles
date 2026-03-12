const fs = require("node:fs")

;(function on_pre_tool_use() {
    const input = process.stdin.on("data", data => {
        const input = JSON.parse(data.toString())
        const command = input.tool_input.command

        // const file = fs.openSync("/Users/vaughn/dotfiles/log.txt", "a")
        // fs.writeSync(file, `Received command: ${command}\n`)
        // fs.closeSync(file)

        const result = {
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                permissionDecision: "deny",
                permissionDecisionReason: "",
                updatedInput: {
                    command: "",
                },
                additionalContext: "",
            },
        }
        if (false) {
            process.stdout.write(JSON.stringify(result) + "\n")
        }
    })
})()
