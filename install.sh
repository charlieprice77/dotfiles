#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing packages..."
sudo apt-get update -qq
sudo apt-get install -y zsh tmux neovim curl

# Install kitty
if ! command -v kitty &>/dev/null; then
    echo "==> Installing kitty..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    # Add kitty to PATH if installed to ~/.local/kitty.app
    KITTY_BIN="$HOME/.local/kitty.app/bin"
    if [[ -d "$KITTY_BIN" && ":$PATH:" != *":$KITTY_BIN:"* ]]; then
        export PATH="$KITTY_BIN:$PATH"
        # Persist in .zshrc if not already there
        grep -qF 'kitty.app/bin' "$HOME/.zshrc" 2>/dev/null || \
            echo 'export PATH="$HOME/.local/kitty.app/bin:$PATH"' >> "$HOME/.zshrc"
    fi
else
    echo "==> kitty already installed, skipping."
fi

echo "==> Copying dotfiles..."

# nvim
mkdir -p "$HOME/.config/nvim"
cp -r "$DOTFILES_DIR/nvim/." "$HOME/.config/nvim/"

# kitty
mkdir -p "$HOME/.config/kitty"
cp "$DOTFILES_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# zshrc
cp "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"

echo "==> Configuring kitty to use zsh..."
if ! grep -q '^shell ' "$HOME/.config/kitty/kitty.conf"; then
    echo "shell $(command -v zsh)" >> "$HOME/.config/kitty/kitty.conf"
fi

echo "==> Configuring tmux to use zsh..."
TMUX_CONF="$HOME/.tmux.conf"
if ! grep -q 'default-shell' "$TMUX_CONF" 2>/dev/null; then
    echo "set-option -g default-shell $(command -v zsh)" >> "$TMUX_CONF"
fi

echo "==> Setting default login shell to zsh..."
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    grep -qF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
fi

echo ""
echo "Done! Log out and back in (or run 'zsh') for shell changes to take effect."
