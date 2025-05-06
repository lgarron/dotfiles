# Lucas Garron's `dotfiles`

My own personal configuration files and scripts for various commandline-based tools and apps. Also serves as the `lgarron/lgarron` [Homebrew](https://brew.sh/) tap.

## Mac

<!-- Note: Steps are spelled out instead of written as shell comments, because `zsh` (the macOS default at first launch) is bonkers and only conditionally treats it as the start of a comment. -->

1. Open `Terminal.app`
2. Trigger Xcode commandline tool installation by trying to use `git`

```shell
git
```

3. Check out the dotfiles repo.

```shell
git clone https://github.com/lgarron/dotfiles ~/Code/git/github.com/lgarron/dotfiles
cd ~/Code/git/github.com/lgarron/dotfiles
```

4. Drag & drop `Terminal.app` into the following permissions in System Settings → Privacy & Security:
    - Full Disk Access
    - Media and Apple Music

Reveal `Privacy & Security` and `Terminal.app` like this:

```shell
open /System/Library/PreferencePanes/Security.prefPane
open -R /System/Applications/Utilities/Terminal.app
```

5. Install dotfiles:

```shell
export PATH=$PATH:/opt/homebrew/bin
make mac-common
```

See [`./exported/`](./exported/) for files that must be manually exported/imported.

## Ubuntu/Linux

    sudo apt install git make
    # Install `bun` from: https://bun.sh/

    git clone https://github.com/lgarron/dotfiles ~/Code/git/github.com/lgarron/dotfiles
    cd ~/Code/git/github.com/lgarron/dotfiles
    make linux-setup

## Languages, ecosystems, and runtimes

- `fish`
- `bun` for TypeScript
- Rust
- Homebrew

In addition:

- `bash` is needed for a small number of bootstrapping scripts.
- Swift is used for macOS scripts where it is difficult to implement an alternative correctly and safely.

## XDG Base Directory Spec

Known compatibility chart: <https://wiki.archlinux.org/index.php/XDG_Base_Directory_support>

## License

MPL
