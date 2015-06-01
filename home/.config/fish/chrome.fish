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
      "$HOME/goma/goma_ctl.py" $argv
    end

    abbr -a goma-start "goma ensure_start"
    abbr -a goma-page  "pen http://localhost:8088/"
    abbr -a goma-check "goma status | grep \"proxy status\""
    abbr -a goma-setup "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"
    abbr -a gyp "env GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=1"

### Building

    set -x NINJA_SETTINGS -j 100 -l 10

    set -x NINJA_PATH (which ninja)
    function ninja
      echo "Invoking wrapped ninja."
      env DYLD_INSERT_LIBRARIES='' $NINJA_PATH $argv
    end

    function chromium-release
      "./out/Release/Chromium.app/Contents/MacOS/Chromium" --enable-logging=stderr $argv
    end
    function chromium-debug
      "./out/Debug/Chromium.app/Contents/MacOS/Chromium" --enable-logging=stderr $argv
    end

    function chrome-release-build
        date
        env DYLD_INSERT_LIBRARIES='' ninja -C out/Release $NINJA_SETTINGS chrome
        and date
        and chromium-release $argv
    end

    function chrome-debug-build
        date
        env DYLD_INSERT_LIBRARIES='' ninja -C out/Debug $NINJA_SETTINGS chrome
        and date
        and chromium-debug $argv
    end

    abbr -a r "chrome-release-build"
    abbr -a d "chrome-debug-build"

## Testing

### Chrome Tests

    function chrome-build-unit-tests-release
      date
      env DYLD_INSERT_LIBRARIES='' ninja -C out/Release $NINJA_SETTINGS browser_tests
      date
    end

    function chrome-build-browser-tests-release
      date
      env DYLD_INSERT_LIBRARIES='' ninja -C out/Release $NINJA_SETTINGS browser_tests
      date
    end

    abbr -a ut="chrome-unit-tests-release-build"
    abbr -a bt="chrome-browser-tests-release-build"

### Chrome Versions

    function chrome-stable
      "/Applications/Google Chrome Stable.app/Contents/MacOS/Google Chrome Stable" $argv
    end
    function chrome-beta
      "/Applications/Google Chrome Beta.app/Contents/MacOS/Google Chrome Beta" $argv
    end
    function chrome-dev
      "/Applications/Google Chrome Dev.app/Contents/MacOS/Google Chrome Dev" $argv
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

    # Overwrite github function for issues
    function github
      if not git remote -v | grep github > /dev/null
        switch-chrome-user "chromium"
        echo "Opening on https://codereview.chromium.org/"
        git cl web &
      else
        switch-chrome-user "creasepattern"
        echo "Opening on GitHub.com"
        hub browse &
      end
    end