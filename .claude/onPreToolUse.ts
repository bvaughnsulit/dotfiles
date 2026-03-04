(function onPreToolUse() {
    const input = process.stdin.on('data', (data) => {
        const input = JSON.parse(data.toString())
        const command = input.tool_input.command
        const result = {
            "hookSpecificOutput" : {
                'hookEventName': "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "",
                "updatedInput": {
                    "command": "",
                },
                "additionalContext": ""
            }
        }
        if (false){
            process.stdout.write(JSON.stringify(result) + "\n")
        }
    })
})()
