#!/usr/bin/zsh

dir=${PWD##*/}

if tmux has-session -t ${dir} 2>/dev/null; then
  tmux a -t ${dir}
else
  tmux new -s ${dir}\; send-keys "nvim ." ENTER
fi
