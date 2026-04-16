#!/bin/bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> Installing packages..."
sudo apt-get update -qq
sudo apt-get install -y zsh tmux curl unzip build-essential git clangd

# Install Neovim (latest from GitHub releases, not apt)
echo "==> Installing Neovim..."
if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -1 | grep -oP '\d+\.\d+')" < "0.11" ]]; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    tar -xzf nvim-linux-x86_64.tar.gz
    sudo mv nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm nvim-linux-x86_64.tar.gz
else
    echo "==> Neovim 0.11+ already installed, skipping."
fi

# Install kitty (skipped on WSL2 - use Windows terminal instead)
if [[ -z "$WSL_DISTRO_NAME" ]]; then
    if ! command -v kitty &>/dev/null; then
        echo "==> Installing kitty..."
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        KITTY_BIN="$HOME/.local/kitty.app/bin"
        if [[ -d "$KITTY_BIN" && ":$PATH:" != *":$KITTY_BIN:"* ]]; then
            export PATH="$KITTY_BIN:$PATH"
            grep -qF 'kitty.app/bin' "$HOME/.zshrc" 2>/dev/null || \
                echo 'export PATH="$HOME/.local/kitty.app/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    else
        echo "==> kitty already installed, skipping."
    fi
else
    echo "==> WSL2 detected, skipping kitty install (use Windows terminal emulator)."
fi

echo "==> Copying dotfiles..."
# nvim
mkdir -p "$HOME/.config/nvim"
cp -r "$DOTFILES_DIR/nvim/." "$HOME/.config/nvim/"

# kitty (copy config even on WSL2, in case it's ever used)
mkdir -p "$HOME/.config/kitty"
cp "$DOTFILES_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# zshrc
cp "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"

# Install lazygit
echo "==> Installing lazygit..."
if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm lazygit.tar.gz lazygit
else
    echo "==> lazygit already installed, skipping."
fi

# Install Claude Code
echo "==> Installing Claude Code..."
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    # Ensure ~/.local/bin is in PATH
    grep -qF 'HOME/.local/bin' "$HOME/.zshrc" 2>/dev/null || \
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "==> Claude Code already installed, skipping."
fi

echo "==> Configuring kitty to use zsh..."
if ! grep -q '^shell ' "$HOME/.config/kitty/kitty.conf"; then
    echo "shell $(command -v zsh)" >> "$HOME/.config/kitty/kitty.conf"
fi

echo "==> Configuring tmux..."
cp "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
if ! grep -q 'default-shell' "$HOME/.tmux.conf" 2>/dev/null; then
    echo "set-option -g default-shell $(command -v zsh)" >> "$HOME/.tmux.conf"
fi

echo "==> Setting default login shell to zsh..."
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    grep -qF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
fi

echo ""
echo "Done! Log out and back in (or run 'zsh') for shell changes to take effect."
