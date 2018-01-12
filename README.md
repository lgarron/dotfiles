# Lucas Garron's dotfiles.

My own personal configuration files for various commandline-based tools.

Linked [using GNU `stow`](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html), because simpler is better.

# Setup

## Mac

    # Install Xcode, then run this:
    sudo xcodebuild -license accept

    git clone https://github.com/Homebrew/brew/ ~/local/brew
    export PATH=${PATH}:${HOME}/local/brew/bin
    brew install stow

    # dotfiles
    git clone https://github.com/lgarron/dotfiles ~/Code/dotfiles
    cd ~/Code/dotfiles
    make [machine]
    make mac-setup

    # Go!
    open -a "iTerm"
    mac-fish-setup

## Chromium Development

See [Chromium.md](./chromium.md)

## XDG Base Directory Spec

Known compatibility chart: <https://wiki.archlinux.org/index.php/XDG_Base_Directory_support>
