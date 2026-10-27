# Development conventions

@~/.agents/AGENTS.md

- Use Herdr and its skill for terminal, pane, tab, session, or workspace operations.
- When checking bindings, read `~/.tmux.conf` or `~/.config/herdr/config.toml`.

## Code quality

- Write tests for new functionality.
- Follow project-specific style guides.
- Keep commits atomic and well-described.
- Ensure all tests pass before merging.
- Keep comments short; explain only what isn't obvious from the code.

## Writing

Run the humanizer skill only on:

- Explanations of complex ideas, such as a design walkthrough, a tradeoff analysis, or a non-obvious bug.
- PR descriptions.
- Code comments.

Everything else, such as short chat replies, progress updates, and status reports, does not need it.

Never commit Superpowers documentation, including `docs/superpowers/`, unless explicitly requested.

## Agent launch aliases

The zsh profiles in `~/personal/dotfiles` define these aliases:

```sh
alias elon='cursor agent --yolo'
alias elon-gotta-read='cursor'
alias claudinho='claude --dangerously-skip-permissions'
alias gippity='codex --dangerously-bypass-approvals-and-sandbox'
```

`elon-gotta-read` opens the Cursor IDE. The other aliases start terminal agents with permission prompts bypassed. The full zsh profile also selects `--model opus` for `claudinho`.
