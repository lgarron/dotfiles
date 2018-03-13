# Lucas Garron's dotfiles.

My own personal configuration files for various commandline-based tools.

Linked [using GNU `stow`](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html), because simpler is better.

# Setup

## Mac

    # Install Xcode, then run this:
    sudo xcodebuild -license accept

    # dotfiles
    git clone https://github.com/lgarron/dotfiles ~/Code/dotfiles
    cd ~/Code/dotfiles
    make mac-setup
    make [machine]
    
    # Go!
    open -a "iTerm"
    mac-fish-setup

## Ubuntu/Linux

    sudo apt install git make stow

    git clone https://github.com/lgarron/dotfiles ~/Code/dotfiles
    cd ~/Code/dotfiles
    make linux-setup
    make fish

## Chromium Development

See [Chromium.md](./chromium.md)

## XDG Base Directory Spec

Known compatibility chart: <https://wiki.archlinux.org/index.php/XDG_Base_Directory_support>
