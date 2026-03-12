;(function output_mock_hook_data() {
    const preToolUseInput = {
        session_id: "abc123",
        transcript_path: "/home/user/.claude/projects/.../transcript.jsonl",
        cwd: "/home/user/my-project",
        permission_mode: "default",
        hook_event_name: "PreToolUse",
        tool_name: "Bash",
        tool_input: {
            command: "npm test",
        },
    }
    const output = JSON.stringify(preToolUseInput)
    process.stdout.write(output + "\n")
})()
