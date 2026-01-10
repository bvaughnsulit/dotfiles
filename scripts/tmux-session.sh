#!/usr/bin/zsh

dir=${PWD##*/}

if [[ -z $TMUX ]]; then
  if tmux has-session -t ${dir} 2>/dev/null; then
    printf "attaching to existing session\n"
    tmux a -t ${dir}
  else
    printf "creating new session\n"
    tmux new -s ${dir}\; send-keys "nvim" ENTER
  fi

else
  if tmux has-session -t ${dir} 2>/dev/null; then
    printf "switching to existing session\n"
    tmux switch -t ${dir}\;
  else
    printf "creating new session\n"
    tmux new -A -s ${dir} -d
    printf "attaching to new session\n"
    tmux switch -t ${dir}\; send-keys "nvim" ENTER
  fi
fi
