#!/usr/bin/env bash
set -euo pipefail

LINKS_ONLY=false
export DOTFILES_WITH_COPILOT=0
for argument in "$@"; do
    case "$argument" in
        --links-only) LINKS_ONLY=true ;;
        --with-copilot) DOTFILES_WITH_COPILOT=1 ;;
        -h|--help)
            echo "Usage: ./bootstrap.sh [--links-only] [--with-copilot]"
            echo "  --links-only  Restore configs without installing packages or plugins."
            echo "  --with-copilot  Include Copilot configs (skipped by default)."
            exit 0
            ;;
        *)
            echo "Unknown option: $argument" >&2
            exit 2
            ;;
    esac
done

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"
OS="$(uname -s)"

if [ "$LINKS_ONLY" = false ]; then
    case "$OS" in
        Darwin)
            for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
                if [ -x "$brew_bin" ]; then
                    export PATH="$(dirname "$brew_bin"):$PATH"
                    break
                fi
            done
            if ! command -v brew >/dev/null 2>&1; then
                echo "Install Homebrew from https://brew.sh first, or use --links-only." >&2
                exit 1
            fi
            brew install git python
            ;;
        Linux)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y git curl wget zsh tmux neovim python3
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y git curl wget zsh tmux neovim python3
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y git curl wget zsh tmux neovim python3
            else
                echo "Install git, curl, zsh, tmux, Neovim and Python 3, then use --links-only." >&2
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS. This setup supports macOS and Linux." >&2
            exit 1
            ;;
    esac
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3.7 or newer is required to run Dotbot." >&2
    exit 1
fi

if [ ! -f dotbot/bin/dotbot ] || [ ! -f dotbot/lib/pyyaml/lib/yaml/__init__.py ]; then
    git submodule update --init --recursive
fi

BACKUP_DIR=""
for relative_path in \
    .zshrc .zprofile .profile .p10k.zsh .gitconfig .tmux.conf .ideavimrc \
    .config/nvim .config/git/ignore .config/ghostty/config \
    "Library/Application Support/com.mitchellh.ghostty/config" \
    .config/herdr/config.toml .config/herdr/sounds/silent.mp3 \
    .config/karabiner/karabiner.json \
    .claude/CLAUDE.md .claude/claude-logo.png .claude/hooks/notify-on-stop.py \
    .claude/skills/code-review .claude/skills/worktree-manager \
    .copilot/copilot-instructions.md .copilot/skills/humanizer \
    .local/bin/url-listener .local/bin/url-forwarder-register \
    .local/bin/open-on-host .local/bin/xdg-open; do
    case "$relative_path" in
        .copilot/*)
            [ "$DOTFILES_WITH_COPILOT" = 1 ] || continue
            ;;
        .config/karabiner/*|Library/*)
            [ "$OS" = Darwin ] || continue
            ;;
    esac
    target="$HOME/$relative_path"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        if [ -z "$BACKUP_DIR" ]; then
            mkdir -p "$HOME/.dotfiles_backup"
            BACKUP_DIR="$(mktemp -d "$HOME/.dotfiles_backup/backup.XXXXXXXX")"
        fi
        mkdir -p "$BACKUP_DIR/$(dirname "$relative_path")"
        mv "$target" "$BACKUP_DIR/$relative_path"
    fi
done
if [ -n "$BACKUP_DIR" ]; then
    echo "Existing configs backed up to: $BACKUP_DIR"
fi

directives=(create link)
if [ "$LINKS_ONLY" = false ]; then
    directives+=(shell)
fi
"$DOTFILES_DIR/dotbot/bin/dotbot" -d "$DOTFILES_DIR" -c "$DOTFILES_DIR/install.conf.yaml" \
    --only "${directives[@]}"

if [ "$DOTFILES_WITH_COPILOT" = 1 ] && [ ! -e "$HOME/.copilot/settings.json" ]; then
    mkdir -p "$HOME/.copilot"
    cp "$DOTFILES_DIR/copilot/settings.json" "$HOME/.copilot/settings.json"
fi

echo "Dotfiles setup complete. Restart your shell; open Neovim to install its plugins."
echo "Herdr settings take effect after a config reload or restart."
