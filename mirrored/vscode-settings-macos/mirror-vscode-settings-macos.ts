#!/opt/homebrew/bin/bun run --

import { watchFile } from "node:fs";
import { type CommentObject, parse, stringify } from "comment-json";
import { Path } from "path-class";

const VSCODE_SETTINGS_PATH = Path.homedir.join(
  "Library/Application Support/Code/User/settings.json",
);

const DOTFILES_SETTINGS_PATH = Path.homedir.join(
  "Code/git/github.com/lgarron/dotfiles/mirrored/vscode-settings-macos/files/Library/Application Support/Code/User/settings.jsonc",
);

const TOP_LEVEL_NORMALIZED_FIELDS = {
  "window.zoomLevel": 1,
  "editor.formatOnSave": true,
  "editor.fontFamily":
    '"SeriousShanns Nerd Font Mono", Menlo, Monaco, monospace',
  "window.autoDetectColorScheme": false,
};

const TOP_LEVEL_FIELDS_TO_DELETE = ["workbench.colorTheme"];

async function mirror() {
  console.log("Copying to mirror…");
  try {
    const parsed: CommentObject = parse(
      await VSCODE_SETTINGS_PATH.readText(),
    ) as CommentObject;

    for (const [key, normalizedValue] of Object.entries(
      TOP_LEVEL_NORMALIZED_FIELDS,
    )) {
      console.log(`Rewriting key: ${key}`);
      if (key in parsed) {
        parsed[key] = normalizedValue;
      }
    }

    for (const key of TOP_LEVEL_FIELDS_TO_DELETE) {
      console.log(`Deleting key: ${key}`);
      delete parsed[key];
    }

    await DOTFILES_SETTINGS_PATH.write(stringify(parsed, null, "\t"));
    console.log("Success!");
  } catch (e) {
    console.error(e);
    // TODO: Log error to file?
  }
}

watchFile(VSCODE_SETTINGS_PATH.path, mirror);
await mirror();
