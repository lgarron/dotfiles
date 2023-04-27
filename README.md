# Lucas Garron's dotfiles

My own personal configuration files for various commandline-based tools.

Linked [using GNU `stow`](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html), because simpler is better.

## Mac

    # Install Xcode tools
    sudo xcodebuild -license accept

    # Install Homebrew
    open https://brew.sh/ # follow install instructions
    brew install fish # needed for dotfiles

    # dotfiles
    git clone https://github.com/lgarron/dotfiles ~/Code/git/github.com/lgarron/dotfiles
    cd ~/Code/git/github.com/lgarron/dotfiles
    make mac-setup
    make [machine]

See [`./exported/`](./exported/) for files that must be manually exported/imported.

## Ubuntu/Linux

    sudo apt install git make stow

    git clone https://github.com/lgarron/dotfiles ~/Code/dotfiles
    cd ~/Code/dotfiles
    make linux-setup fish

## GitPod

If the built-in dotfile functionality fails due to [this bug](https://github.com/gitpod-io/gitpod/issues/14984), install dotfiles manually using:

```shell
git clone https://github.com/lgarron/dotfiles ~/dotfiles && cd ~/dotfiles
script/bootstrap
fish # start a new shell
```

## XDG Base Directory Spec

Known compatibility chart: <https://wiki.archlinux.org/index.php/XDG_Base_Directory_support>
