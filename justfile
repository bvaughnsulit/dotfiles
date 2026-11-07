set positional-arguments

dotfiles_directory := env_var_or_default("DOTFILES_DIR", env_var("HOME") / "dotfiles")

# Launch the sandbox for the current worktree.
[no-cd]
sandbox *args:
    uv run --no-project "{{dotfiles_directory}}/scripts/run-sandbox.py" "$@"
