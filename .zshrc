# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# export NODE_PATH=$NODE_PATH:`npm root --location=global`

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$PATH:$HOME/.local/share/bob/nvim-bin"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

alias ls='ls -a'
alias home='cd ~'
alias dot='cd ~/dotfiles'
alias gho='gh browse'

# tmux
alias vi='sh ~/dotfiles/scripts/tmux-session.sh'
alias tmvi='sh ~/dotfiles/scripts/tmux-session.sh'
alias tmls='tmux new -A -s tmux \; choose-session'
alias tm='tmux new -A -s tmux'

alias nvim-color='nvim --cmd "+lua vim.g.set_scheme='true'"'
alias nvim-dark='nvim --cmd "+lua vim.g.set_scheme=\"dark\""'
alias nvim-light='nvim --cmd "+lua vim.g.set_scheme=\"light\""'

alias lazyvim='NVIM_APPNAME=lazyvim nvim'
alias nvim-min='NVIM_APPNAME=minimal-nvim nvim'
alias plug='cd $(fd . ~/.local/share/nvim/lazy/ --type dir --max-depth 1 | fzf)' 
alias nvim-debug="INIT_DEBUG=true nvim"

alias lg='lazygit'
alias venv='source venv/bin/activate'
alias pr='gh pr checkout'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"


# add computer-specific configs in a separate, non-committed file
[[ ! -f ~/.zshrc_addtl ]] || source ~/.zshrc_addtl

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(~/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd . ~ --type dir --follow --max-depth 5 -E Library/'
export FZF_DEFAULT_OPTS='--layout reverse'
export FZF_COMPLETION_TRIGGER='//'
alias cdf='cd $(fzf)'
