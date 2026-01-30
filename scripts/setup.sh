#!/bin/bash

export DOTFILES_DIR="$HOME/dotfiles"

if [ "$(pwd)" != "$DOTFILES_DIR" ]; then
  echo "Either the dotfiles directory is not in the expected location ($DOTFILES_DIR) or you are not running the script from within the dotfiles directory."
  exit 1
fi

echo "Making scripts executable..."
chmod +x ${DOTFILES_DIR}/scripts/tmux-session.sh
chmod +x ${DOTFILES_DIR}/.claude/notification-hook.sh
chmod +x ${DOTFILES_DIR}/.claude/statusline.sh
echo "Done."

echo "Creating file symbolic links..."
ln -si ${DOTFILES_DIR}/.claude/settings.json ~/.claude/settings.json
ln -si ${DOTFILES_DIR}/opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc
ln -si ${DOTFILES_DIR}/.gitconfig ~/.gitconfig
ln -si ${DOTFILES_DIR}/.gitignore_global ~/.gitignore_global
ln -si ${DOTFILES_DIR}/.p10k.zsh ~/.p10k.zsh
ln -si ${DOTFILES_DIR}/.zshrc ~/.zshrc
ln -si ${DOTFILES_DIR}/lazygit/lazygit.yml ~/Library/Application\ Support/lazygit/config.yml
echo "Done."

echo "Creating directory symbolic links..."
ln -siF ${DOTFILES_DIR}/ghostty ~/.config/ghostty
ln -siF ${DOTFILES_DIR}/kitty ~/.config/kitty
ln -siF ${DOTFILES_DIR}/nvim ~/.config/nvim
ln -siF ${DOTFILES_DIR}/tmux ~/.config/tmux
ln -siF ${DOTFILES_DIR}/opencode/plugins ~/.config/opencode/plugins
ln -siF ${DOTFILES_DIR}/.claude/skills ~/.claude/skills
echo "Done."

echo "Setup complete."
