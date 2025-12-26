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

const WINDOW_ZOOM_LEVEL = "window.zoomLevel";
const WINDOW_ZOOM_LEVEL_NORMALIZED = 1;

const EDITOR_FORMAT_ON_SAVE = "editor.formatOnSave";
const EDITOR_FORMAT_ON_SAVE_NORMALIZED = true;

const EDITOR_FONT_FAMILY = "editor.fontFamily";
const EDITOR_FONT_FAMILY_NORMALIZED =
  '"SeriousShanns Nerd Font Mono", Menlo, Monaco, monospace';

const WINDOW_AUTO_DETECT_COLOR_SCHEME = "window.autoDetectColorScheme";
const WINDOW_AUTO_DETECT_COLOR_SCHEME_NORMALIZED = false;

async function mirror() {
  console.log("Copying to mirror…");
  try {
    const parsed: CommentObject = parse(
      await VSCODE_SETTINGS_PATH.readText(),
    ) as CommentObject;

    if (EDITOR_FORMAT_ON_SAVE in parsed) {
      parsed[EDITOR_FORMAT_ON_SAVE] = EDITOR_FORMAT_ON_SAVE_NORMALIZED;
    }

    if (WINDOW_ZOOM_LEVEL in parsed) {
      parsed[WINDOW_ZOOM_LEVEL] = WINDOW_ZOOM_LEVEL_NORMALIZED;
    }

    if (EDITOR_FONT_FAMILY in parsed) {
      parsed[EDITOR_FONT_FAMILY] = EDITOR_FONT_FAMILY_NORMALIZED;
    }

    if (WINDOW_AUTO_DETECT_COLOR_SCHEME in parsed) {
      parsed[EDITOR_FONT_FAMILY] = WINDOW_AUTO_DETECT_COLOR_SCHEME_NORMALIZED;
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
