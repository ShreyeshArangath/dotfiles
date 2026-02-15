# ========================================
# XDG Base Directory Specification
# ========================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ========================================
# Core Path Configuration
# ========================================
# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# System paths
export PATH="/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# ========================================
# Zsh Configuration
# ========================================
# Enable colors and vcs info
autoload -U colors && colors
autoload -Uz vcs_info

# Git branch info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST

# Prompt: user@host ~/path (branch) %
PROMPT='%F{green}%n@%m%f %F{cyan}%~%f${vcs_info_msg_0_} %# '

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Basic completions
autoload -Uz compinit && compinit

# Load zsh plugins (if installed)
ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"

# zsh-autosuggestions
if [ -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# zsh-syntax-highlighting (must be sourced at the end)
if [ -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ========================================
# Development Tools
# ========================================
# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Go
export PATH="$PATH:/usr/local/go/bin"

# Android SDK (commented out per user preference)
# export PATH="$HOME/Library/Android/sdk/tools:$PATH"
# export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# ========================================
# SSH Key Management (Personal)
# ========================================
if [[ $- == *i* ]]; then
  personal_ssh() {
    ssh-add -D
    local ssh_add_arg=""
    [[ "$(uname)" = "Darwin" ]] && ssh_add_arg="--apple-use-keychain"
    ssh-add $ssh_add_arg ~/.ssh/id_rsa_shreyesharangath
    echo "Loaded personal SSH key"
  }
fi

# ========================================
# Aliases
# ========================================
alias vi="nvim"
alias vim="nvim"
alias notify="terminal-notifier -sound default -ignoreDnD"

# ========================================
# Profiling (uncomment for debugging slow shell startup)
# ========================================
# zmodload zsh/zprof

# ========================================
# Machine-Specific Overrides
# ========================================
# Source .zshrc.local for machine-specific configurations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Source .zshrc.linkedin for work-specific configurations (on LinkedIn machines)
[[ -f ~/.zshrc.linkedin ]] && source ~/.zshrc.linkedin

# ========================================
# Tool-Specific Additions (auto-generated)
# ========================================
# Added by Windsurf
export PATH="/Users/sarangat/.codeium/windsurf/bin:$PATH"
