#!/usr/bin/env bash
# Install script for the dotfiles on a mac environment

install_brew() {
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew already installed"
  fi
}

install_brew_packages() {
  echo "Installing brew packages..."
  brew bundle --file=$HOME/.dotfiles/mac/Brewfile --force
}

# Install the dotfiles in a mac environment
install_brew
install_brew_packages
