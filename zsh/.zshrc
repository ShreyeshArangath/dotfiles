# ========================================
# Powerlevel10k Instant Prompt
# ========================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# LinkedIn paths (work machines)
export PATH="/usr/local/linkedin/bin:/export/content/linkedin/bin:/export/content/granular/bin:$PATH"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# Tools
export PATH="$HOME/tools/kubectl-plugins:$PATH"

# ========================================
# Zsh Configuration
# ========================================
export ZSH="$HOME/.zsh"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt autocd

# Vim mode keybindings
bindkey -v
KEYTIMEOUT=1
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

# Completion
autoload -U compinit
compinit

# ========================================
# Prompt (Powerlevel10k)
# ========================================
[[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]] && source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ========================================
# Zsh Plugins
# ========================================
[[ -r ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
