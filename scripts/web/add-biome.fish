#!/usr/bin/env -S fish --no-config

set BIOME "./biome.json"
set PACKAGE_JSON "./package.json"

if test -f $BIOME
  echo "[add-biome] Error: `$BIOME` already exists!"
  exit 1
end

function cancel
  echo "Cancelling..."
  exit
end

# Prompt first, so that ^C prevents any files from being written.
echo "[add-biome] Enter a source code directory, or multiple separated by spaces (Ctrl-C to cancel):"
read --command "./src" --line BIOME_SOURCE_DIRS ; or cancel

if ! test -f $PACKAGE_JSON
  echo "[add-biome] Warning: no `$PACKAGE_JSON` observed in the current folder. Check if you're in the intended folder."
end
echo "[add-biome] Writing: $BIOME"
echo '{
  "formatter": {
    "indentStyle": "space",
    "indentWidth": 2
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  }
}
' > $BIOME

echo "[add-biome] Installing `biome`."
npm install --save-dev @biomejs/biome@latest

set TEMP_PACKAGE_JSON (mktemp)
echo "[add-biome] Adding `npm` scripts..."
cat $PACKAGE_JSON > $TEMP_PACKAGE_JSON
set ADDED_JSON "{lint: \"npx @biomejs/biome check $BIOME_SOURCE_DIRS\", format: \"npx @biomejs/biome format --write $BIOME_SOURCE_DIRS\"}"
echo "[add-biome] $ADDED_JSON"
cat $TEMP_PACKAGE_JSON | jq -r ".scripts += $ADDED_JSON" > $PACKAGE_JSON

echo "[add-biome] Done!"
