# Chrome

    # echo "[lgarron/dotfiles] Loading chrome.fish"

## Directories

    abbr -a src      "$HOME/chromium/src/"
    abbr -a webkit   "$HOME/chromium/src/third_party/WebKit/"
    abbr -a wk       "$HOME/chromium/src/third_party/WebKit/"
    abbr -a devtools "$HOME/chromium/src/third_party/WebKit/Source/devtools/"
    abbr -a dt       "$HOME/chromium/src/third_party/WebKit/Source/devtools/"

## Development

    set PATH $HOME/Code/depot_tools $PATH

### Goma

    function goma
      ~/goma/goma_ctl.py $argv
    end

    set GOMA_START_COMMAND "goma ensure_start"
    set GYP_COMMAND "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"

    abbr -a goma-start "$GOMA_START_COMMAND"
    abbr -a goma-page  "pen http://localhost:8088/"
    abbr -a goma-check "goma status | grep \"proxy status\""
    abbr -a goma-setup "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"
    abbr -a gyp "$GYP_COMMAND"

    abbr -a gggg "$GOMA_START_COMMAND ; git pull origin master ; gclient sync ; $GYP_COMMAND"


### Building

    set -x NINJA_SETTINGS -j 100 -l 75

    set -x NINJA_PATH (which ninja)
    function ninja
      goma status | grep "proxy status"
      echo "Invoking wrapped ninja."
      env DYLD_INSERT_LIBRARIES='' $NINJA_PATH $NINJA_SETTINGS $argv
    end

    function chrome-release-run
      cd (git rev-parse --show-toplevel)
      if test -e "./out/Release/Chromium.app/Contents/MacOS/Chromium"
        "./out/Release/Chromium.app/Contents/MacOS/Chromium" --enable-logging=stderr $argv
      else if test -e "./out/Release/chrome"
        "./out/Release/chrome" --enable-logging=stderr $argv
      end
    end
    function chrome-debug-run
      cd (git rev-parse --show-toplevel)
      if test -e "./out/Debug/Chromium.app/Contents/MacOS/Chromium"
        "./out/Debug/Chromium.app/Contents/MacOS/Chromium" --enable-logging=stderr $argv
      else if test -e "./out/Debug/chrome"
        "./out/Debug/chrome" --enable-logging=stderr $argv
      end
    end

    function chrome-release
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Release chrome; \
        and date; \
        and chrome-release-run $argv
    end

    function chrome-debug
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Debug chrome; \
        and date; \
        and chrome-debug-run $argv
    end

    abbr -a r "chrome-release badssl.com"
    abbr -a d "chrome-debug"

    abbr -a rdt "chrome-release-build --remote-debugging-port=9222 --no-first-run --user-data-dir=/tmp/devtools-test-profile http://localhost:9222\#http://localhost:8000/front_end/inspector.html\?experiments=true badssl.com"

## iOS

    function ios-debug-build
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Debug-iphonesimulator chrome; \
        and ./out/Debug-iphonesimulator/iossim out/Debug-iphonesimulator/Chromium.app/
    end

    abbr -a i "ios-debug-build"

## Testing

### Chrome Tests

    function chrome-release-build-unit-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Release unit_tests; \
        and date; \
        and ./out/Release/unit_tests $argv
    end

    function chrome-release-build-browser-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Release browser_tests; \
        and date; \
        and ./out/Release/browser_tests $argv
    end

    function chrome-release-build-content-browser-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Release content_browsertests; /
        and date; /
        and ./out/Release/content_browsertests $argv
    end

    # Webkit Tests and Layout Tests
    function chrome-release-build-webkit-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Release content_shell; \
        and date; \
        and python third_party/WebKit/Tools/Scripts/run-webkit-tests $argv
    end

    abbr -a ut="chrome-release-build-unit-tests"
    abbr -a bt="chrome-release-build-browser-tests"
    abbr -a cbt="chrome-release-build-content-browser-tests"
    abbr -a layout="chrome-release-build-webkit-tests"

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

#### Abbreviations

    abbr -a stable chrome-stable-temp
    abbr -a beta chrome-beta-temp
    abbr -a dev chrome-dev-temp
    abbr -a canary chrome-canary-temp

### "GitHub"

    function switch-chrome-user
      set -x USER $argv[1]
      osascript -e '
        tell application "System Events"
          tell process "Google Chrome"
            click menu item "'"$USER"'" of menu "People" of menu bar 1
        end tell
      end tell'
    end

    abbr -r gx
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

  abbr -a hsts-gen "cd $HOME/chromium/src/net/http ; go run $HOME/Code/transport-security-state-generate/transport_security_state_static_generate.go $HOME/chromium/src/net/http/transport_security_state_static.json $HOME/chromium/src/net/http/transport_security_state_static.certs"