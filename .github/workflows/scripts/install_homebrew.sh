#!/bin/bash
set -e

echo "Updating package list and installing build-essential..."
sudo apt-get update && sudo apt-get install -y build-essential

echo "Installing git and curl..."
sudo apt-get install -y git curl

echo "Creating Homebrew directory..."
mkdir -p "$HOME/.linuxbrew"

echo "Cloning the Homebrew repository..."
git clone https://github.com/Homebrew/brew "$HOME/.linuxbrew/Homebrew"

echo "Creating bin directory for Homebrew..."
mkdir -p "$HOME/.linuxbrew/bin"

echo "Linking the brew executable..."
ln -s "$HOME/.linuxbrew/Homebrew/bin/brew" "$HOME/.linuxbrew/bin/brew"

# Export environment variables so that brew is available in this script
export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

brew update && brew --version
brew tap homebrew/core

echo "Homebrew installation and initial setup complete."
