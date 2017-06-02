# Lucas Garron's dotfiles.

My own personal configuration files for various commandline-based tools.

Linked [using GNU `stow`](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html), because simpler is better.

# Setup

## Mac

    # Install Xcode, then run this:
    sudo xcodebuild -license accept

    git clone https://github.com/Homebrew/brew/ ~/local/brew
    export PATH=${PATH}:${HOME}/local/brew/bin

    brew install stow fish
    brew cask install sublime-text iterm2

    # dotfiles
    git clone https://github.com/lgarron/dotfiles ~/Code/dotfiles
    cd ~/Code/dotfiles
    make [machine]
    make mac-setup
    make mac-chrome-versions # Rewrites all Chrome apps; not idempotent.
    # make mac-right-dock

    # fish
    fish -c "source ~/.config/fish/config.fish"
    echo "$HOME/local/brew/bin/fish" | sudo tee -a /etc/shells; cat /etc/shells
    chsh -s $HOME/local/brew/bin/fish

    # Go!
    open -a "iTerm"

    osx-setup-shortcuts

## Chromium Development

See [Chromium.md](./chromium.md)
