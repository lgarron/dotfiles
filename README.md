# Lucas Garron's `dotfiles`

My own personal configuration files and scripts for various commandline-based tools and apps. Also serves as the `lgarron/lgarron` [Homebrew](https://brew.sh/) tap.

Linked [using GNU `stow`](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html) (for now).

## Mac

```shell
# Trigger Xcode commandline tool installation by trying to use `git`
git
```

```shell
git clone https://github.com/lgarron/dotfiles ~/Code/git/github.com/lgarron/dotfiles
cd ~/Code/git/github.com/lgarron/dotfiles
```

```shell
# Open "Full Disk Access" → drag & drop `Terminal.app` to give it full access.
# Reveal the panel and app like this:
open /System/Library/PreferencePanes/Security.prefPane
open -R /System/Applications/Utilities/Terminal.app
```

```shell
export PATH=$PATH:/opt/homebrew/bin # Bootstrapping env var
make mac-common
```

See [`./exported/`](./exported/) for files that must be manually exported/imported.

## Ubuntu/Linux

    sudo apt install git make stow

    git clone https://github.com/lgarron/dotfiles ~/Code/git/github.com/lgarron/dotfiles
    cd ~/Code/git/github.com/lgarron/dotfiles
    make linux-setup

## Languages, ecosystems, and runtimes

- `bash` (deprecated, except for bootstrapping)
- `fish`
- `bun` for TypeScript
- Rust
- Homebrew

## XDG Base Directory Spec

Known compatibility chart: <https://wiki.archlinux.org/index.php/XDG_Base_Directory_support>

## License

MPL
