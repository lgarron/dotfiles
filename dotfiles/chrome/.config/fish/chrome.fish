# Chrome

    # echo "[lgarron/dotfiles] Loading chrome.fish

## Directories

    set CHROMIUM_SRC "$HOME/chromium/src"

    abbr -a src      "$CHROMIUM_SRC/"
    abbr -a webkit   "$CHROMIUM_SRC/third_party/WebKit/"
    abbr -a wk       "$CHROMIUM_SRC/third_party/WebKit/"
    abbr -a devtools "$CHROMIUM_SRC/third_party/WebKit/Source/devtools/"
    abbr -a dt       "$CHROMIUM_SRC/third_party/WebKit/Source/devtools/"

## Development

    set PATH $HOME/Code/depot_tools $PATH

### Goma

    function goma
      ~/goma/goma_ctl.py $argv
    end

    set GOMA_START_COMMAND "goma ensure_start"
    set GYP_COMMAND "env GYP_GENERATORS=ninja ./build/gyp_chromium"

    abbr -a goma-start "$GOMA_START_COMMAND"
    abbr -a goma-page  "open http://localhost:8088/"
    abbr -a goma-check "goma status | grep \"status\""
    abbr -a goma-setup "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"
    abbr -a gyp "$GYP_COMMAND"

### gn

    set -x GYP_CHROMIUM_NO_ACTION 1

    function gnTemplate
      echo "# Debug/Release
is_debug = $argv[1]

# Faster Builds
enable_nacl = false
is_component_build = true
symbol_level = 1
use_goma = true

# DevTools
debug_devtools = true

# See \"gn args <out_dir> --list\" for available build arguments."
    end

    function gn-gen-debug
      mkdir -p out/gnDebug
      gnTemplate "true" > out/gnDebug/args.gn
      gn gen out/gnDebug
    end

    function gn-gen-release
      mkdir -p out/gnRelease
      gnTemplate "false" > out/gnRelease/args.gn
      gn gen out/gnRelease
    end

### Building

    set -x NINJA_SETTINGS -j 100 -l 75

    # Linux sandbox
    set -x CHROME_DEVEL_SANDBOX /usr/local/sbin/chrome-devel-sandbox
    abbr -a sandbox "env BUILDTYPE=Release ./build/update-linux-sandbox.sh"

    function ninja
      goma status | grep "status"
      # echo "Invoking wrapped ninja."
      if [ (uname) = "Darwin" ]
        env DYLD_INSERT_LIBRARIES='' command ninja $NINJA_SETTINGS $argv
      else
        command ninja $NINJA_SETTINGS $argv
      end
    end

    function run-if-exists
      set BINARY_PATH $argv[1]
      set -e argv[1]
      if test -e "$BINARY_PATH"
          eval "$BINARY_PATH" --enable-logging=stderr (string escape -- $argv)
      end
    end


### Chromium

    abbr -a ggggg "$GOMA_START_COMMAND ; git pull origin master ; gclient sync; gn-gen-debug; gn-gen-release"

    function chromium-run
      set FOLDER $argv[1]
      set -e argv[1]
      cd (git rev-parse --show-toplevel)
      run-if-exists "$FOLDER/Chromium.app/Contents/MacOS/Chromium" $argv
      run-if-exists "$FOLDER/chrome" $argv
    end

    function chromium-build-run
      set FOLDER $argv[1]
      cd (git rev-parse --show-toplevel)
      date
      ninja -C "$FOLDER" chrome; \
        and date; \
        and chromium-run $argv
    end

    function release
      chromium-build-run "out/gnRelease" $argv
    end

    function debug
      chromium-build-run "out/gnDebug" $argv
    end

    abbr -a r "release badssl.com"
    abbr -a d "debug"

## iOS

    function ios-debug
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnDebug-iphonesimulator chrome; \
        and ./out/gnDebug-iphonesimulator/iossim out/gnDebug-iphonesimulator/Chromium.app/
    end

    abbr -a i "ios-debug"

## Testing

### Chrome Tests

    function unit-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnRelease unit_tests; \
        and date; \
        and ./out/gnRelease/unit_tests $argv
    end

    function content-unit-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnRelease content_unittests; \
        and date; \
        and ./out/gnRelease/content_unittests $argv
    end

    function net-unit-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnRelease net_unittests; \
        and date; \
        and ./out/gnRelease/net_unittests $argv
    end

    function browser-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnRelease browser_tests; \
        and date; \
        and ./out/gnRelease/browser_tests $argv
    end

    function content-browser-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnRelease content_browsertests; /
        and date; /
        and ./out/gnRelease/content_browsertests $argv
    end

    # Webkit (Layout) Tests
    function layout-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/gnRelease blink_tests; \
        and date; \
        and python third_party/WebKit/Tools/Scripts/run-webkit-tests -t gnRelease $argv
    end

    abbr -a layout="layout-tests"

    abbr -a pre="git cl presubmit --upload --force"

### Chrome Versions

    function chrome-stable
      "/Applications/Google Chrome Stable.app/Contents/MacOS/Google Chrome" $argv
    end
    function chrome-beta
      "/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome" $argv
    end
    function chrome-dev
      "/Applications/Google Chrome Dev.app/Contents/MacOS/Google Chrome" $argv
    end
    function chrome-canary
      "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary" $argv
    end

    if test -e "/Users/lgarron/Google Drive/Graphics/Chrome OSX Icons/set-chrome-icons.sh"
      "/Users/lgarron/Google Drive/Graphics/Chrome OSX Icons/set-chrome-icons.sh" &
    end

### Temp Profiles

    function chrome-stable-temp
      set TEMP_FOLDER /tmp/(date "+Chrome Stable Temp Profile | %Y-%m-%d | %H-%M-%S")
      echo chrome-stable "--user-data-dir=\"$TEMP_FOLDER\"" $argv
      chrome-stable --user-data-dir="$TEMP_FOLDER" $argv
    end
    function chrome-beta-temp
      set TEMP_FOLDER /tmp/(date "+Chrome Beta Temp Profile | %Y-%m-%d | %H-%M-%S")
      echo chrome-beta "--user-data-dir=\"$TEMP_FOLDER\"" $argv
      chrome-beta --user-data-dir="$TEMP_FOLDER" $argv
    end
    function chrome-dev-temp
      chrome-dev --user-data-dir=/tmp/(date "+Chrome Dev Temp Profile | %Y-%m-%d | %H-%M-%S") $argv
    end
    function chrome-canary-temp
      set TEMP_FOLDER /tmp/(date "+Chrome Canary Temp Profile | %Y-%m-%d | %H-%M-%S")
      echo chrome-canary "--user-data-dir=\"$TEMP_FOLDER\"" $argv
      chrome-canary --user-data-dir="$TEMP_FOLDER" $argv
    end

## Old Chromes

    function old-chrome
      set CHROME_VERSION "$argv[1]"
      set -e argv[1]

      set OLD_CHROME_PATH "/Applications/Google Chrome Old Versions/Google Chrome $CHROME_VERSION.app/Contents/MacOS/Google Chrome"

      if not test -e $OLD_CHROME_PATH
        echo "Chrome version not available: $CHROME_VERSION"
        return 1
      end

      set EXPECTED_MAJOR_VERSION (echo "Google Chrome $CHROME_VERSION")
      set ACTUAL_MAJOR_VERSION (eval "\"$OLD_CHROME_PATH\"" --version | awk -F. '{$0=$1}1')

      if [ "$EXPECTED_MAJOR_VERSION" != "$ACTUAL_MAJOR_VERSION" ]
        echo "Chrome binary does not match expected version."
        echo "Expected: $EXPECTED_MAJOR_VERSION"
        echo "Actual: $ACTUAL_MAJOR_VERSION"
        return 2
      end

      echo "$OLD_CHROME_PATH" $argv
      eval "\"$OLD_CHROME_PATH\"" (string escape -- $argv)
    end

    function old-chrome-temp
      set TEMP_FOLDER /tmp/(date "+Chrome Canary Temp Profile | %Y-%m-%d | %H-%M-%S")
      old-chrome $argv --user-data-dir="\"$TEMP_FOLDER\""
    end

#### Abbreviations

    abbr -a stable chrome-stable-temp
    abbr -a beta chrome-beta-temp
    abbr -a dev chrome-dev-temp
    abbr -a canary chrome-canary-temp

    abbr -a old old-chrome-temp

    function ksadmin
      env DYLD_INSERT_LIBRARIES='' "/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/ksadmin" $argv
    end


## Git

    function __fish_git_tags
      if [ "$CHROMIUM_SRC" = (git rev-parse --show-toplevel) ]
        # Ignore thousands of release tags.
        command git tag | grep -v "^\d\+\.\d\+\.\d\+\.\d\+\$"
      else
        command git tag
      end
    end

    function __fish_git_branches
      if [ "$CHROMIUM_SRC" = (git rev-parse --show-toplevel) ]
        # Ignore a whole bunch of release branches.
        command git branch --no-color ^/dev/null | sgrep -v ' -> ' | sed -e 's/^..//' -e 's/^remotes\///'
      else
        command git branch --no-color -a ^/dev/null | sgrep -v ' -> ' | sed -e 's/^..//' -e 's/^remotes\///'
      end
    end

### "GitHub"

    function switch-chrome-user
      set -x USER $argv[1]
      osascript -e '
        tell application "Google Chrome Dev" to activate
        tell application "System Events" to tell process "Google Chrome"
          click menu item "'"$USER"'" of menu "People" of menu bar item "People" of menu bar 1
        end tell'
    end

    abbr -e gx
    function gx
      if git remote -v | grep chromium.googlesource.com > /dev/null
        echo "Invoking wrapped (+ truncated history) gitx."
        gitx --256 & 
      else
        echo "Invoking wrapped gitx."
        gitx $argv
      end
    end

    # Overwrite github function for issues
    functions -e github
    function github
      if git remote -v | grep chromium.googlesource.com > /dev/null
        switch-chrome-user "chromium"
        echo "Opening on https://codereview.chromium.org/"
        git cl web &
      else
        switch-chrome-user "creasepattern"
        echo "Opening on GitHub.com"
        hub browse &
      end
    end

    abbr -a gcu "git cl upload"

## HSTS

  abbr -a tsss "cd $HOME/chromium/src/net/http ; \
transport_security_state_static_generate \
transport_security_state_static.json \
transport_security_state_static.certs"

  abbr -a hs "hstspreload"
  abbr -a hsd "hstspreload +d"
  abbr -a hss "hstspreload status"
  abbr -a ghs "go run $GOPATH/src/github.com/chromium/hstspreload/cmd/hstspreload/*.go"
  complete -c hstspreload -x -a "+d -d +h -h preloadabledomain removabledomain preloadableheader removableheader status batch"
