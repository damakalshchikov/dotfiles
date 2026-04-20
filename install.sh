#!/bin/bash

DOTFILES="$HOME/dotfiles"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; }

# Detect OS
OS="$(uname)"

create_symlink() {
    local src="$1"
    local dst="$2"

    # If a real file already exists (not a symlink), back it up
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
        warning "Existing file found: $dst -> backing up to $dst.backup"
        mv "$dst" "$dst.backup"
    fi

    ln -sf "$src" "$dst"
    info "Symlink created: $dst -> $src"
}

echo ""
echo "Installing dotfiles on $OS..."
echo ""

# Shared (macOS and Linux)
create_symlink "$DOTFILES/.zshrc"    "$HOME/.zshrc"
create_symlink "$DOTFILES/.zprofile" "$HOME/.zprofile"
create_symlink "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# macOS-specific
if [[ "$OS" == "Darwin" ]]; then
    info "macOS: applying system-specific symlinks..."
    # create_symlink "$DOTFILES/macos/.somefile" "$HOME/.somefile"
fi

# Linux-specific
if [[ "$OS" == "Linux" ]]; then
    info "Linux: applying system-specific symlinks..."
    # create_symlink "$DOTFILES/linux/.somefile" "$HOME/.somefile"
fi

echo ""
info "Done. Restart the terminal or run: source ~/.zshrc"
echo ""
