#!/usr/bin/env -S fish --no-config

function js_version
  if not test -f package.json
    return 1
  end
  set VERSION (cat package.json | jq -r -e ".version")
  echo -n "v$VERSION"
end

function previous_js_version
  if not test -f package.json
    return 1
  end

  set PREVIOUS_VERSION (git show HEAD~:package.json | jq -r -e ".version")
  echo -n "v$PREVIOUS_VERSION"
end

function rust_version_internal
  cat Cargo.toml | toml2json | jq -r -e $argv[1]
end

function rust_version
  if not test -f Cargo.toml
    return 1
  end

  set VERSION (
    rust_version_internal ".package.version | select( . != null )" ||
    rust_version_internal ".workspace.package.version | select( . != null )"
  )
  echo -n "v$VERSION"
end

function previous_rust_version_internal
  git show HEAD~:Cargo.toml | toml2json | jq -r -e $argv[1]
end

function previous_rust_version
  if not test -f Cargo.toml
    return 1
  end

  set PREVIOUS_VERSION (
    previous_rust_version_internal ".package.version | select( . != null )" ||
    previous_rust_version_internal ".workspace.package.version | select( . != null )"
  )
  echo -n "v$PREVIOUS_VERSION"
end

if contains -- "--previous" $argv
  previous_js_version; or previous_rust_version
else
  js_version; or rust_version
end

