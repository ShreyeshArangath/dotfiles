# Development Environment Configuration

- Use Herdr and its Herdr skill for any terminal, pane, tab, session, or workspace manipulation. Offload all terminal-related operations to Herdr instead of using tmux directly.

## Tmux Configuration

Tmux is configured with vim-style navigation and the Dracula theme.

### Key Bindings

**Pane Navigation:**
- `prefix + h/j/k/l` - Navigate panes (vim-style with prefix)
- `Alt + h/j/k/l` - Navigate panes without prefix
- `Alt + H/J/K/L` - Resize panes (5 cells at a time)

**Window Management:**
- `Alt + 1-5` - Jump to window 1-5
- `Alt + n/p` - Next/previous window
- `Alt + Tab` - Last window
- `Alt + w` - Choose window menu
- `prefix + c` - Create new window (prompts for name)
- `prefix + |` - Split horizontally
- `prefix + -` - Split vertically

**Session Management:**
- `Alt + [/]` - Switch between sessions
- `prefix + S` - Session tree switcher
- `prefix + N` - Create new session (prompts for name)
- `prefix + R` - Rename current session

**Copy Mode (vi-style):**
- `prefix + [` - Enter copy mode
- `v` - Begin selection
- `y` - Yank and exit copy mode
- `Y` - Yank without exiting
- `Ctrl-u/d` - Half-page scroll up/down

**Other:**
- `prefix + r` - Reload tmux configuration
- Mouse support enabled

### Plugin Setup

Install TPM (Tmux Plugin Manager) and plugins:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Press `prefix + I` to install plugins:
- tpm - Plugin manager
- tmux-yank - Better clipboard integration
- dracula/tmux - Dracula color theme

## Code Quality Standards
- Write tests for new functionality
- Follow project-specific style guides
- Keep commits atomic and well-described
- Ensure all tests pass before merging
- Keep code comments short; comment only what isn't obvious from the code

## Writing
- Run the humanizer skill on any prose you write (docs, PR descriptions, commit bodies, comments)

## Superpowers documentation
- Never commit Superpowers documentation, including files under `docs/superpowers/`, unless the user explicitly requests that commit.
