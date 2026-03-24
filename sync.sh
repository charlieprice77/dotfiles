#!/bin/bash
cp -r ~/.config/nvim ~/dotfiles/
cp ~/.config/kitty/kitty.conf ~/dotfiles/
cd ~/dotfiles
git add .
git commit -m "Syncing dotfiles"
git push
