# dotfiles

Neovim + kitty + tmux config with zsh

## Installation

Clone this repo and run the install script:

```sh
git clone <repo-url> ~/dotfiles
bash ~/dotfiles/install.sh
```

The script will:
- Install **kitty**, **neovim**, **tmux**, and **zsh**
- Copy configs to their correct locations (`~/.config/nvim`, `~/.config/kitty`, `~/.zshrc`)
- Set zsh as the default shell for kitty and tmux
- Change your login shell to zsh via `chsh`

Log out and back in (or run `zsh`) for the shell change to take effect.

## Post-install (nvim)

Open nvim — Lazy will automatically install plugins, then run:

```
:MasonInstall clangd
```

```sh
npm install -g tree-sitter-cli
```

## Syncing changes back

Run `sync.sh` to copy configs from their live locations back into this repo and push:

```sh
bash ~/dotfiles/sync.sh
```

## Structure

```
dotfiles/
├── kitty.conf          # kitty terminal config
├── nvim/               # neovim config (lazy.nvim)
│   ├── init.lua
│   └── lazy-lock.json
├── shell/
│   └── .zshrc
├── install.sh          # install everything from scratch
└── sync.sh             # sync live configs back to repo
```
