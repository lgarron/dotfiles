# .zshrc Customization - Lucas Garron, 2013

## File Paths

    ZSH_PATH="${HOME}/.oh-my-zsh/"
    SUBLIME_TEXT_PATH="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
    STDERRRED_PATH="${HOME}/local/dylib/libstderred.dylib"
    INSTALLED_FILE_PATH="${HOME}/local/config/installed.txt"
    MATHEMATICA_SCRIPT_PATH="/Applications/Mathematica.app/Contents/MacOS/MathematicaScript"
    COMPUTER_NAME="$(scutil --get ComputerName)"


## oh-my-zsh and shell

    ZSH="${ZSH_PATH}"
    ZSH_THEME="sunrise"
    DISABLE_AUTO_TITLE="true"
    COMPLETION_WAITING_DOTS="true"
    DISABLE_UPDATE_PROMPT="true"
    plugins=(git osx)

    unsetopt correctall
    setopt correct

    source $ZSH/oh-my-zsh.sh

    # Useful for settings aside commands you just typed (so that they're in the history and can be used later, without executing now.)
    setopt INTERACTIVECOMMENTS


## Shell

    export GOPATH="${HOME}/.go"

    # Set the $PATH
    path=(${path}
      "${HOME}/local/bin/scripts"
      "${HOME}/local/bin/misc"
      "${HOME}/local/bin/dance-hacking"
      "${HOME}/.cabal/bin/"
      "${HOME}/Dropbox/Code/non-VCS/emsdk_portable"
      "${HOME}/Dropbox/Code/non-VCS/emsdk_portable/clang/3.2_64bit/bin"
      "${HOME}/Dropbox/Code/non-VCS/emsdk_portable/node/0.10.18_64bit/bin"
      "${HOME}/Dropbox/Code/non-VCS/emsdk_portable/emscripten/1.7.8"
      "${GOPATH}/bin"
    ) #zsh

    # For Cairo. Urgh.
    # https://github.com/Homebrew/homebrew/issues/14123
    export PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig

    # Output stderr in red.
    if [ -f "${STDERRRED_PATH}" ]
    then
      export DYLD_INSERT_LIBRARIES="${STDERRRED_PATH}${DYLD_INSERT_LIBRARIES:+:$DYLD_INSERT_LIBRARIES}"
    fi

    # Open man page in Chrome
    # export MANPAGER="man2html > /tmp/man-page.html && open /tmp/man-page.html"


## Homebrew and homebrew-cask

    # Include homebrew in python path
    export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"

    # Install applications to the global folder.
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"

    # Contains a node_modules folder symlinked to ~/.node_modules
    NPM_PATH="${HOME}/local/node"

    function bi   { brew install                       $@ && echo "[$(date "+%Y-%m-%d")][${COMPUTER_NAME}][brew install]"      $@ >> "${INSTALLED_FILE_PATH}" && rehash }
    function bci  { brew cask install                  $@ && echo "[$(date "+%Y-%m-%d")][${COMPUTER_NAME}][brew cask install]" $@ >> "${INSTALLED_FILE_PATH}" && rehash }
    function pipi { pip install                        $@ && echo "[$(date "+%Y-%m-%d")][${COMPUTER_NAME}][pip install]"       $@ >> "${INSTALLED_FILE_PATH}" && rehash }
    function cabi { cabal install                      $@ && echo "[$(date "+%Y-%m-%d")][${COMPUTER_NAME}][cabal install]"     $@ >> "${INSTALLED_FILE_PATH}" && rehash }
    function npmi { npm install --prefix="${NPM_PATH}" $@ && echo "[$(date "+%Y-%m-%d")][${COMPUTER_NAME}][npm install]"       $@ >> "${INSTALLED_FILE_PATH}" && rehash }
    function gemi { sudo gem install                   $@ && echo "[$(date "+%Y-%m-%d")][${COMPUTER_NAME}][gem install]"       $@ >> "${INSTALLED_FILE_PATH}" && rehash }
    alias bs="brew search"
    alias bcs="brew cask search"
    alias pips="pip search"
    alias cabs="cabal search"
    alias npms="npm search"
    alias gems="gem search"


## Shortcuts

### Shell

    # Reload .zshrc file
    alias rc="echo \"Reloading .zshrc file.\" && source ~/.zshrc"

    # Copy stdout to clipboard (after command has finished)
    alias t="tee >(pbcopy)"

    # Make folder and `cd` into it immediately.
    function mcd() { mkdir "$@"; cd "$@" }

### Editors

    alias subl="${SUBLIME_TEXT_PATH}"
    export EDITOR="${SUBLIME_TEXT_PATH} -w"
    alias e='emacs'
    alias s='subl'

### Hashes

    alias md5='openssl md5'
    alias sha1='openssl sha1'
    alias sha256='openssl dgst -sha256'

### System

    alias battery='ioreg -rc AppleSmartBattery'
    alias o='open .' # Open pwd in Finder.
    alias or='open -R' # Reveal file/folder in Finder.

    # Lower the priority of a process.
    alias nicest="nice -n 20"

## Search

    # List dirs in the current folder.
    alias dirs="find . -d -maxdepth 1 -mindepth 1 -type d"

    ## Quick find - Is there a way to define this using alias?
    function f() { find . -iname "*${1}*" }
    function f2 { mdfind -onlyin . -name "${1}" }

    alias fx='find . -iname' # find exact

    # Quick grep
    function gre() { grep -ir "${1}" . }

    alias changes="watchmedo shell-command --patterns=\"*\" --recursive --command='echo \"\${watch_src_path}\"' ."

## Git

    alias g="git"

    alias git-dir="git rev-parse --git-dir"

    alias gs="git status"
    alias gl="git log"
    alias glp="git log --oneline --decorate=full --graph --remotes" # git log pretty, from http://www.xerxesb.com/2010/command-line-replacement-for-gitk/

    alias gdcw="git diff --color-words"
    alias gd="gdcw"
    alias gdc="gdcw --cached"
    alias gdno="git diff --name-only"
    #alias gdi="git difftool -t fmdiff" # Doesn't work right now.

    alias gst="git stage"
    alias gc="git commit -m"
    alias gca="git commit --amend"
    alias gcane="git commit --amend --no-edit"

    alias gb="git branch"
    alias gco="git checkout"
    alias gcod="git checkout --detach"
    alias gcb="git checkout -b"

    alias gh="hub browse"

    alias ghash="git rev-parse HEAD"
    alias glast="git show HEAD"

    alias gsi="git submodule init"
    alias gsu="git submodule update"
    alias gsui="git submodule update --init"

    alias gt="git tag"

    alias gr="git rebase"

    function gpp() {
      git diff HEAD
      echo "----------------"
      echo "Commit message was:"
      git log HEAD -1 | t
      echo "----------------"
      read -q "REPLY?Go ahead? (y/n) "
      echo "]n"
      echo "----------------"
      if [[ "$REPLY" == "y" ]]
      then
        PREVIOUS_HEAD=$(ghash)
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        echo "Previous HEAD of ${BRANCH}: ${PREVIOUS_HEAD}"
        git commit --all --amend --no-edit && git push -f
        export PREVIOUS_HEAD="${PREVIOUS_HEAD}"
      fi
    }

    function gppundo() {
      CURRENT_HEAD=$(ghash)
      echo "Resetting from ${CURRENT_HEAD} to ${PREVIOUS_HEAD} (but keeping changes)."
      git reset --hard "${PREVIOUS_HEAD}"
      gco "${CURRENT_HEAD}" -- $(git rev-parse --show-toplevel)
    }

    function gpb() {
        # Push current branch, creating and tracking on the origin if necessary.
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        git push -u origin "${BRANCH}"
    }

    # Copy hash of latest commit to clipboard
    function glc {
      LATEST=$(ghash)
      echo "Latest commit: ${LATEST}"
      echo -n "${LATEST}" | pbcopy
      echo "Copied to clipboard."
    }

    alias gx="gitx --all"

## OSX Applications

    alias audacity="open -a Audacity"
    alias gimp="open -a GIMP"
    alias chrome="open -a \"Google Chrome\""
    BROWSER="${chrome}"

    ## Open Quicksilver in the current directory.
    alias q="qs ."

## Network

    # Convenience for getting the current public IP.
    alias ip="curl icanhazip.com 2>& /dev/null | tr -cd \"[:digit:].\""

## Development / Programming

    alias mcl="make clean"

    # Use four cores for make.
    alias mj="make -j 4"

    # Haskell
    alias hs=runghc

    # Julia
    alias jl=julia

    # Mathematica
    function ms {
      REALPATH=$(realpath "${1}")
      shift
      "${MATHEMATICA_SCRIPT_PATH}" -script "${REALPATH}" $@
    }

    # Get file extension
    function ext {
      echo "${1##*.}" | awk '{print tolower($0)}'
    }

    alias kb="keybase"

    # Sigh. https://github.com/Homebrew/homebrew/issues/36426#issuecomment-72631663
    export MACOSX_DEPLOYMENT_TARGET=10.10

    # Colored cat (syntax highlighting). Require pip install pygmentize
    alias ccat="pygmentize -g"

## Tools

    # Server from the current directory.
    # From http://apple.stackexchange.com/questions/5435/got-any-tips-or-tricks-for-terminal-in-mac-os-x
    function serve() { open "http://localhost:${1:-8080}/" &&  python -m SimpleHTTPServer ${1:-8080}; }

    alias screensaver_desktop="/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background"

    # Watch the current directory tree and run a command after any change.
    # Usage:
    #   watch ls
    #   watch "make test" --patterns "*.py;*.txt"
    alias watch="watchmedo shell-command . --ignore-patterns=\"*/.DS_Store\" --patterns=\"*\" --recursive --command"


    # alias vsh="cd ${HOME}/Virtual\ Machines/docker/ && vagrant up && vagrant ssh"

    alias gpg="gpg2"

    alias ...="awk '{fflush(); printf \".\"}' && echo \"\""

    function 7zf() {
      7z a "${1}.7z" "${1}"
    }

## Run private settings (API keys, etc.)

    source "${HOME}/.zshrc-private"

## Welcome Message

    HOSTNAME=$(hostname)
    if [ "${HOSTNAME}" = "Galois" ]
    then
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        echo ""
        echo " ██████     █████    ██         ██████    ██   ███████ "
        echo "██         ██   ██   ██        ██    ██   ██   ██      "
        echo "██   ███   ███████   ██        ██    ██   ██   ███████ "
        echo "██    ██   ██   ██   ██        ██    ██   ██        ██ "
        echo " ██████    ██   ██   ███████    ██████    ██   ███████ "
        echo ""
    elif [ "${HOSTNAME}" = "Noether" ]
    then
        # Based on ANSI Shadow with the shadow removed:
        # http://patorjk.com/software/taag/#p=display&v=1&f=ANSI%20Shadow&t=Galois%0AGALOIS
        echo ""
        echo "███    ██  ██████  ███████ ████████ ██   ██ ███████ ██████ "
        echo "████   ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        echo "██ ██  ██ ██    ██ █████      ██    ███████ █████   ██████ "
        echo "██  ██ ██ ██    ██ ██         ██    ██   ██ ██      ██   ██"
        echo "██   ████  ██████  ███████    ██    ██   ██ ███████ ██   ██"
        echo ""
    fi
