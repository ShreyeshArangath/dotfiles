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
    else
        PKG_MGR="yum"
    fi

    # Install EPEL repository for additional packages
    if [ "$DISTRO" = "rhel" ] || [ "$DISTRO" = "centos" ]; then
        sudo $PKG_MGR install -y epel-release || true
    fi

    # Install essential development tools
    sudo $PKG_MGR groupinstall -y "Development Tools" || true
    sudo $PKG_MGR install -y \
        git \
        curl \
        wget \
        zsh \
        tmux \
        neovim \
        gcc \
        make \
        python3 \
        python3-pip \
        openssl-devel \
        bzip2-devel \
        libffi-devel \
        || true

    echo -e "${GREEN}Essential packages installed${NC}"
elif [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
    # Debian-based systems (apt)
    echo -e "${YELLOW}Installing essential packages via apt...${NC}"
    sudo apt-get update
    sudo apt-get install -y \
        git \
        curl \
        wget \
        zsh \
        tmux \
        neovim \
        build-essential \
        python3 \
        python3-pip \
        libssl-dev \
        libbz2-dev \
        libffi-dev \
        || true

    echo -e "${GREEN}Essential packages installed${NC}"
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

# Run Dotbot
echo ""
echo -e "${YELLOW}Running Dotbot configuration...${NC}"
"${DOTFILES_DIR}/dotbot/bin/dotbot" -d "${DOTFILES_DIR}" -c "${DOTFILES_DIR}/install.conf.yaml"

echo ""
echo -e "${GREEN}=========================================="
echo "  Bootstrap Complete!"
echo "==========================================${NC}"
echo ""
echo "Your development environment is now set up."
echo "Please check the post-installation instructions above."
echo ""
