# Chrome

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

    abbr -a goma-start "goma ensure_start"
    abbr -a goma-page  "pen http://localhost:8088/"
    abbr -a goma-check "goma status | grep \"proxy status\""
    abbr -a goma-setup "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"
    abbr -a gyp "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"

### Building

    set -x NINJA_SETTINGS -j 100 -l 75

    set -x NINJA_PATH (which ninja)
    function ninja
      goma status | grep "proxy status"
      echo "Invoking wrapped ninja."
      env DYLD_INSERT_LIBRARIES='' $NINJA_PATH $NINJA_SETTINGS $argv
    end

    function chromium-release
      "./out/Release/Chromium.app/Contents/MacOS/Chromium" --enable-logging=stderr $argv
    end
    function chromium-debug
      "./out/Debug/Chromium.app/Contents/MacOS/Chromium" --enable-logging=stderr $argv
    end

    function chrome-release-build
        date
        ninja -C out/Release chrome
        and date
        and chromium-release $argv
    end

    function chrome-debug-build
        date
        ninja -C out/Debug chrome
        and date
        and chromium-debug $argv
    end

    abbr -a r "chrome-release-build"
    abbr -a d "chrome-debug-build"

## Testing

### Chrome Tests

    function chrome-release-build-unit-tests
      date
      ninja -C out/Release browser_tests
      date
    end

    function chrome-release-build-browser-tests
      date
      ninja -C out/Release browser_tests
      date
    end

    abbr -a ut="chrome-release-build-unit-tests"
    abbr -a bt="chrome-release-build-browser-tests"

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

#### Abbreviations

    abbr -a stable chrome-stable
    abbr -a beta chrome-beta
    abbr -a dev chrome-dev
    abbr -a canary chrome-canary

### Temp Profiles

    function stable-temp
      chrome-stable --user-data-dir=/tmp/(date "+%Y-%m-%d | %H-%M-%S") $argv
    end
    function beta-temp
      chrome-beta --user-data-dir=/tmp/(date "+%Y-%m-%d | %H-%M-%S") $argv
    end
    function dev-temp
      chrome-dev --user-data-dir=/tmp/(date "+%Y-%m-%d | %H-%M-%S") $argv
    end
    function canary-temp
      chrome-canary --user-data-dir=/tmp/(date "+%Y-%m-%d | %H-%M-%S") $argv
    end

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
