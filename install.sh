#!/bin/bash

export GITHUB_USER=toddtee

#Install xcode
/usr/bin/xcode-select --install

echo "After Xcode Command Line Developer Tools has installed press enter."
read

# Update MacOS
softwareupdate -i -a

# Install chezmoi
which chezmoi || sh -c "$(curl -fsLS https://chezmoi.io/get)"

# Setup chezmoi
$HOME/bin/chezmoi init $GITHUB_USER --ssh

# Install brew if not present
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Change into chezmoi directory
chezmoi cd

#Start brewing...
brew update
brew upgrade
brew tap homebrew/bundle
brew bundle --verbose
