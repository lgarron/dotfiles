# Chrome

    # echo "[lgarron/dotfiles] Loading chrome.fish

## Directories

    set CHROMIUM_SRC     "$HOME/chromium/src"
    set ALT_CHROMIUM_SRC "$HOME/alt/src"
    set BLING_SRC        "$HOME/bling/src"

    abbr -a src      "$CHROMIUM_SRC/"
    abbr -a alt      "$ALT_CHROMIUM_SRC/"
    abbr -a bling    "$BLING_SRC/"


## Development

    set PATH $HOME/Code/depot_tools $PATH

    set -x GOOGLE_API_KEY no
    set -x GOOGLE_DEFAULT_CLIENT_ID no
    set -x GOOGLE_DEFAULT_CLIENT_SECRET no

### Goma

    function goma
      ~/goma/goma_ctl.py $argv
    end

    set -x "GOMA_OAUTH2_CONFIG_FILE" "$HOME/.goma_oauth2_config"

    set GOMA_START_COMMAND "goma ensure_start"

    abbr -a goma-start "$GOMA_START_COMMAND"
    abbr -a goma-page  "open http://localhost:8088/"
    abbr -a goma-check "goma status | grep \"status\""
    
### gn

    function gnTemplate
      echo "# Debug/Release
is_debug = $argv[1]

# Faster Builds
enable_nacl = false
is_component_build = true
symbol_level = 1
use_goma = true

# Catchin' Bugs
# https://groups.google.com/a/chromium.org/forum/#!topic/chromium-dev/0fit7KBlaUY
dcheck_always_on = true

# DevTools
debug_devtools = true

# See \"gn args <out_dir> --list\" for available build arguments."
    end

    function gn-gen-debug
      mkdir -p out/Debug
      gnTemplate "true" > out/Debug/args.gn
      gn gen out/Debug
    end

    function gn-gen-release
      mkdir -p out/Release
      gnTemplate "false" > out/Release/args.gn
      gn gen out/Release
    end

### Building

    if contains (hostname -s) $HYPATIA
      set -x NINJA_SETTINGS -j 256 -l 75
    else
      set -x NINJA_SETTINGS -j 100 -l 75
    end

    # Linux sandbox
    set -x CHROME_DEVEL_SANDBOX /usr/local/sbin/chrome-devel-sandbox
    abbr -a sandbox "env BUILDTYPE=Release ./build/update-linux-sandbox.sh"

    function ninja
      goma status | grep "status"
      # echo "Invoking wrapped ninja."
      if [ (uname) = "Darwin" ]
        env DYLD_INSERT_LIBRARIES='' command ninja $NINJA_SETTINGS (string escape -- $argv)
      else
        command ninja $NINJA_SETTINGS (string escape -- $argv)
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

    abbr -a ggg "$GOMA_START_COMMAND ; git pull origin master ; gclient sync"

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
      chromium-build-run "out/Release" $argv
    end

    function debug
      chromium-build-run "out/Debug" $argv
    end

    abbr -a r "release \"https://permission.site/\""
    abbr -a d "debug"

    abbr -a v "release --user-data-dir=\"$HOME/Temporary/mac-views\" \"https://permission.site/\""

## iOS

    function ios-debug
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Debug-iphonesimulator chrome; \
        and ./out/Debug-iphonesimulator/iossim ./out/Debug-iphonesimulator/Chromium.app/
    end

    abbr -a i "ios-debug"

## Building

    function debug-build-run
      set BINARY $argv[1]
      set -e argv[1]

      cd (git rev-parse --show-toplevel)
      date
      ninja -C "out/Debug" "$BINARY"; \
        and date; \
        and eval "out/Debug/$BINARY" (string escape -- $argv)
    end

    function release-build-run
      set BINARY $argv[1]
      set -e argv[1]

      cd (git rev-parse --show-toplevel)
      date
      ninja -C "out/Release" "$BINARY"; \
        and date; \
        and eval "out/Release/$BINARY" (string escape -- $argv)
    end

### Utilities

    function cert_verify_tool
      release-build-run cert_verify_tool $argv
    end


## Testing

### Chrome Tests


    function unit-tests
      release-build-run unit_tests $argv
    end

    function content-unittests
      release-build-run content_unittests $argv
    end

    function net-unittests
      release-build-run net_unittests $argv
    end

    function browser-tests
      release-build-run browser_tests $argv
    end

    function content-browsertests
      release-build-run content_browsertests $argv
    end

    # Webkit (Layout) Tests
    function layout-tests
      cd (git rev-parse --show-toplevel)
      date
      ninja -C out/Release blink_tests; \
        and date; \
        and python third_party/WebKit/Tools/Scripts/run-webkit-tests -t Release $argv
    end

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

    if test -e "/Users/lgarron/Google Drive (lgarron@chromium.org)/Graphics/Chromium/Chrome OSX Icons/set-chrome-icons.sh"
      "/Users/lgarron/Google Drive (lgarron@chromium.org)/Graphics/Chromium/Chrome OSX Icons/set-chrome-icons.sh" &
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

    abbr -a pre "git cl presubmit --upload --force"
    abbr -a gnb "git new-branch --upstream-current"

    function ksadmin
      env DYLD_INSERT_LIBRARIES='' "/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/MacOS/ksadmin" $argv
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

## Crash reporting

    # Crash reporting takes a long time for Chromium builds
    function disable-crash-reporting
      launchctl unload -w /System/Library/LaunchAgents/com.apple.ReportCrash.plist
      sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ReportCrash.Root.plist
    end

    function enable-crash-reporting
      launchctl load -w /System/Library/LaunchAgents/com.apple.ReportCrash.plist
      sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.ReportCrash.Root.plist
    end

## HSTS

  abbr -a tsss "cd $HOME/chromium/src/net/http ; \
transport_security_state_static_generate \
transport_security_state_static.json \
transport_security_state_static.pins"

  abbr -a hs "hstspreload"
  abbr -a hsd "hstspreload +d"
  abbr -a hss "hstspreload status"
  abbr -a ghs "go run $GOPATH/src/github.com/chromium/hstspreload/cmd/hstspreload/*.go"
  complete -c hstspreload -x -a "+d -d +h -h preloadabledomain removabledomain preloadableheader removableheader status batch"
