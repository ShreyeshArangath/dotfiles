# Dotfiles

Personal development environment configuration managed with [Dotbot](https://github.com/anishathalye/dotbot). This repository provides a complete, reproducible development environment setup that works across personal and work machines (macOS and Linux).

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

That's it! The script will:
- **macOS**: Install Homebrew (if not present) and packages from Brewfile
- **Linux**: Install essential packages via yum/dnf (RHEL/CentOS/Fedora/Amazon Linux) or apt (Ubuntu/Debian)
- Backup existing config files (if any) to `~/.dotfiles_backup/` (overwrites previous backup)
- Install Oh My Zsh with plugins
- Create all configuration symlinks
- Set up Tmux Plugin Manager and install plugins (tmux-yank, Nord theme)
- Reload tmux configuration if tmux is running

### Supported Platforms

- **macOS**: Intel (x86_64) and Apple Silicon (arm64/M1/M2/M3)
- **Linux**: RHEL-based (yum/dnf) and Debian-based (apt)

## Post-Installation Steps

After running the bootstrap script:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Install Neovim plugins**:
   ```bash
   nvim
   # In Neovim, plugins will auto-install on first launch
   # Or manually run: :Lazy sync
   ```

3. **Tmux is ready to use**:
   - Plugins are automatically installed (tmux-yank, Nord theme)
   - Just run `tmux` to start
   - See Tmux section below for key bindings

## Work Machine Setup

For LinkedIn work machines, enable work-specific configurations:

```bash
# Create work-specific zsh configuration
cat > ~/.zshrc.local << 'EOF'
# LinkedIn paths
export PATH="/usr/local/linkedin/bin:/export/content/linkedin/bin:/export/content/granular/bin:$PATH"

# Java for LinkedIn
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_172.jdk/Contents/Home/"
export PATH="$JAVA_HOME/bin:$PATH"

# Kubernetes environment
export K8S_LDAP_GROUP=cop-dev
export NAMESPACE=cop-dev

# Work SSH helper
if [[ $- == *i* ]]; then
  work_ssh() {
    ssh-add -D
    local ssh_add_arg=""
    [[ "$(uname)" = "Darwin" ]] && ssh_add_arg="--apple-use-keychain"
    ssh-add $ssh_add_arg ~/.ssh/sarangat_at_linkedin.com_ssh_key
    echo "Loaded LinkedIn SSH key"
  }
fi
EOF

# Enable LinkedIn git configuration
cp ~/dotfiles/git/.gitconfig.linkedin ~/.gitconfig.local

# Reload shell
source ~/.zshrc
```

This approach ensures:
- The repository stays personal by default
- Work configs are not committed to the repository
- Easy context switching between personal and work environments

## Directory Structure

```
dotfiles/
├── git/
│   ├── .gitconfig            # Personal git config
│   └── .gitconfig.linkedin   # Work git config (copy to ~/.gitconfig.local)
├── nvim/                     # Neovim configuration (kickstart.nvim based)
│   ├── init.lua
│   └── lua/
├── tmux/
│   └── .tmux.conf           # Tmux configuration
├── zsh/
│   ├── .zshrc               # Personal/shared zsh config
│   └── .zshrc.linkedin      # Work zsh config (copy to ~/.zshrc.local)
├── dotbot/                  # Dotbot submodule (symlink manager)
├── Brewfile                 # Homebrew packages
├── bootstrap.sh             # Main installation script
├── install.conf.yaml        # Dotbot configuration
└── README.md
```

## Configuration Details

### Zsh

**Personal Configuration (`.zshrc`):**
- XDG Base Directory setup
- Homebrew, Volta, Go, Rust paths
- Oh My Zsh with plugins:
  - `git` - Git aliases and functions
  - `zsh-autosuggestions` - Command suggestions
  - `zsh-syntax-highlighting` - Syntax highlighting
- Personal SSH key management (`personal_ssh()`)
- Aliases: `vi`/`vim` → `nvim`

**Work Configuration (`.zshrc.linkedin`):**
- LinkedIn paths
- Java 1.8 setup
- Kubernetes environment variables
- Work SSH functions (`work_ssh()`, `reload_ssh_keys()`)

### Git

**Personal Configuration (`.gitconfig`):**
- User: shreyesharangath@gmail.com
- Editor: nvim
- Git LFS support
- Includes `.gitconfig.local` for machine-specific overrides

**Work Configuration (`.gitconfig.linkedin`):**
- User: sarangath@linkedin.com
- Copy to `~/.gitconfig.local` on work machines

### Tmux

**Features:**
- Vim-style pane navigation (prefix + h/j/k/l)
- Alt navigation without prefix (Alt + h/j/k/l)
- Nord theme for beautiful aesthetics
- TPM integration with auto-installed plugins
- Mouse support enabled
- Vi mode for copy/paste

**Key Bindings:**

*Pane Navigation:*
- `prefix + h/j/k/l` - Navigate panes (vim-style)
- `Alt + h/j/k/l` - Navigate panes (no prefix needed)
- `Alt + H/J/K/L` - Resize panes

*Window Management:*
- `Alt + 1-5` - Jump to window 1-5
- `Alt + n/p` - Next/previous window
- `Alt + Tab` - Last window
- `prefix + c` - Create new window (prompts for name)
- `prefix + |` - Split horizontally
- `prefix + -` - Split vertically

*Session Management:*
- `Alt + [/]` - Switch between sessions
- `prefix + S` - Session tree chooser
- `prefix + N` - Create new session (prompts for name)
- `prefix + R` - Rename current session

*Copy Mode (vi-style):*
- `prefix + [` - Enter copy mode
- `v` - Begin selection
- `y` - Yank and exit
- `Y` - Yank without exiting
- `Ctrl-u/d` - Half-page scroll

*Other:*
- `prefix + r` - Reload tmux config

**Plugins:**
- [TPM](https://github.com/tmux-plugins/tpm) - Plugin manager
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank) - Better clipboard integration
- [Nord theme](https://github.com/nordtheme/tmux) - Beautiful color scheme

**Note for macOS users:** To use Alt navigation, configure your terminal:
- **iTerm2**: Preferences → Profiles → Keys → Set left/right option key to "Esc+"
- **Terminal.app**: Enable "Use Option as Meta key" in preferences

### Neovim

Based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) with:
- LSP support
- Tree-sitter syntax highlighting
- Telescope fuzzy finder
- Git integration (fugitive, gitsigns)
- Auto-completion
- Custom plugins and keybindings

## SSH Key Management

Helper functions for managing SSH keys:

**Personal Machines:**
```bash
personal_ssh  # Load personal SSH key only
```

**Work Machines:**
```bash
work_ssh        # Load LinkedIn SSH key only
reload_ssh_keys # Load both personal and LinkedIn keys
```

## Updating

To update your dotfiles:

```bash
cd ~/dotfiles
git pull
./bootstrap.sh  # Re-run to update symlinks and dependencies
```

**Update packages:**

macOS (Homebrew):
```bash
brew bundle --file=~/dotfiles/Brewfile
brew upgrade
```

Linux (RHEL/CentOS/Fedora):
```bash
sudo yum update
# or
sudo dnf upgrade
```

Linux (Ubuntu/Debian):
```bash
sudo apt update && sudo apt upgrade
```

**Update Neovim plugins:**
```bash
nvim +Lazy sync
```

**Update Oh My Zsh:**
```bash
omz update
```

## Adding New Configurations

### Add a New Package

Add to `Brewfile`:
```ruby
brew "package-name"
```

Then run:
```bash
brew bundle --file=~/dotfiles/Brewfile
```

### Add a New Dotfile

1. Create the file in the appropriate directory (e.g., `zsh/.my-config`)
2. Add to `install.conf.yaml`:
   ```yaml
   - link:
       ~/.my-config: zsh/.my-config
   ```
3. Re-run `./bootstrap.sh`

## Machine-Specific Configuration

For configuration that shouldn't be in the repository (secrets, machine-specific paths, etc.), use:

- `~/.zshrc.local` - Sourced automatically by `.zshrc`
- `~/.gitconfig.local` - Included automatically by `.gitconfig`

These files are gitignored and won't be tracked.

## Troubleshooting

### Symlinks not created

```bash
cd ~/dotfiles
./dotbot/bin/dotbot -d . -c install.conf.yaml -v
```

### Oh My Zsh plugins not working

```bash
# Reinstall plugins
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
./bootstrap.sh
```

### Neovim plugins not loading

```bash
# Clear plugin cache and reinstall
rm -rf ~/.local/share/nvim
nvim +Lazy sync
```

### Tmux plugins not loading

```bash
# Reinstall TPM and plugins
rm -rf ~/.tmux/plugins
./bootstrap.sh
# Plugins will be automatically installed
```

### Alt navigation not working in tmux

Configure your terminal emulator:
- **iTerm2**: Preferences → Profiles → Keys → Set left/right option key to "Esc+"
- **Terminal.app**: Preferences → Profiles → Keyboard → Enable "Use Option as Meta key"

### Homebrew not found (Apple Silicon)

Add to your current shell session:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then re-run the bootstrap script.

## Uninstall

To remove all configurations:

```bash
# Remove symlinks
rm ~/.zshrc ~/.gitconfig ~/.tmux.conf
rm -rf ~/.config/nvim

# Remove Oh My Zsh
rm -rf ~/.oh-my-zsh

# Remove TPM
rm -rf ~/.tmux/plugins

# Optional: Remove Homebrew packages
brew bundle cleanup --file=~/dotfiles/Brewfile --force
```

## License

This repository is for personal use. Feel free to fork and customize for your own needs.
