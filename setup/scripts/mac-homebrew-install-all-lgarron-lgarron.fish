#!/usr/bin/env -S fish --no-config --

# This avoids the need for a Brewfile that needs to be kept in sync.

for formula in (brew tap-info lgarron/lgarron --json | jq -r ".[0].formula_names[]")
    brew reinstall $formula || brew install --HEAD $formula || brew install $formula
end
