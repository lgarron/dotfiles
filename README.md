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
# Pre-emptively place Homebrew in the path (so that its binaries can be used as soon as it is installed).
export PATH="$PATH:/opt/homebrew/bin"

# Install everything.
make mac-common
```

See [`./exported/`](./exported/) for files that must be manually exported/imported.

## Ubuntu/Linux

```shell
sudo apt install git make
# Install `bun` from: https://bun.sh/

git clone https://github.com/lgarron/dotfiles ~/Code/git/github.com/lgarron/dotfiles
cd ~/Code/git/github.com/lgarron/dotfiles
make linux-setup
```

## Languages, ecosystems, and runtimes

- `fish`
- `bun` for TypeScript
- Rust
- Homebrew

In addition:

- `bash` is needed for two bootstrapping scripts (one for macOS and one for Linux).
- Ruby is needed for Homebrew formulas.
- Swift is used for macOS scripts where it is difficult to implement an alternative correctly and safely.

## XDG Base Directory Spec

Known compatibility chart: <https://wiki.archlinux.org/index.php/XDG_Base_Directory_support>

## Homebrew tap

This repo serves as the Homebrew tap `lgarron/lgarron`, so it can be used to install my scripts (from inside this repo) and programs (from various repos):

```shell
# Example
brew install --HEAD lgarron/lgarron/sd-card-backup
```

This uses a trick: Homebrew accepts repository redirect, and <https://github.com/lgarron/Homebrew-lgarron> redirects to <https://github.com/lgarron/dotfiles> (due to moving the repo from the latter to the former and back).

Scripts are listed [in the `./scripts` folder](./scripts/README.md).

## License

MPL
