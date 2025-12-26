#!/usr/bin/env -S fish --no-config --

for formula in (brew tap-info lgarron/lgarron --json | jq -r ".[0].formula_names[]")
    brew reinstall $formula || brew install --HEAD $formula || brew install $formula
end
