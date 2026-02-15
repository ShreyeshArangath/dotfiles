#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  Dotfiles Bootstrap Script"
echo "=========================================="
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        fi
        ;;
    Darwin*)
        DISTRO="macos"
        ;;
    *)
        echo -e "${RED}Unsupported OS: ${OS}${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Detected OS: ${DISTRO}${NC}"
echo ""

# Install package manager and essential packages
if [ "$DISTRO" = "macos" ]; then
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo -e "${GREEN}Adding Homebrew to PATH for Apple Silicon...${NC}"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}Homebrew is already installed.${NC}"
    fi
elif [ "$DISTRO" = "rhel" ] || [ "$DISTRO" = "centos" ] || [ "$DISTRO" = "fedora" ] || [ "$DISTRO" = "amzn" ]; then
    # RHEL-based systems (yum/dnf)
    echo -e "${YELLOW}Installing essential packages via yum/dnf...${NC}"

    # Determine if we should use dnf or yum
    if command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
        echo "Using dnf package manager"
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
        echo "Using yum package manager"
    else
        echo -e "${RED}Error: Neither dnf nor yum found on this system${NC}"
        echo -e "${YELLOW}Please install packages manually: git curl wget zsh tmux${NC}"
        PKG_MGR=""
    fi

    if [ -n "$PKG_MGR" ]; then
        # Install EPEL repository for additional packages
        if [ "$DISTRO" = "rhel" ] || [ "$DISTRO" = "centos" ]; then
            echo "Installing EPEL repository..."
            sudo $PKG_MGR install -y epel-release || echo "EPEL installation failed or already installed"
        fi

        # Install essential development tools
        echo "Installing Development Tools..."
        sudo $PKG_MGR groupinstall -y "Development Tools" || echo "Development Tools installation failed or already installed"

        echo "Installing essential packages..."
        sudo $PKG_MGR install -y \
            git \
            curl \
            wget \
            zsh \
            tmux \
            gcc \
            make \
            python3 \
            python3-pip \
            openssl-devel \
            bzip2-devel \
            libffi-devel

        if [ $? -ne 0 ]; then
            echo -e "${RED}Package installation failed. You may need to install packages manually.${NC}"
        fi
    fi

    if [ -n "$PKG_MGR" ]; then
        # Try to install neovim from package manager
        echo "Installing neovim..."
        if sudo $PKG_MGR install -y neovim 2>/dev/null; then
            echo -e "${GREEN}Neovim installed from package manager${NC}"
        else
            echo -e "${YELLOW}Neovim not available in repos, installing from AppImage...${NC}"
            # Install neovim via AppImage as fallback
            if [ ! -f "$HOME/.local/bin/nvim" ]; then
                mkdir -p "$HOME/.local/bin"
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                chmod u+x nvim.appimage
                mv nvim.appimage "$HOME/.local/bin/nvim"
                echo -e "${GREEN}Neovim installed via AppImage to ~/.local/bin/nvim${NC}"
            else
                echo -e "${GREEN}Neovim already installed at ~/.local/bin/nvim${NC}"
            fi
        fi

        echo -e "${GREEN}Package installation complete${NC}"
    fi
elif [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
    # Debian-based systems (apt)
    echo -e "${YELLOW}Installing essential packages via apt...${NC}"

    echo "Updating package lists..."
    sudo apt-get update

    echo "Installing essential packages..."
    sudo apt-get install -y \
        git \
        curl \
        wget \
        zsh \
        tmux \
        build-essential \
        python3 \
        python3-pip \
        libssl-dev \
        libbz2-dev \
        libffi-dev

    if [ $? -ne 0 ]; then
        echo -e "${RED}Package installation failed. You may need to install packages manually.${NC}"
    fi

    # Try to install neovim from package manager
    echo "Installing neovim..."
    if sudo apt-get install -y neovim 2>/dev/null; then
        echo -e "${GREEN}Neovim installed from package manager${NC}"
    else
        echo -e "${YELLOW}Neovim not available in repos, installing from AppImage...${NC}"
        # Install neovim via AppImage as fallback
        if [ ! -f "$HOME/.local/bin/nvim" ]; then
            mkdir -p "$HOME/.local/bin"
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            mv nvim.appimage "$HOME/.local/bin/nvim"
            echo -e "${GREEN}Neovim installed via AppImage to ~/.local/bin/nvim${NC}"
        else
            echo -e "${GREEN}Neovim already installed at ~/.local/bin/nvim${NC}"
        fi
    fi

    echo -e "${GREEN}Package installation complete${NC}"
else
    echo -e "${YELLOW}Unknown Linux distribution. Skipping package installation.${NC}"
    echo -e "${YELLOW}Please ensure git, curl, zsh, tmux, and neovim are installed manually.${NC}"
fi

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Initialize and update git submodules
echo ""
echo -e "${YELLOW}Initializing Dotbot submodule...${NC}"
git submodule update --init --recursive

# Backup and remove existing config files that should be symlinked
echo ""
echo -e "${YELLOW}Preparing config files for symlinking...${NC}"
BACKUP_DIR="$HOME/.dotfiles_backup"

# Remove old backup if it exists
if [ -d "$BACKUP_DIR" ]; then
    echo "Removing old backup directory..."
    rm -rf "$BACKUP_DIR"
fi

BACKED_UP=false

for config_file in "$HOME/.zshrc" "$HOME/.gitconfig" "$HOME/.tmux.conf"; do
    if [ -f "$config_file" ] && [ ! -L "$config_file" ]; then
        echo "Backing up existing $(basename $config_file) to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        mv "$config_file" "$BACKUP_DIR/"
        BACKED_UP=true
    fi
done

if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    echo "Backing up existing nvim config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$HOME/.config/nvim" "$BACKUP_DIR/"
    BACKED_UP=true
fi

if [ "$BACKED_UP" = true ]; then
    echo -e "${GREEN}Existing configs backed up to: $BACKUP_DIR${NC}"
fi

# Run Dotbot
echo ""
echo -e "${YELLOW}Running Dotbot configuration...${NC}"
"${DOTFILES_DIR}/dotbot/bin/dotbot" -d "${DOTFILES_DIR}" -c "${DOTFILES_DIR}/install.conf.yaml"

echo ""
echo -e "${GREEN}=========================================="
echo "  Bootstrap Complete!"
echo "==========================================${NC}"
echo ""

# Reload tmux config if tmux is running
if command -v tmux &> /dev/null && tmux list-sessions &> /dev/null; then
    echo -e "${YELLOW}Reloading tmux configuration...${NC}"
    tmux source-file ~/.tmux.conf && echo -e "${GREEN}Tmux config reloaded!${NC}" || echo -e "${YELLOW}Could not reload tmux. Please restart tmux to see changes.${NC}"
fi

echo ""
echo "Your development environment is now set up."
echo "Please check the post-installation instructions above."
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}Note: Your old configs were backed up to: $BACKUP_DIR${NC}"
    echo ""
fi
