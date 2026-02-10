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
# Oh My Zsh Configuration
# ========================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ZSH_THEME_RANDOM_CANDIDATES=("robbyrussell" "agnoster")
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
zstyle ':omz:plugins:nvm' lazy yes
source $ZSH/oh-my-zsh.sh

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
