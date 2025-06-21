#!/bin/bash
set -e

echo "Updating package list and installing build-essential..."
sudo apt-get update && sudo apt-get install -y build-essential

echo "Installing git and curl..."
sudo apt-get install -y git curl

echo "Creating Homebrew directory in /home/linuxbrew/.linuxbrew..."
sudo mkdir -p /home/linuxbrew/.linuxbrew
# Ensure the current user owns this directory so that brew can write to it
sudo chown -R $USER: /home/linuxbrew/.linuxbrew

echo "Cloning the Homebrew repository..."
git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew

echo "Creating bin directory for Homebrew..."
sudo mkdir -p /home/linuxbrew/.linuxbrew/bin
sudo chown -R $USER: /home/linuxbrew/.linuxbrew/bin

echo "Linking the brew executable..."
ln -s /home/linuxbrew/.linuxbrew/Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew

# Export environment variables so that brew uses the expected prefix
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export PATH="$HOMEBREW_PREFIX/bin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man:$MANPATH"
export INFOPATH="$HOMEBREW_PREFIX/share/info:$INFOPATH"

echo "Updating Homebrew..."
brew update

echo "Checking Homebrew version..."
brew --version

echo "Tapping homebrew/core..."
brew tap homebrew/core

echo "Homebrew installation and initial setup complete."
