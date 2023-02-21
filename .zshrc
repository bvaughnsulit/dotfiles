# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# export NODE_PATH=$NODE_PATH:`npm root --location=global`

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

alias ls='ls -a'
# alias vim='nvim'
alias home='cd ~'
alias gho='gh browse'

# tmux
alias vi='sh ~/dotfiles/scripts/tmux-session.sh'
alias tmvi='sh ~/dotfiles/scripts/tmux-session.sh'
alias tmls='tmux new -A -s tmux \; choose-session'
alias tm='tmux new -A -s tmux' 

alias lazygit='lazygit --use-config-file="$HOME/dotfiles/lazygit.yml"'

# add computer-specific configs in a separate, non-committed file
[[ ! -f ~/.zshrc_addtl ]] || source ~/.zshrc_addtl
