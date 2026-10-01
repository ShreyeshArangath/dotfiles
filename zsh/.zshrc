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

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# Tools
export PATH="$HOME/tools/kubectl-plugins:$PATH"

# ========================================
# url-forwarder (SSH sessions only)
# ========================================
# Route browser opens back to the host Mac via the reverse SSH tunnel.
# Only set inside SSH sessions so local Mac shells are untouched.
if [ -n "${SSH_CONNECTION-}" ] && [ -x "$HOME/.local/bin/open-on-host" ]; then
  export BROWSER="$HOME/.local/bin/open-on-host"
fi

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
# Zsh Autosuggestions
# ========================================
[[ -r ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ========================================
# Development Tools
# ========================================
# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Go
export PATH="$PATH:/usr/local/go/bin"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -d "$NVM_DIR" ]] || export NVM_DIR="$XDG_CONFIG_HOME/nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# Other locally installed tools
export PATH="$HOME/.opencode/bin:$HOME/.codeium/windsurf/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
[[ -d "/Applications/IntelliJ IDEA.app/Contents/MacOS" ]] && export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"

# Java version switching (macOS)
use_java() {
  if [[ $# -ne 1 ]] || [[ ! -x /usr/libexec/java_home ]]; then
    echo "Usage: use_java <version> (requires macOS java_home)" >&2
    return 1
  fi
  local java_home
  java_home="$(/usr/libexec/java_home -v "$1")" || return 1
  if [[ ! -x "$java_home/bin/java" ]]; then
    echo "Java executable not found in: $java_home" >&2
    return 1
  fi
  export JAVA_HOME="$java_home"
  export PATH="$JAVA_HOME/bin:$PATH"
  "$JAVA_HOME/bin/java" -version
}
use_java_21() { use_java 21; }
use_java_17() { use_java 17; }
use_java_11() { use_java 11; }
use_java_8() { use_java 1.8; }

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
alias claudinho="claude --dangerously-skip-permissions --model opus"
alias copium="copilot --autopilot"
alias kayfabe-dev="$HOME/personal/kayfabe/target/debug/kayfabe"
alias kayfabe-dev-build="cargo build --manifest-path $HOME/personal/kayfabe/Cargo.toml"

# ========================================
# Profiling (uncomment for debugging slow shell startup)
# ========================================
# zmodload zsh/zprof

# ========================================
# Machine-Specific Overrides
# ========================================
# Source .zshrc.local for machine-specific configurations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

typeset -U path

# Keep syntax highlighting after widgets, aliases, and local overrides.
if [[ -r ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
