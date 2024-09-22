#!/usr/bin/env bash
# Install script for the dotfiles
DOTFILES_REPO="git@github.com:masterkeysrd/dotfiles.git"

# Install the dotfiles in a mac environment
install_mac() {
  if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone $DOTFILES_REPO $HOME/.dotfiles
  else
    echo "Updating dotfiles..."
    git -C $HOME/.dotfiles pull
  fi

  echo "Installing dotfiles..."
  $HOME/.dotfiles/install_mac.sh
}

install() {
  if [ "$(uname)" == "Darwin" ]; then
    install_mac
  else
    echo "Unsupported OS"
  fi
}

install
