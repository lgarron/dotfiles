# Chromium Development

##  Chromium
    
    # Checkout
    dff
    make cr-chromium

    # Setup
    src # cd to folder
    if [ (uname -s) = "Linux" ]; ./build/install-build-deps.sh; end
    gn-gen-release

    # Build
    src # cd to folder
    ggg # goma ensure_start; git pull; gclient sync
    r # Release build

## iOS Chrome (Bling)

    # Checkout
    dff
    make cr-bling

    # Build
    bling # cd to folder
    ggg # goma ensure_start; git pull; gclient sync
    i # iOS debug build

## Android Chrome (Clank)

    # Checkout
    dff
    make cr-clank

    # Setup
    clank
    ./build/install-build-deps.sh
    ./build/install-build-deps-android.sh
    gn-gen-android

    # Build
    clank
    ggg # goma ensure_start; git pull; gclient sync
    aaaa # android-build; android-install; android-log
