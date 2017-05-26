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

    dff; make cr-tools
    # These are slow, so do them in two windows in parallel:
    dff; make cr-chromium
    dff; make cr-bling

    # Chromium
    src # cd to folder
    gn-gen-release # Run once
    ggg # goma ensure_start; git pull; gclient sync
    r # Release build

    # iOS Chrome (Bling)
    bling # cd to folder
    ggg # goma ensure_start; git pull; gclient sync
    i # iOS debug build

    # Android Chrome (Clank)
    clank
    gn-gen-android
    ggg
    aaa # android-build; android-install; android-log

# To automate or document

- Batch password actions at the beginning
  - `sudo gem install jekyll`
- Install Shell Integration
- Keyboard remapping
- Install Chrome versions
- set Chrome icons
- Split apps by machine?
- Add idempotent setup steps to machine target dependencies?
- Import BetterTouchTool settings
- Speed up ffmpeg install or do it async
- Chrome Sync
  - Everything except passwords
- Make sure application defaults (e.g. for Hammerspoon) are not written nd lost before application install
- Move `osx-setup-shortcuts` to Makefile and/or script file.
- git config user.email
- Auth
  - GitHub