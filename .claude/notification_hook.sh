#!/bin/bash

input=$(cat)

MESSAGE=$(echo "$input" | jq -r '.message')
CWD=$(echo "$input" | jq -r '.cwd')

# Replace home directory with ~ for brevity
if [[ "$CWD" == "$HOME"* ]]; then
    CWD="~${CWD#$HOME}"
fi

# Send nvim notification if inside Neovim
if [ -n "$NVIM" ]; then
    nvim --server "$NVIM" --remote-send "<cmd>lua print '$MESSAGE'<cr>"
fi

osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\" subtitle \"$CWD\" sound name \"Blow\""
