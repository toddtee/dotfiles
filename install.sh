#!/bin/bash

export GITHUB_USER=toddtee
export BREWFILE=$HOME/.local/share/chezmoi/Brewfile

# Install chezmoi
which chezmoi || sh -c "$(curl -fsLS https://chezmoi.io/get)"

# Setup chezmoi
$HOME/bin/chezmoi init $GITHUB_USER

# Install brew if not present
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Start brewing
echo "Updating brew"
brew update
echo "Upgrading brew packages"
brew upgrade
echo "Tapping brew"
brew tap homebrew/bundle
echo "Installing packages from Brewfile."
brew bundle --file $BREWFILE --verbose

# Cleanup
[ -d "$HOME/bin" ] && rm -rf $HOME/bin || echo "No cleanup required."
